require 'spec_helper'

describe "Authentication" do
  subject { page }

  describe "signin page" do
    before { visit signin_path }
    let(:signin) { "Sign in" }

    describe "before signing in" do
      it { should have_selector('h1', text: signin) }
      it { should have_title(signin) }

      it { should_not have_link('Users') }
      it { should_not have_link('Profile') }
      it { should_not have_link('Settings') }
      it { should_not have_link('Sign out') }
    end

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

      specify { current_path.should == root_path }
      it { should have_title(user.name) }
      it { should_not have_error_message('Invalid') }

      it { should have_link('Users',    href: users_path) }
      it { should have_link('Profile',  href: user_path(user)) }
      it { should have_link('Settings', href: edit_user_path(user)) }
      it { should have_link('Sign out', href: signout_path) }

      it { should_not have_link('Sign in',  href: signin_path) }

      describe "move around the site" do
        before { click_link "Contact" }
        it { should have_link "Sign out" }
        it { should_not have_link('Sign in', href: signin_path) }
      end

      describe "followed with signout" do
        before { click_link "Sign out" }
        it { should have_link "Sign in" }
        it { should have_success_message "signed out" }
        specify { current_path.should == signin_path }
      end
    end
  end

  describe "authorization" do
    describe "for non-signed-in users" do
      let(:user) { FactoryGirl.create(:user) }

      describe "in the Users area" do
        describe "when attempting to visit a protected page" do
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

            describe "when signing in again" do
              before do
                click_link 'Sign out'
                visit signin_path
                fill_in "Email", with: user.email
                fill_in "Password", with: user.password
                click_button "Sign in"
              end

              it "should render the default profile page" do
                page.should have_title(user.name)
                current_path.should == root_path
              end
            end
          end
        end

        describe "submitting to the update action" do
          before { put user_path(user) }
          specify { response.should redirect_to(signin_path) }
        end

        describe "visiting the index" do
          before { visit users_path }
          it { should have_title('Sign in') }
        end

        describe "visiting the followers page" do
          before { visit followers_user_path(user) }
          it { should have_title('Sign in') }
        end

        describe "visiting the following page" do
          before { visit following_user_path(user) }
          it { should have_title('Sign in') }
        end
      end

      describe "in the Microposts controller" do
        describe "posting to the #create action" do
          before { post microposts_path }
          specify { response.should redirect_to(signin_path)}
        end
        describe "submitting to the #destroy action" do
          before { delete micropost_path(FactoryGirl.create(:micropost)) }
          specify { response.should redirect_to(signin_path)}
        end
      end

      describe "In the Relationships controller" do
        describe "posting to the #create action" do
          before { post relationships_path }
          specify { response.should redirect_to(signin_path)}
        end
        describe "submitting to the #destroy action" do
          before { delete relationship_path(1) }
          specify { response.should redirect_to(signin_path)}
        end
      end

      describe "in the static pages" do
        describe "the home page" do
          it { should_not have_selector('img.gravatar') }
          it { should_not have_selector('div.pagination') }
          it { should_not have_selector('form') }
        end
      end
    end

    describe "as signed-in user" do
      let(:user)      { FactoryGirl.create(:user) }
      let(:micropost) { FactoryGirl.create(:micropost, user: user) }
      before { sign_in user }

      describe "visit the new user form" do
        before { visit signup_path }

        it { should have_title('Edit user') }
        it { should have_selector('h1', text: 'Update your profile') }
        it { should have_selector('img.gravatar') }

        it { should_not have_selector('h1', text: 'Sign up') }
        it { should_not have_title('Sign Up') }
        specify { current_path.should == edit_user_path(user) }
      end

      describe "POST to the User#create action" do
        before { post users_path }
        specify { response.should redirect_to edit_user_path(user) }
      end

      describe "visit the sign in page" do
        before { visit signin_path }
        it { should have_selector('h1', text: user.name ) }
        specify { current_path.should == user_path(user) }
      end

      describe "POST to the Session#create action" do
        before { post sessions_path }
        specify { response.should redirect_to user_path(user) }
      end
    end

    describe "as wrong user" do
      let(:user)       { FactoryGirl.create(:user) }
      let(:wrong_user) { FactoryGirl.create(:user, email: "wrong@examle.com") }
      let(:micropost)  { FactoryGirl.create(:micropost, user: wrong_user) }
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

      describe "submitting a DELETE request to the Microposts#destory action" do
        before { delete micropost_path(micropost) }
        it      { should_not have_success_message("deleted") }
        specify { response.should redirect_to root_path }
      end
    end

    describe "as non-admin user" do
      let(:user)      { FactoryGirl.create(:user) }
      let(:non_admin) { FactoryGirl.create(:user) }

      before do
        user.save!
        non_admin.save!
        sign_in non_admin
      end

      describe "submitting a DELETE request to the Users#destroy action" do
        it "should send the user to the home page" do
          delete user_path(user)
          response.should redirect_to(root_path)
        end
        it "should not change the number of users" do
          expect { delete user_path(user) }.not_to change(User, :count)
        end
      end
    end

    describe "as an admin user" do
      let(:admin) { FactoryGirl.create(:admin) }
      before { sign_in admin }

      describe "attempting to DELETE themselves" do
        it "should send the user to the home page" do
          delete user_path(admin)
          response.should redirect_to(root_path)
        end
        it "should not change the number of users" do
          expect { delete user_path(admin) }.not_to change(User, :count)
        end
      end
    end
  end
end
