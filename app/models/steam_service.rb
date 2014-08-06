class SteamService

  def initialize(user_id)
    @current_user_id = user_id
  end

  def retrieve_games(user_id)
    begin
      games = Steam::Player.owned_games(user_id, params: {include_appinfo: 1})
    rescue Steam::JSONError
      games = []
    end
    games['games'].map { |game| Game.new(game) }
  end

  def find_matching_games(friend_ids)
    if friend_ids.count == 0
      return []
    end
    finder = GameFinder.new
    finder.add_players_games(retrieve_games(@current_user_id))
    friend_ids.each do |friend_id|
      finder.add_players_games(retrieve_games(friend_id))
    end
    finder.playable_games
  end

end
