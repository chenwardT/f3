require 'test_helper'

describe ForumsController do
  let(:forum) { Forum.first }
  let(:user) { create(:user) }

  let(:full_perms) do
    create(:group, Group.permission_fields.map { |field| [field, true] }.to_h)
  end

  let (:no_perms) do
    create(:group, Group.permission_fields.map { |field| [field, false] }.to_h)
  end

  before do
    3.times { create(:forum) }
  end

  describe "GET :index" do
    describe "with permssion" do
      before do
        user.groups << full_perms
        get :index
      end

      it "renders forums/index" do
        must_render_template "forums/index"
      end

      it "responds with success" do
        must_respond_with :success
      end

      it "includes all top-level forums" do
        assigns(:top_level_forums).count.must_equal 3
      end
    end

    # TODO: Write this once filtering by permissions on index for user is implemented.
    # describe "without permission" do
    # end
  end

  describe "GET :show" do
    describe "with permission" do
      let(:forum) { create(:forum) }
      let(:user) { create(:user) }

      before do
        user.groups << full_perms
        sign_in user
        get :show, { id: forum.id }
      end

      # TODO: Why is this seeing views_count == 2 after supposedly being viewed once?
      it "registers a global view" do
        forum.reload.views_count.wont_equal 0
      end

      it "registers a user-specific view" do
        forum.reload.view_for(user).count.must_equal 1
      end
    end

    describe "without permission" do
      before do
        user.groups << full_perms
        sign_in user
        full_perms.update_attribute(:view_forum, false)
        get :show, {id: forum.id}
      end

      it "redirects to root" do
        must_redirect_to root_path
      end

      it "doesn't register a global view when no user is logged in" do
        forum.views_count.must_equal 0
      end
    end
  end
end
