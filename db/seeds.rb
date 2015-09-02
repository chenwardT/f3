# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

Group.create(name: 'guest',
             description: 'Not Logged In',
             create_forum: false,
             view_topic: true,
             view_forum: true,
             preapproved_posts: false,
             create_post: false,
             edit_own_post: false,
             soft_delete_own_post: false,
             hard_delete_own_post: false,
             create_topic: false,
             lock_or_unlock_own_topic: false,
             copy_or_move_own_topic: false,
             edit_any_post: false,
             soft_delete_any_post: false,
             hard_delete_any_post: false,
             lock_or_unlock_any_topic: false,
             copy_or_move_any_topic: false,
             moderate_any_forum: false)

admin = Group.create(name: 'admin',
                     description: 'Administrators',
                     create_forum: true,
                     view_topic: true,
                     view_forum: true,
                     preapproved_posts: true,
                     create_post: true,
                     edit_own_post: true,
                     soft_delete_own_post: true,
                     hard_delete_own_post: true,
                     create_topic: true,
                     lock_or_unlock_own_topic: true,
                     copy_or_move_own_topic: true,
                     edit_any_post: true,
                     soft_delete_any_post: true,
                     hard_delete_any_post: true,
                     lock_or_unlock_any_topic: true,
                     copy_or_move_any_topic: true,
                     moderate_any_forum: true)

mod = Group.create(name: 'moderator',
                   description: 'Moderators',
                   create_forum: true,
                   view_topic: true,
                   view_forum: true,
                   preapproved_posts: true,
                   create_post: true,
                   edit_own_post: true,
                   soft_delete_own_post: true,
                   hard_delete_own_post: true,
                   create_topic: true,
                   lock_or_unlock_own_topic: true,
                   copy_or_move_own_topic: true,
                   edit_any_post: true,
                   soft_delete_any_post: true,
                   hard_delete_any_post: true,
                   lock_or_unlock_any_topic: true,
                   copy_or_move_any_topic: true,
                   moderate_any_forum: true)

registered = Group.create(name: 'registered',
                          description: 'Registered Users',
                          create_forum: false,
                          view_topic: true,
                          view_forum: true,
                          preapproved_posts: true,
                          create_post: true,
                          edit_own_post: true,
                          soft_delete_own_post: false,
                          hard_delete_own_post: false,
                          create_topic: true,
                          lock_or_unlock_own_topic: false,
                          copy_or_move_own_topic: false,
                          edit_any_post: false,
                          soft_delete_any_post: false,
                          hard_delete_any_post: false,
                          lock_or_unlock_any_topic: false,
                          copy_or_move_any_topic: false,
                          moderate_any_forum: false)

read_only = Group.create(name: 'read_only',
                         description: 'Read Only Users',
                         create_forum: false,
                         view_topic: true,
                         view_forum: true,
                         preapproved_posts: true,
                         create_post: false,
                         edit_own_post: false,
                         soft_delete_own_post: false,
                         hard_delete_own_post: false,
                         create_topic: false,
                         lock_or_unlock_own_topic: false,
                         copy_or_move_own_topic: false,
                         edit_any_post: false,
                         soft_delete_any_post: false,
                         hard_delete_any_post: false,
                         lock_or_unlock_any_topic: false,
                         copy_or_move_any_topic: false,
                         moderate_any_forum: false)

no_perms = Group.create(name: 'no_perms',
                         description: 'No Permission Users',
                         create_forum: false,
                         view_topic: false,
                         view_forum: false,
                         preapproved_posts: false,
                         create_post: false,
                         edit_own_post: false,
                         soft_delete_own_post: false,
                         hard_delete_own_post: false,
                         create_topic: false,
                         lock_or_unlock_own_topic: false,
                         copy_or_move_own_topic: false,
                         edit_any_post: false,
                         soft_delete_any_post: false,
                         hard_delete_any_post: false,
                         lock_or_unlock_any_topic: false,
                         copy_or_move_any_topic: false,
                         moderate_any_forum: false)

user = User.new(email: 'chenward.t@gmail.com', username: 'chenwardT', password: 'test1234',
                password_confirmation: 'test1234')
user.groups << admin
user.save!

user = User.new(email: 'registered@test.com', username: 'registered', password: 'test1234',
                password_confirmation: 'test1234')
user.groups << registered
user.save!

user = User.new(email: 'readonly@test.com', username: 'readonly', password: 'test1234',
                password_confirmation: 'test1234')
user.groups << read_only
user.save!

user = User.new(email: 'noperms@test.com', username: 'noperms', password: 'test1234',
                password_confirmation: 'test1234')
user.groups << no_perms
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
  user.groups << registered
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