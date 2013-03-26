$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'rspec'
require 'rr'
require 'rspec/autorun'
require 'actionmailer_extensions'

RSpec.configure do |config|
  config.include(RR::Adapters::RSpec2)
end

