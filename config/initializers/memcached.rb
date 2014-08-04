options = {namespace: "steam-sauna:#{Rails.env}"}
username = ENV['MEMCACHIER_USERNAME']
password = ENV['MEMCACHIER_PASSWORD']
if username && password
  options = options.merge(username: username, password: password)
end

server = ENV['MEMCACHIER_SERVERS']
SteamSauna::Globals.memcached = Dalli::Client.new(server, options)
