module WelcomeHelper
  def game_icon(game)    
    image_tag(game.icon_url, alt: game.name)
  end

  def game_logo(game)
    image_tag(game.logo_url, alt: game.name)
  end
end
