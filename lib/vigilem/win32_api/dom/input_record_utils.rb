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
      
      dom_loc = dom_location(virtual_key_name, event_record.wVirtualScanCode, dw_state_names)
      
      key = dom_key(virtual_key_name, u_char = event_record.uChar.UnicodeChar)
      
      code = dom_code(virtual_key_name, u_char, dom_loc, *dw_state_names)
      
      options = {:key => key, :code => code, :location => dom_loc, :repeat => false, 
                              :modifiers => modifiers, :os_specific => ::FFIUtils.struct_to_h(event_record) }
      
      if event_record.bKeyDown == 1
        if (prev_event = current_keys.last) and %w(keypress keydown).include?(prev_event.type) and prev_event.key == options[:key]
          options[:repeat] = true
        end
        
        key_event = ::VDOM::KeyboardEvent.new('keydown', options)
        key_down_events = [key_event, key_event.copy_to('keypress')]
        @current_keys += key_down_events.flatten
        key_down_events
      else
        key_event = ::VDOM::KeyboardEvent.new('keyup', options)
        current_keys.delete_if {|current| current.key == key_event.key and current.location == key_event.location }
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
    # @return [Integer<0|1|2>]
    def dom_location(vk_name, v_scancode, dw_state_names)
      l_r_location = InputRecordUtils.lr_location_from_name(vk_name) ||
                     lr_not_in_name(vk_name, v_scancode, dw_state_names) || ""
      
      ::VDOM::Utils.common_str_to_dom_location(l_r_location.upcase) || DOM_KEY_LOCATION_STANDARD
    end
    
    # gets the l or r using other params than just the name
    # @see    location_less_vks_map
    # @param  [Symbol] vk_name
    # @param  [Integer] v_scancode
    # @param  [Symbol<#{location_less_vks_map.keys}>]
    # @raise  [RuntimeError] when the location cannot be found
    # @return [String<'l'|'r'>]
    def lr_not_in_name!(vk_name, v_scancode, dw_state_names)
      if lr = lr_not_in_name(vk_name, v_scancode, dw_state_names)
        lr
      else
        raise RuntimeError, "Cannot get location from #{vk_name}, #{v_scancode}, #{current_keys}, #{dw_state_names}"
      end
    end
    
    # gets the l or r using other params than just the name
    # @see    location_less_vks_map
    # @param  [Symbol] vk_name
    # @param  [Integer] v_scancode
    # @param  [Symbol<#{location_less_vks_map.keys}>]
    # @return [String<'l'||'r'>]
    def lr_not_in_name(vk_name, v_scancode, dw_state_names)
      if vk_name == :VK_SHIFT
        if lr = InputRecordUtils.lr_location_from_name(shift_scan_code_to_location_vk[v_scancode])
          lr.downcase
        end
      else
        regexp = location_less_vks_map[vk_name]
        # other side key pressed? weird but eh
        if other_location = current_keys.find {|current| current.key =~ regexp }
          InputRecordUtils.flip_lr_sides(::VDOM::Utils.to_dom_location_common_str(other_location.location)).downcase
        # ok other one isn't being pressed then the one showing up in dw_control_state is this
        else
          applicable_state_names = dw_state_names.grep(regexp)
          # there are no previous keys 
          if applicable_state_names.size > 1
            raise "Both `#{vk_name}' are pressed but there is no record in the current keys:#{current_keys.join(',')}"
          elsif location = InputRecordUtils.lr_location_from_name(dw_state_names.grep(regexp).first)
            location.downcase
          end
        end
      end
    end
    
    # @see    MapVirtualKey, 
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
        if(char = u_char_value.chr) =~ /^[a-z]$/i
          "Key#{char.upcase}"
        elsif char =~ /^[0-9]$/
          "Digit#{char}"
        else
          UNKNOWN_VAL
        end
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