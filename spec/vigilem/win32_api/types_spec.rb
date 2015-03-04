require 'spec_helper'

describe Vigilem::Win32API::Types do
=begin
    # Check for 64b operating systems.
    if Vigilem::Core::System.x64bit?
      ::FFI.typedef(:uint64, :ulong_ptr)
      ::FFI.typedef(:int64, :long_ptr)
    else
      ::FFI.typedef(:ulong, :ulong_ptr)
      ::FFI.typedef(:long, :long_ptr)
    end
=end
  describe described_class::PVOID do
    
    describe '::from_native' do
      
      #def from_native(value, ctx)
      #  value.address
      #end
    end
    
    describe '::to_native' do
      
=begin
      def to_native(value, ctx)
        case
        when value.kind_of?(FFI::Pointer)
          value
        when value.kind_of?(FFI::Struct)
          value.to_ptr
        else
          FFI::Pointer.new(value.to_i)
        end
      end
=end
    end
  end
=begin
    
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
          value
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
    ::FFI.typedef(:handle, :HWND)
    
    ::FFI.typedef(:ushort, :word)
    ::FFI.typedef(:ushort, :WORD)
    
    ::FFI.typedef(:ushort, :wchar)
    ::FFI.typedef(:ushort, :WCHAR)
    
    ::FFI.typedef(:uint, :dword)
    ::FFI.typedef(:uint, :DWORD)
    
    ::FFI.typedef(:int, :BOOL)
    
    ::FFI.typedef(:uchar, :BYTE)
    
    ::FFI.typedef(:ulong_ptr, :WPARAM)
    ::FFI.typedef(:long_ptr, :LPARAM)
=end
  describe described_class::POINT do
    
    it 'will have methods as attrs' do
      expect(described_class.new).to respond_to(:x, :y)
    end
    
    it %q(will have an size eql to it's layout types sizes) do
      expect(described_class.new.to_ptr.type_size).to eql(described_class.size)
    end
  end
  
  describe described_class::MSG do
    
    it 'will have methods as attrs' do
      expect(described_class.new).to respond_to(:hwnd, :message, :wParam, :lParam, :time, :pt)
    end
    
    it %q(will have an size eql to it's layout types sizes) do
      expect(described_class.new.to_ptr.size).to eql(described_class.size)
    end
    
  end
  
  describe described_class::COORD do
    it_behaves_like 'attributes_and_size_test' do
      let(:ary) { [:x, :y] }
      let(:sze) { 4 }
    end
  end
  
end