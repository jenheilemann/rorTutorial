require 'spec_helper'

describe "Authentication" do
  subject { page }

  describe "signin page" do
    before { visit signin_path }
    let(:signin) { "Sign in" }

    it { should have_selector('h1', text: signin) }
    it { should have_title(signin) }

    describe "with invalid information" do
      before do
        fill_in "Email",    with: "fakeuser"
        fill_in "Password", with: "fakepassword"
        click_button signin
      end

      it { should have_title(signin) }
      it { should have_error_message('Invalid') }

      describe "after visiting another page" do
        before { click_link "Home" }
        it { should_not have_error_message('Invalid') }
      end
    end

    describe "with blank information" do
      before { click_button signin }

      it { should have_title(signin) }
      it { should have_error_message("Invalid") }
    end

    describe "with valid information" do
      let(:user) { FactoryGirl.create(:user) }
      before { valid_signin(user) }

      specify { current_path.should == user_path(user) }
      it { should have_title(user.name) }
      it { should_not have_error_message('Invalid') }
      it { should     have_link('Profile', href: user_path(user)) }
      it { should     have_link('Settings', href: edit_user_path(user)) }
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

  describe "authorization" do
    describe "for non-signed-in users" do
      let(:user) { FactoryGirl.create(:user) }

      describe "in the Users area" do
        describe "visiting the edit page" do
          before { visit edit_user_path(user) }
          it { should have_title('Sign in') }
          it { should have_notice_message('Please sign in') }
          specify { current_path.should == signin_path }

          describe "after signing in" do
            before do
              fill_in "Email", with: user.email
              fill_in "Password", with: user.password
              click_button "Sign in"
            end
            it { should have_title('Edit user') }
          end
        end

        describe "submitting to the update action" do
          before { put user_path(user) }
          specify { response.should redirect_to(signin_path) }
        end

      end
    end

    describe "as wrong user" do
      let(:user)       { FactoryGirl.create(:user) }
      let(:wrong_user) { FactoryGirl.create(:user, email: "wrong@examle.com") }
      before { sign_in user }

      describe "visiting the Users/edit page" do
        before { visit edit_user_path(wrong_user) }
        it { should_not have_title("Edit user") }
        specify { current_path.should == root_path }
      end

      describe "submitting a PUT request to the Users#update action" do
        before { put user_path(wrong_user) }
        specify { response.should redirect_to root_path }
      end
    end
  end
end
