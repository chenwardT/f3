# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

user = User.new(email: 'chenward.t@gmail.com', username: 'chenwardT', password: 'test1234',
                password_confirmation: 'test1234')
user.save!

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
    5.times do
      topic = subforum.topics.create!(user: User.all.sample, title: Faker::Lorem.sentence)
      5.times do
        topic.posts.create!(user: User.all.sample, body: Faker::Lorem.paragraph)
      end
    end

    2.times do
      innermost_forum = subforum.forums.create!(title: Faker::Commerce.product_name,
                                                description: Faker::Lorem.sentence)
      4.times do
        topic = innermost_forum.topics.create!(user: User.all.sample, title: Faker::Lorem.sentence)
        3.times do
          topic.posts.create!(user: User.all.sample, body: Faker::Lorem.paragraph)
        end
      end
    end
  end
end