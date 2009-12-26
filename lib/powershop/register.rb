module Powershop
  class Register
   
    ATTRIBUTES = %w(register_number description dials hidden last_reading_at last_reading_value
                     last_reading_type estimated_reading_value)
   
    ATTRIBUTES.each { |r| attr_accessor r }
   
    def initialize(hash)
      ATTRIBUTES.each do |r|
        send("#{r}=", hash[r])
      end
    end
    
  end
end