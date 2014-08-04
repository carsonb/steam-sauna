require 'test_helper'

module Remote
  class AgeCheckRedirectionTest < Remote::Test

    test "it should be able to get around the age check wall" do
      response = RestClient.get('http://store.steampowered.com/app/33900/')
      age_check = SteamAgeCheck.new(response.body)
      assert age_check.present?

      other_check = SteamAgeCheck.new(age_check.fill_and_submit)
      refute other_check.present?
    end
  end
end
