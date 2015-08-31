require 'test_helper'

describe "PostsController" do
  let(:user) { FactoryGirl.create(:user) }
  let(:forum) { FactoryGirl.create(:forum) }
  let(:topic) { FactoryGirl.create(:topic, forum: forum, user: user)}

  let(:post_params) { FactoryGirl.attributes_for(:post, user: user, topic_id: topic.id) }

  let(:post_params_too_short) do
    FactoryGirl.attributes_for(:post, user: user, topic_id: topic.id, body: 'under10')
  end

  let(:full_perms) do
    FactoryGirl.create(:group, Group.permission_fields.map { |field| [field, true] }.to_h)
  end

  let (:no_perms) do
    FactoryGirl.create(:group, Group.permission_fields.map { |field| [field, false] }.to_h)
  end

  describe "POST :create" do
    describe "with permission" do
      before do
        user.groups << full_perms
        sign_in user
      end

      it "creates the post on the topic" do
        value { post :create, post: post_params }.must_change 'topic.posts.count'
        flash[:success].must_equal "Post successfully created"
        must_redirect_to topic_path(post_params[:topic_id], page: 1)
      end

      it "notifies user of reason for post failure and redirects" do
        post :create, post: post_params_too_short
        flash[:danger].must_equal 'Error posting reply: Body is too short (minimum is 10 characters)'
      end

      describe "when topic has a full page of posts" do
        before do
          POSTS_PER_PAGE.times { FactoryGirl.create(:post, topic: topic, user: user) }
        end

        it "redirects to last page of topic on post creation" do
          post :create, post: post_params
          must_redirect_to topic_path(topic, page: 2)
        end

        it "redirects to last page of topic on failure to create post" do
          FactoryGirl.create(:post, topic: topic, user: user)
          post :create, post: post_params_too_short
          must_redirect_to topic_path(topic, page: 2)
        end
      end
    end

    describe "without permission" do
      before do
        user.groups << full_perms
        sign_in user
        full_perms.update_attribute(:create_post, false)
      end

      it "does not allow the post to be created" do
        value { post :create, post: post_params }.wont_change 'topic.posts.count'
        must_redirect_to root_path
        flash[:danger].must_equal "You are not authorized to do that"
      end
    end
  end

  describe "POST :soft_delete" do
    describe "with permission" do
      let(:post1) { FactoryGirl.create(:post, topic: topic, user: user) }
      let(:post2) { FactoryGirl.create(:post, topic: topic, user: user) }
      let(:post3) { FactoryGirl.create(:post, topic: topic, user: user) }

      before do
        user.groups << full_perms
        sign_in user
      end

      it "soft deletes referenced posts when sent via AJAX post" do
        xhr :post, :soft_delete, ids: [post2.id, post3.id]

        response.content_type.must_equal Mime::JS
        response.body.must_equal "location.reload();"
        Post.where(id: [post2.id, post3.id]).each { |post| post.state.must_equal 'deleted' }
      end

      it "redirects to forum index when not requested via AJAX" do
        post :soft_delete, ids: [post2.id, post3.id]

        must_redirect_to forums_path
      end
    end

    describe "without permission" do
      let(:post1) { FactoryGirl.create(:post, topic: topic, user: user) }
      let(:post2) { FactoryGirl.create(:post, topic: topic, user: user) }
      let(:post3) { FactoryGirl.create(:post, topic: topic, user: user) }

      before do
        user.groups << full_perms
        sign_in user
        full_perms.update_attributes(soft_delete_own_post: false, soft_delete_any_post: false)
      end

      it "redirects to forum index and displays error in flash" do
        xhr :post, :soft_delete, ids: [post1.id, post2.id]

        response.content_type.must_equal Mime::JS
        response.body.must_equal "location.reload();"
        flash[:danger].must_equal 'You are not authorized to do that'
      end
    end
  end

  describe "POST :undelete" do
    let(:post1) { FactoryGirl.create(:post, topic: topic, user: user, state: 'deleted') }
    let(:post2) { FactoryGirl.create(:post, topic: topic, user: user, state: 'deleted') }
    let(:post3) { FactoryGirl.create(:post, topic: topic, user: user, state: 'unapproved')}

    describe "with permission" do
      before do
        user.groups << full_perms
        sign_in user
      end

      it "sets state to visible on all soft deleted posts" do
        xhr :post, :undelete, ids: [post1.id, post2.id]

        must_render_template nil
        post1.reload.state.must_equal 'visible'
        post2.reload.state.must_equal 'visible'
      end

      it "does not touch state of posts that weren't soft deleted" do
        xhr :post, :undelete, ids: [post1.id, post3.id]

        must_render_template nil
        post1.reload.state.must_equal 'visible'
        post3.reload.state.must_equal 'unapproved'
      end
    end

    describe "without permission" do
      before do
        user.groups << full_perms
        sign_in user
        full_perms.update_attributes(soft_delete_own_post: false, soft_delete_any_post: false)
      end

      it "responds with JS page reload and displays error in flash" do
        xhr :post, :undelete, ids: [post1.id, post2.id]

        post1.reload.state.must_equal 'deleted'
        post2.reload.state.must_equal 'deleted'
        response.content_type.must_equal Mime::JS
        response.body.must_equal "location.reload();"
        flash[:danger].must_equal 'You are not authorized to do that'
      end
    end
  end
end
