require 'test_helper'

class RemotePageRetrievalTest < ActiveSupport::TestCase
  attr_reader :cs, :necro, :error, :retrieval
  setup do
    @error = channel!(StandardError)
    @cs = fetch_page(name: 'counter_strike.html')
    @necro = fetch_page(name: 'necrodancer.html')
    @retrieval = RemotePageRetrieval.new(error)
  end

  test "properly synchronizing a channel" do
    to_close = channel!(Integer)
    sync = retrieval.synchronize(to_close, 5)

    1.upto(5) { sync << 1}
    assert to_close.closed?, "The channel to_close should no longer be open"
    assert sync.closed?, "The synchronization channel should no longer be open"
  end
end
