class SteamAgeCheck
  attr_reader :document, :content
  def initialize(content)
    @content = content
    @document = Nokogiri::HTML(content)
  end

  def present?
    document.css('#agegate_box').present?
  end

  def snr
    @snr ||= document.css('#agegate_box input[name="snr"]').first['value']
  end

  def submission_location
    @location ||= document.css('#agegate_box form').first['action']
  end

  def fill_and_submit
    return content unless present?
    form = {snr: snr, ageDay: '15', ageMonth: 'March', ageYear: '1965'}
    response = RestClient.post(submission_location, form) do |response, request, result, &block|
      if [301, 302, 307].include? response.code
        RestClient.get(response.headers[:location], {cookies: response.cookies})
      else
        response.return!(request, result, &block)
      end
    end
    response.body
  end

end
