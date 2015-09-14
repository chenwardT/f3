FactoryGirl.define do

  sequence :email do |n|
    "user#{n}@example.com"
  end

  sequence :username do |n|
    "user#{n}"
  end

  factory :user do
    username
    email
    password "test1234"
    password_confirmation "test1234"
    time_zone "America/New_York"
    website "someuser.com"
    bio "Hi I'm a user"
    signature "~sig"
    birthday "Thu, 30 Jul 2015".to_date
    country "United States"
    quote "frog blast the vent core"
    confirmed_at Time.now
  end

  sequence :forum_title do |n|
    "Forum Title #{n}"
  end

  factory :forum do
    title { generate(:forum_title) }
    description "we discuss things here"
    forum nil
  end

  sequence :topic_title do |n|
    "Topic Title #{n}"
  end

  factory :topic do
    forum { |f| f.association(:forum) }
    user { |u| u.association(:user) }
    title { generate(:topic_title) }
  end

  factory :post do
    topic { |t| t.association(:topic) }
    user { |u| u.association(:user) }
    body "quality poast"
  end

  factory :view do
    viewable nil
    viewable_type nil
    user { |u| u.association(:user) }
    count 0
  end

  sequence :group_name do |n|
    "group#{n}"
  end

  factory :group do
    name { generate(:group_name) }
  end

  factory :forum_permission do
    forum { |f| f.association(:forum) }
    group { |g| g.association(:group) }
  end
end