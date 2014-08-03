class SteamGame < ActiveRecord::Base
  serialize :categories, Array
end
