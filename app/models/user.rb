class User < ActiveRecord::Base
  serialize :friends, Array

  def self.fetch_and_or_store(steam_ids)
    missing_accounts = missing_users(steam_ids)
    steam_accounts = steam_users(missing_accounts)
    steam_accounts.each(&:save)

    where(uid: steam_ids)
  end

  def self.missing_users(ids)
    existing_users = where(uid: ids)
    ids.reject do |uid|
      existing_users.exists?(uid: uid)
    end
  end

  def self.steam_users(ids)
    summaries(ids).map do |user|
      User.new(
        uid: user['steamid'],
        image: user['avatar'],
        nickname: user['personaname']
      )
    end
  end

  def self.summaries(ids)
    Steam::User.summaries(ids)
  end

  def update_friends
    self.friends = steam_friends.map do |friend|
      friend['steamid'].to_i
    end
    save!
  end

  def friends?
    friends.present?
  end

  def steam_friends
    Steam::User.friends(uid)
  end
end
