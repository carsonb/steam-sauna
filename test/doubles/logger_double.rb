class LoggerDouble
  LOG_LEVELS = %i(debug info warn error fatal unknown)

  def initialize
    @logs = {}
  end

  def logs_for(level)
    loggable?(level) ? @logs[level] : raise(StandardError, "Invalid log level: #{level}")
  end

  def method_missing(method, *args)
    if loggable?(method)
      define_and_log(method, *args)
    else
      super
    end
  end

  def define_and_log(method, *args)
    class_eval <<-RUBY
    def #{method}(message)
      @logs[:#{method}] ||= []
      @logs[:#{method}] << message
    end
    RUBY
    public_send(method, *args)
  end

  def loggable?(level)
    LOG_LEVELS.include?(level)
  end
end
