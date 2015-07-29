require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'user to_s returns username' do
    assert_equal users(:tom).to_s, users(:tom).username
  end
end
