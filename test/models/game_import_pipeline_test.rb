require 'test_helper'

class GameImportPipelineTest < ActiveSupport::TestCase
  attr_reader :pipeline, :cs, :necro, :error
  setup do
    @error = channel!(StandardError)
    @cs = fetch_page(name: 'counter_strike.html')
    @necro = fetch_page(name: 'necrodancer.html')
    @pipeline = GameImportPipeline.new
    pipeline.timeout = 0.1
  end

  test "retrieving missing or outdated games includes games in the DB and those that do not exist" do
    games = [4567, steam_games(:cs_source).app_id, steam_games(:cs_go).app_id]
    missing_games = pipeline.retrive_missing_or_outdated_games(games)
    assert_equal [4567, steam_games(:cs_source).app_id].sort, missing_games.sort
  end

  test "fetch_pages fetches all the pages from steam" do
    before = Proc.new do
      WebMock::API.stub_request(:get, 'http://store.steampowered.com/app/1234').to_return(body: cs, status: 200)
      WebMock::API.stub_request(:get, 'http://store.steampowered.com/app/4321').to_return(body: necro, status: 200)
    end

    result_chan = pipeline.fetch_pages([1234, 4321], 2, error, before: before)
    results = []
    async_process do |s|
      s.case(result_chan, :receive) { |content| results << content }
    end

    assert_equal 2, results.length
    assert results.delete(cs)
    assert results.delete(necro)
  end

  test "extract_details takes all the page data and makes it usable" do
    pages = channel!(String, 2)
    pages << cs
    pages << necro

    details_chan = pipeline.extract_details(pages, 2, error)

    results = []
    async_process do |s|
      s.case(details_chan, :receive) { |d| results << d }
    end

    assert_equal 2, results.count
    assert results.select{ |r| r[:title] == 'Counter Strike: Global Offensive' }
    assert results.select{ |r| r[:title] == 'Crypt of the NecroDancer' }
  end

  test "import game takes a game entry and adds it to the database" do
    assert_difference "SteamGame.count" do
      game = pipeline.import_game({multi_player: true, title: 'Awesomenauts', app_id: 9999}, error)
      assert_equal 9999, game.app_id
      assert game.multi_player?
      assert_equal 'Awesomenauts', game.title
    end
  end

  test "import_game just updates a record if it already exists" do
    old_title = steam_games(:cs_source).title
    assert_no_difference "SteamGame.count" do
      game = pipeline.import_game({multi_player: true, title: 'Awesomenauts', app_id: 1234}, error)
      assert_equal 1234, game.app_id
      assert_not_equal old_title, game.title
    end
  end

  test "import_game sends all errors off to the error channel for proper handling" do
    go! { pipeline.import_game({garbage: 'data', to: 'raise errors'}, error)}

    assert_raises_child_of NoMethodError do
      async_process {}
    end
  end

  def async_process(&blk)
    processing = true
    while processing do
      select! do |s|
        blk.yield(s)
        s.case(error, :receive) { |err| raise err }
        s.timeout(0.1) { processing = false }
      end
    end
  end
end
