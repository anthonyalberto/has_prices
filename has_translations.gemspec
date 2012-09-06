Gem::Specification.new do |s|
  s.name        = 'has_prices'
  s.version     = '0.0.1'
  s.date        = '2012-09-06'
  s.summary     = "Manage prices per currency with ActiveRecord models"
  s.description = "Using your local settings, this gem allows you to call a method `price` on your models. See the Github page for more information"
  s.authors     = ["Anthony Alberto"]
  s.email       = 'alberto.anthony@gmail.com'
  s.files       = ["lib/has_prices.rb"]
  s.homepage    = 'http://github.com/anthonyalberto/has_prices'

  s.require_paths = ['lib']
  s.license     = 'MIT'
  s.add_dependency 'activesupport', '>= 3.0'
  s.add_dependency 'activerecord', '>= 3.0' 
end
