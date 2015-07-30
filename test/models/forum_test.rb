require 'test_helper'

class ForumTest < ActiveSupport::TestCase
  test 'forum hierarchy' do
    assert_equal forums(:cars).forums, [forums(:na), forums(:hybrids), forums(:electric)]
    assert_includes forums(:hybrids).forums, forums(:prius)
    assert_includes forums(:electric).forums, forums(:model_s)
    assert_equal forums(:model_s).forums, [forums(:model_s_2014), forums(:model_s_2015)]
  end

  test 'to_s returns title' do
    assert_equal forums(:cars).to_s, forums(:cars).title
  end

  test 'topic_count returns count of nested topics' do
    assert_equal forums(:cars).topic_count, forums(:cars).topics.count
  end

  test 'self_and_descendents returns the forum and all children of any depth' do
    assert_equal forums(:cars).self_and_descendents.count, Forum.count
    assert_equal forums(:model_s).self_and_descendents.count, 3
    assert_equal forums(:model_s_2015).self_and_descendents.count, 1
  end

  test 'self_and_desc_topic_count returns num of topics in forum and all children' do
    assert_equal forums(:cars).self_and_desc_topic_count, Topic.count
    assert_equal forums(:model_s).self_and_desc_topic_count, 3
    assert_equal forums(:model_s_2015).self_and_desc_topic_count, 1
  end

  test 'post_count returns num of posts in the forum' do
    assert_equal forums(:cars).post_count, 2
  end

  test 'self_and_desc_post_count returns num of posts in forum and all children' do
    assert_equal forums(:cars).self_and_desc_post_count, Post.count
    assert_equal forums(:model_s).self_and_desc_post_count, 6
    assert_equal forums(:model_s_2015).self_and_desc_post_count, 2
  end

  test 'last_topic returns the last topic created in the forum' do
    topic = Topic.where(forum: forums(:cars)).order(created_at: :desc).first
    assert_equal forums(:cars).last_topic, topic
  end

  test 'last_post_in_last_topic returns the last post in the last topic created in the forum' do
    post = forums(:cars).last_topic.posts.order(created_at: :desc).first
    assert_equal forums(:cars).last_post_in_last_topic, post
  end

  # test 'tree_sql_for returns SQL to get forum and all children' do
  # end

  test 'tree_for scope returns forum and all children' do
    assert_equal Forum.tree_for(forums(:cars)).count, Forum.count
  end
end
