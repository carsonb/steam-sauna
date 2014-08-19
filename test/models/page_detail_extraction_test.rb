require 'test_helper'

class PageDetailExtractionTest < ActiveSupport::TestCase

  attr_reader :cs, :necro, :detail_extractor
  setup do
    @error = channel!(StandardError)
    @cs = fetch_page(name: 'counter_strike.html')
    @necro = fetch_page(name: 'necrodancer.html')
    @detail_extractor = PageDetailExtraction.new(@error)
  end

  test "extracting the details from game pages" do
    pages = channel!(String)
    go! { pages << cs; pages << necro; pages.close }

    details = detail_extractor.extract(pages)

    results = []
    results << details.receive.first
    results << details.receive.first
    assert_includes results, :title, 'Counter Strike: Global Offensive'
    assert_includes results, :title, 'Crypt of the NecroDancer'

    assert details.closed?
  end
end
