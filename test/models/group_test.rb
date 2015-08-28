require 'test_helper'

describe Group do
  let(:group) { FactoryGirl.create(:group, name: 'some name') }

  before do
    3.times do
      user = FactoryGirl.create(:user)
      user.groups << group
    end
  end

  it "returns the group's name" do
    group.to_s.must_equal 'some name'
  end

  it "returns the count of users in the group" do
    group.user_count.must_equal 3
  end
end
