module Powershop
  module OAuth
    
    attr_accessor :client
    
    delegate :get_request_token, :to => :client
    delegate :get_access_token,  :to => :client
    delegate :get,               :to => :client
    delegate :post,              :to => :client
    delegate :put,               :to => :client
    
    def create_consumer(key, secret)
      @client = ::OAuth::Consumer.new(key, secret, 
                                        :site               => api_base_url, 
                                        :request_token_path => "/external_api/oauth/request_token", 
                                        :authorize_path     => "/external_api/oauth/authorize", 
                                        :access_token_path  => "/external_api/oauth/access_token")
    end
    
    
    def api_base_url
      if TEST_MODE
        "https://suppliertest.youdo.co.nz"
      else
        raise "Powershop haven't released the production url!"
      end
    end
    
  end
end