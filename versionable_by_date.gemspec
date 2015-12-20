$LOAD_PATH.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'versionable_by_date/gem_version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'versionable_by_date'
  s.version     = VersionableByDate::VERSION
  s.authors     = ['draffensperger']
  s.email       = ['d.raffensperger@gmail.com']
  s.homepage    = 'https://github.com/CruGlobal/versionable_by_date'
  s.summary     = 'Date-granular versioning for specific model fields (query-friendly history log)'
  s.description = 'This complements a full audit trail solution by giving a '\
                  'compact queryable history log for specified fields.'
  s.license     = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  s.add_dependency 'activerecord', ['>= 3.0', '< 6.0']
  s.add_dependency 'activesupport', ['>= 3.0', '< 6.0']

  s.add_development_dependency 'rails', '~> 4.2.5'
  s.add_development_dependency 'rspec-rails', '~> 3.4.0'
  s.add_development_dependency 'rubocop', '~> 0.35.1'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'pry-byebug'
end
