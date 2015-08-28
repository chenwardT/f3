require "test_helper"

describe ForumPermission do
  let(:group) { FactoryGirl.create(:group, name: 'some group') }
  let(:forum_1) { FactoryGirl.create(:forum, title: 'root forum') }
  let(:forum_2) { FactoryGirl.create(:forum, title: 'forum 2', forum: forum_1) }
  let(:forum_3) { FactoryGirl.create(:forum, title: 'forum 3', forum: forum_2) }
  let(:fp_1) { ForumPermission.find_by(forum: forum_1, group: group) }
  let(:fp_2) { ForumPermission.find_by(forum: forum_2, group: group) }
  let(:fp_3) { ForumPermission.find_by(forum: forum_3, group: group) }

  it "must display the forum and group" do
    fp_1.to_s.must_equal 'root forum: some group'
  end

  it "must get the effective permissions" do
    fp_3.effective_permissions.must_equal group

    fp_1.update_attribute(:inherit, false)

    fp_3.effective_permissions.must_equal fp_1
  end
end
