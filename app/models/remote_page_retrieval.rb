class RemotePageRetrieval
  attr_reader :error_channel, :before_fetch, :retriever
  def initialize(error_channel, retriever: SteamCatalogPage, before_fetch: ->{})
    @error_channel = error_channel
    @before_fetch = before_fetch
    @retriever = retriever
  end

  def retrieve(identifiers)
    results = channel!(retriever.response_type)
    sync = synchronize(results, identifiers.count)

    identifiers.each do |id|
      go! do
        begin
          before_fetch.call
          response = retriever.new(id)
          results << response.body
          sync << 1
        rescue => e
          error_channel << e
        end
      end
    end
    results
  end

  def synchronize(watched, count)
    sync = channel!(Integer)
    go! do
      processing = true
      while processing do
        select! do |s|
          s.case(sync, :receive) do
            count -= 1
            if count == 0
              watched.close
              sync.close
              processing = false
            end
          end
        end
      end
    end
    sync
  end
end
