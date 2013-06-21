require 'spec_helper'

describe "User Pages" do
  subject { page }

  describe "Profile page" do
    let(:user) { FactoryGirl.create(:user) }
    before { visit user_path(user) }

    it { should have_selector('h1',    text: user.name) }
    it { should have_selector('title', text: user.name) }
  end
  describe "Signup page" do
    before { visit signup_path }

    it { should have_selector('h1',    text: "Sign Up") }
    it { should have_selector('title', text: full_title("Sign Up")) }
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
        should have_content('error')
      end
      it "password digest error is not displayed" do
        should_not have_content('Password digest')
      end
    end

    describe "with invalid information" do
      before do
        fill_in "Name",             with: ""
        fill_in "Email",            with: "user@example"
        fill_in "Password",         with: "foo"
        fill_in "Confirm Password", with: "bar"
        click_button submit
      end

      it { should have_selector('title', text: 'Sign Up')}
      it { should have_content('error') }
    end

    describe "with valid information" do
      before do
        fill_in "Name",             with: "Example User"
        fill_in "Email",            with: "user@example.com"
        fill_in "Password",         with: "foobar"
        fill_in "Confirm Password", with: "foobar"
      end

      it "should create a user" do
        expect { click_button submit }.to change(User, :count).by(1)
      end
    end
  end
end
