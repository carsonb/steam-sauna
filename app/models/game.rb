class Game
  attr_reader :name, :appid
  def initialize(hash)
    @name = hash['name']
    @appid = hash['appid']
  end
end
