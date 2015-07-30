require 'test_helper'

class ViewableTest < ActiveSupport::TestCase
  test 'view_for a topic returns num of times a user viewed the topic' do
    topic = Topic.first
    assert_nil topic.view_for(users(:alice))

    topic.register_view_by(users(:alice))
    assert_equal 1, topic.view_for(users(:alice)).count
  end

  test 'register_view_by increments counters and updates times' do
    topic = Topic.first
    assert_nil topic.view_for(users(:alice))

    # Create View instance
    topic.register_view_by(users(:alice))

    # Global view count increment
    assert_difference('topic.view_count', 1) do
      topic.register_view_by(users(:alice))
    end

    # User-specific view count increment
    assert_difference('topic.view_for(users(:alice)).count', 1) do
      topic.register_view_by(users(:alice))
    end

    assert_no_difference('topic.view_for(users(:alice)).current_viewed_at') do
      topic.register_view_by(users(:alice))
    end
  end

  test 'register_view_by does nothing if no user is supplied' do
    topic = Topic.first
    assert_nil topic.view_for(users(:alice))

    assert_no_difference('View.count') do
      topic.register_view_by(nil)
    end

    assert_nil topic.view_count
  end
end