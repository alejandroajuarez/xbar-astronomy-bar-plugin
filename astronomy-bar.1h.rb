#!/usr/bin/env /Users/alejandro/.rbenv/shims/ruby
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
    today = Date.today
    current_time = Time.now
    response = HTTP.headers('Authorization' => "Basic #{@credentials}").get("#{BASE_URL}/bodies/positions/sun",
      params: {
        longitude: '-106.443599',
        latitude: '31.892559',
        elevation: 0,
        from_date: today.to_s,
        to_date: (today + 1).to_s,
        time: current_time.strftime("%H:%M:%S"),
        total_day_count: 2
      }
    )

    JSON.parse(response.body)
  end

  def display_sun_info
    data = sun_position
    
    # Debug: Print entire data structure
    puts "Full API Response Debug:"
    begin
      puts JSON.pretty_generate(data)
    rescue
      puts data.inspect
    end
    puts "---"

    # Get current date in the exact format from API response
    current_time = Time.now
    possible_dates = [
      current_time.strftime("%Y-%m-%dT%H:%M:%S.%L%:z")  # Matches the API's date format
    ]

    # Find the cell matching current date
    sun_data = data['data']['table']['rows'].first['cells']
               .find do |cell| 
                 possible_dates.any? { |date| cell['date'].start_with?(date[0..-7]) }
               end

    # More detailed error checking
    if sun_data.nil?
      puts "\u26A0\uFE0F No matching date found | color=red"
      puts "---"
      puts "Possible dates checked:"
      possible_dates.each { |date| puts date }
      puts "Available dates in response:"
      data['data']['table']['rows'].first['cells'].each do |cell|
        puts cell['date']
      end
      
      # Use the first cell if no exact match
      sun_data = data['data']['table']['rows'].first['cells'].first
    end
    
    # Extract values
    altitude = sun_data['position']['horizontal']['altitude']['degrees'].to_f.round(2)
    
    # Determine icon and symbol
    icon = altitude > 0 ? "\u2600" : "\u25CF"
    
    # Additional information extraction
    azimuth = sun_data['position']['horizontal']['azimuth']['degrees'].to_f.round(2)
    constellation = sun_data['position']['constellation']['name']
    
    puts "#{icon} #{altitude}\u00B0 | size=14"
    puts "---"
    puts "Azimuth: #{azimuth}\u00B0"
    puts "Constellation: #{constellation}"
    puts "Date Used: #{sun_data['date']}"
    puts "Refresh | refresh=true"
  rescue StandardError => e
    puts "\u26A0\uFE0F Error | color=red"
    puts "---"
    puts "Details: #{e.message}"
    puts "Backtrace: #{e.backtrace.first}"
    puts "Refresh | refresh=true"
  end
end
  
# Use environment variables
tracker = AstronomyTracker.new(
  app_id: ENV['ASTRONOMY_APP_ID'], 
  app_secret: ENV['ASTRONOMY_SECRET']
)

tracker.display_sun_info