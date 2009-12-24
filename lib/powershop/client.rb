module Powershop
  class Client
  
    include OAuth
  
    def initialize(oauth_consumer_key, oauth_consumer_secret)
      create_oauth_client(oauth_consumer_key, oauth_consumer_secret)
    end
  
    def customer
      response = self.get(api_url("customer"))
      
      puts response.body
      
    end
    
    private
      
      # NB: For Powershop, the "js" format (usually reserved for executable Javascript)
      # is used to denote JSON encoding (instead of the more familiar "json")
      def api_url(endpoint)
        "#{api_base_url}/external_api/v1/#{endpoint}.js"
      end
      
  end
end