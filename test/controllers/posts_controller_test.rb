require 'test_helper'

# TODO: Permission specs for delete, etc on any vs own
describe "PostsController" do
  let(:user) { create(:user) }
  let(:forum) { create(:forum) }
  let(:topic) { create(:topic, forum: forum, user: user)}

  let(:post_params) { FactoryGirl.attributes_for(:post, user: user, topic_id: topic.id) }

  let(:post_params_too_short) do
    FactoryGirl.attributes_for(:post, user: user, topic_id: topic.id, body: 'under10')
  end

  let(:full_perms) do
    create(:group, Group.permission_fields.map { |field| [field, true] }.to_h)
  end

  let (:no_perms) do
    create(:group, Group.permission_fields.map { |field| [field, false] }.to_h)
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
          POSTS_PER_PAGE.times { create(:post, topic: topic, user: user) }
        end

        it "redirects to last page of topic on post creation" do
          post :create, post: post_params
          must_redirect_to topic_path(topic, page: 2)
        end

        it "redirects to last page of topic on failure to create post" do
          create(:post, topic: topic, user: user)
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
        flash[:danger].must_equal NOT_AUTHORIZED_MSG
      end
    end
  end

  describe "POST :update" do
    let(:post1) { create(:post, topic: topic, user: user) }

    describe "with permission" do
      before do
        user.groups << full_perms
        sign_in user
      end

      it "allows editing by user if user is the author and can edit their own posts" do
        full_perms.update_attribute(:edit_any_post, false)
        xhr :post, :update, id: post1.id, body: 'new body 10char', post: { topic_id: post1.topic.id }

        post1.reload.body.must_equal 'new body 10char'
      end

      it "allows editing by any user that can edit any post" do
        not_the_owner = create(:user)
        post1.update_attribute(:user, not_the_owner)
        xhr :post, :update, id: post1.id, body: 'new body 10char', post: { topic_id: post1.topic.id }

        post1.reload.body.must_equal 'new body 10char'
      end
    end

    describe "without permission" do
      before do
        user.groups << full_perms
        sign_in user
        full_perms.update_attributes(edit_own_post: false, edit_any_post: false)
      end

      it "does not allow the post to be edited" do
        xhr :post, :update, id: post1.id, body: 'new body 10char', post: { topic_id: post1.topic.id }

        response.content_type.must_equal Mime::JS
        response.body.must_equal "location.reload();"
        flash[:danger].must_equal NOT_AUTHORIZED_MSG
      end
    end
  end

  describe "POST :soft_delete" do
    describe "with permission" do
      let(:post1) { create(:post, topic: topic, user: user) }
      let(:post2) { create(:post, topic: topic, user: user) }
      let(:post3) { create(:post, topic: topic, user: user) }

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
      let(:post1) { create(:post, topic: topic, user: user) }
      let(:post2) { create(:post, topic: topic, user: user) }
      let(:post3) { create(:post, topic: topic, user: user) }

      before do
        user.groups << full_perms
        sign_in user
        full_perms.update_attributes(soft_delete_own_post: false, soft_delete_any_post: false)
      end

      it "redirects to forum index and displays error in flash" do
        xhr :post, :soft_delete, ids: [post1.id, post2.id]

        response.content_type.must_equal Mime::JS
        response.body.must_equal "location.reload();"
        flash[:danger].must_equal NOT_AUTHORIZED_MSG
      end
    end
  end

  describe "POST :undelete" do
    let(:post1) { create(:post, topic: topic, user: user, state: 'deleted') }
    let(:post2) { create(:post, topic: topic, user: user, state: 'deleted') }
    let(:post3) { create(:post, topic: topic, user: user, state: 'unapproved')}

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
        flash[:danger].must_equal NOT_AUTHORIZED_MSG
      end
    end
  end

  describe "POST :approve" do
    let(:approved_post) { create(:post, topic: topic, user: user) }
    let(:unapproved_post) { create(:post, topic: topic, user: user, state: :unapproved) }

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
        flash[:danger].must_equal NOT_AUTHORIZED_MSG
      end
    end
  end

  describe "POST :unapprove" do
    let(:approved_post) { create(:post, topic: topic, user: user) }
    let(:unapproved_post) { create(:post, topic: topic, user: user, state: :unapproved) }

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
        flash[:danger].must_equal NOT_AUTHORIZED_MSG
      end
    end
  end

  describe "POST :hard_delete" do
    let(:post1) { create(:post, topic: topic, user: user) }
    let(:post2) { create(:post, topic: topic, user: user) }

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
        flash[:danger].must_equal NOT_AUTHORIZED_MSG
      end
    end
  end

  describe "POST :merge" do
    let(:post1) { create(:post, topic: topic, user: user) }
    let(:user2) { create(:user) }
    let(:post2) { create(:post, topic: topic, user: user2) }

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
        flash[:danger].must_equal NOT_AUTHORIZED_MSG
      end
    end
  end

  describe "POST :move" do
    let(:post1) { create(:post, topic: topic, user: user) }
    let(:post2) { create(:post, topic: topic, user: user) }

    describe "with permission" do
      before do
        user.groups << full_perms
        sign_in user
      end

      it "moves the posts to a new topic with a specified title and forum" do
        old_topic_for_post1 = post1.topic
        xhr :post, :move, { post_ids: [post1.id, post2.id], create_topic: 'true',
                            destination_forum_id: forum.id, new_topic_title: 'moved here' }

        old_topic_for_post1.posts.must_be_empty
        post1.reload.topic.wont_equal old_topic_for_post1
        post1.topic.must_equal post2.reload.topic
        post1.topic.title.must_equal 'moved here'
        post1.topic.forum.must_equal forum
      end

      it "moves the posts to an existing topic given by an url" do
        existing_topic = create(:topic)
        old_topic_for_post1 = post1.topic
        xhr :post, :move, { post_ids: [post1.id, post2.id], create_topic: "false",
                            url: topic_url(existing_topic) }

        old_topic_for_post1.posts.must_be_empty
        post1.reload.topic.wont_equal old_topic_for_post1
        post1.topic.must_equal post2.reload.topic
        topic_url(post1.topic).must_equal topic_url(existing_topic)
      end
    end

    describe "without permission" do
      before do
        user.groups << full_perms
        sign_in user
        full_perms.update_attributes(moderate_any_forum: false, copy_or_move_any_post: false)
      end

      it "reloads the page and displays a warning" do
        value do
          xhr :post, :move, { post_ids: [post1.id, post2.id], create_topic: 'true',
                              destination_forum_id: forum.id, new_topic_title: 'moved here' }
        end.wont_change "post1.topic.id"

        response.content_type.must_equal Mime::JS
        response.body.must_equal "location.reload();"
        flash[:danger].must_equal NOT_AUTHORIZED_MSG
      end
    end
  end

  describe "POST :copy" do
    let(:post1) { create(:post, topic: topic, user: user) }
    let(:post2) { create(:post, topic: topic, user: user) }

    describe "with permission" do
      before do
        user.groups << full_perms
        sign_in user
      end

      it "copies the posts to a new topic with a specified title and forum" do
        old_topic_for_post1 = post1.topic
        xhr :post, :copy, { post_ids: [post1.id, post2.id], create_topic: 'true',
                            destination_forum_id: forum.id, new_topic_title: 'copied here' }

        Topic.find_by(title: 'copied here').posts.count.must_equal 2
        old_topic_for_post1.posts.wont_be_empty
      end

      it "copies the posts to an existing topic given by an url" do
        existing_topic = create(:topic)
        old_topic_for_post1 = post1.topic

        value do
          xhr :post, :copy, { post_ids: [post1.id, post2.id], create_topic: "false",
                              url: topic_url(existing_topic) }
        end.must_change "existing_topic.posts.count", 2

        old_topic_for_post1.posts.wont_be_empty
      end
    end

    describe "without permission" do
      before do
        user.groups << full_perms
        sign_in user
        full_perms.update_attributes(moderate_any_forum: false, copy_or_move_any_post: false)
      end

      it "reloads the page and displays a warning" do
        xhr :post, :copy, { post_ids: [post1.id, post2.id], create_topic: 'true',
                            destination_forum_id: forum.id, new_topic_title: 'copied here' }

        Topic.find_by(title: 'copied here').must_be_nil
        response.content_type.must_equal Mime::JS
        response.body.must_equal "location.reload();"
        flash[:danger].must_equal NOT_AUTHORIZED_MSG
      end
    end
  end
end
