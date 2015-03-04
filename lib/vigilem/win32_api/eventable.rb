module Vigilem::Win32API
  # 
  # @abstract included into the same module as RubyizedAPI
  #           or respond_to? [:read_console_input, :peek_console_input]  
  module Eventable
    
    # @param  [Integer] limit
    # @return [Array]
    def read_many_nonblock(limit=1)
      [*(read_console_input({:nLength => limit, :blocking => false }) if has_any?)]
    end
    
    # blocks until the specified number of events are read
    # @param  [Integer] number_of_events=1
    # @return [Array] 
    def read_many(number_of_events=1)
      read_console_input({:nLength => number_of_events, :blocking => true })
    end
    
    # non_blocking
    # commonly used with event processing
    # @param  [Integer]
    # @return [InputRecord]
    def read_one_nonblock
      read_one if has_any?
    end
    
    # blocking
    # reads one event from the input buffer
    # @return [Array]
    def read_one
      read_console_input.shift
    end
    
    # checks whether the input buffer has events
    # @return [TrueClass || FalseClass]
    def has_any?
      peek_console_input.size > 0
    end
  end
end
