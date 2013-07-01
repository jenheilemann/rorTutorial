namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
    admin = User.create!( name: "Admin User",
                  email: APP_CONFIG['admin_email'],
                  password: APP_CONFIG['favorite_password'],
                  password_confirmation: APP_CONFIG['favorite_password'])
    admin.toggle!(:admin)
    User.create!( name: "Example User",
                  email: APP_CONFIG['user_email'],
                  password: APP_CONFIG['favorite_password'],
                  password_confirmation: APP_CONFIG['favorite_password'])
    44.times do |n|
      name = Faker::Name.name
      email = "example-#{n+1}@railstutorial.org"
      password = "password"
      User.create!( name: name,
                    email: email,
                    password: password,
                    password_confirmation: password)
    end
  end
end