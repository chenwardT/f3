require 'test_helper'

class ViewTest < ActiveSupport::TestCase
  test 'viewed_at returns updated_at' do
    topic = Topic.first
    view = View.create!(user: users(:alice), viewable: topic, viewable_type: topic.class)

    assert_equal view.viewed_at, view.updated_at
  end

  test 'view times are set during creation' do
    topic = Topic.first
    view = View.create!(user: users(:alice), viewable: topic, viewable_type: topic.class)

    assert_not_nil view.current_viewed_at
    assert_not_nil view.past_viewed_at
  end
end
