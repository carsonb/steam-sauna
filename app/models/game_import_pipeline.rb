class GameImportPipeline

  TIMEOUT = 5.0

  attr_accessor :timeout, :stale_game_data

  def import(app_ids=[])
    error = channel!(StandardError)
    done = channel!(Integer)

    return [] if app_ids.blank?
    games_to_update = retrive_missing_or_outdated_games(app_ids)
    count = games_to_update.length

    pages = fetch_pages(games_to_update, count, error)
    details = extract_details(pages, count, error)

    import_games(details, count, error, done)

    success = false

    select! do |s|
      s.case(done, :receive) { success = true }
      s.case(error, :receive) { |err| report_error(err) }
      s.timeout(timeout) { report_timeout }
    end

    success
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
    details_chan = channel!(CatalogPageDetails::Details, count)
    go! do
      loop do
        select! do |s|
          s.case(page_chan, :receive) do |content|
            begin
              details = CatalogPageDetails.new(content)
              details_chan << CatalogPageDetails::Details.new(details.as_hash)
            rescue => e
              error << e
            end
          end
          s.timeout(timeout) {}
        end
      end
    end
    details_chan
  end

  def import_games(details_chan, count, error, done)
    go! do
      counter = 0
      select! do |s|
        s.case(details_chan, :receive) do |details|
          build_game(details)
          counter += 1
          if counter == count
            done << 1
          end
        end
        s.timeout(timeout) do
          report_timeout
          done << 1
        end
      end
    end
  rescue => e
    error << e
  end

  def build_game(details)
  end

  def report_error(error)
  end

  def report_timeout
  end

  def timeout
    @timeout || TIMEOUT
  end

  def stale_game_data
    @stale_game_data ||= 1.week.ago.utc
  end
end
