# @todo metal events need to be in another windows console
# @todo alot of the receive methods are too brittle

require 'bundler'
Bundler.setup

require 'timeout'

require 'vigilem/support/core_ext/debug_puts'

require 'attributes_and_size_test'

require 'input_helper'

=begin
#to discover when tests hang which will happen because I have not correctly isolated the tests
# also can use rspec -f d
RSpec.configure do |config|
  
  config.before :all do |example_group|
    puts "#{example_group.class.description}"
  end
  
  config.before :each do |example|
    puts "->#{example.description}"
  end
end
=end
