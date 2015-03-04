module Vigilem

# 
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
      FFIUtils.struct_to_h(self)
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
    
    # 
    # @param  input_record [EventUnion?]
    # @return [INPUT_RECORD::Union::*_EVENT_RECORD]
    def self.event_record(input_record)
      sym = ConsoleInputEvents.vk_hash[input_record.EventType].to_s.downcase.titlecase.gsub(/\s+/, '').to_sym
      input_record.Event[sym] unless sym.nil? or sym.empty?
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