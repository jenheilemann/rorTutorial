namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
    # stuff all the user creation into a begin/rescue block, because if I forget
    # to run db:reset then db:populate throws yells about emails already being
    # taken... but sometimes I just want to keep some of the old data too.
    begin
      # create the admin user
      admin = User.create!( name: "Admin User",
                    email: ENV['admin_email'].dup,
                    password: ENV['favorite_password'].dup,
                    password_confirmation: ENV['favorite_password'].dup)
      admin.toggle!(:admin)
      # create the default example user
      User.create!( name: "Example User",
                    email: ENV['user_email'].dup,
                    password: ENV['favorite_password'].dup,
                    password_confirmation: ENV['favorite_password'].dup)
      # create a bunch of fake users to fill everything
      44.times do |n|
        name = Faker::Name.name
        email = "example-#{n+1}@railstutorial.org"
        password = "password"
        User.create!( name: name,
                      email: email,
                      password: password,
                      password_confirmation: password)
      end
    rescue
      # do nothing! it didn't work, but that's okay, because WHO CARES
    end

    # give some of the users microposts
    users = User.all(limit: 6)
    50.times do
      content = Faker::Lorem.sentence(6)
      users.each { |user| user.microposts.create!(content: content) }
    end
  end
end