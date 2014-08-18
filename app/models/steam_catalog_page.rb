class SteamCatalogPage
  USER_AGENT = "SteamSauna - Making the API you didn't"
  def self.response_type
    String
  end

  def initialize(app_id, endpoint: 'http://store.steampowered.com/app')
    @endpoint = endpoint
    @app_id = app_id
  end

  def body
    fetch_data
    response.body
  end

  def url
    "#{@endpoint}/#{@app_id}"
  end

  private
  attr_reader :response
  def fetch_data
    @response ||= RestClient.get(url, user_agent: USER_AGENT)
  end
end
