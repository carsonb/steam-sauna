module TrackedJob
  extend ActiveSupport::Concern

  EXPIRATION = 5.minutes

  included do
    include SuckerPunch::Job
    alias_method :perform, :tracking
  end

  attr_accessor :uuid
  attr_writer :expiration

  def uuid
    @uuid ||= SecureRandom.uuid
  end

  def processing?
    memcached.fetch(uuid).present?
  end

  def expiration
    @expiration || EXPIRATION
  end

  def tracking(*args)
    add_uuid
    Timeout.timeout(expiration) do
      perform_without_tracking(*args)
    end
    remove_uuid
  end

  def add_uuid
    memcached.set(uuid, true)
  end

  def remove_uuid
    memcached.delete(uuid)
  end

  def memcached
    SteamSauna::Globals.memcached
  end
end
