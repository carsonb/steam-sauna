class GameImportPipeline

  TIMEOUT = 5.0

  attr_accessor :timeout, :stale_game_data, :logger

  def import(app_ids=[])
    error = channel!(StandardError)
    done = channel!(Integer)

    return [] if app_ids.blank?
    games_to_update = retrive_missing_or_outdated_games(app_ids)
    count = games_to_update.length

    pages = fetch_pages(games_to_update, count, error)
    details = extract_details(pages, count, error)

    processing = true
    imported_games = 0
    while processing do
      select! do |s|
        s.case(details, :receive) do |detail|
          import_game(detail, error)
          imported_games += 1
          processing = false if imported_games == count
        end
        s.case(error, :receive) { |err| report_error(err) }
        s.timeout(timeout) { report_timeout('importing'); processing = false}
      end
    end

    imported_games == count
  end

  def retrive_missing_or_outdated_games(app_ids)
    existing_games = SteamGame.where(app_id: app_ids).pluck(:app_id, :updated_at)
    games_to_update = existing_games.map do |app_id, updated_at|
      app_ids.delete(app_id)
      if updated_at < stale_game_data
        app_id
      end
    end
    games_to_update.compact + app_ids
  end

  def fetch_pages(app_ids, count, error, before: ->{})
    clazz = SteamCatalogPage
    page_chan = channel!(String)
    app_ids.each do |id|
      go! do
        begin
          before.call
          page = SteamCatalogPage.new(id)
          content = page.body
          page_chan << content
        rescue => e
          error << e
        end
      end
    end
    page_chan
  end

  def extract_details(page_chan, count, error)
    details_chan = channel!(Hash, count)
    go! do
      loop do
        select! do |s|
          s.case(page_chan, :receive) do |content|
            begin
              details = CatalogPageDetails.new(content)
              details_chan << details.as_hash
            rescue => e
              error << e
            end
          end
          s.timeout(timeout) { report_timeout('extract_details') }
        end
      end
    end
    details_chan
  end

  def import_game(game_detail, error)
    game = SteamGame.where(app_id: game_detail.delete(:app_id)).first_or_initialize
    game.update_attributes(game_detail)
    game.save!
    game
  rescue => e
    error << e
  end

  def report_error(error)
    raise error
  end

  def report_timeout(stage)
    error_message = "[GameImportPipeline] Received a timeout during the processing of stage: #{stage}"
    if logger
      logger.warn error_message
    else
      raise Timeout::Error, error_message
    end
  end

  def timeout
    @timeout || TIMEOUT
  end

  def stale_game_data
    @stale_game_data ||= 1.week.ago.utc
  end
end
