require 'test_helper'

class GameFilterTest < ActiveSupport::TestCase
  class GameFilterDouble < GameFilter
    attr_accessor :existing_games

    def fun_filter
      [100, 200]
    end
  end

  setup do
    @filter = GameFilterDouble.new([1, 2, 3, 4, 5])
    @filter.existing_games = [1, 3, 5]
  end

  test "finding the missing game ids" do
    assert_equal [2, 4], @filter.missing_games
  end

  test "running various filters on game ids" do
    assert_equal [2, 4, 100, 200], @filter.filter(:missing_games, :fun_filter)
  end
end
