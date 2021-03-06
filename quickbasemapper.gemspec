Gem::Specification.new do |s|
  s.name         = 'quickbasemapper'
  s.version      = '2.0.1'
  s.date         = '2012-07-03'
  s.summary      = "AR-like library for interacting with QuickBase"
  s.description  = "AR-like library for interacting with QuickBase"
  s.authors      = ["AIS"]
  s.email        = 'khensel@advantagequickbase.com'
  s.files        = ["lib/quickbasemapper.rb"]
  s.homepage     = 'http://www.advantagequickbase.com'
  
  s.add_dependency 'gmail', '~> 0.4.0'
  s.add_dependency 'tlsmail'
end