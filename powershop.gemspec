Gem::Specification.new do |s|
  s.name     = "powershop"
  s.version  = "0.0.1"
  s.date     = "2009-12-26"
  s.summary  = "Allows Ruby applications to communicate with the Powershop API"
  s.email    = "nik@codetocustomer.com"
  s.homepage = "http://github.com/codetocustomer/powershop"
  s.description = "Allows Ruby applications to communicate with the Powershop API"
  s.has_rdoc = false
  s.authors  = ["Nik Wakelin"]
  s.add_dependency('oauth', '>= 0.3.1')
  s.add_dependency('activesupport', '>= 2.3.5')  
  s.files    = ["init.rb",
    "LICENSE",
    "Rakefile",
    "README.textile",
    "examples/powershop_example.rb", 
    "lib/powershop.rb",
    "lib/powershop/client.rb",
    "lib/powershop/oauth.rb",
    "lib/powershop/property.rb",
    "lib/powershop/register.rb",
    "script/console",
    "test/client_test.rb",
    "test/test_helper.rb",
    "test/responses/get_top_up.json",
    "test/responses/icp_number_error.json",
    "test/responses/meter_readings.json",
    "test/responses/products.json",
    "test/responses/properties.json",
    "test/responses/success.json",
    "powershop.gemspec"]
end