require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = FactoryGirl.create(:user)
  end

  test 'user to_s returns username' do
    assert_equal @user.to_s, @user.username
  end

  test 'newest scope should return last created username' do
    @new_user = FactoryGirl.create(:user, username: 'the new guy')
    assert_equal User.newest, @new_user.username
  end
end
