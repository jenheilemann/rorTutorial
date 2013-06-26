def valid_signin(user)
  fill_in "Email",    with: user.email
  fill_in "Password", with: user.password
  click_button signin
  # keep sign in info even when not using Capybara
  cookies[:remember_token] = user.remember_token
end