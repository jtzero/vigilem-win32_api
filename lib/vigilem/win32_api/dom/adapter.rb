require 'vigilem./core/adapters/buffered_adapter'

require 'vigilem/core/eventable'

require 'vigilem/core/event_handler'

require 'vigilem/win32_api/input_system_handler'

module Vigilem
module Win32API
module DOM
  # 
  # 
  class Adapter
    
    require 'vigilem/win32_api/dom/input_record_utils'
    
    include InputRecordUtils
    
    include Core::Adapters::BufferedAdapter
    
    include Core::EventHandler
    
    default_handler()
    
    # 
    # @param  link
    def initialize(link=InputSystemHandler.new)
      initialize_buffered(link)
      self.dom_ir_utils_source = link
      on(Win32API::KEY_EVENT_RECORD) {|event| to_dom_key_event(event) } 
    end
    
    include Core::Eventable
    
    # 
    # @param  [Integer] limit
    # @return 
    def read_many_nonblock(limit=1)
      buffered!(limit) do |len_remainder|
        dom_src_events = link.read_many_nonblock(len_remainder).map do |event| 
          handle(event.event_record)
        end.compact.flatten
        ret, to_buffer = Support::Utils.split_at(dom_src_events, len_remainder)
        buffer.concat([*to_buffer])
        ret
      end
    end
    
    # 
    # @return [TrueClass || FalseClass]
    def has_any?
      not buffer.empty? || link.has_any?
    end
    
  end
end
end
end