require 'spec_helper'

module RubyizedSteps

  include InputHelper
  
  # this is malformed but due do timing and blocking this si the best way
  step 'read_console_input called before user presses a key' do
    adapt = InputSystemHandler.new
    flush
    write_console_input_test
    @api_return = adapt.read_console_input
  end
  
  step 'a PINPUT_RECORD is returned' do
    expect(@api_return).to be_a ::Vigilem::Win32API::PINPUT_RECORD
  end
end

RSpec.configure { |c| c.include RubyizedSteps }
