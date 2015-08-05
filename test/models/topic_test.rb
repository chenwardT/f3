require 'test_helper'

class TopicTest < ActiveSupport::TestCase
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

  test 'to_s returns title' do
    assert_equal @top_topic.title, @top_topic.to_s
  end

  test 'reply_count returns number of replies in topic' do
    assert_equal @top_topic.posts.count - 1, @top_topic.reply_count
  end

  test 'last_post returns last post created in topic' do
    assert_equal Post.where(topic: @top_topic).order(created_at: :desc).first, @top_topic.last_post
  end

  test 'ordered_posts returns posts in chronological order by creation time' do
    sleep(0.1)
    FactoryGirl.create(:post, user: @user, topic: @top_topic)
    assert @top_topic.ordered_posts.first.created_at < @top_topic.ordered_posts.last.created_at
  end

  test 'num_pages returns the number of pages for a given post' do
    assert_equal 1, @top_topic.num_pages

    assert_difference('@top_topic.reload.num_pages', 1) do
      POSTS_PER_PAGE.times do
        FactoryGirl.create(:post, user: @user, topic: @top_topic)
      end
    end
  end
end
