require 'test_helper'

class PostTest < ActiveSupport::TestCase
  test 'update topic last_post_at after post creation' do
    topic = Topic.first
    # Must create post here as callbacks not running on post creation in fixtures
    topic.posts.create!(user: users(:alice), body: 'body')
    old_ts = topic.reload.last_post_at
    sleep(1)
    post = topic.posts.create!(user: users(:alice), body: 'body')
    new_ts = topic.reload.last_post_at

    assert_not_equal old_ts, new_ts
    # Complaint about checking implementation of #== for TimeWithZone unless we cast to int
    assert_equal new_ts.to_i, post.created_at.to_i
  end
end
