lib = File.expand_path('../lib', __FILE__)
$:.unshift(lib) unless $:.include?(lib)
require 'client/version'

Gem::Specification.new do |s|
  s.name        = 'shutterstock-client'
  s.version     = ShutterstockAPI::VERSION
  s.date        = '2014-02-21'
  s.summary     = 'A ruby client to work with shutterstock api'
  s.description = "see summary"
  s.authors     = ['jhogue, vkajjam, flindiakos, wusher, alicht']
  s.email       = 'vkajjam@shutterstock.com'

  s.files        = Dir[
    'README.md', 'LICENSE', 'Rakefile', 'lib/**/*'
  ]
  s.test_files   = Dir['spec/**/*']

  s.homepage    = 'https://github.com/shutterstock/ruby-shutterstock-api' 
  s.license     = 'Copyright shutterstock.com 2014'
  s.add_dependency "httparty"
  s.add_dependency "activesupport"
  s.add_dependency "rspec"
  s.add_development_dependency "pry"
  s.add_development_dependency "vcr"
  s.add_development_dependency "webmock"
  s.add_development_dependency "rake"
  s.add_development_dependency "guard"
  s.add_development_dependency "guard-rspec"
  s.add_development_dependency "rb-readline"
  s.add_development_dependency "rubocop"
end
