require 'test_helper'

class TopicTest < ActiveSupport::TestCase
  test 'to_s returns title' do
    assert_equal Topic.first.to_s, Topic.first.title
  end

  test 'reply_count returns number of replies in topic' do
    assert_equal Topic.first.reply_count, Topic.first.posts.count - 1
  end

  test 'last_post returns last post created in topic' do
    topic = Topic.first
    assert_equal topic.last_post, Post.where(topic: topic).order(created_at: :desc).first
  end

  test 'ordered_posts returns posts in ascending order by creation time' do
    topic = Topic.first
    topic.posts.create!(user: users(:alice), body: 'body')
    assert topic.ordered_posts.first.created_at < topic.ordered_posts.last.created_at
  end

  test 'num_pages returns the number of pages for a given post' do
    topic = Topic.first
    assert_equal topic.num_pages, 1

    15.times do
      topic.posts.create!(user: users(:alice), body: 'body')
    end

    topic.reload
    assert_equal topic.num_pages, 2
  end
end
