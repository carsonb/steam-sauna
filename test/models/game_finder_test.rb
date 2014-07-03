require 'test_helper'

class GameFinderTest < ActiveSupport::TestCase

  GAMES = {
    csgo: Game.new('name' => 'CS GO', 'appid' => 1),
    aoe2: Game.new('name' => 'AoE 2', 'appid' => 2),
    arma3: Game.new('name' => 'Arma3', 'appid' => 3),
    peggle: Game.new('name' => 'Peggle', 'appid' => 4)
  }

  setup do
    @games_a = make_list %i(csgo aoe2)
    @games_b = make_list %i(arma3 peggle aoe2)
    @games_c = make_list %i(aoe2 arma3 peggle)
    @all_players = [@games_a, @games_b, @games_c]
  end

  test "it should only return the games that can be played by all players" do
    finder = GameFinder.new
    @all_players.each { |games| finder.add_players_games(games) }
    assert_equal [GAMES[:aoe2]], finder.playable_games
  end

  def make_list(keys)
    keys.map{ |k| GAMES[k] }
  end
end
