module Vigilem
module Win32API
  # 
  # group of all the console input events listed by MSoft
  module ConsoleInputEvents
    
    
    # 
    class MOUSE_EVENT_RECORD < ::VFFIStruct
      layout_with_methods :dwMousePosition, Win32API::COORD,
                     :dwButtonState, :DWORD,
                     :dwControlKeyState, :DWORD,
                     :dwEventFlags, :DWORD
    end
    
    
    # 
    class WINDOW_BUFFER_SIZE_RECORD < ::VFFIStruct
      layout_with_methods :dwSize, Win32API::COORD
    end
    
    
    # "These events are used internally and should be ignored."
    class MENU_EVENT_RECORD < ::VFFIStruct
      layout_with_methods :dwCommandId, :uint
    end
    
    
    # "These events are used internally and should be ignored."
    class FOCUS_EVENT_RECORD < ::VFFIStruct
      layout_with_methods :bSetFocus, :BOOL
    end
    
    
    # 
    class KEY_EVENT_RECORD < ::VFFIStruct
      layout_with_methods :bKeyDown, :BOOL,
                          :wRepeatCount, :WORD,
                          :wVirtualKeyCode, :WORD,
                          :wVirtualScanCode, :WORD,
                          *union(:uChar, 
                            [:UnicodeChar, :unicode_char], :WCHAR,
                            [:AsciiChar, :ascii_char], :CHAR
                          ),
                          :dwControlKeyState, :uint
      
      alias_method :b_key_down, :bKeyDown
      alias_method :w_repeat_count, :wRepeatCount
      alias_method :w_virtual_key_code, :wVirtualKeyCode
      alias_method :w_virtual_scan_code, :wVirtualScanCode
      alias_method :u_char, :uChar
      alias_method :dw_control_key_state, :dwControlKeyState
    end
    
    @events = Win32API::Constants::Events
    
    # 
    # @return [Array<Symbol>]
    def self.vk_names
      @_console_input_events_ ||= @events.constants.grep(/^(?!CTRL).*/)
    end
    
    # 
    # @return [TransmutableHash<Integer, Symbol>]
    def self.vk_hash
      @_console_input_event_hash_ ||= vk_names.map.with_object(Support::TransmutableHash.new()) {|event_name, hsh| hsh[@events.const_get(event_name)] = event_name }
    end
    
    # 
    # @return [Array<VFFIStruct>]
    def self.structs
      @_structs_ ||= constants.map {|const| const_get(const) }
    end
  end
  
  include ConsoleInputEvents
end
end
