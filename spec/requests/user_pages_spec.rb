require 'spec_helper'

describe "User Pages" do
  subject { page }

  describe "Profile page" do
    let(:user) { FactoryGirl.create(:user) }
    before { visit user_path(user) }

    it { should have_content(user.name) }
    it { should have_title(user.name) }
  end

  describe "Signup page" do
    before { visit signup_path }

    it { should have_selector('h1', text: "Sign Up") }
    it { should have_title(full_title("Sign Up")) }
  end

  describe "Signing up" do
    before { visit signup_path }
    let(:submit) { "Create my account" }

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
