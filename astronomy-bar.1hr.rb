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


  
  # Use environment variables
tracker = AstronomyTracker.new(
  app_id: ENV['ASTRONOMY_APP_ID'], 
  app_secret: ENV['ASTRONOMY_SECRET']
)