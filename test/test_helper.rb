ENV["RAILS_ENV"] ||= "test"
require File.expand_path('../../config/environment', __FILE__)
require File.expand_path(File.dirname(__FILE__) + '/doubles/logger_double')
require 'rails/test_help'
require "minitest/autorun"
require 'webmock/minitest'
require 'pry'
require 'pry-debugger'

class ActiveSupport::TestCase
  ActiveRecord::Migration.check_pending!

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  def fetch_page(name: 'counter_strike.html')
    File.read(Rails.root + "test/data/game_pages/#{name}")
  end

  def assert_raises_child_of(error, &blk)
    begin
      blk.yield
    rescue => e
      parent = e.class.superclass
      assert_equal error, parent, "Expected an error of type #{error} but received of type #{parent} instead"
    end
  end
end
