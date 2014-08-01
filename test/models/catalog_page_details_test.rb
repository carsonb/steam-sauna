require 'test_helper'

class CatalogPageDetailsTest < ActiveSupport::TestCase
  attr_reader :page_details

  setup do
    @page_details = CatalogPageDetails.new(fetch_page(name: 'counter_strike.html'))
  end

  test "getting the title for a game" do
    assert_equal 'Counter-Strike: Global Offensive', page_details.title
  end

  test "getting the game_id for a game" do
    assert_equal 730, page_details.game_id
  end

  test "getting the header_image strips out the uri parameters" do
    assert_equal 'http://cdn.akamai.steamstatic.com/steam/apps/730/header_292x136.jpg', page_details.header_image
  end

  test "getting the capsule_image strips out the uri parameters" do
    assert_equal 'http://cdn.akamai.steamstatic.com/steam/apps/730/capsule_231x87.jpg', page_details.capsule_image
  end

  test "getting the page details for a multiplayer game" do
    assert page_details.multi_player?, "Counter Strike is a multi-player game"
  end

  test "getting the page details for a single player game" do
    page_details = CatalogPageDetails.new(fetch_page(name: 'necrodancer.html'))
    assert page_details.single_player?, "Crypt of the Necrodancer is a single player game"
  end

  test "initalizing a details value object" do
    details = CatalogPageDetails::Details.new(page_details.as_hash)
    assert_equal 'Counter-Strike: Global Offensive', details.title
  end
end
