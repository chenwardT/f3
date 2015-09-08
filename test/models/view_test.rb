require 'test_helper'

describe View do
  let(:user) { create(:user) }

  let(:top) { create(:forum) }
  let(:top_topic) { create(:topic, forum: top, user: user) }

  it "returns when it was last viewed" do
    view = create(:view, user: user, viewable: top_topic, viewable_type: top_topic.class)

    view.viewed_at.must_equal view.updated_at
  end

  it "sets view times during creation" do
    view = create(:view, user: user, viewable: top_topic, viewable_type: top_topic.class)

    view.current_viewed_at.wont_be_nil
    view.past_viewed_at.wont_be_nil
  end
end
