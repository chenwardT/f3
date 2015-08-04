require 'test_helper'

class ForumTest < ActiveSupport::TestCase
  test 'forum hierarchy' do
    assert_equal [forums(:na), forums(:hybrids), forums(:electric)], forums(:cars).forums
    assert_includes forums(:hybrids).forums, forums(:prius)
    assert_includes forums(:electric).forums, forums(:model_s)
    assert_equal [forums(:model_s_2014), forums(:model_s_2015)], forums(:model_s).forums
  end

  test 'to_s returns title' do
    assert_equal forums(:cars).title, forums(:cars).to_s
  end

  test 'topic_count returns count of nested topics' do
    assert_equal forums(:cars).topics.count, forums(:cars).topic_count
  end

  test 'self_and_descendents returns the forum and all children of any depth' do
    assert_equal Forum.count, forums(:cars).self_and_descendents.count
    assert_equal 3, forums(:model_s).self_and_descendents.count
    assert_equal 1, forums(:model_s_2015).self_and_descendents.count
  end

  test 'self_and_desc_topic_count returns num of topics in forum and all children' do
    assert_equal Topic.count, forums(:cars).self_and_desc_topic_count
    assert_equal 3, forums(:model_s).self_and_desc_topic_count
    assert_equal 1, forums(:model_s_2015).self_and_desc_topic_count
  end

  test 'post_count returns num of posts in the forum' do
    assert_equal 2, forums(:cars).post_count
  end

  test 'self_and_desc_post_count returns num of posts in forum and all children' do
    assert_equal Post.count, forums(:cars).self_and_desc_post_count
    assert_equal 6, forums(:model_s).self_and_desc_post_count
    assert_equal 2, forums(:model_s_2015).self_and_desc_post_count
  end

  test 'last_topic returns the last topic created in the forum' do
    topic = Topic.where(forum: forums(:cars)).order(created_at: :desc).first
    assert_equal topic, forums(:cars).last_topic
  end

  test 'last_post_in_last_topic returns the last post in the last topic created in the forum' do
    post = forums(:cars).last_topic.posts.order(created_at: :desc).first
    assert_equal post, forums(:cars).last_post_in_last_topic
  end

  # test 'tree_sql_for returns SQL to get forum and all children' do
  # end

  test 'tree_for scope returns forum and all children' do
    assert_equal Forum.count, Forum.tree_for(forums(:cars)).count
  end
end
