class Game
  attr_reader :name, :appid, :img_logo_url, :img_icon_url
  def initialize(hash)
    @name = hash['name']
    @appid = hash['appid']
    @img_logo_url = hash['img_logo_url']
    @img_icon_url = hash['img_icon_url']
  end

  def to_s
    "#{@name},#{@appid}"
  end
end
