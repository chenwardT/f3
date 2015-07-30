require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'user to_s returns username' do
    assert_equal users(:tom).to_s, users(:tom).username
  end

  test 'newest scope should return last created username' do
    assert_equal User.newest, users(:alice).username
  end
end
