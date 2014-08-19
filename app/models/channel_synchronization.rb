module ChannelSynchronization
  def synchronize(watched, count)
    sync = channel!(Integer)
    go! do
      processing = true
      while processing do
        select! do |s|
          s.case(sync, :receive) do
            count -= 1
            if count == 0
              watched.close
              sync.close
              processing = false
            end
          end
        end
      end
    end
    sync
  end
end
