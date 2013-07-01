FactoryGirl.define do
  factory :user do
    sequence(:name)  { |n| "Real User #{n}" }
    sequence(:email) { |n| "realuser-#{n}@nerdery.com" }
    password               "realpassword"
    password_confirmation  "realpassword"

    factory :admin do
      admin true
    end
  end
end