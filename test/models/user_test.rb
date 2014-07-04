require 'test_helper'

class UserDouble < User
  def self.summaries(ids)
    @results
  end

  def self.summary_results=(results)
    @results = results
  end
end

class UserTest < ActiveSupport::TestCase

  test "determine missing userids" do
    assert_equal [4321], User.missing_users([1234, 4321])
  end

  test "retrieving users from steam" do
    user = User.new(
      uid: 4321,
      image: 'https://image.com/image.png',
      nickname: 'The Humble Sausage'
    )
    UserDouble.summary_results = [
      {
        'steamid' => 4321,
        'avatar' => 'https://image.com/image.png',
        'personaname' => 'The Humble Sausage'
      }
    ]
    steam_users = UserDouble.steam_users([4321])
    assert_equal 1, steam_users.length
    steam_user = steam_users.first
    assert_equal user.uid, steam_user.uid
    assert_equal user.image, steam_user.image
    assert_equal user.nickname, steam_user.nickname
  end
end
