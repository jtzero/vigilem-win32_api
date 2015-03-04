=begin
require 'bundler'
Bundler.setup

require 'vigilem/win32'

require 'vigilem/win32_api/event_common'

include Vigilem::Win32API

module FakeInputSystem
  class << self
    
    INPUT_RECORD = Vigilem::Win32API::INPUT_RECORD
    
    def GetStdHandle(arg)
      3
    end
    
    def PeekConsoleInputW(hConsoleInput, lpBuffer, nLength, lpNumberOfEventsRead)
      lpBuffer.replace([INPUT_RECORD.new])
      1
    end
    
    def ReadConsoleInputW(hConsoleInput, lpBuffer, nLength, lpNumberOfEventsRead)
      lpBuffer.replace([INPUT_RECORD.new])
      1
    end
  end
end

adapt = EventCommon::Adapter.new.attach(InputSystemHandler.new(FakeInputSystem))

puts 'press a button'

puts adapt.read_console_input.inspect
=end