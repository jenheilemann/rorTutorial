namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
    make_users
    make_microposts
    make_relationships
  end
end

def make_users
  print "Making the users..."
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
      print "."
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
    puts "\nNeeded to rescue."
  end
  puts "done."
end

def make_microposts
  # give some of the users microposts
  print "Giving some of the users microposts..."
  users = User.all(limit: 7)
  content = Array.new
  50.times do
    content << Faker::Lorem.sentence(6)
  end
  users.each do |user|
    print '.'
    content.shuffle!
    content.each { |new_post| user.microposts.create!(content: new_post) }
    print '.'
  end
  puts "done."
end

def make_relationships
  print "Creating relationships"
  users = User.all
  user = choose_user(users)
  print " for User #{user.id}..."

  followed_users = users[0..20]
  followers      = users[0..40]

  followed_users.delete(user)
  followers.delete(user)

  followed_users.each do |followed|
    print '.'
    user.follow!(followed)
  end
  followers.each do |follower|
    print '.'
    follower.follow!(user)
  end
  puts 'done.'
end

def choose_user(users)
  users.detect do |u|
    u.relationships.count == 0
  end
end