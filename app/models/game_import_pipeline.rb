class GameImportPipeline
  include AsynchronousProcessing
  attr_accessor :stale_game_data

  def import(app_ids=[])
    return [] if app_ids.blank?
    games_to_update = GameFilter.new(app_ids).filter(:outdated_games, :missing_games)
    count = games_to_update.length

    pages = fetch_pages(games_to_update, count, error)
    details = extract_details(pages, count, error)

    complete_processing(details, count, error)
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
    counter = 0
    process('extract_details') do |s, done|
      s.case(page_chan, :receive) do |content|
        details = CatalogPageDetails.new(content)
        details_chan << details.as_hash
        counter += 1
        go! {done << 1} if counter == count
      end
    end
    details_chan
  end

  def complete_processing(details, count, error)
    imported_games = 0
    process('importing') do |s, done|
      s.case(details, :receive) do |detail|
        import_game(detail, error)
        imported_games += 1
        go! { done << 1 } if imported_games == count
      end
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
