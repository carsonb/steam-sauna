class Game
  attr_reader :name, :appid, :img_logo_url, :img_icon_url
  def initialize(hash)
    @name = hash['name']
    @appid = hash['appid']
    @img_logo_url = hash['img_logo_url']
    @img_icon_url = hash['img_icon_url']
  end

  def icon_url
    if @img_icon_url.present?
      "http://media.steampowered.com/steamcommunity/public/images/apps/#{@appid}/#{@img_icon_url}.jpg"
    else
      "http://placehold.it/32x32.png/000000/ffffff&text=#{@name.first}"
    end
  end

  def logo_url
    if @img_logo_url.present?
      "http://media.steampowered.com/steamcommunity/public/images/apps/#{@appid}/#{@img_logo_url}.jpg"
    else
      "http://placehold.it/184x69.png/000000/ffffff&text=#{URI.escape(@name.truncate(12, omission: '…'))}"
    end
  end
end
