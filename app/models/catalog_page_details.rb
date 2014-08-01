class CatalogPageDetails
  CATEGORY_REGEX = /category2=(\d+)/
  GAME_ID_REGEX = /steam\/apps\/(\d+)/

  UNKNOWN_GAME_ID = -1

  MULTIPLAYER_CATEGORY = 1
  SINGLEPLAYER_CATEGORY = 2
  GAME_DETAILS = '.game_area_details_specs .name a'

  attr_reader :content
  def initialize(html)
    @content = Nokogiri::HTML(html)
  end

  def title
    @title ||= content.css('.apphub_AppName').text
  end

  def capsule_image
    @capsule_image ||= strip_params(content.css('link[rel="image_src"]').first['href'])
  end

  def header_image
    @header_image ||= strip_params(content.css('.game_header_image').first['src'])
  end

  def game_id
    @game_id ||= if game_id = header_image.match(GAME_ID_REGEX)
      game_id[1].to_i
    else
      UNKNOWN_GAME_ID
    end
  end

  def single_player?
    details.include? SINGLEPLAYER_CATEGORY
  end

  def multi_player?
    details.include? MULTIPLAYER_CATEGORY
  end

  def details
    @details ||= begin
      details = content.css(GAME_DETAILS).map do |detail|
        if category = detail['href'].match(CATEGORY_REGEX)
          category[1].to_i
        end
      end
      details.compact
    end
  end

  def as_hash
    {
      multi: multi_player?,
      single: single_player?,
      game_id: game_id,
      capsule_image: capsule_image,
      header_image: header_image,
      title: title
    }
  end

  class Details
    KEYS = [:multi, :single, :game_id, :capsule_image, :header_image, :title]
    attr_accessor :multi, :single, :game_id, :capsule_image, :header_image, :title

    def initialize(details)
      KEYS.each do |k|
        public_send("#{k}=".to_sym, details[k])
      end
    end
  end

  private
  def strip_params(url)
    uri = URI.parse(url)
    "#{uri.scheme}://#{uri.host}#{uri.path}"
  end
end
