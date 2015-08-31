require 'test_helper'

describe Topic do
  let(:user) { FactoryGirl.create(:user) }

  let(:top) { FactoryGirl.create(:forum) }
  let(:top_topic) { FactoryGirl.create(:topic, forum: top, user: user) }

  let(:depth1) { FactoryGirl.create(:forum, forum: top) }
  let(:d1_topic) { FactoryGirl.create(:topic, forum: depth1, user: user) }

  let(:depth2a) { FactoryGirl.create(:forum, forum: depth1) }
  let(:d2a_topic) { FactoryGirl.create(:topic, forum: depth2a, user: user) }

  let(:depth2b) { FactoryGirl.create(:forum, forum: depth1) }
  let(:d2b_topic) { FactoryGirl.create(:topic, forum: depth2b, user: user) }

  before do
    [top_topic, d1_topic, d2a_topic, d2b_topic].each do |topic|
      2.times { FactoryGirl.create(:post, topic: topic, user: user) }
    end
  end

  it "returns the title" do
    top_topic.title.must_equal top_topic.to_s
  end
  
  it "returns the number of replies" do
    top_topic.reply_count.must_equal (top_topic.posts.count - 1)
  end

  it "returns the last post created" do
    top_topic.last_post.must_equal Post.where(topic: top_topic).order(created_at: :desc).first
  end

  it "returns posts in chronological order by creation time" do
    sleep(0.1)
    FactoryGirl.create(:post, topic: top_topic, user: user)

    top_topic.ordered_posts.first.created_at.must_be :<, top_topic.ordered_posts.last.created_at
  end

  it "returns the posts that are visible or deleted" do
    top_topic.visible_posts.count.must_equal 2

    value do
      FactoryGirl.create(:post, topic: top_topic, user: user, state: :unapproved)
      FactoryGirl.create(:post, topic: top_topic, user: user, state: :visible)
    end.must_change "top_topic.visible_posts.count"
  end

  it "returns the number of pages it spans" do
    top_topic.num_pages.must_equal 1

    value do
      POST_PER_PAGE.times do
        FactoryGirl.create(:post, user: user, topic: top_topic)
      end.must_change "top_topic.reload.num_pages"
    end
  end
end
