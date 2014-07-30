require 'test_helper'

class SteamCatalogPageTest < ActiveSupport::TestCase
  test "retrieving the body of a page" do
    stub_request(:get, 'http://foobar.com/1234').to_return(body: 'hello world', status: 200)
    page = SteamCatalogPage.new(1234, endpoint: 'http://foobar.com')
    assert_equal 'hello world', page.body
    assert_requested :get, 'http://foobar.com/1234'
  end

  test "getting the body of a page multiple times only makes a single HTTP request" do
    stub_request(:get, 'http://foobar.com/1234').to_return(body: 'hello world', status: 200)
    page = SteamCatalogPage.new(1234, endpoint: 'http://foobar.com')
    5.times { page.body }
    assert_requested :get, 'http://foobar.com/1234', times: 1
  end

  test "errors raised in responses are passed raised to the caller" do
    stub_request(:any, 'http://foobar.com/1234').to_return(body: 'not found', status: 404)
    begin
      page = SteamCatalogPage.new(1234, endpoint: 'http://foobar.com')
      page.body
      flunk("An HTTP Error should have been raised")
    rescue RestClient::Exception => e
      pass
    end
  end
end
