require 'test_helper'

class ForumTest < ActiveSupport::TestCase
  def setup
    @user = FactoryGirl.create(:user)

    @top = FactoryGirl.create(:forum)
    @top_topic = FactoryGirl.create(:topic, forum: @top, user: @user)
    FactoryGirl.create(:post, topic: @top_topic, user: @user)
    FactoryGirl.create(:post, topic: @top_topic, user: @user)

    @depth1 = FactoryGirl.create(:forum, forum: @top)
    @d1_topic = FactoryGirl.create(:topic, forum: @depth1, user: @user)
    FactoryGirl.create(:post, topic: @d1_topic, user: @user)
    FactoryGirl.create(:post, topic: @d1_topic, user: @user)

    @depth2a = FactoryGirl.create(:forum, forum: @depth1)
    @d2a_topic = FactoryGirl.create(:topic, forum: @depth2a, user: @user)
    FactoryGirl.create(:post, topic: @d2a_topic, user: @user)
    FactoryGirl.create(:post, topic: @d2a_topic, user: @user)

    @depth2b = FactoryGirl.create(:forum, forum: @depth1)
    @d2b_topic = FactoryGirl.create(:topic, forum: @depth2b, user: @user)
    FactoryGirl.create(:post, topic: @d2b_topic, user: @user)
    FactoryGirl.create(:post, topic: @d2b_topic, user: @user)
  end

  test 'forum hierarchy' do
    assert_includes @top.forums, @depth1
    assert_includes @depth1.forums, @depth2a
    assert_includes @depth1.forums, @depth2a
    assert_equal [@depth2a, @depth2b], @depth1.forums
  end

  test 'to_s returns title' do
    assert_equal @top.title, @top.to_s
  end

  test 'topic_count returns count of nested topics' do
    assert_equal @top.topics.count, @top.topic_count
  end

  test 'self_and_descendents returns the forum and all children of any depth' do
    assert_equal Forum.count, @top.self_and_descendents.count
    assert_equal 3, @depth1.self_and_descendents.count
    assert_equal 1, @depth2b.self_and_descendents.count
  end

  test 'self_and_desc_topic_count returns num of topics in forum and all children' do
    assert_equal Topic.count, @top.self_and_desc_topic_count
    assert_equal 3, @depth1.self_and_desc_topic_count
    assert_equal 1, @depth2b.self_and_desc_topic_count
  end

  test 'post_count returns num of posts in the forum' do
    assert_equal 2, @top.post_count
  end

  test 'self_and_desc_post_count returns num of posts in forum and children' do
    assert_equal Post.count, @top.self_and_desc_post_count
    assert_equal 6, @depth1.self_and_desc_post_count
    assert_equal 2, @depth2b.self_and_desc_post_count
  end

  test 'last_topic returns the last topic that was posted to in in the forum and children' do
    sleep(0.1)
    topic = FactoryGirl.create(:topic, forum: @depth1, user: @user)
    FactoryGirl.create(:post, topic: topic, user: @user)

    topic = Topic.where(forum: @top.self_and_descendents).order(created_at: :desc).first
    assert_equal topic, @top.last_topic
  end

  test 'last_post_in_last_topic returns the last post in the last topic created in the forum' do
    sleep(0.1)
    topic = FactoryGirl.create(:topic, forum: @depth1, user: @user)
    FactoryGirl.create(:post, topic: topic, user: @user)

    post = @top.last_topic.posts.order(created_at: :desc).first
    assert_equal post, @top.last_post_in_last_topic
  end

  # test 'tree_sql_for returns SQL to get forum and all children' do
  # end

  test 'tree_for scope returns forum and all children' do
    assert_equal Forum.count, Forum.tree_for(@top).count
  end
end
