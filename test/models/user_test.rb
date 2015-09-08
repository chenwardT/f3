require 'test_helper'

describe User do
  let(:user) { create(:user) }
  let(:group) { create(:group) }
  let(:forum_1) { create(:forum) }
  let(:forum_2) { create(:forum, forum: forum_1) }

  before do
    user.groups << group
  end

  it "returns the username" do
    user.to_s.must_equal user.username
  end

  it "can be scoped by creation date, ascending" do
    new_user = create(:user)
    User.newest.must_equal new_user.username
  end

  it "returns populated profile fields" do
    user.profile_fields.sort.must_equal [:country, :bio, :quote, :website, :signature].sort
  end

  it "checks permission given an action and a forum" do
    fp = ForumPermission.find_by(forum: forum_2, group: group)
    fp.update_attributes(inherit: false, view_forum: false)

    user.able_to?(:view_forum, forum_2).must_equal false

    fp.update_attribute(:view_forum, true)

    user.able_to?(:view_forum, forum_2).must_equal true
  end

  it "returns whether it's an admin" do
    user.is_admin?.must_equal false

    user.groups.first.update_attribute(:admin, true)

    user.is_admin?.must_equal true
  end

  it "returns whether it's a guest" do
    create(:group, name: 'guest')

    user.is_guest?.must_equal false

    user.groups.delete_all
    user.groups << Group.guest

    user.is_guest?.must_equal true
  end
end
