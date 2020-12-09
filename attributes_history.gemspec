$LOAD_PATH.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'attributes_history/gem_version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'attributes_history'
  s.version     = AttributesHistory::VERSION
  s.authors     = ['draffensperger']
  s.email       = ['d.raffensperger@gmail.com']
  s.homepage    = 'https://github.com/CruGlobal/attributes_history'
  s.summary     = 'Date-granular history for specified model fields. Compact & easy to query.'
  s.description = s.summary
  s.license     = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  s.add_dependency 'activerecord', ['>= 3.0', '< 6.2']
  s.add_dependency 'activesupport', ['>= 3.0', '< 6.2']

  s.add_development_dependency 'rails', '~> 6.1.0'
  s.add_development_dependency 'rspec-rails', '~> 3.8.0'
  s.add_development_dependency 'rubocop', '~> 0.49.0'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'pry-byebug'
end
