require 'test_helper'

class ViewableTest < ActiveSupport::TestCase
  def setup
    @user = FactoryGirl.create(:user)

    @top = FactoryGirl.create(:forum)
    @top_topic = FactoryGirl.create(:topic, forum: @top, user: @user)
    FactoryGirl.create(:post, topic: @top_topic, user: @user)
    FactoryGirl.create(:post, topic: @top_topic, user: @user)
  end

  test 'view_for a topic returns num of times a user viewed the topic' do
    assert_nil @top_topic.view_for(@user)

    @top_topic.register_view_by(@user)
    assert_equal 1, @top_topic.view_for(@user).count
  end

  test 'register_view_by increments counters and updates times' do
    assert_nil @top_topic.view_for(@user)

    # Create View instance
    @top_topic.register_view_by(@user)

    # Global view count increment
    assert_difference('@top_topic.views_count', 1) do
      @top_topic.register_view_by(@user)
    end

    # User-specific view count increment
    assert_difference('@top_topic.view_for(@user).count', 1) do
      @top_topic.register_view_by(@user)
    end

    assert_no_difference('@top_topic.view_for(@user).current_viewed_at') do
      @top_topic.register_view_by(@user)
    end
  end

  test 'register_view_by does nothing if no user is supplied' do
    assert_nil @top_topic.view_for(@user)

    assert_no_difference('View.count') do
      @top_topic.register_view_by(nil)
    end

    assert_nil @top_topic.views_count
  end
end

# FIXME: Module specs not working: must be run within a transaction (register_spec_type?)
# and some spec methods not being recognized (must_change, wont_change).

# describe Viewable do
#   let(:user) { FactoryGirl.create(:user) }
#
#   let(:top) { FactoryGirl.create(:forum) }
#   let(:top_topic) { FactoryGirl.create(:topic, forum: top, user: user) }
#
#   before do
#     FactoryGirl.create(:post, topic: top_topic, user: user)
#     FactoryGirl.create(:post, topic: top_topic, user: user)
#   end
#
#   it "returns the number of times a user viewed itself" do
#     top_topic.view_for(user).must_be_nil
#
#     top_topic.register_view_by(user)
#
#     top_topic.view_for(user).count.must_equal 1
#   end
#
#   it "can increment view counter and update times" do
#     top_topic.view_for(user).must_be_nil
#
#     top_topic.register_view_by(user)
#
#     value do
#       top_topic.register_view_by(user)
#     end.must_change "top_topic.views_count"
#
#     # User-specific view count increment
#     value do
#       top_topic.register_view_by(user)
#     end.must_change "top_topic.view_for(user).count"
#
#     value do
#       top_topic.register_view_by(user)
#     end.must_change "top_topic.view_for(user).current_viewed_at"
#   end
#
#   it "doesn't register a view if no user is supplied" do
#     top_topic.view_for(user).must_be_nil
#
#     value do
#       top_topic.register_view_by(nil)
#     end.wont_change "View.count"
#
#     top_topic.views_count.must_be_nil
#   end
# end