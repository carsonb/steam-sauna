class PlayerImportJob
  include TrackedJob
  workers 4

  attr_reader :user

  def perform_without_tracking(user_id)
    Steam.apikey = ENV['STEAM_API_KEY']
    @user = User.find(user_id)

    user.update_friends unless user.friends?
    User.fetch_and_or_store(user.friends)
    apps = steam.retrieve_games
    app_ids = apps.map(&:appid)

    pipeline = GameImportPipeline.new
    pipeline.logger = Rails.logger
    pipeline.import(app_ids)
  end

  def steam
    @steam ||= SteamService.new(user.uid)
  end
end
