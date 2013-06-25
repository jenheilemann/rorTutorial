# Authentication steps

Given(/^a user visits the 'sign in' page$/) do
  visit signin_path
end

When(/^he submits invalid signin information$/) do
  fill_in "Email",    with: "fake@email.com"
  fill_in "Password", with: "fake"
  click_button "Sign in"
end

When(/^he submits an empty signin form$/) do
  click_button "Sign in"
end

Then(/^he should see an error message$/) do
  page.should have_selector('div.alert.alert-error')
end

Given(/^the user has an account$/) do
  @user = User.create(name:"Example User", email: "fakeemail@example.com",
                      password: "password", password_confirmation: "password")
end

When(/^the user submits valid signin information$/) do
  fill_in "Email",    with: @user.email
  fill_in "Password", with: @user.password
  click_button "Sign in"
end

Then(/^he should see his profile page$/) do
  page.should have_selector('title', text: @user.name)
end

Then(/^he should see a 'sign out' link$/) do
  page.should have_link('Sign out')
end

