FactoryGirl.define do
  factory :user do
    name                   "Real User"
    email                  "realuser@nerdery.com"
    password               "realpassword"
    password_confirmation  "realpassword"
  end
end