require 'test_helper'

class ViewTest < ActiveSupport::TestCase
  def setup
    @user = FactoryGirl.create(:user)

    @top = FactoryGirl.create(:forum)
    @top_topic = FactoryGirl.create(:topic, forum: @top, user: @user)
  end

  test 'viewed_at returns updated_at' do
    view = FactoryGirl.create(:view, user: @user, viewable: @top_topic, viewable_type: @top_topic.class)

    assert_equal view.viewed_at, view.updated_at
  end

  test 'view times are set during creation' do
    view = FactoryGirl.create(:view, user: @user, viewable: @top_topic, viewable_type: @top_topic.class)

    assert_not_nil view.current_viewed_at
    assert_not_nil view.past_viewed_at
  end
end
