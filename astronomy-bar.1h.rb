#!/usr/bin/env ruby
# <xbar.title>Astronomy Tracker</xbar.title>
# <xbar.version>v1.0</xbar.version>
# <xbar.author>Alejandro Juarez</xbar.author>
# <xbar.desc>Shows sun position in menu bar</xbar.desc>
# <xbar.dependencies>http</xbar.dependencies>
# <xbar.var>string(ASTRONOMY_APP_ID=""): Astronomy App ID</xbar.var>
# <xbar.var>string(ASTRONOMY_SECRET=""): Astronomy Secret ID</xbar.var>
require 'http'
require 'base64'
require 'json'
require 'date'

class AstronomyTracker
  BASE_URL = 'https://api.astronomyapi.com/api/v2'
  
  def initialize(app_id:, app_secret:)
    @credentials = Base64.strict_encode64("#{app_id}:#{app_secret}")
  end

  def sun_position
    response = HTTP.headers('Authorization' => "Basic #{@credentials}").get("#{BASE_URL}/bodies/positions/sun",
      params: {
        longitude: '-106.443599',
        latitude: '31.892559',
        from_date: Date.today.to_s,
        time: Time.now.strftime("%I:%M:%S %p")
      }
    )

    JSON.parse(response.body)
  end

  def display_sun_info
    data = sun_position

    # Get current date in the same format as API response
    current_date = Time.now.strftime("%Y-%m-$dT07:00:00.000-07:00")

    # Extract the first(current) sun position data
    sun_data = data['data']['table']['rows'].first['cells']
                .find { |cell| cell['date'] == current_date }

    # Direct hash access for nested values
    altitude = sun_data['position']['horizontal']['altitude']['degrees'].to_f.round(2)

    icon = altitude > 0 ? "\u2600" : "\u25CF"

    azimuth = sun_data['position']['horizontal']['azimuth']['degrees'].to_f.round(2)
    constellation = sun_data['position']['constellation']['name']

    puts "#{icon} #{altitude}#{"\u00B0"}"
    puts "---"
    puts "Azimuth: #{azimuth}"
    puts "Constellation: #{constellation}"
    puts "Date: #{current_date}"
    puts "Refresh | refresh=true"
  rescue StandardError => e
    puts "Error: #{e.message}"
    puts "Error details: #{e.backtrace.first}"
  end
end
  
  # Use environment variables
tracker = AstronomyTracker.new(
  app_id: ENV['ASTRONOMY_APP_ID'], 
  app_secret: ENV['ASTRONOMY_SECRET']
)

tracker.display_sun_info