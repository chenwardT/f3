require 'test_helper'

describe Forum do
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

  it "is created with the correct hierarchy" do
    top.forums.must_include depth1
    depth1.forums.must_include depth2a
    depth1.forums.must_include depth2b
    depth1.forums.must_equal [depth2a, depth2b]
  end

  it "returns the title" do
    top.to_s.must_equal top.title
  end

  it "returns the permission set for a given forum" do
    group = create(:group)

    top.permissions_for(group).must_equal ForumPermission.find_by(group: group, forum: top)
  end

  it "returns a count of the nested topics" do
    top.topic_count.must_equal top.topics.count
  end

  it "returns itself and all children of any depth" do
    top.self_and_descendents.count.must_equal Forum.count
    depth1.self_and_descendents.count.must_equal 3
    depth2b.self_and_descendents.count.must_equal 1
  end

  it "returns a count of topics in itself and all children of any depth" do
    top.self_and_desc_topic_count.must_equal Topic.count
    depth1.self_and_desc_topic_count.must_equal 3
    depth2b.self_and_desc_topic_count.must_equal 1
  end

  it "returns a count of the posts in itself" do
    top.post_count.must_equal 2
  end

  it "returns a count of posts in itself and all children of any depth" do
    top.self_and_desc_post_count.must_equal Post.count
    depth1.self_and_desc_post_count.must_equal 6
    depth2b.self_and_desc_post_count.must_equal 2
  end

  it "returns the last topic posted to itself and all children of any depth" do
    sleep(0.1)
    topic = create(:topic, forum: depth1, user: user)
    create(:post, topic: topic, user: user)

    newest_topic = Topic.where(forum: top.self_and_descendents).order(created_at: :desc).first
    top.last_topic.must_equal newest_topic
  end

  it "returns the last post in the last topic created in itself" do
    sleep(0.1)
    topic = create(:topic, forum: depth1, user: user)
    create(:post, topic: topic, user: user)

    newest_post = top.last_topic.posts.order(created_at: :desc).first
    top.last_post_in_last_topic.must_equal newest_post
  end

  describe "handling of associated permission sets" do
    before do
      3.times { create(:group) }
    end

    it "creates a set of permissions for each group on creation of itself" do
      new_forum = create(:forum)
      new_forum.forum_permissions.count.must_equal 3
    end

    it "destroys all associated forum permissions, forums, and topics on destruction of itself" do
      value { depth2b.destroy }.must_change "ForumPermission.where(forum: depth2b).count", -3
      value { depth2a.destroy }.must_change "Topic.where(forum: depth2a).count", -1
      value { top.destroy }.must_change "Forum.where(parent: top).count", -1
    end
  end
end