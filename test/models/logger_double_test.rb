require 'test_helper'

class LoggerDoubleTest < ActiveSupport::TestCase
  attr_reader :logger

  TESTS = {
    assert_methods_missing: LoggerDouble::LOG_LEVELS,
    debug: "Hello World",
    info: "Goodbye Lenin",
    warn: "Here's Johnny",
    error: "Gotta catch em All",
    fatal: "Hostage Down",
    unknown: "dunno",
    assert_methods_exist: LoggerDouble::LOG_LEVELS
  }

  setup do
    @logger = LoggerDouble.new
  end

  test "that logging works the way it should" do
    TESTS.each do |test, value|
      case test
      when :assert_methods_missing, :assert_methods_exist
        public_send(test, value)
      else
        logger.public_send(test, value)
        assert_equal [value], logger.logs_for(test)
      end
    end
  end

  def assert_methods_exist(methods)
    methods.each do |method|
      assert logger.respond_to?(method), "The LoggerDouble should be responding to #{method}"
    end
  end

  def assert_methods_missing(methods)
    methods.each do |method|
      refute logger.respond_to?(method), "The LoggerDouble should not be responding to #{method}"
    end
  end

end
