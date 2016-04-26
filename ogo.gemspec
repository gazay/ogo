lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ogo/version'

Gem::Specification.new do |s|
  s.name        = 'ogo'
  s.version     = Ogo::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['gazay']
  s.licenses    = ['MIT']
  s.email       = ['alex.gaziev@gmail.com']
  s.homepage    = 'https://github.com/gazay/ogo'
  s.summary     = %q{Parse open graphs for social networks}
  s.description = %q{Provides information from opengraph tags for different social networks}

  s.files         = `git ls-files`.split("\n")
  s.require_paths = ['lib']
  s.required_ruby_version = '> 2.0'
  s.add_dependency 'nokogiri', '>= 1.6'
  s.add_dependency 'addressable', '>= 2.4.0'
  s.add_development_dependency 'rspec', '>= 3.0'
  s.add_development_dependency 'fastimage'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'byebug'
  s.add_development_dependency 'rake'
end
