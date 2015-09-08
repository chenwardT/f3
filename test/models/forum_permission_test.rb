require "test_helper"

describe ForumPermission do
  let(:group) { create(:group, name: 'some group') }
  let(:forum_1) { create(:forum, title: 'root forum') }
  let(:forum_2) { create(:forum, title: 'forum 2', forum: forum_1) }
  let(:forum_3) { create(:forum, title: 'forum 3', forum: forum_2) }
  let(:fp_1) { ForumPermission.find_by(forum: forum_1, group: group) }
  let(:fp_2) { ForumPermission.find_by(forum: forum_2, group: group) }
  let(:fp_3) { ForumPermission.find_by(forum: forum_3, group: group) }

  it "displays the forum and group" do
    fp_1.to_s.must_equal 'root forum: some group'
  end

  describe "permission inheritance" do
    it "uses its own permissions when it isn't set to inherit" do
      fp_3.update_attribute(:inherit, false)

      fp_3.effective_permissions.must_equal fp_3
    end

    it "uses the permissions of the closest parent forum that isn't set to inherit" do
      fp_1.update_attribute(:inherit, false)

      fp_3.effective_permissions.must_equal fp_1
    end

    it "uses the group's permissions when inheriting through the root forum" do
      fp_3.effective_permissions.must_equal group
    end
  end
end
