require 'spec_helper'

describe "Authentication" do
  subject { page }

  describe "signin page" do
    before { visit signin_path }
    let(:signin) { "Sign in" }

    it { should have_selector('h1',    text: "Sign in") }
    it { should have_selector('title', text: "Sign in") }

    describe "with invalid information" do
      before do
        fill_in "Email",    with: "fakeuser"
        fill_in "Password", with: "fakepassword"
        click_button signin
      end

      it { should have_selector('title', text: "Sign in") }
      it { should have_selector('div.alert.alert-error', text: "Invalid") }

      describe "after visiting another page" do
        before { click_link "Home" }
        it { should_not have_selector('div.alert.alert-error') }
      end
    end

    describe "with blank information" do
      before do
        click_button signin
      end

      it { should have_selector('title', text: "Sign in") }
      it { should have_selector('div.alert.alert-error', text: "Invalid") }
    end

    describe "with valid information" do
      let(:user) { FactoryGirl.create(:user) }
      before do
        fill_in "Email",    with: user.email.upcase
        fill_in "Password", with: user.password
        click_button signin
      end

      it { current_path.should == user_path(user) }
      it { should have_selector('title', text: user.name) }
      it { should     have_link('Profile', href: user_path(user)) }
      it { should     have_link('Sign out', href: signout_path) }
      it { should_not have_link('Sign in', href: signin_path) }

      describe "move around the site" do
        before { click_link "Contact" }
        it { should have_link "Sign out" }
        it { should_not have_link('Sign in', href: signin_path) }
      end

      describe "followed with signout" do
        before { click_link "Sign out" }
        it { should have_link "Sign in" }
      end
    end
  end
end
