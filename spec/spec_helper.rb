$LOAD_PATH << File.join([File.dirname(__FILE__)])

require 'rubygems'
require 'rspec'
require 'mcollective'
require 'mcollective/client'
require 'mcollective/test'

#require_relative '../application/mysqlreplication.rb'
require_relative '../agent/mysqlreplication.rb'

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'
  config.mock_with :mocha

  config.include(MCollective::Test::Matchers)
  config.before :each do
    MCollective::PluginManager.clear
  end
end
