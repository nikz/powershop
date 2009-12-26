module Powershop
  class Property
   
    ATTRIBUTES = %w(icp_number address start_date end_date unit_balance daily_consumption 
                     last_account_review_at registers)
   
    ATTRIBUTES.each { |r| attr_accessor r }
   
    def initialize(client, hash)
      @client = client
      
      ATTRIBUTES.each do |r|
        send("#{r}=", hash[r])
      end
    end
    
    # Could override this in case a Hash doesn't suit for an address ;)
    # def address=(address_hash)
    # end
    
    def registers=(register_array)
      @registers = register_array.map { |r| Register.new(r) }
    end
    
  end
end