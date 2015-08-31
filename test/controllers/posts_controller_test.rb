require 'test_helper'

# TODO: Permission specs for delete, etc on any vs own
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

  describe "POST :approve" do
    let(:approved_post) { FactoryGirl.create(:post, topic: topic, user: user) }
    let(:unapproved_post) { FactoryGirl.create(:post, topic: topic, user: user, state: :unapproved) }

    describe "with permission" do
      before do
        user.groups << full_perms
        sign_in user
      end

      it "approves the posts that are unapproved" do
        xhr :post, :approve, { ids: [approved_post.id, unapproved_post.id] }
        unapproved_post.reload.state.must_equal 'visible'
      end
    end

    describe "without permission" do
      before do
        user.groups << full_perms
        sign_in user
        full_perms.update_attribute(:moderate_any_forum, false)
      end

      it "reloads the page and displays a warning" do
        xhr :post, :approve, { ids: [approved_post.id, unapproved_post.id] }
        unapproved_post.reload.state.must_equal 'unapproved'
        response.content_type.must_equal Mime::JS
        response.body.must_equal "location.reload();"
        flash[:danger].must_equal 'You are not authorized to do that'
      end
    end
  end

  describe "POST :unapprove" do
    let(:approved_post) { FactoryGirl.create(:post, topic: topic, user: user) }
    let(:unapproved_post) { FactoryGirl.create(:post, topic: topic, user: user, state: :unapproved) }

    describe "with permission" do
      before do
        user.groups << full_perms
        sign_in user
      end

      it "unapproves the posts that are approved" do
        xhr :post, :unapprove, { ids: [approved_post.id, unapproved_post.id] }
        approved_post.reload.state.must_equal 'unapproved'
      end
    end

    describe "without permission" do
      before do
        user.groups << full_perms
        sign_in user
        full_perms.update_attribute(:moderate_any_forum, false)
      end

      it "reloads the page and displays a warning" do
        xhr :post, :unapprove, { ids: [approved_post.id, unapproved_post.id] }
        approved_post.reload.state.must_equal 'visible'
        response.content_type.must_equal Mime::JS
        response.body.must_equal "location.reload();"
        flash[:danger].must_equal 'You are not authorized to do that'
      end
    end
  end

  describe "POST :hard_delete" do
    let(:post1) { FactoryGirl.create(:post, topic: topic, user: user) }
    let(:post2) { FactoryGirl.create(:post, topic: topic, user: user) }

    describe "with permission" do
      before do
        user.groups << full_perms
        sign_in user
      end

      it "hard deletes the posts" do
        xhr :post, :hard_delete, ids: [post1.id, post2.id]

        Post.where(id: [post1.id, post2.id]).must_be_empty
      end
    end

    describe "without permission" do
      before do
        user.groups << full_perms
        sign_in user
        full_perms.update_attributes(hard_delete_own_post: false, hard_delete_any_post: false)
      end

      it "reloads the page and displays a warning" do
        xhr :post, :hard_delete, { ids: [post1.id, post2.id] }
        Post.where(id: [post1.id, post2.id]).wont_be_empty
        response.content_type.must_equal Mime::JS
        response.body.must_equal "location.reload();"
        flash[:danger].must_equal 'You are not authorized to do that'
      end
    end
  end

  describe "POST :merge" do
    let(:post1) { FactoryGirl.create(:post, topic: topic, user: user) }
    let(:user2) { FactoryGirl.create(:user) }
    let(:post2) { FactoryGirl.create(:post, topic: topic, user: user2) }

    describe "with permission" do
      before do
        user.groups << full_perms
        sign_in user
      end

      it "merges the posts into the selected destination post, setting the author" do
        expected_body = post1.body + post2.body

        value do
          xhr :post, :merge, { sources: [post1.id, post2.id], destination: post1.id,
                               author: post2.author, body: post1.body + post2.body}
        end.must_change "topic.posts.count", -1

        Post.where(id: post2.id).must_be_empty
        post1.reload.body.must_equal expected_body
        post1.author.must_equal post2.author
      end
    end

    describe "without permission" do
      before do
        user.groups << full_perms
        sign_in user
        full_perms.update_attribute(:moderate_any_forum, false)
      end

      it "reloads the page and displays a warning" do
        xhr :post, :merge, { sources: [post1.id, post2.id], destination: post1.id,
                             author: post2.author, body: post1.body + post2.body}

        Post.where(id: [post1.id, post2.id]).count.must_equal 2
        response.content_type.must_equal Mime::JS
        response.body.must_equal "location.reload();"
        flash[:danger].must_equal 'You are not authorized to do that'
      end
    end
  end

  describe "POST :move" do
    describe "with permission" do

    end

    describe "without permission" do

    end
  end

  describe "POST :copy" do
    describe "with permission" do

    end

    describe "without permission" do

    end
  end
end
