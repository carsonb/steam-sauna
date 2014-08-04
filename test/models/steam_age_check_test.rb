require 'test_helper'

class SteamAgeCheckTest < ActiveSupport::TestCase
  attr_reader :age_check, :no_age_check

  setup do
    @age_check = SteamAgeCheck.new(fetch_page(name: 'arma2_agecheck.html'))
    @no_age_check = SteamAgeCheck.new(fetch_page)
  end

  test "it detects when there is an age gate on the page" do
    assert age_check.present?, "The age check should be present on the arma2 page"
    refute no_age_check.present?, "The age check should not be present on a catalog page"
  end

  test "it is able to extract the hidden forms SNR token" do
    assert_equal '1_agecheck_agecheck__age-gate', age_check.snr
  end

  test "it should be able to extract the form submission endpoint" do
    assert_equal 'http://store.steampowered.com/agecheck/app/33900/', age_check.submission_location
  end

  test "it should be able to submit the form to retrieve the actual game details" do
    expected_form_params = {
      snr: '1_agecheck_agecheck__age-gate',
      ageDay: '15',
      ageMonth: 'March',
      ageYear: '1965'
    }

    stub_request(:post, 'http://store.steampowered.com/agecheck/app/33900/').
      with(body: expected_form_params).to_return(body: 'hello there', status: 200)

    result = age_check.fill_and_submit
    assert_equal 'hello there', result
  end

  test "it should just return the content if there is no age check on the page" do
    assert_equal fetch_page, no_age_check.fill_and_submit
  end

  test "it should be able to handle a redirect and return the game details" do
    expected_form_params = {
      snr: '1_agecheck_agecheck__age-gate',
      ageDay: '15',
      ageMonth: 'March',
      ageYear: '1965'
    }

    stub_request(:post, 'http://store.steampowered.com/agecheck/app/33900/').
      with(body: expected_form_params).to_return(headers: {'Location' => 'http://foo.com/blah'}, status: 302)
    stub_request(:get, 'http://foo.com/blah').to_return(body: 'hello there', status: 200)

    result = age_check.fill_and_submit
    assert_equal 'hello there', result
  end
end
