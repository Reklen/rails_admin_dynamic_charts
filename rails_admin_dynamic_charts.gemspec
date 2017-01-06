$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'rails_admin_dynamic_charts/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'rails_admin_dynamic_charts'
  s.version     =  RailsAdminDynamicCharts::VERSION
  s.authors     = ['Miguel Sancho', 'Maikel Arcia', 'Abel Esponda']
  s.email       = %w(sanchojaf@gmail.com macarci@gmail.com abelesponda8916@gmail.com)
  s.homepage    = 'https://github.com/abelesponda/rails_admin_dynamic_charts'
  s.summary     = 'Charts for Rails Admin'
  s.description = 'Dynamic Charts for Rails Admin'

  s.files = Dir['{app,config,db,lib}/**/*']
  s.test_files = Dir['spec/**/*']

  s.add_dependency 'rails', '>= 3.2'
  s.add_dependency 'rails_admin', '> 0'
  s.add_dependency 'chartkick', '> 0'
  s.add_dependency 'jquery-rails'
  s.add_dependency 'descriptive_statistics', '> 0'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'sqlite3'
  s.license = 'MIT'
end
