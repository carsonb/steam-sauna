class GameFinder
  attr_reader :collection, :players, :games
  def initialize
    @collection = Hash.new(0)
    @games = {}
    @players = 0
  end

  def add_players_games(games)
    games.each do |game|
      self.collection[game.name] += 1
      self.games[game.name] ||= game
    end
    @players += 1
  end

  def playable_games
    owned_by_all = collection.reject { |key, value| value != players }
    games.slice(*owned_by_all.keys).values
  end
end
