require 'vigilem/ffi'

require 'vigilem/win32_api/input__record'

module Vigilem
module Win32API
  
  # 
  class PINPUT_RECORD
    
    include FFI::ArrayPointerSync
    
    # @see    ArrayPointerSync#initialize_array_sync
    # @param  [Integer || FFI::Pointer] max_len_or_ptr
    # @param  [Array] 
    def initialize(max_len_or_ptr, *init_values)
      initialize_ary_ptr_sync(max_len_or_ptr, *init_values)
    end
    
    class << self
      
      # 
      # @param  [FFI::Pointer]
      # @return [self]
      def from_pointer(pointer)
        new(pointer)
      end
      
      # 
      # @return [Class || Symbol]
      def ary_type
        INPUT_RECORD
      end
      
      # Converts the specified value from the native type.
      # @param  value
      # @param  ctx
      # @return [PINPUT_RECORD]
      def from_native(value, ctx)
        new(value)
      end
      
      # Converts the specified value to the native type.
      # @param  value
      # @param  ctx
      # @return [FFI::Pointer]
      def to_native(value, ctx)
        value.ptr
      end
      
      # 
      # @return [Array<#ary_type>]
      def ary_of_type(pointer)
        _compact(super(pointer))
      end
      
     private
      # 
      # removes records that are #clear?
      # @return [self]
      def _compact(ary)
        ary.reject {|ir| ir.clear? }
      end
    end
    
  end
  PInputRecord = PINPUT_RECORD
  ::FFI.typedef(PINPUT_RECORD, :pinput_record)
  ::FFI.typedef(PINPUT_RECORD, :PINPUT_RECORD)
end
end
