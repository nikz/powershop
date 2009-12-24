
require "oauth"
require "activesupport"

directory = File.expand_path(File.dirname(__FILE__))

require File.join(directory, 'powershop', 'base')
require File.join(directory, 'powershop', 'oauth')

module Powershop
  
  VERSION   = "0.0.1"
  
  # use test mode by default
  TEST_MODE = true
  
end