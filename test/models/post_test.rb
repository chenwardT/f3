require 'test_helper'

class PostTest < ActiveSupport::TestCase
  def setup
    @user = FactoryGirl.create(:user)

    @top = FactoryGirl.create(:forum)
    @top_topic = FactoryGirl.create(:topic, forum: @top, user: @user)
    FactoryGirl.create(:post, topic: @top_topic, user: @user)
    FactoryGirl.create(:post, topic: @top_topic, user: @user)
  end

  test 'update topic last_post_at after post creation' do
    old_ts = @top_topic.last_post_at
    sleep(0.1)
    post = FactoryGirl.create(:post, topic: @top_topic, user: @user)
    new_ts = @top_topic.reload.last_post_at

    assert_not_equal old_ts, new_ts
    # Complaint about checking implementation of #== for TimeWithZone unless we cast to int
    assert_equal new_ts.to_i, post.created_at.to_i
  end
end
