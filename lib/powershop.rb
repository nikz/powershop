
require "active_support"
require "ostruct"
require "cgi"

gem "oauth", ">= 0.3.1"
require "oauth"

directory = File.expand_path(File.dirname(__FILE__))

require File.join(directory, 'powershop', 'client')
require File.join(directory, 'powershop', 'oauth')
require File.join(directory, 'powershop', 'property')
require File.join(directory, 'powershop', 'register')

module Powershop

  class RateLimitExceeded < StandardError; end
  class PowershopError < StandardError; end
  class PowershopOAuthError < StandardError; end
  
  VERSION   = "0.0.1"
  
  # use test url
  API_BASE_URL = "https://secure.powershop.co.nz"  
  API_TEST_URL = "https://suppliertest.youdo.co.nz"
  
end