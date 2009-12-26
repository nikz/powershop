require 'rubygems'

require File.dirname(__FILE__) + '/../lib/powershop'
require 'pp'

# insert your consumer key/secret pair here
CONSUMER_KEY    = "YOUR_CONSUMER_KEY"
CONSUMER_SECRET = "YOUR_CONSUMER_SECRET" 

p = Powershop::Client.new(CONSUMER_KEY, CONSUMER_SECRET)

rt = p.request_token

`open #{rt.authorize_url}`

puts "Paste OAuth Verifier:"
verifier = gets.chomp

access_token, access_secret = p.authorize_from_request(rt.token, rt.secret, verifier)

puts "Your Access Token:  #{access_token}"
puts "Your Access Secret: #{access_secret}"

puts
puts "Now let's make an API call..."

pp p.properties
