module WelcomeHelper
  def game_icon(game)    
    if game.img_icon_url.present?
      image_tag("http://media.steampowered.com/steamcommunity/public/images/apps/#{game.appid}/#{game.img_icon_url}.jpg", alt: game.name)
    else
      image_tag("http://placehold.it/32x32.png/000000/ffffff&text=#{game.name.first}", alt: game.name)
    end
  end

  def game_logo(game)
    if game.img_logo_url.present?
      image_tag("http://media.steampowered.com/steamcommunity/public/images/apps/#{game.appid}/#{game.img_logo_url}.jpg", alt: game.name)
    else
      image_tag("http://placehold.it/184x69.png/000000/ffffff&text=#{URI.escape(game.name.truncate(12, omission: '…'))}", alt: game.name)
    end
  end
end
