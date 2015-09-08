require 'test_helper'

describe Topic do
  let(:user) { create(:user) }

  let(:top) { create(:forum) }
  let(:top_topic) { create(:topic, forum: top, user: user) }

  let(:depth1) { create(:forum, forum: top) }
  let(:d1_topic) { create(:topic, forum: depth1, user: user) }

  let(:depth2a) { create(:forum, forum: depth1) }
  let(:d2a_topic) { create(:topic, forum: depth2a, user: user) }

  let(:depth2b) { create(:forum, forum: depth1) }
  let(:d2b_topic) { create(:topic, forum: depth2b, user: user) }

  before do
    [top_topic, d1_topic, d2a_topic, d2b_topic].each do |topic|
      2.times { create(:post, topic: topic, user: user) }
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
    create(:post, topic: top_topic, user: user)

    top_topic.ordered_posts.first.created_at.must_be :<, top_topic.ordered_posts.last.created_at
  end

  it "returns the posts that are visible or deleted" do
    top_topic.visible_posts.count.must_equal 2

    value do
      create(:post, topic: top_topic, user: user, state: :unapproved)
      create(:post, topic: top_topic, user: user, state: :visible)
    end.must_change "top_topic.visible_posts.count"
  end

  it "returns the number of pages it spans" do
    top_topic.num_pages.must_equal 1

    value do
      POST_PER_PAGE.times do
        create(:post, user: user, topic: top_topic)
      end.must_change "top_topic.reload.num_pages"
    end
  end

  it "destroys associated posts on destruction of itself" do
    value { top_topic.destroy }.must_change "Post.where(topic: top_topic).count", -2
  end
end
