require 'vigilem/win32_api/console_input_events'

module Vigilem
module Win32API
  
  # 
  class INPUT_RECORD < ::VFFIStruct
    
    # @!attr [Integer] the ID type of this record
    layout_with_methods :EventType, :WORD,
      *(union(:Event) do
        ConsoleInputEvents.vk_names.map do |event|
          event.to_s.downcase.titlecase.split(/\s+/).join.to_sym
        end.sort.zip(ConsoleInputEvents.structs.sort {|klass, other_klass| klass.name <=> other_klass.name }).flatten
      end)
    
    # 
    # @return [Hash]
    def to_h
      hsh = FFIUtils.struct_to_h(self)
      sym = self.class.event_record_sym(type)
      hsh[:Event].reject! {|key, value| key != sym }
      hsh
    end
    
    # 
    # @return [Integer]
    def type
      self.EventType
    end
    
    # 
    # @return [INPUT_RECORD::Union::*_EVENT_RECORD]
    def event_record
      self.class.event_record(self)
    end
    
    class << self
      # 
      # @param  input_record [EventUnion?]
      # @return [INPUT_RECORD::Union::*_EVENT_RECORD]
      def event_record(input_record)
        sym = event_record_sym(input_record.EventType)
        input_record.Event[sym] unless sym.nil? or sym.empty?
      end
      
      # 
      # @param  [Integer] event_type
      # @return [Symbol]
      def event_record_sym(event_type)
        ConsoleInputEvents.vk_hash[event_type].to_s.downcase.titlecase.gsub(/\s+/, '').to_sym
      end
    end
    
    # 
    # @return [String] 
    def inspect
      head, tail = super.split(' ', 2)
      "#{head} event_record=#{event_record.inspect} #{tail}"
    end
  end
  InputRecord = INPUT_RECORD
end
end