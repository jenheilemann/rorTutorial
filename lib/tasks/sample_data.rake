namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
    admin = User.create!( name: "Admin User",
                  email: ENV['admin_email'].dup,
                  password: ENV['favorite_password'].dup,
                  password_confirmation: ENV['favorite_password'].dup)
    admin.toggle!(:admin)
    User.create!( name: "Example User",
                  email: ENV['user_email'].dup,
                  password: ENV['favorite_password'].dup,
                  password_confirmation: ENV['favorite_password'].dup)
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