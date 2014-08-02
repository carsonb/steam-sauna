module AsynchronousProcessing
  extend ActiveSupport::Concern

  TIMEOUT = 5.0

  included do
    attr_accessor :timeout, :logger, :error
  end

  def process(stage, channel)
    done = channel!(Integer)
    processing = true
    while processing do
      select! do |s|
        s.case(done, :receive) { processing = false}
        blk.yield(s, done)
        s.case(error, :receive) { |err| error << err }
        s.timeout(timeout) { report_timeout(stage); done << 1 }
      end
    end
  end

  def timeout
    @timeout || TIMEOUT
  end

  def error
    @error ||= channel!(StandardError)
  end

  def report_timeout(stage)
    error_message = "[#{self.class}] Received a timeout during the processing of stage: #{stage}"
    if logger
      logger.warn error_message
    else
      raise Timeout::Error, error_message
    end
  end

  def report_error(error)
    raise error
  end
end
