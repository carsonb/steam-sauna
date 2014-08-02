module AsynchronousProcessing
  extend ActiveSupport::Concern

  TIMEOUT = 5.0

  included do
    attr_accessor :timeout, :logger, :error
  end

  def process(stage, &blk)
    done = channel!(Integer)
    processing = true
    while processing do
      select! do |s|
        s.case(done, :receive) { processing = false}
        begin
          blk.yield(s, done)
        rescue => e
          go! { error << e }
        end
        s.case(error, :receive) do |err|
          report_error(err)
          go! { done << 1 }
        end
        s.timeout(timeout) do
          report_timeout(stage)
          go! { done << 1 }
        end
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
    if logger
      logger.error error.message
      logger.error error.backtrace if error.backtrace
    else
      raise error
    end
  end
end
