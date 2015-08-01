# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

admin = Group.create(name: 'admin')
mod = Group.create(name: 'moderator')

user = User.new(email: 'chenward.t@gmail.com', username: 'chenwardT', password: 'test1234',
                password_confirmation: 'test1234')

user.save!

admin.users << user
# mod.users << user

# TODO: Ensure this doesn't duplicate acct info when we set unique constraints.
40.times do
  name = Faker::Name.name
  user = User.new(email: Faker::Internet.email(name), username: Faker::Internet.user_name(name),
                  password: 'test1234', password_confirmation: 'test1234',
                  birthday: Faker::Date.birthday, time_zone: Faker::Address.time_zone,
                  country: Faker::Address.country, quote: Faker::Company.catch_phrase,
                  website: Faker::Internet.url, bio: Faker::Lorem.paragraph,
                  signature: Faker::Hacker.say_something_smart)
  user.save!
end

# Top level forums
3.times do
  Forum.create!(title: Faker::Company.name + " " + Faker::Company.suffix,
                description: Faker::Company.bs)
end

# Nested forums
Forum.all.each do |forum|
  4.times do
    subforum = forum.forums.create!(title: Faker::Commerce.department,
                                    description: Faker::Company.catch_phrase)
    # Topics
    5.times do
      author = User.all.sample
      topic = subforum.topics.create!(user: author, title: Faker::Lorem.sentence)
      topic.posts.create!(user: author, body: Faker::Lorem.paragraph)

      # Replies
      5.times do
        topic.posts.create!(user: User.all.sample, body: Faker::Lorem.paragraph)
      end
    end

    2.times do
      innermost_forum = subforum.forums.create!(title: Faker::Commerce.product_name,
                                                description: Faker::Lorem.sentence)
      # Topics
      4.times do
        author = User.all.sample
        topic = innermost_forum.topics.create!(user: author, title: Faker::Lorem.sentence)
        topic.posts.create!(user: author, body: Faker::Lorem.paragraph)
        
        # Replies
        3.times do
          topic.posts.create!(user: User.all.sample, body: Faker::Lorem.paragraph)
        end
      end
    end
  end
end