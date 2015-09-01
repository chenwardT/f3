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

  it "returns the permission set for a given forum" do
    forum = FactoryGirl.create(:forum)

    group.permissions_for(forum).must_equal ForumPermission.find_by(group: group, forum: forum)
  end

  describe "handles associated forum permission sets" do
    let(:forum) { FactoryGirl.create(:forum) }

    it "creates a set of forum permissions on creation of itself" do
      value do
        3.times { FactoryGirl.create(:group) }
      end.must_change "ForumPermission.where(forum: forum).count", 3
    end

    it "destroys associated forum permissions on destruction of itself" do
      value do
        # TODO: Cleanup when cascading deletion implemented.
        group.users.each { |user| user.groups.delete(group) }
        group.destroy
      end.must_change "ForumPermission.where(forum: forum).count", -1
    end
  end
end
