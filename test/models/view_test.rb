require 'test_helper'

describe View do
  let(:user) { FactoryGirl.create(:user) }

  let(:top) { FactoryGirl.create(:forum) }
  let(:top_topic) { FactoryGirl.create(:topic, forum: top, user: user) }

  it "returns when it was last viewed" do
    view = FactoryGirl.create(:view, user: user, viewable: top_topic, viewable_type: top_topic.class)

    view.viewed_at.must_equal view.updated_at
  end

  it "sets view times during creation" do
    view = FactoryGirl.create(:view, user: user, viewable: top_topic, viewable_type: top_topic.class)

    view.current_viewed_at.wont_be_nil
    view.past_viewed_at.wont_be_nil
  end
end
