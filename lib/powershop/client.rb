module Powershop
  class Client

    attr_accessor :oauth
    
    def initialize(oauth_consumer_key, oauth_consumer_secret)
      @oauth = OAuth.new(oauth_consumer_key, oauth_consumer_secret)
      
      @current_property = nil
    end
    
    # so we can oauth straight through the Client
    %w(request_token authorize_from_request authorize_from_access access_token).each do |method|
      delegate method, :to => :oauth
    end
    
    # proxy all our requests with an error wrapper
    %w(get post put delete).each do |http_method|
      define_method(http_method) do |*args|
        url, options   = args
        options      ||= {}
        
        options[:icp_number] ||= @current_property.icp_number if @current_property
        
        parse(@oauth.send(http_method, "#{url}?#{to_query(options)}"))
      end
    end
    
    def properties
      result = self.get(api_url("customer"))
      
      result.properties.collect do |p|
        Property.new(self, p)
      end
    end
    
    # choose which property (icp_number) to use for all calls requiring an icp_number
    def set_property(property)
      @current_property = property
    end
    
    def get_meter_readings(options = {})
      options[:end_date]   ||= Date.today
      
      self.get(api_url("meter_readings"), options)
    end
    
    # 'readings' should be a hash of register_number => reading values
    #  e.g
    #     { "10073:1" => 5000, "10073:2" => 2000 }
    def post_meter_readings(readings, options = {})

      readings.each do |register_number, reading|
        options["readings[#{register_number}]"] = reading 
      end
      
      response = self.post(api_url("meter_readings"), options)
      
      if response.result == "success"
        true
      else
        raise reponse.message
      end
    end
    
    def products(options = {})
      self.get(api_url("products"), options)
    end
    
    def get_top_up(options = {})
      self.get(api_url("top_up"), options)
    end
    
    def top_up!(options = {})
      raise "You must specify an Offer Key" unless options[:offer_key]
      
      self.post(api_url("top_up"), options)
    end
    
    private
      
      # NB: For Powershop, the "js" format (usually reserved for executable Javascript)
      # is used to denote JSON encoding (instead of the more familiar "json")
      def api_url(endpoint)
        "#{API_BASE_URL}/external_api/v1/#{endpoint}.js"
      end
      
      def parse(response)
        check_errors(response)
        
        result = ActiveSupport::JSON.decode(response.body)["result"]
        
        if result.is_a?(Array)
          result.map { |r| OpenStruct.new(r) }
        else
          OpenStruct.new(result)
        end
      end
      
      def check_errors(response)
        case response.code.to_i
          when 400
            raise PowershopError.new(response.body)
          when 401
            raise PowershopOAuthError.new(response.body)
          when 503
            raise RateLimitExceeded.new(response.body)
        end
      end
      
      def to_query(options)
        options.inject([]) do |collection, opt|
          key, value = opt
          
          value = value.strftime("%Y-%m-%d") if value.is_a?(Date) || value.is_a?(Time)

          collection << "#{key}=#{value}"
          collection
        end * '&'
      end
      
  end
end