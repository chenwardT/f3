require 'test_helper'

describe "PostsController" do
  let(:forum) { FactoryGirl.create(:forum) }
  let(:user) { FactoryGirl.create(:user) }
  let(:topic) { FactoryGirl.create(:topic, forum: forum, user: user)}
  let(:post_params) { FactoryGirl.attributes_for(:post, user: user, topic_id: topic.id) }
  let(:bad_post_params) { FactoryGirl.attributes_for(:post, user: user, topic_id: topic.id, body: 'under10') }

  describe "POST :create" do
    before do
      sign_in user
    end

    it "creates the post on the topic" do
      value { post :create, post: post_params }.must_change 'topic.posts.count'
    end

    describe "when topic has a full page of posts" do
      before do
        15.times { FactoryGirl.create(:post, topic: topic, user: user) }
      end

      it "redirects to last page of topic on post creation" do
        post :create, post: post_params
        must_redirect_to "/topics/#{topic.id}?page=2"
      end
    end

    it "confirms post creation via flash" do
      post :create, post: post_params
      flash[:success].must_equal 'Post successfully created'
    end

    it "redirects to last page of topic on failure to create post" do
      post :create, post: bad_post_params
      must_redirect_to "/topics/#{topic.id}?page=0"
    end

    it "notifies user of post creation failure via flash when invalid" do
      post :create, post: bad_post_params
      flash[:danger].must_equal 'Error posting reply'
    end
  end

  describe "POST :soft_delete" do
    describe "by authorized user" do
      let(:admin_group) { FactoryGirl.create(:group, name: 'admin') }
      let(:admin) { FactoryGirl.create(:user) }
      let(:post1) { FactoryGirl.create(:post, topic: topic, user: user) }
      let(:post2) { FactoryGirl.create(:post, topic: topic, user: user) }

      before do
        admin.groups << admin_group
        admin.save
        sign_in admin
      end

      it "soft deletes referenced posts when sent via AJAX post" do
        xhr :post, :soft_delete, ids: [post1.id, post2.id]

        must_render_template nil
        Post.where(state: 'deleted').count.must_equal 2
      end

      it "redirects to forum index when not requested via AJAX" do
        post :soft_delete, ids: [post1.id, post2.id]

        must_redirect_to forums_path
      end
    end

    describe "by unauthorized user" do
      let(:post1) { FactoryGirl.create(:post, topic: topic, user: user) }
      let(:post2) { FactoryGirl.create(:post, topic: topic, user: user) }

      before do
        sign_in user
      end

      it "redirects to forum index and displays error in flash" do
        xhr :post, :soft_delete, ids: [post1.id, post2.id]

        must_redirect_to forums_path
        flash[:danger].must_equal 'You are not authorized to do that'
      end
    end
  end

  describe "POST :undelete" do
    let(:post1) { FactoryGirl.create(:post, topic: topic, user: user, state: 'deleted') }
    let(:post2) { FactoryGirl.create(:post, topic: topic, user: user, state: 'deleted') }
    let(:post3) { FactoryGirl.create(:post, topic: topic, user: user, state: 'unapproved')}

    describe "by authorized user" do
      let(:admin_group) { FactoryGirl.create(:group, name: 'admin') }
      let(:admin) { FactoryGirl.create(:user) }

      before do
        admin.groups << admin_group
        admin.save
        sign_in admin
      end

      it "sets state to visible on all soft-deleted posts" do
        xhr :post, :undelete, ids: [post1.id, post2.id]

        must_render_template nil
        post1.reload.state.must_equal 'visible'
        post2.reload.state.must_equal 'visible'
      end

      it "does not touch state of posts that weren't soft-deleted" do
        xhr :post, :undelete, ids: [post1.id, post3.id]

        must_render_template nil
        post1.reload.state.must_equal 'visible'
        post3.reload.state.must_equal 'unapproved'
      end
    end

    describe "by unauthorized user" do
      before do
        sign_in user
      end

      it "redirects to forum index and displays error in flash" do
        xhr :post, :undelete, ids: [post1.id, post2.id]

        post1.reload.state.must_equal 'deleted'
        post2.reload.state.must_equal 'deleted'
        must_redirect_to forums_path
        flash[:danger].must_equal 'You are not authorized to do that'
      end
    end
  end
end
