require 'test_helper'

class ViewableTest < ActiveSupport::TestCase
  def setup
    @user = FactoryGirl.create(:user)

    @top = FactoryGirl.create(:forum)
    @top_topic = FactoryGirl.create(:topic, forum: @top, user: @user)
    FactoryGirl.create(:post, topic: @top_topic, user: @user)
    FactoryGirl.create(:post, topic: @top_topic, user: @user)
  end

  test 'view_for a topic returns num of times a user viewed the topic' do
    assert_nil @top_topic.view_for(@user)

    @top_topic.register_view_by(@user)
    assert_equal 1, @top_topic.view_for(@user).count
  end

  test 'register_view_by increments counters and updates times' do
    assert_nil @top_topic.view_for(@user)

    # Create View instance
    @top_topic.register_view_by(@user)

    # Global view count increment
    assert_difference('@top_topic.views_count', 1) do
      @top_topic.register_view_by(@user)
    end

    # User-specific view count increment
    assert_difference('@top_topic.view_for(@user).count', 1) do
      @top_topic.register_view_by(@user)
    end

    assert_no_difference('@top_topic.view_for(@user).current_viewed_at') do
      @top_topic.register_view_by(@user)
    end
  end

  test 'register_view_by does nothing if no user is supplied' do
    assert_nil @top_topic.view_for(@user)

    assert_no_difference('View.count') do
      @top_topic.register_view_by(nil)
    end

    assert_nil @top_topic.views_count
  end
end