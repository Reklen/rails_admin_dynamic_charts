ENV["RAILS_ENV"] ||= 'test'

require File.expand_path("../dummy/config/environment", __FILE__)
require 'rspec/rails'
require 'rails_admin'

ENGINE_RAILS_ROOT=File.join(File.dirname(__FILE__), '../')


Dir[File.join(ENGINE_RAILS_ROOT, 'spec/support/**/*.rb')].each {|f| require f}


RSpec.configure do |config|
  config.mock_with :rspec
end