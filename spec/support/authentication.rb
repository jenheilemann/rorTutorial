def valid_signin(user, signin="Sign in")
  fill_in "Email",    with: user.email
  fill_in "Password", with: user.password
  click_button signin
end