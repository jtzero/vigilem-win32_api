require 'vigilem/win32_api/virtual_keys'

module Vigilem::Win32API
module Utils
# http://www.w3.org/TR/2013/WD-uievents-20130725/keyboard-sections.svg
# http://www.computer-hardware-explained.com/image-files/computer-keyboard-layout-explained.jpg
# https://upload.wikimedia.org/wikipedia/commons/9/9c/ISO_keyboard_%28105%29_QWERTY_UK.svg
# http://i.stack.imgur.com/FU0R2.png
# 
module Keyboard
  
  include Vigilem::Win32API::VirtualKeys
  
  # 
  # 
  module ControlPadKeys
    
    # 
    # @param  virtual_key
    # @return [TrueClass || FalseClass]
    def control_pad_key?(virtual_key)
      [Keyboard::VK[:INSERT], Keyboard::VK[:DELETE], Keyboard::VK[:PRIOR], Keyboard::VK[:NEXT], Keyboard::VK[:END], Keyboard::VK[:HOME]].include?(virtual_key)
    end
  end
  
  include ControlPadKeys
  extend ControlPadKeys
  
  # 
  # 
  module NavigationKeys
    
    # 
    # @param  virtual_key
    # @return [TrueClass || FalseClass]
    def arrow_key?(virtual_key)
      virtual_key.between?(Keyboard::VK[:LEFT], Keyboard::VK[:DOWN])
    end
    
    # 
    # @param  virtual_key
    # @param  dw_state_names
    # @return [TrueClass || FalseClass]
    def nav_arrow_key?(virtual_key, *dw_state_names)
      arrow_key?(virtual_key) and dw_state_names.include?(:ENHANCED_KEY)
    end
    
    # the pad above the arrow keys, what is CLEAR again?
    #
    # @param  virtual_key
    # @param  dw_state_names
    # @return [TrueClass || FalseClass]
    def nav_control_key?(virtual_key, *dw_state_names)
      (control_pad_key?(virtual_key) or virtual_key == Keyboard::VK[:CLEAR]) and dw_state_names.include?(:ENHANCED_KEY)
    end
  end
  
  include NavigationKeys
  extend NavigationKeys
  
  # 
  # 
  module NumpadKeys
    
    # 
    # @param  virtual_key
    # @return [TrueClass || FalseClass]
    def numlock?(virtual_key)
      virtual_key == Keyboard::VK[:NUMLOCK]
    end
    
    # 
    # @param  virtual_key
    # @param  [Array] dw_state_names
    # @return [TrueClass || FalseClass]
    def numpad_return?(virtual_key, *dw_state_names)
      virtual_key == 0x0D and dw_state_names.include?(:ENHANCED_KEY)
    end
    
    # 
    # numpad_except_return_or_numlock
    # @param  virtual_key
    # @return [TrueClass || FalseClass]
    def numpad_number_function?(virtual_key)
      virtual_key.between?(Keyboard::VK[:NUMPAD0], Keyboard::VK[:DIVIDE])
    end
    
    # 
    # @param  virtual_key
    # @param  [Array] dw_state_names
    # @return [TrueClass || FalseClass]
    def numpad_arrow?(virtual_key, *dw_state_names)
      arrow_key?(virtual_key) and not dw_state_names.include?(:ENHANCED_KEY)
    end
    
    # 
    # @param  virtual_key
    # @param  [Array] dw_state_names
    # @return [TrueClass || FalseClass]
    def numpad_control_key?(virtual_key, *dw_state_names)
      control_pad_key?(virtual_key) and not dw_state_names.include?(:ENHANCED_KEY)
    end
    
    # 
    # @param  virtual_key
    # @param  [Array] dw_state_names
    # @return [TrueClass || FalseClass]
    def numpad?(virtual_key, *dw_state_names)
      numpad_return?(virtual_key, *dw_state_names) or numpad_number_function?(virtual_key) or 
        numlock?(virtual_key) or numpad_control_key?(virtual_key, *dw_state_names)
    end
    
  end
  
  include NumpadKeys
  extend NumpadKeys
  
end
end
end