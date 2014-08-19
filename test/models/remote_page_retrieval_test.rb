require 'test_helper'

class RemotePageRetrievalTest < ActiveSupport::TestCase
  attr_reader :cs, :necro, :error, :retrieval
  setup do
    before = Proc.new do
      WebMock::API.stub_request(:get, 'http://store.steampowered.com/app/1234').to_return(body: cs, status: 200)
      WebMock::API.stub_request(:get, 'http://store.steampowered.com/app/4321').to_return(body: necro, status: 200)
    end
    @error = channel!(StandardError)
    @cs = fetch_page(name: 'counter_strike.html')
    @necro = fetch_page(name: 'necrodancer.html')
    @retrieval = RemotePageRetrieval.new(error, before_fetch: before)
  end

  test "properly synchronizing a channel" do
    to_close = channel!(Integer)
    sync = retrieval.synchronize(to_close, 5)

    1.upto(5) { sync << 1}
    assert to_close.closed?, "The channel to_close should no longer be open"
    assert sync.closed?, "The synchronization channel should no longer be open"
  end

  test "retrieving remote pages" do
    results = retrieval.retrieve([1234, 4321])
    content = []
    content << results.receive.first
    content << results.receive.first

    assert_equal [cs, necro].sort, content.sort
    refute results.receive.first, "After all the content has been retrieved the channel should be closed"
    assert results.closed?
  end
end
