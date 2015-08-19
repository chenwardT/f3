require "test_helper"

describe ForumPermission do
  let(:forum_permission) { ForumPermission.new }

  it "must be valid" do
    value(forum_permission).must_be :valid?
  end
end
