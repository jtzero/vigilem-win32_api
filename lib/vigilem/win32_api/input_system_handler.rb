require 'vigilem/core/input_system_handler'

require 'vigilem/core/hub'

require 'vigilem/core/adapters/buffered_adapter'

require 'vigilem/win32_api'

require 'vigilem/win32_api/rubyized'

require 'vigilem/win32_api/eventable'

module Vigilem
module Win32API
  
  # 
  class InputSystemHandler
    
    include Core::InputSystemHandler
    
    include Core::Adapters::BufferedAdapter
    
    include Rubyized
    
    include Eventable
    
    # 
    # @param lnk
    def initialize(lnk=nil)
      initialize_buffered(lnk || Vigilem::Win32API)
    end
    
    def win32_api_rubyized_source
      self
    end
    
    def_delegator :link, :GetStdHandle
    
    # 
    # @param  [Finum] hConsoleInput
    # @param  [PINPUT_RECORD] lpBuffer, out, this item will be updated
    # @param  [Integer] nLength
    # @param  [::FFI::Pointer] lpNumberOfEventsRead, out, this item will be updated
    # @return [Integer] 1 or 0
    def PeekConsoleInput(hConsoleInput, lpBuffer, nLength, lpNumberOfEventsRead)
      semaphore.synchronize {
        events = buffered(nLength) do |len_remainder|
          ret = link.PeekConsoleInputW(hConsoleInput, lpBuffer, nLength, lpNumberOfEventsRead)
          lpBuffer
        end
        _update_out_args(lpBuffer, lpNumberOfEventsRead, events)
        ret ||= 1
      }
    end
    
    # 
    # @param  [Finum] hConsoleInput
    # @param  [PINPUT_RECORD] lpBuffer, out, this item will be updated
    # @param  [Integer] nLength
    # @param  [::FFI::Pointer] lpNumberOfEventsRead, out, this item will be updated
    # @return [Integer] 1 or 0
    def ReadConsoleInput(hConsoleInput, lpBuffer, nLength, lpNumberOfEventsRead)
      semaphore.synchronize {
        events = buffered!(nLength) do |still_to_get|
          ret = link.ReadConsoleInputW(hConsoleInput, lpBuffer, still_to_get, lpNumberOfEventsRead)
          demux(*lpBuffer) unless lpBuffer.empty?
          lpBuffer
        end
        _update_out_args(lpBuffer, lpNumberOfEventsRead, events)
        ret ||= 1
      }
    end
    
    # 
    # @see    
    # @param  [Integer] uCode
    # @param  [Integer] uMapType
    # @return 
    def MapVirtualKey(uCode, uMapType)
      # without this it could fail silently
      raise ArgumentError, "uCode has to be a Integer not #{uCode.class}:`#{uCode}'" unless uCode.is_a? Integer
      raise ArgumentError, "uMapType has to be a Integer not #{uMapType.class}:`#{uMapType}'" unless uMapType.is_a? Integer
      link.MapVirtualKeyW(uCode, uMapType)
    end
    
    # the hub that sends and receives messages for 
    # this buffer
    # @raise  RuntimeError
    # @return 
    def hub
      @hub ||= (Core::Hub.aquire(link()) << self.buffer)
    end
    
    # 
    # @see    Hub#demux
    # @param  [Array] msgs
    # @return 
    def demux(*msgs)
      hub.demux(self, *msgs)
    end
   private
    
    # 
    # @param  [PINPUT_RECORD] lpBuffer
    # @param  [::FFI::Pointer] lpNumberOfEventsRead
    # @param  [Array] events
    # @return [Array]
    def _update_out_args(lpBuffer, lpNumberOfEventsRead, events)
      FFIUtils.add_int_typedef(lpNumberOfEventsRead, :dword, evnt_sze = events.size)
      begin
        lpBuffer.replace(events + [*lpBuffer[evnt_sze..-1]])
      rescue ArgumentError => e
        if e.message =~ /bad value for range/
          e.message.replace("#{e.message}, #{evnt_sze.inspect}..-1")
          raise e
        else
          raise
        end
      end
    end
    
  end
end
end
