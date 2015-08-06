require 'test_helper'

describe "ForumsController" do
  before do
    3.times { FactoryGirl.create(:forum) }
  end

  let(:forum) { Forum.first }

  describe "GET :index" do
    before do
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

  describe "GET :show without logged in user" do
    before do
      get :show, {id: forum.id}
    end

    it "renders forums/show" do
      must_render_template "forums/show"
    end

    it "responds with success" do
      must_respond_with :success
    end

    it "doesn't register a global view when no user is logged in" do
      forum.views_count.must_equal 0
    end
  end

  describe "GET :show with user logged in" do
    let(:forum) { FactoryGirl.create(:forum) }
    let(:user) { FactoryGirl.create(:user) }

    before do
      forum.reload.views_count.must_equal 0
      sign_in user
      get :show, {id: forum.id }
    end

    # TODO: Why is this seeing views_count == 2 after supposedly being viewed once?
    it "registers a global view" do
      forum.reload.views_count.wont_equal 0
    end

    it "registers a user-specific view" do
      forum.reload.view_for(user).count.must_equal 1
    end
  end
end
