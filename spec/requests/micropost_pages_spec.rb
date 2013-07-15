require 'spec_helper'

describe "MicropostPages" do
  subject { page }
  let(:user) { FactoryGirl.create(:user) }

  describe "home page" do
    let!(:mp1) { FactoryGirl.create(:micropost, user: user) }
    let!(:mp2) { FactoryGirl.create(:micropost, user: user) }
    before do
      sign_in user
      visit root_path
    end
    it { should have_selector("li##{mp1.id}", text: mp1.content) }
    it { should have_selector("li##{mp2.id}", text: mp2.content) }

    describe "sidebar" do
      it { should have_button("Post") }
      it { should have_selector('img.gravatar') }
      it { should have_content ("2 microposts") }
    end

    describe "follower/following counts" do
      let(:other_user) { FactoryGirl.create(:user) }
      before do
        user.follow!(other_user)
        visit root_path
      end

      it { should have_link("1 following", href: following_user_path(user)) }
      it { should have_link("0 followers", href: followers_user_path(user)) }
    end
  end

  describe "pagination" do
    # creating a different user because we need to delete this one eventually
    # and rspec doesn't properly clear out this user from the database
    let(:other_user) { FactoryGirl.create(:user) }
    before(:all) { 50.times { FactoryGirl.create(:micropost, user: other_user) } }
    after(:all) do
      other_user.delete
    end

    describe "on the profile pages" do
      before do
        sign_in other_user
        visit user_path(other_user)
      end

      it { should have_selector('div.pagination') }
      it "and list each micropost for page 1" do
        other_user.microposts.paginate(page: 1).each do |post|
          page.should have_selector('li', text: post.content)
        end
      end
    end

    describe "on the user home page" do
      before do
        sign_in other_user
        visit root_path
      end

      it { should have_selector('div.pagination') }
      it "should list each micropost for page 1" do
        other_user.microposts.paginate(page: 1).each do |post|
          page.should have_selector("li##{post.id}", text: post.content)
        end
      end
      it "should not list each micropost for page 2" do
        other_user.microposts.paginate(page: 2).each do |post|
          page.should_not have_selector("li##{post.id}", text: post.content)
        end
      end
    end
  end

  describe "creating a micropost" do
    let!(:mp1) { FactoryGirl.create(:micropost, user: user) }
    let!(:mp2) { FactoryGirl.create(:micropost, user: user) }
    before do
      sign_in user
      visit root_path
    end
    describe "without entering information" do
      before { click_button "Post" }
      it { should have_error_message('error') }
      it { should have_selector("li##{mp1.id}", text: mp1.content) }
      it { should have_selector("li##{mp2.id}", text: mp2.content) }

      it "should not create a micropost" do
        expect { click_button "Post" }.not_to change(Micropost, :count)
      end
    end

    describe "with valid information" do
      before { fill_in "micropost_content", with: "Lorem Ipsum" }

      it "should create a micropost" do
        expect { click_button "Post" }.to change(Micropost, :count).by(1)
        current_path.should == root_path
        should have_selector("li", text: "Lorem Ipsum")
        should have_success_message('Micropost created')
      end
    end
  end

  describe "deleting a micropost" do
    let!(:mp1) { FactoryGirl.create(:micropost, user: user) }
    let!(:mp2) { FactoryGirl.create(:micropost, user: user) }
    before do
      sign_in user
      visit root_path
    end
    describe "as correct user" do
      before { click_link "delete" }
      it "should delete a micropost" do
        expect { click_link "delete" }.to change(Micropost, :count).by(-1)
      end
      specify { current_path.should == root_path }
      it { should have_success_message("deleted") }
      it { should have_content ("1 micropost") }
    end
    describe "for another user" do
      let(:other_user) { FactoryGirl.create(:user) }
      let!(:mp3) { FactoryGirl.create(:micropost, user: other_user) }

      before { visit user_path(other_user) }

      it { should have_selector("li##{mp3.id}", text: mp3.content) }
      it { should_not have_link("delete") }
    end
  end
end
