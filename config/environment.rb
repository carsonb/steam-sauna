# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
SteamSauna::Application.initialize!

SteamSauna::Application.configure do
  config.autoload_paths += %W(#{config.root}/app/jobs)
end
