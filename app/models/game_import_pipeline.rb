class GameImportPipeline
  include AsynchronousProcessing
  attr_accessor :stale_game_data

  def import(app_ids=[])
    return [] if app_ids.blank?
    games_to_update = retrive_missing_or_outdated_games(app_ids)
    count = games_to_update.length

    logger.info "Starting to import #{count} games from Steam"

    pages = fetch_pages(games_to_update, count, error)
    details, missed = extract_details(pages, count, error)

    complete_processing(details, missed, count, error)
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
    clazz1 = SteamCatalogPage
    clazz2 = SteamAgeCheck
    page_chan = channel!(Hash, count)
    app_ids.each do |id|
      go! do
        begin
          before.call
          page = SteamCatalogPage.new(id)
          age_check = SteamAgeCheck.new(page.body)
          logger.info "[GameImportPipeline - fetch] Retrieving page data for app #{id}"
          content = age_check.fill_and_submit
          page_chan << {content: content, id: id} unless content.blank?
        rescue => e
          error << e
        end
      end
    end
    page_chan
  end

  def extract_details(page_chan, count, error)
    details_chan = channel!(Hash, count)
    missed_chan = channel!(Integer)
    counter = 0
    go! {
      process('extract_details') do |s, done|
        s.case(page_chan, :receive) do |data|
          content = data[:content]
          logger.info "[#{counter}/#{count}] Extracting details from page for app #{data[:id]}"
          begin
            details = CatalogPageDetails.new(content).as_hash
            go! { details_chan << details if details }
          rescue => e
            Rails.logger.error("[GameImportPipeline] Could not extract details for app #{data[:id]}")
            go! { missed_chan << 1}
          end
          counter += 1
          go! {done << 1} if counter == count
        end
      end
    }
    [details_chan, missed_chan]
  end

  def complete_processing(details, missed, count, error)
    imported_games = 0
    begin
      process('importing') do |s, done|
        s.case(details, :receive) do |detail|
          game = import_game(detail, error)
          imported_games += 1
          logger.info "[#{imported_games}/#{count}] [#{game.app_id}] #{game.title} has been imported"
          go! { done << 1 } if imported_games == count
        end
        s.case(missed, :receive) do |detail|
          imported_games += 1
          logger.info "[#{imported_games}/#{count}] A game could not be imported"
          go! { done << 1 } if imported_games == count
        end
      end
    rescue Timeout::Error => e
      logger.error "[GameImportPipeline] Timeout exception raised"
    end

    imported_games == count
  end

  def import_game(game_detail, error)
    game = SteamGame.where(app_id: game_detail.delete(:app_id)).first_or_initialize
    game.update_attributes(game_detail)
    game.save!
    game
  rescue => e
    error << e
  end

  def stale_game_data
    @stale_game_data ||= 1.week.ago.utc
  end
end
