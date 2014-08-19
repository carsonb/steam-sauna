class PageDetailExtraction
  attr_reader :error_channel, :page_details, :workers
  def initialize(error_channel, page_details: CatalogPageDetails)
    @error_channel = error_channel
    @page_details = page_details
  end

  def extract(pages)
    results = channel!(Hash)

    go! do
      loop do
        content = pages.receive.first
        if content
          results << page_details.new(content).as_hash
        elsif pages.closed? && results.open?
          results.close
        else
          break
        end
      end
    end

    results
  end
end
