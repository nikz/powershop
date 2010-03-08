require File.dirname(__FILE__) + '/test_helper.rb'

class ClientTest < Test::Unit::TestCase
   
  STUB_API_CALLS = true
  
  # specify a real consumer key/secret pair here to test against the actual API
  CONSUMER_KEY    = "YOUR_CONSUMER_KEY"
  CONSUMER_SECRET = "YOUR_CONSUMER_SECRET"
  
  # specify an access token/secret pair here to test against the actual API
  ACCESS_TOKEN  = "YOUR_ACCESS_TOKEN"
  ACCESS_SECRET = "YOUR_ACCESS_SECRET"
    
  def setup
    @powershop_client = Powershop::Client.new(CONSUMER_KEY, CONSUMER_SECRET)
    
    if STUB_API_CALLS
      Powershop::OAuth.any_instance.expects(:authorize_from_access).with { |x, y| x == ACCESS_TOKEN && y == ACCESS_SECRET }.returns(true)      
    end
    
    @powershop_client.authorize_from_access(ACCESS_TOKEN, ACCESS_SECRET)
    
  end  
  
  def test_test_mode
    Powershop::Client.test_mode = true      
    Powershop::OAuth.any_instance.expects(:get).with { |url| url.starts_with?(Powershop::API_TEST_URL) }.returns(stub(:code => 200, :body => test_response("properties")))     
    
    @powershop_client.properties.first      
  end
  
  def test_live_mode       
    Powershop::OAuth.any_instance.expects(:get).with { |url| url.starts_with?(Powershop::API_BASE_URL) }.returns(stub(:code => 200, :body => test_response("properties")))     
    
    assert !Powershop::Client.test_mode 
    @powershop_client.properties.first 
  end
  
  def test_properties
    if STUB_API_CALLS
      Powershop::OAuth.any_instance.expects(:get).with { |url| url =~ /customer/ }.returns(stub(:code => 200, :body => test_response("properties")))
    end
    
    assert properties = @powershop_client.properties
    
    properties.each do |p|
      assert p.is_a? Powershop::Property
      assert p.registers.first.is_a? Powershop::Register
    end

    if STUB_API_CALLS
      p = properties.first
      
      assert_equal "0001427254UNF48", p.icp_number
      assert_equal 120.1,             p.daily_consumption
      assert_equal -8261,             p.unit_balance
      
      r = p.registers.first
      
      assert_equal "109479:1",        r.register_number
      assert_equal 5,                 r.dials
    end
  end     
  
  def test_current_property
    if STUB_API_CALLS
      Powershop::OAuth.any_instance.expects(:get).with { |url| url =~ /customer/ }.returns(stub(:code => 200, :body => test_response("properties")))
    end
    
    @powershop_client.set_property(property = @powershop_client.properties.first)  
    
    assert_equal property, @powershop_client.current_property
  end
  
  def test_get_meter_readings
    if STUB_API_CALLS
      Powershop::OAuth.any_instance.expects(:get).with { |url| url =~ /customer/ }.returns(stub(:code => 200, :body => test_response("properties")))
      Powershop::OAuth.any_instance.expects(:get).with { |url| url =~ /meter_readings/ }.returns(stub(:code => 200, :body => test_response("meter_readings")))      
    end
    
    @powershop_client.set_property(@powershop_client.properties.first)
    
    assert readings = @powershop_client.get_meter_readings(:start_date => 2.weeks.ago)
    
    if STUB_API_CALLS
      assert_equal "customer", readings.first.reading_type
      assert_equal "63918",      readings.first.reading_value
    end
  end
  
  def test_powershop_errors
    if STUB_API_CALLS
      Powershop::OAuth.any_instance.expects(:get).with { |url| url =~ /meter_readings/ }.returns(stub(:code => 400, :body => test_response("icp_number_error")))      
    end
    
    assert_raises Powershop::PowershopError do
      @powershop_client.get_meter_readings(:start_date => 2.weeks.ago)
    end
  end
  
  def test_products
    if STUB_API_CALLS
      Powershop::OAuth.any_instance.expects(:get).with { |url| url =~ /customer/ }.returns(stub(:code => 200, :body => test_response("properties")))
      Powershop::OAuth.any_instance.expects(:get).with { |url| url =~ /products/ }.returns(stub(:code => 200, :body => test_response("products")))      
    end
    
    @powershop_client.set_property(@powershop_client.properties.first)
    
    assert products = @powershop_client.products
    
    if STUB_API_CALLS
      flower_power_catchup = products.detect { |p| p.name == "$84.90 catch up pack" }
      
      assert_equal "0.1772",      flower_power_catchup.price_per_unit
      assert_match /PowerKiwi/, flower_power_catchup.description
    end
  end

  def test_post_meter_readings
    if STUB_API_CALLS
      Powershop::OAuth.any_instance.expects(:get).with { |url| url =~ /customer/ }.returns(stub(:code => 200, :body => test_response("properties")))
      Powershop::OAuth.any_instance.expects(:post).with { |url| url =~ /meter_readings/ }.returns(stub(:code => 200, :body => test_response("success")))      
    end
    
    property = @powershop_client.properties.first
    @powershop_client.set_property(property)
    
    new_readings = property.registers.inject({}) do |hash, r|
      hash[r.register_number] = r.last_reading_value.to_i + 500
      hash
    end
    
    assert @powershop_client.post_meter_readings(new_readings)
  end

  def test_topping_up
    if STUB_API_CALLS
      Powershop::OAuth.any_instance.expects(:get).with { |url| url =~ /customer/ }.returns(stub(:code => 200, :body => test_response("properties")))
      Powershop::OAuth.any_instance.expects(:get).with { |url| url =~ /top_up/ }.returns(stub(:code => 200, :body => test_response("get_top_up")))
      Powershop::OAuth.any_instance.expects(:post).with { |url| url =~ /top_up/ }.returns(stub(:code => 200, :body => test_response("success")))      
    end
        
    @powershop_client.set_property(@powershop_client.properties.first)
    
    assert top_up_details = @powershop_client.get_top_up
    
    offer_key = top_up_details.offer_key
    assert_not_nil offer_key
    
    assert_raises RuntimeError, "You must specify an Offer Key" do
      @powershop_client.top_up!
    end
    
    assert @powershop_client.top_up!(:offer_key => offer_key)
  end
  
  private
  
    def test_response(name)
      File.open(File.join(File.dirname(__FILE__), "responses", "#{name}.json"), "rb").read
    end
  
end
