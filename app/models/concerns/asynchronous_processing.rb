module AsynchronousProcessing
  extend ActiveSupport::Concern

  TIMEOUT = 5.0

  included do
    attr_accessor :timeout, :logger
  end

  def process(stage, &blk)
    done = channel!(Integer)
    completed = channel!(Boolean)
    processing = true
    go! do
      while processing do
        select! do |s|
          s.case(done, :receive) { processing = false; completed << true }
          begin
            blk.yield(s, done)
          rescue => e
            go! { error << e }
          end
          s.case(error, :receive) do |err|
            report_error(err)
            go! { processing = false; completed << false }
          end
          s.timeout(timeout) do
            report_timeout(stage)
            go! { processing = false; completed << false }
          end
        end
      end
    end

    completed
  end

  def timeout
    @timeout || TIMEOUT
  end

  def error
    @error ||= channel!(StandardError)
  end

  def error=(channel)
    @error = channel
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

  def bench(report_chan)
    if report_chan
      result = Benchmark.measure do
        yield
      end
      go! { report_chan << result }
    else
      yield
    end
  end
end
