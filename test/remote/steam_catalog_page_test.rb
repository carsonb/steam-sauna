require 'test_helper'

module Remote
  class SteamCatalogPageTest < Remote::Test
    test "making a real HTTP call to the Steam Storefront" do
      Remote::Test::APPS.each do |app_id, title|
        page = SteamCatalogPage.new(app_id)
        assert_match title, page.body
      end
    end
  end
end
