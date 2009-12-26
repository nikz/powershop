module Powershop
  
  # based on OAuth implementation for Twitter Gem, 
  # http://github.com/jnunemaker/twitter/
  class OAuth
    
    attr_accessor :consumer
    
    %w(get post put delete).each do |http_method|
      delegate http_method,    :to => :access_token      
    end
    
    def initialize(key, secret)
      @consumer = ::OAuth::Consumer.new(key, secret, 
                                        :site               => API_BASE_URL, 
                                        :request_token_path => "/external_api/oauth/request_token", 
                                        :authorize_path     => "/external_api/oauth/authorize", 
                                        :access_token_path  => "/external_api/oauth/access_token")
    end
    
    def request_token(options={})
      # default to Out-Of-Band unless an oauth callback is specified
      # NB: Powershop requires an OAuth callback, ref: [E908]
      options[:oauth_callback] ||= "oob"
    
      @request_token ||= consumer.get_request_token(options)
    end
    
    def authorize_from_request(rtoken, rsecret, verifier_or_pin)
      request_token = ::OAuth::RequestToken.new(consumer, rtoken, rsecret)
      access_token = request_token.get_access_token(:oauth_verifier => verifier_or_pin)
      @atoken, @asecret = access_token.token, access_token.secret
    end
  
    def access_token
      @access_token ||= ::OAuth::AccessToken.new(consumer, @atoken, @asecret)
    end
    
    def authorize_from_access(atoken, asecret)
      @atoken, @asecret = atoken, asecret
    end
    
  end
end