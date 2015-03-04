require 'ffi'

require 'vigilem/core'

module Vigilem
module Win32API
  
  # 
  module Types
    
    extend ::FFI::Library
  
    # Check for 64b operating systems.
    if Vigilem::Core::System.x64bit?
      ::FFI.typedef(:uint64, :ulong_ptr)
      ::FFI.typedef(:int64, :long_ptr)
    else
      ::FFI.typedef(:ulong, :ulong_ptr)
      ::FFI.typedef(:long, :long_ptr)
    end
    
    
    # 
    module PVOID
      extend ::FFI::DataConverter
      native_type ::FFI::Type::POINTER
      
      class << self
        # Converts the specified value from the native type.
        # @return [Bignum, Integer]
        def from_native(value, ctx)
          value.address
        end
        
        # Converts the specified value to the native type.
        # @return [::FFI::Pointer]
        def to_native(value, ctx)
          case
          when value.kind_of?(::FFI::Pointer)
            value
          when value.kind_of?(::FFI::Struct)
            value.to_ptr
          else
            ::FFI::Pointer.new(value.to_i)
          end
        end
      end
    end
    
    
    # 
    class PBYTE
    
      include ::Vigilem::FFI::ArrayPointerSync
      
      # @see    ArrayPointerSync#initialize_array_sync
      # @param  [Integer || ::FFI::Pointer] max_len_or_ptr
      # @param  [Array] 
      def initialize(max_len_or_ptr, *init_values)
        initialize_array_sync(max_len_or_ptr, *init_values)
      end
      
      class << self
        
        # 
        # [Class || Symbol] 
        def array_type
          :BYTE
        end
        
        # Converts the specified value from the native type.
        # @return [Integer]
        def from_native(value, ctx)
          new(value)
        end
        
        # Converts the specified value to the native type.
        # @return [::FFI::Pointer]
        def to_native(value, ctx)
          case 
          when value.is_a?(::FFI::Pointer)
            value
          when value.is_a?(self)
            value.ptr
          else
            raise "#{value} is an Unsupported Type"
          end
        end
      end
    end
    
    ::FFI.typedef(PVOID, :p_void)
    ::FFI.typedef(PVOID, :PVOID)
    
    ::FFI.typedef(PBYTE, :PBYTE)
    
    ::FFI.typedef(:p_void, :handle)
    ::FFI.typedef(:PVOID, :HANDLE)
    
    ::FFI.typedef(:handle, :h_wnd)
    ::FFI.typedef(:h_wnd, :HWND)
    
    ::FFI.typedef(:ushort, :word)
    ::FFI.typedef(:word, :WORD)
    
    ::FFI.typedef(:ushort, :wchar)
    ::FFI.typedef(:wchar, :WCHAR)
    
    ::FFI.typedef(:ushort, :char)
    ::FFI.typedef(:char, :CHAR)
    
    ::FFI.typedef(:uint, :dword)
    ::FFI.typedef(:uint, :DWORD)
    
    ::FFI.typedef(:uint, :UINT)
    
    ::FFI.typedef(:int, :BOOL)
    
    ::FFI.typedef(:uchar, :BYTE)
    
    ::FFI.typedef(:ulong_ptr, :WPARAM)
    ::FFI.typedef(:long_ptr, :LPARAM)
    
    
    # 
    class POINT < ::VFFIStruct
      layout_with_methods :x, :long,
                          :y, :long
    end
    
    
    # 
    class MSG < ::VFFIStruct
      layout_with_methods :hwnd, :HWND,
                          :message, :uint,
                          :wParam, :WPARAM,
                          :lParam, :LPARAM,
                          :time, :DWORD,
                          :pt, POINT
    end
    
    
    # 
    class COORD < ::VFFIStruct
      layout_with_methods :x, :short,
                          :y, :short
    end
    
  end
  
  include Types
end
end