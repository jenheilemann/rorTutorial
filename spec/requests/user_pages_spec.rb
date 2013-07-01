require 'spec_helper'

describe "User Pages" do
  subject { page }

  describe "Index" do
    let(:user) { FactoryGirl.create(:user) }

    before(:each) do
      sign_in user
      visit users_path
    end

    it { should have_title("All users") }
    it { should have_selector("h1", text: "All users") }

    describe "pagination" do
      before(:all) { 30.times { FactoryGirl.create(:user) } }
      after(:all)  { User.delete_all }

      it { should have_selector('div.pagination') }

      it "should list each user for page 1" do
        User.paginate(page: 1).each do |user|
          page.should have_selector('li', text: user.name)
        end
      end
    end

    describe "delete links" do
      it { should_not have_link("delete") }

      describe "as an admin user" do
        let(:admin) { FactoryGirl.create(:admin) }
        before do
          sign_in admin
          visit users_path
        end

        it { should have_link('delete',     href: user_path(User.first)) }
        it { should_not have_link('delete', href: user_path(admin)) }
        it "should be able to delete another user" do
          expect { click_link('delete') }.to change(User, :count).by(-1)
        end
      end
    end
  end

  describe "Profile page" do
    let(:user) { FactoryGirl.create(:user) }
    before { visit user_path(user) }

    it { should have_content(user.name) }
    it { should have_title(user.name) }
    it { should have_selector('img.gravatar') }
  end

  describe "Edit" do
    let(:user) { FactoryGirl.create(:user) }
    before do
      sign_in user
      visit edit_user_path(user)
    end

    describe "page" do
      it { should have_selector('h1', text: 'Update your profile') }
      it { should have_title('Edit user') }
      it { should have_selector('img.gravatar')}
      it { should have_link('change', href: "http://gravatar.com/emails") }
    end

    describe "with invalid information" do
      before { click_button "Save changes" }
      it { should have_selector('h1', text: 'Update your profile') }
      it { should have_error_message "error" }
    end

    describe "with valid information" do
      let(:new_name)  { "New name" }
      let(:new_email) { "new@email.com" }
      before do
        fill_in "Name",             with: new_name
        fill_in "Email",            with: new_email
        fill_in "Password",         with: user.password
        fill_in "Confirm Password", with: user.password
        click_button "Save changes"
      end

      it { current_path.should == user_path(user) }
      it { should_not have_error_message "error" }
      it { should have_success_message "updated" }
      it { should have_content(new_name) }
      it { should have_title(new_name) }
      it { should have_link('Sign out', href: signout_path) }
      it { should have_selector('img.gravatar')}
      specify { user.reload.name.should  == new_name }
      specify { user.reload.email.should == new_email }
    end
  end

  describe "Signup page" do
    before { visit signup_path }
    let(:submit) { "Create my account" }

    it { should have_selector('h1', text: "Sign Up") }
    it { should have_title(full_title("Sign Up")) }

    describe "when no information is filled in" do
      before { click_button submit }
      it "a user is not created" do
        expect { click_button submit }.not_to change(User, :count)
      end
      it "error messages are displayed" do
        should have_error_message('error')
      end
      it "password digest error is not displayed" do
        should_not have_content('Password digest')
      end
    end

    describe "with invalid information" do
      before do
        invalid_signup
        click_button submit
      end

      it { should have_title('Sign Up')}
      it { should have_error_message('error') }
    end

    describe "with valid information" do
      before { valid_signup }

      it "should create a user" do
        expect { click_button submit }.to change(User, :count).by(1)
      end

      describe "after saving the user" do
        before { click_button submit }
        let(:user) { User.find_by_email("user@example.com") }

        it { current_path.should == user_path(user) }
        it { should have_title(user.name) }
        it { should have_success_message('Welcome') }
        it { should have_link('Sign out') }
      end
    end
  end
end
