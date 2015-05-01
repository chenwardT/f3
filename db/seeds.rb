# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

user = User.new
user.email = 'chenward.t@gmail.com'
user.password = 'test1234'
user.password_confirmation = 'test1234'
user.save!

3.times do
  Category.create!(title: Faker::Commerce.department, description: Faker::Lorem.sentence)
end

Category.all.each do |category|
  4.times do
    forum = category.forums.create!(title: Faker::Commerce.product_name)

    5.times do
      topic = forum.topics.create!(title: Faker::Lorem.sentence, user: user)

      5.times do
        topic.posts.create!(user: user, body: Faker::Lorem.paragraph)
      end
    end
  end
end