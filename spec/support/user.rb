def valid_signup
  fill_in "Name",             with: "Example User"
  fill_in "Email",            with: "user@example.com"
  fill_in "Password",         with: "foobar"
  fill_in "Confirm Password", with: "foobar"
end

def invalid_signup
  fill_in "Name",             with: ""
  fill_in "Email",            with: "user@example"
  fill_in "Password",         with: "foo"
  fill_in "Confirm Password", with: "bar"
end