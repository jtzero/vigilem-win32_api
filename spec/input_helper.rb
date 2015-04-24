require 'fiddle/import'

require 'coveralls'
Coveralls.wear!

module InputHelper
  include Vigilem::Win32API
  
  module Fid
    require 'fiddle/types'
    
    extend Fiddle::Importer
    
    dlload 'kernel32.dll', 'user32.dll'
    
    include Fiddle::Win32Types
    
    extern 'HANDLE GetStdHandle(DWORD)', :stdcall
    
    extern 'BOOL FlushConsoleInputBuffer(HANDLE)', :stdcall
    
    extern 'BOOL WriteConsoleInput(HANDLE, PVOID, DWORD, PVOID)', :stdcall
  end
  
  def std_handle
    Fid.GetStdHandle(0xFFFFFFF6)
  end
  
  # clear out the user entered stuff queue
  def flush
    Fid.FlushConsoleInputBuffer(std_handle) 
  end
  
  def write_console_input_test(num_to_write=1)
    nLength ||= 1
    lpNumberOfEventsWritten ||= ' ' * 4
    1.upto(num_to_write) do |num|
      if num.odd?
        Fid.WriteConsoleInput(std_handle, [0x0001, 1, 0, 0x61, 1, 0x41, 97].pack('SxxlSSSSL'), 
                                                                           nLength, lpNumberOfEventsWritten)
      else
        Fid.WriteConsoleInput(std_handle, [0x0001, 0, 0, 0x61, 1, 0x41, 97].pack('SxxlSSSSL'), 
                                                                           nLength, lpNumberOfEventsWritten)
      end
    end
    
  end
  
end

RSpec.configure do |c|
  c.include InputHelper
end
