require 'test_helper'

class TopicTest < ActiveSupport::TestCase
  test 'to_s returns title' do
    assert_equal Topic.first.title, Topic.first.to_s
  end

  test 'reply_count returns number of replies in topic' do
    assert_equal Topic.first.posts.count - 1, Topic.first.reply_count
  end

  test 'last_post returns last post created in topic' do
    topic = Topic.first
    assert_equal Post.where(topic: topic).order(created_at: :desc).first, topic.last_post
  end

  test 'ordered_posts returns posts in ascending order by creation time' do
    topic = Topic.first
    topic.posts.create!(user: users(:alice), body: 'body')
    sleep(1)
    topic.posts.create!(user: users(:alice), body: 'body')
    assert topic.ordered_posts.first.created_at < topic.ordered_posts.last.created_at
  end

  test 'num_pages returns the number of pages for a given post' do
    topic = Topic.first
    assert_equal 1, topic.num_pages

    15.times do
      topic.posts.create!(user: users(:alice), body: 'body')
    end

    topic.reload
    assert_equal 2, topic.num_pages
  end
end
