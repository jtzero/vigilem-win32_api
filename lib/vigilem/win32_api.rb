require 'ffi'

require 'vigilem/win32_api/constants'
require 'vigilem/win32_api/virtual_keys/map'

require 'vigilem/win32_api/types'
require 'vigilem/win32_api/console_input_events'

require 'vigilem/win32_api/input__record'
require 'vigilem/win32_api/p_input__record'

module Vigilem

  # @see    http://msdn.microsoft.com for usage
  # @todo   consider FFI options Hash :blocking (Boolean) — default: @blocking — set to true if the C function is a blocking call
  module Win32API
    include Constants
    
    VirtualKeys::Map.invert.each do |vk_name, int|
      const_set(vk_name, int)
    end
    
    extend ::FFI::Library
    
    ffi_lib 'kernel32', 'user32'
    ffi_convention :stdcall
    
    attach_function :GetStdHandle, [:DWORD], :HANDLE
    
    attach_function :MapVirtualKeyW, [:UINT, :UINT], :UINT
    
   module_function
    
    def PeekConsoleInputW(hConsoleInput, lpBuffer, nLength, lpNumberOfEventsRead)
      _PeekConsoleInputW(hConsoleInput, lpBuffer, nLength, lpNumberOfEventsRead)
    end
    
    def ReadConsoleInputW(hConsoleInput, lpBuffer, nLength, lpNumberOfEventsRead)
      _ReadConsoleInputW(hConsoleInput, lpBuffer, nLength, lpNumberOfEventsRead)
    end
    
    def ReadConsoleInputW(hConsoleInput, lpBuffer, nLength, lpNumberOfEventsRead)
      _ReadConsoleInputW(hConsoleInput, lpBuffer, nLength, lpNumberOfEventsRead)
    end
    
    def WriteConsoleInputW(hConsoleInput, lpBuffer, nLength, lpNumberOfEventsRead)
      _WriteConsoleInputW(hConsoleInput, lpBuffer, nLength, lpNumberOfEventsRead)
    end
    
   private
    
    attach_function :_PeekConsoleInputW, :PeekConsoleInputW, [:HANDLE, :PINPUT_RECORD, :DWORD, :pointer], :BOOL
    
    attach_function :_ReadConsoleInputW, :ReadConsoleInputW, [:HANDLE, :PINPUT_RECORD, :DWORD, :pointer], :BOOL
    
    attach_function :_ReadConsoleInputW, :ReadConsoleInputW, [:HANDLE, :PINPUT_RECORD, :DWORD, :pointer], :BOOL
    
    # future use
    attach_function :_WriteConsoleInputW, :WriteConsoleInputW, [:HANDLE, :PINPUT_RECORD, :DWORD, :pointer], :BOOL
    
  end
end

require 'vigilem/win32_api/rubyized'

require 'vigilem/win32_api/input_system_handler'

require 'vigilem/win32_api/dom'