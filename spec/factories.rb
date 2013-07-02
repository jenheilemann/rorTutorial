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

  factory :micropost do
    # make sure we're under the 160 character limit
    content { Faker::Lorem.sentence(6)[0..159] }
    user
  end
end