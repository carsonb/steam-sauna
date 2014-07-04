module WelcomeHelper
  def game_icon(game)
    image_tag("http://media.steampowered.com/steamcommunity/public/images/apps/#{game.appid}/#{game.img_icon_url}.jpg")
  end

  def game_logo(game)
    image_tag("http://media.steampowered.com/steamcommunity/public/images/apps/#{game.appid}/#{game.img_logo_url}.jpg")
  end

  def user_icon(user)
    image_tag(user['avatar'])
  end
end
