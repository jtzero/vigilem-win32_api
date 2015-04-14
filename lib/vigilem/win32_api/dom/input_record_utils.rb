require 'vigilem/support'

require 'vigilem/win32_api'
require 'vigilem/win32_api/utils/keyboard'

require 'vigilem/win32_api/virtual_keys'

require 'vigilem/win32_api/dom/key_values_tables'
require 'vigilem/win32_api/dom/code_values_tables'

module Vigilem
module Win32API
module DOM
  # http://msdn.microsoft.com/en-us/library/windows/desktop/dd375731%28v=vs.85%29.aspx
  # methods to convert InputRecords to DOM Events
  # @abstract requires a dom_ir_utils_source method
  #           and included into the same module
  #           as RubyizedAPI
  # @todo module KeyEventRecordUtils
  module InputRecordUtils
    
    NULL_STR = "\x00"
    
    UNKNOWN_VAL = 'Unidentified'
    
    include VirtualKeys
    
    include Constants
    
    include CodeValuesTables
    
    include Utils::Keyboard
    
    # the current keys being pressed
    # @return [Array]
    def current_keys
      @current_keys ||= []
    end
    
    attr_writer :current_keys
    
    # converts and event_record to DOM KeyEvent
    # @note the righ Alt and right ctrl are 'enhanced' 
    # @param  [] event_record
    # @return [Array<Vigilem::DOM::KeyboardEvent>]
    def to_dom_key_event(event_record)
      dw_state_names = dw_control_key_state_vks(event_record.dwControlKeyState)
                    
                    # all test need fixed
                    # will this work for a range? if not it needs to 
      virtual_key_name = Map.virtual_keyname(vk_code = event_record.wVirtualKeyCode)
      
      modifiers = dom_modifiers(*dw_state_names)
      
      b_key_down = event_record.bKeyDown
      
      dom_loc = dom_location(virtual_key_name, event_record.wVirtualScanCode, b_key_down, dw_state_names)
      
      key = dom_key(virtual_key_name, u_char = event_record.uChar.UnicodeChar)
      
      code = dom_code(virtual_key_name, u_char, dom_loc, b_key_down, *dw_state_names)
      
      options = {:key => key, :code => code, :location => dom_loc, :repeat => false, 
                              :modifiers => modifiers, :os_specific => ::FFIUtils.struct_to_h(event_record) }
      
      if b_key_down == 1
        if (prev_event = self.current_keys.last) and %w(keypress keydown).include?(prev_event.type) and prev_event.key == options[:key]
          options[:repeat] = true
        end
        
        key_event = ::VDOM::KeyboardEvent.new('keydown', options)
        key_down_events = [key_event, key_event.copy_to('keypress')]
        (self.current_keys += key_down_events.flatten).sort_by!(&:time_stamp) unless self.current_keys.find {|ck| ck.code == key_event.code and ck.location == key_event.location }
        key_down_events
      else
        key_event = ::VDOM::KeyboardEvent.new('keyup', options)
        self.current_keys.delete_if {|current| current.code == key_event.code and current.location == key_event.location }
        [*key_event].flatten
      end
    end
    
    # converts a Integer representing dwControlKeyState from KEY_EVENT_RECORD to an 
    # array of virtual-keys, Symbols
    # @param  [Integer] dw_control_key_state
    # @return [Array<Symbol>] the win modifiers
    def dw_control_key_state_vks(dw_control_key_state)
      DWControlKeys.constants.select do |const|
        (dw_control_key_state & (value = DWControlKeys.const_get(const))) == value
      end
    end
    
    # 
    # @return [Hash]
    def location_less_vks_map
      @location_less_vks_map ||= {:VK_MENU => /alt/i, :VK_CONTROL => /control|ctrl/i, :VK_SHIFT => /shift/i }
    end
    
    # 
    # @param  [Symbol] vk_name
    # @return [TrueClass || FalseClass]
    def vk_without_location_info?(vk_name)
      location_less_vks_map.keys.include? vk_name
    end
    
    # 
    # @return [Hash]
    def shift_scan_code_to_location_vk
      @shift_scan_location ||= { dom_ir_utils_source.map_virtual_key(VK[:LSHIFT], MAPVK::VK_TO_VSC) => :VK_LSHIFT, 
                                 dom_ir_utils_source.map_virtual_key(VK[:RSHIFT], MAPVK::VK_TO_VSC) => :VK_RSHIFT }
    end
    
    class << self
      # 
      # @param  [String<'L'||'l'||'R'||'r'>] str, to convert
      # @return [String<'R'||'r'||'L'||'l'>] its opposite
      def flip_lr_sides(str)
        str.tr('LlRr', 'RrLl')
      end
      
      # 
      # @param  [Symbol] key_name
      # @return [String || NilClass]
      def lr_location_from_name(key_name)
        key_name.to_s.gsub(/VK_(L(?!EFT)|R(?!IGHT))?.+/, '\1')[/L|R/]
      end
      
      # 
      # @param  [String] str, value to test
      # @return [TrueClass || FalseClass] whether or not the String
      # is #empty? or just contains NULL_STR
      def empty_or_null?(str)
        str.strip.empty? or (str == NULL_STR * str.length)
      end
      
    end
    
    # 
    # @param  [Symbol] vk_name
    # @param  [Array<Symbol>] dw_state_names
    # @param  [Integer] b_key_down
    # @return [Integer<0|1|2>]
    def dom_location(vk_name, v_scancode, b_key_down, dw_state_names)
      l_r_location = InputRecordUtils.lr_location_from_name(vk_name) ||
                     lr_not_in_name(vk_name, v_scancode, b_key_down, dw_state_names) || ""
      
      ::VDOM::Utils.common_str_to_dom_location(l_r_location.upcase) || DOM_KEY_LOCATION_STANDARD
    end
    
    # gets the l or r using other params than just the name
    # @see    location_less_vks_map
    # @todo   change name
    # @param  [Symbol] vk_name
    # @param  [Integer] v_scancode
    # @param  [Symbol<#{location_less_vks_map.keys}>]
    # @raise  [RuntimeError] when the location cannot be found
    # @return [String<'l'|'r'>]
    def lr_not_in_name!(vk_name, v_scancode, b_key_down, dw_state_names)
      if lr = lr_not_in_name(vk_name, v_scancode, b_key_down, dw_state_names)
        lr
      else
        raise RuntimeError, "Cannot get location from #{vk_name}, #{v_scancode}, #{b_key_down}, #{current_keys}, #{dw_state_names}"
      end
    end
    
    # gets the l or r using other params than just the name
    # @todo   change name
    # @see    location_less_vks_map
    # @param  [Symbol] vk_name
    # @param  [Integer] v_scancode
    # @param  [Integer] b_key_down
    # @param  [Symbol<#{location_less_vks_map.keys}>]
    # @return [String<'l'||'r'>]
    def lr_not_in_name(vk_name, v_scancode, b_key_down, dw_state_names)
      if vk_name == :VK_SHIFT
        if lr = InputRecordUtils.lr_location_from_name(shift_scan_code_to_location_vk[v_scancode])
          lr.downcase
        end
      else
        regexp = location_less_vks_map[vk_name]
        available_state_names = dw_state_names.grep(regexp)
        if b_key_down == 1
          if available_state_names.size == 1
            InputRecordUtils.lr_location_from_name(available_state_names.first).downcase
          elsif available_state_names.size > 1 #both pressed
            previous_match = _get_current_keys_by_key_and_type(regexp, 'keydown')
            if previous_match.size == 2 # both already pressed? repeat
              ::VDOM::Utils.dom_location_to_common_str(previous_match.last.location)
            elsif previous_match.size == 1 # must be new
              InputRecordUtils.flip_lr_sides(::VDOM::Utils.dom_location_to_common_str(previous_match.last.location).downcase)
            end
          end
        else
          if available_state_names.size == 1 # keyup and other one is currently pressed? this is the other
            InputRecordUtils.flip_lr_sides(InputRecordUtils.lr_location_from_name(available_state_names.first).downcase)
          elsif available_state_names.size == 0 # last one just released
            if not (previous_match = _get_current_keys_by_key_and_type(regexp, 'keydown')).empty?
              ::VDOM::Utils.dom_location_to_common_str(previous_match.last.location)
            end
          end
        end
        
      end
      
    end
    
    # 
    # @param  [regexp] key
    # @param  [String] type
    # @return [Array<VDOM::KeyboardEvent>]
    def _get_current_keys_by_key_and_type(key, type)
      self.current_keys.select {|current| current.key =~ key and current.type == type }
    end
    
    # @see    MapVirtualKey
    # @param  [Symbol] virtual_key
    # @param  u_char
    # @return [String]
    def dom_key(virtual_key, u_char)
      vk = :"VK_#{virtual_key.to_s.gsub(/^VK_/, '')}"
         # returns 0 when no character available
      if KeyValuesTables::WhitespaceKeys.has_key?(vk) or
        (character = dom_ir_utils_source.map_virtual_key(Map.virtual_key_code(vk), MAPVK::VK_TO_CHAR)) == 0
        KeyTable.dom_key(vk) || UNKNOWN_VAL
      else
        u_char.chr
      end
    end
    
    # 
    # @param  [Symbol] virtual_key
    # @param  [String] u_char_value
    # @param  [String<"l"||"r"> || Integer] location
    # @param  [Array<Symbol<:LEFT_KEY_PRESSED||"r">>] location
    # @raise  RuntimeError 
    # @return 
    def dom_code(virtual_key, u_char_value, location, *dw_state_names)
      if (code = CodeTable.dom_code(Support::Utils.unwrap_ary([*dw_state_names.grep(:ENHANCED_KEY), virtual_key])))
        if code.is_a? Array
          dom_loc = location.is_a?(String) ? ::VDOM::Utils.common_str_to_dom_location(location.upcase) : location
          code.grep(::VDOM::Utils.codes_regex[dom_loc]).first
        else
          code
        end
      else
        char = u_char_value.chr
        if dcode = key_or_digit_code(char)
          dcode
        elsif (vk_char = virtual_key.to_s.gsub('VK_', '')).size == 1 and (vk_code = key_or_digit_code(vk_char))
          vk_code
        else
          UNKNOWN_VAL
        end
      end
    end
    
    # 
    # @param  [String] char
    # @return [String || NilClass] 
    def key_or_digit_code(char)
      schar = char.to_s
      if schar =~ /^[a-z]$/i
        "Key#{char.upcase}"
      elsif schar =~ /^[0-9]$/
        "Digit#{char}"
      end
    end
    
    # @see    Vigilem::DOM::KeyEvent::alternative_key_names
    # @param  [Array] dw_control_state_names
    # @return [Array] 
    def dom_modifiers(*dw_control_state_names)
      ::VDOM::KeyboardEvent::shared_keyboard_and_mouse_event_init(dw_control_state_names.map do |mod| 
          if mod == :RIGHT_ALT_PRESSED
            :metaKey
          else
            mod.to_s.gsub(/right|left|pressed|on|_/i, '').downcase.to_sym
          end
        end)
    end
    
   private
    
    attr_writer :dom_ir_utils_source
    
    alias_method :dom_ir_utils_src=, :dom_ir_utils_source=
    
    # 
    # @raise  [NotImplementedError]
    # @return 
    def dom_ir_utils_source
      @dom_ir_utils_source ||= self
    end
    
    alias_method :dom_ir_utils_src=, :dom_ir_utils_source
    
  end
end
end
end