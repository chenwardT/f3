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
20.times do
  name = Faker::Name.name
  user = User.new(email: Faker::Internet.email(name), username: name, password: 'test1234',
                  password_confirmation: 'test1234')
  user.save!
end

3.times do
  Category.create!(title: Faker::Commerce.department, description: Faker::Lorem.sentence)
end

Category.all.each do |category|
  4.times do
    forum = category.forums.create!(title: Faker::Commerce.product_name,
                                    description: Faker::Lorem.sentence)
    5.times do
      topic = forum.topics.create!( user: User.all.sample, title: Faker::Lorem.sentence)
      5.times do
        topic.posts.create!(user: User.all.sample, body: Faker::Lorem.paragraph)
      end
    end
  end
end