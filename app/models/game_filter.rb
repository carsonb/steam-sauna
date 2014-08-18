class GameFilter
  attr_reader :app_ids
  def initialize(app_ids)
    @app_ids = app_ids
  end

  def outdated_games
    SteamGame.where('updated_at < ?', 1.week.ago).pluck(:app_id)
  end

  def missing_games
    app_ids - existing_games
  end

  def filter(*methods)
    games = methods.map do |method|
      public_send(method)
    end

    games.flatten
  end

  private
  def existing_games
    SteamGame.where(app_id: app_ids).pluck(:app_id)
  end
end
