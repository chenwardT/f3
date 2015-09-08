require 'test_helper'

describe Post do
  include Rails.application.routes.url_helpers

  let(:user) { create(:user) }
  let(:mod) { create(:user) }
  let(:forum) { create(:forum) }
  let(:topic) { create(:topic, forum: forum, user: user) }
  let(:post_1) { create(:post, topic: topic, user: user) }
  let(:post_2) { create(:post, topic: topic, user: user) }
  let(:post_3) { create(:post, topic: topic, user: user) }

  it "updates the topic's last_post_at after post creation" do
    old_ts = topic.last_post_at
    sleep(0.1)
    post = create(:post, topic: topic, user: user)
    new_ts = topic.reload.last_post_at

    old_ts.wont_equal new_ts
    new_ts.to_i.must_equal post.created_at.to_i
  end

  it "can be soft deleted, record the moderating user, and the reason" do
    value do
      Post.soft_delete(ids=[post_2.id, post_3.id], user=mod, reason='low effort post')
    end.must_change "Post.where(state: :deleted).count", 2
    
    deleted = Post.where(state: :deleted)
    
    deleted.first.moderator.must_equal mod
    deleted.first.mod_reason.must_equal 'low effort post'
    deleted.second.moderator.must_equal mod
    deleted.second.mod_reason.must_equal 'low effort post'
  end

  it "can be undeleted, record the moderating user, and the reason" do
    post_ids = [post_2.id, post_3.id]
    Post.where(id: post_ids).update_all(state: :deleted)

    value do
      Post.undelete(ids=post_ids, user=mod)
    end.must_change "Post.where(state: :deleted).count", -2

    undeleted = Post.where(id: post_ids)

    undeleted.first.moderator.must_equal mod
    undeleted.second.moderator.must_equal mod
  end

  it "can be approved, record the moderating user" do
    post_ids = [post_2.id, post_3.id]
    Post.where(id: post_ids).update_all(state: :unapproved)

    value do
      Post.approve(ids=post_ids, user=mod)
    end.must_change "Post.where(state: :unapproved).count", -2

    approved = Post.where(id: post_ids)

    approved.first.moderator.must_equal mod
    approved.second.moderator.must_equal mod
  end

  it "can be unapproved, record the moderating user, and the reason" do
    post_ids = [post_2.id, post_3.id]
    Post.where(id: post_ids).update_all(state: :visible)

    value do
      Post.unapprove(ids=post_ids, user=mod)
    end.must_change "Post.where(state: :unapproved).count", 2

    unapproved = Post.where(id: post_ids)

    unapproved.first.moderator.must_equal mod
    unapproved.second.moderator.must_equal mod
  end

  it "can merge multiple posts into one, set the new author, record the moderating user,
      and the reason" do
    post_ids = [post_2.id, post_3.id]
    merged_body = post_2.body + post_3.body

    value do
      Post.merge(sources=post_ids, destination=post_2.id, author=post_2.author.id,
                 body=merged_body, user=mod, reason='some reason')
    end.must_change "topic.posts.count", -1

    post_2.reload.body.must_equal merged_body
    post_2.author.must_equal post_2.author
    post_2.moderator.must_equal mod
    post_2.mod_reason.must_equal 'some reason'
  end

  it "can move multiple posts to a new topic" do
    post_ids = [post_2.id, post_3.id]
    new_topic = nil

    value do
      new_topic = Post.move(create_topic=true, new_topic_author=mod, post_ids=post_ids,
                            destination_forum_id=forum.id, new_topic_title='some new topic')
    end.must_change "topic.posts.count", -2

    new_topic.author.must_equal mod
    new_topic.forum.must_equal forum
    new_topic.title.must_equal 'some new topic'
    new_topic.posts.sort.must_equal [post_2, post_3].sort
  end

  it "can move multiple posts to an existing topic" do
    post_ids = [post_2.id, post_3.id]
    existing_topic = create(:topic, forum: forum)
    dest_topic = nil

    value do
      dest_topic = Post.move(create_topic=false, new_topic_author=nil, post_ids=post_ids,
                             destination_forum_id=nil, new_topic_title=nil,
                             dest_topic_url=topic_url(existing_topic, host: 'test.com'))
    end.must_change "existing_topic.posts.count", 2

    existing_topic.must_equal dest_topic
    existing_topic.posts.sort.must_equal [post_2, post_3].sort
  end

  it "can copy multiple posts to a new topic" do
    post_ids = [post_2.id, post_3.id]
    new_topic = Post.copy(create_topic=true, new_topic_author=mod, post_ids=post_ids,
                            destination_forum_id=forum.id, new_topic_title='some new topic')

    new_topic.author.must_equal mod
    new_topic.forum.must_equal forum
    new_topic.title.must_equal 'some new topic'
    new_topic.posts.pluck(:body).sort.must_equal Post.where(id: post_ids).pluck(:body).sort
  end

  it "can copy multiple posts to an existing topic" do
    post_ids = [post_2.id, post_3.id]
    existing_topic = create(:topic, forum: forum)
    dest_topic = Post.copy(create_topic=false, new_topic_author=nil, post_ids=post_ids,
                           destination_forum_id=nil, new_topic_title=nil,
                           dest_topic_url=topic_url(existing_topic, host: 'test.com'))

    existing_topic.must_equal dest_topic
    existing_topic.posts.pluck(:body).sort.must_equal Post.where(id: post_ids).pluck(:body).sort
  end

  it "can tell if it's been soft deleted" do
    post = create(:post)

    post.deleted?.must_equal false

    post.update_attribute(:state, :deleted)

    post.deleted?.must_equal true
  end

  it "can tell if it's not approved" do
    post = create(:post)

    post.unapproved?.must_equal false

    post.update_attribute(:state, :unapproved)

    post.unapproved?.must_equal true
  end
end