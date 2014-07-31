require 'test_helper'

class GameImportPipelineTest < ActiveSupport::TestCase
  attr_reader :pipeline
  setup do
    @pipeline = GameImportPipeline.new
    pipeline.timeout = 0.1
  end

  test "retrieving missing or outdated games includes games in the DB and those that do not exist" do
    games = [4567, steam_games(:cs_source).app_id, steam_games(:cs_go).app_id]
    missing_games = pipeline.retrive_missing_or_outdated_games(games)
    assert_equal [4567, steam_games(:cs_source).app_id].sort, missing_games.sort
  end

  test "fetch_pages fetches all the pages from steam" do
    cs = fetch_page(name: 'counter_strike.html')
    necro = fetch_page(name: 'necrodancer.html')
  end
end
