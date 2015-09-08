require 'test_helper'

describe TopicsController do
  let(:user) { create(:user) }

  let(:forum) { create(:forum) }
  let(:topic) { create(:topic, forum: forum, user: user) }
  let(:post1) { create(:post1, topic: topic, user: user) }

  let(:full_perms) do
    create(:group, Group.permission_fields.map { |field| [field, true] }.to_h)
  end

  let (:no_perms) do
    create(:group, Group.permission_fields.map { |field| [field, false] }.to_h)
  end

  describe "GET :show" do
    describe "with moderator permission" do
      before do
        user.groups << full_perms
        sign_in user
        get :show, { id: topic.id }
      end

      it "generates moderation data" do
        assigns(:forum_list).wont_be_nil
      end
    end

    describe "with non-moderator permission" do
      before do
        full_perms.update_attribute(:moderate_any_forum, false)
        user.groups << full_perms
        sign_in user
        get :show, { id: topic.id }
      end

      it "displays the topic and registers a view" do
        assigns(:topic).must_equal topic
        topic.view_for(user).count.must_equal 1
        must_render_template "topics/show"
      end

      it "prepares a post for replying" do
        assigns(:post).topic.must_equal topic
      end

      it "does not generate moderation data" do
        assigns(:forum_list).must_be_nil
      end
    end

    describe "without permission" do
      before do
        full_perms.update_attribute(:view_topic, false)
        user.groups << full_perms
        sign_in user
        get :show, { id: topic.id }
      end

      it "redirects and displays a warning" do
        flash[:danger].must_equal NOT_AUTHORIZED_MSG
        must_redirect_to root_path
      end
    end
  end

  describe "GET :new" do
    describe "with permission" do
      before do
        user.groups << full_perms
        sign_in user
        get :new, { forum: forum.id }
      end

      it "displays the new topic form" do
        assigns(:topic).author.must_equal user
        assigns(:topic).forum_id.must_equal forum.id
        must_render_template 'topics/new'
      end
    end

    describe "without permission" do
      before do
        full_perms.update_attribute(:create_topic, false)
        user.groups << full_perms
        sign_in user
        get :new, { forum: forum.id }
      end

      it "redirects and displays an error" do
        flash[:danger].must_equal NOT_AUTHORIZED_MSG
        must_redirect_to root_path
      end
    end
  end

  describe "POST :create" do
    describe "with permission" do
      before do
        user.groups << full_perms
        sign_in user
      end

      it "saves the topic, notifies the user of success, and redirects to it" do
        value do
          post :create, { topic: {title: 'some title', forum_id: forum.id},
                          post: {body: 'a quality poast'} }
        end.must_change "Topic.count"

        flash[:success].must_equal 'New topic created'
        must_redirect_to topic_path(assigns(:topic))
      end
    end

    describe "without permission" do
      before do
        full_perms.update_attribute(:create_topic, false)
        user.groups << full_perms
        sign_in user
      end

      it "redirects and displays an error" do
        value do
          post :create, { topic: {title: 'some title', forum_id: forum.id},
                          post: {body: 'a quality poast'} }
        end.wont_change "Topic.count"

        flash[:danger].must_equal NOT_AUTHORIZED_MSG
        must_redirect_to root_path
      end
    end
  end
end
