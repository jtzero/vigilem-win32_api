require 'spec_helper'

require 'vigilem/dom'

require 'vigilem/win32_api'

require 'vigilem/win32_api/input_system_handler'

require 'vigilem/win32_api/dom/input_record_utils'


describe Vigilem::Win32API::DOM::InputRecordUtils do
  
  let(:api) { Vigilem::Win32API }
  
  let(:dw_numlock) { 0x0020 }
  
  let(:dw_lmenu) { 0x0002 }
  
  let(:dw_LEFT_CTRL_PRESSED) { 0x0008 }
  
  let(:dw_rmenu) { 0x0001 }
  
  let(:dw_shift) { 0x0010 }
  
  let(:key_event_record) { api::KEY_EVENT_RECORD[1, 1, 0x41, 30, {:UnicodeChar => 65 }, dw_numlock] }
  
  let(:event_record_lmenu)  { api::KEY_EVENT_RECORD[1, 1, 0x12, 30, {:UnicodeChar => 0 }, dw_numlock + dw_lmenu] }
  
  let(:event_record_l_control)  { api::KEY_EVENT_RECORD[1, 1, 0x11, 29, {:UnicodeChar => 0 }, dw_numlock + dw_LEFT_CTRL_PRESSED] }
  
  let!(:host) do
    class IRU
      include Vigilem::Core::Adapters::Adapter
      include Vigilem::Win32API::Rubyized
      include Vigilem::Win32API::DOM::InputRecordUtils
      
      def initialize
        self.win32_api_rubyized_src = self.link
      end
      
      def link
        @isys ||= Vigilem::Win32API::InputSystemHandler.new
      end
    end
    IRU.new
  end
  
  describe '#current_keys' do
    it 'defaults to an empty array' do
      expect(host.current_keys).to eql([])
    end
  end
  
  describe '#to_dom_key_event' do
    
    # 
    def key_event(type, key, code, wVirtualKeyCode, wVirtualScanCode, unicodeChar, opts={})
      mod_state = opts[:modifier_state] || {}
      opts.delete(:modifier_state)
      os_specific = opts[:os_specific] || {}
      opts.delete(:os_specific)
      {
        bubbles: false, cancelable: false, code: code, detail: 0, isTrusted: true, 
        isComposing: false, key: key, location: 0, 
        modifier_state: {"Accel"=>false, "Alt"=>false, "AltGraph"=>false, "CapsLock"=>false, "Control"=>false, 
                         "Fn"=>false, "FnLock"=>false, "Hyper"=>false, "Meta"=>false, "NumLock"=>false, "OS"=>false, 
                         "ScrollLock"=>false, "Shift"=>false, "Super"=>false, "Symbol"=>false, "SymbolLock"=>false}.merge(mod_state),
        os_specific: {:bKeyDown=>1, :wRepeatCount=>1, :wVirtualKeyCode=>wVirtualKeyCode, :wVirtualScanCode=>wVirtualScanCode, 
                                                  :uChar=>{:UnicodeChar=>unicodeChar, :AsciiChar=>unicodeChar}, :dwControlKeyState=>dw_numlock}.merge(os_specific), 
        repeat: false, timeStamp: kind_of(Numeric), type: type, view: nil
      }.merge(opts)
    end
    
    context 'simple conversion' do
      
      before :each do
        allow(host).to receive(:dom_modifiers).and_call_original
      end
      
      let!(:result) { host.to_dom_key_event(key_event_record) }
      
      it 'converts an input_record to a DOM Event' do
        expect(result).to match [
            an_object_having_attributes(key_event('keydown', "A", "KeyA", 65, 30, 65, :modifier_state => { "NumLock" => true })),
            an_object_having_attributes(key_event('keypress', "A", "KeyA", 65, 30, 65, :modifier_state => { "NumLock" => true }))
          ]
      end
      
      it 'sends the dw_state_names to dom_modifiers' do
        expect(host).to have_received(:dom_modifiers).with(:NUMLOCK_ON)
      end
      
      # @todo be more specific
      it 'updates #current_keys' do
        expect(host.current_keys.size).to be > 0
      end
    end
    
    context 'conversion with modifiers' do
      
      before :each do
        allow(host).to receive(:dom_modifiers).and_call_original
      end
      
      let!(:result) { host.to_dom_key_event(event_record_l_control) }
      
      it 'converts an input_record to a DOM Event' do
        expect(result).to match [
            an_object_having_attributes(key_event('keydown', "Control", "ControlLeft", 0x11, 29, 0, 
                                                    :modifier_state => { "Accel" => true, "Control" => true, "NumLock" => true }, :location => 1, 
                                                        :os_specific => {:dwControlKeyState => dw_numlock + dw_LEFT_CTRL_PRESSED})),
            an_object_having_attributes(key_event('keypress', "Control", "ControlLeft", 0x11, 29, 0, 
                                                    :modifier_state => { "Accel" => true, "Control" => true, "NumLock" => true }, :location => 1,
                                                        :os_specific => {:dwControlKeyState => dw_numlock + dw_LEFT_CTRL_PRESSED})),
          ]
      end
      
      it 'sends the dw_state_names to dom_modifiers' do
        expect(host).to have_received(:dom_modifiers).with(:LEFT_CTRL_PRESSED, :NUMLOCK_ON)
      end
      
      # @todo be more specific
      it 'updates #current_keys' do
        expect(host.current_keys.size).to be > 0
      end
    end
    
    context 'repeats' do
      
      let(:repeat_results) { 1.upto(2).map {|n| host.to_dom_key_event(key_event_record) } }
      
      it 'converts an input_record to a DOM Event and keeps track of state' do
        expect(repeat_results).to match [
            [an_object_having_attributes(key_event('keydown', "A", "KeyA", 65, 30, 65, :modifier_state => { "NumLock" => true })),   # its wrongly making this repeat
             an_object_having_attributes(key_event('keypress', "A", "KeyA", 65, 30, 65, :modifier_state => { "NumLock" => true }))], # its wrongly making this repeat
            [an_object_having_attributes(key_event('keydown', "A", "KeyA", 65, 30, 65, :modifier_state => { "NumLock" => true }, repeat: true)), 
            an_object_having_attributes(key_event('keypress', "A", "KeyA", 65, 30, 65, :modifier_state => { "NumLock" => true }, repeat: true))] # chrome 39.0.2171.95 m produces `false'
          ]
      end
    end
    
  end
  
  describe '#dw_control_key_state_vks' do
    it 'lists the names of the constants that represent the dw_control_state' do
      expect(host.dw_control_key_state_vks(dw_numlock + dw_lmenu)).to eql([:LEFT_ALT_PRESSED, :NUMLOCK_ON])
    end
  end
  
  describe '#location_less_vks_map' do
    it 'returns a Hash with vk as keys' do
      expect(host.location_less_vks_map.keys).to all( be_instance_of(Symbol) )
    end
    
    it 'returns a Hash with Regexp as values' do
      expect(host.location_less_vks_map.values).to all( be_instance_of(Regexp) )
    end
  end
  
  describe '#vk_without_location_info?' do
    it 'returns whether or not a virtual key need location info' do
      expect(:VK_MENU).to be_truthy
    end
  end
  
  describe '#shift_scan_code_to_location_vk' do
    
    let(:l_shift) { IRU::VK_LSHIFT }
    
    let(:l_shift_vsc) { api.MapVirtualKeyW(l_shift, IRU::MapVK::VK_TO_VSC) }
    
    it 'creates a hash that maps the scancodes to :VK_LSHIFT and :VK_RSHIFT ' do
      expect(host.shift_scan_code_to_location_vk[l_shift_vsc]).to eql(:VK_LSHIFT)
    end
  end
  
  describe '::flip_lr_sides' do
    it 'converts "l" or "L" to "r" or "R"' do
      expect(described_class.flip_lr_sides('L')).to eql('R')
    end
  end
  
  describe '::lr_location_from_name' do
    it 'pulls the "L" or "R" from the string name' do
      expect(described_class.lr_location_from_name(:LEFT_CTRL_PRESSED)).to eql('L')
    end
  end
  
  describe '::empty_or_null?' do
    it 'returns true for empty Strings ' do 
      expect(described_class.empty_or_null?("")).to be_truthy
    end
    
    it 'returns true for a String with only "\x00"' do 
      expect(described_class.empty_or_null?("\x00\x00")).to be_truthy
    end
  end
  
  describe '#dom_location' do
    
    let(:vk_menu_vsc) { api.MapVirtualKeyW(IRU::VK_MENU, IRU::MapVK::VK_TO_VSC) }
    
    context ', both ALT\'s are pressed yet niether in the current_keys' do
      
      let(:dw_state_names) { host.dw_control_key_state_vks(3) }
      
      it 'will raise an error in this situation' do
        expect { host.dom_location(:VK_MENU, vk_menu_vsc, dw_state_names) }.to raise_error
      end
      
    end
    
    context 'generic vk with dw_state_names' do
    
      let(:dw_state_names) { host.dw_control_key_state_vks(2) }
      
      let(:dw_state_names_right) { host.dw_control_key_state_vks(1) }
      
      it 'will get left the location from the dw_state_name' do
        expect(host.dom_location(:VK_MENU, vk_menu_vsc, 1, dw_state_names)).to eql(1)
      end
      
      it 'will get right the location from the dw_state_name' do
        expect(host.dom_location(:VK_MENU, vk_menu_vsc, 1, dw_state_names_right)).to eql(2)
      end
    end
    
  end
  
  describe '#lr_not_in_name' do
    
    let(:vk_menu_vsc) { api.MapVirtualKeyW(IRU::VK_MENU, IRU::MapVK::VK_TO_VSC) }
    
    let(:vk_rmenu_vsc) { api.MapVirtualKeyW(IRU::VK_RMENU, IRU::MapVK::VK_TO_VSC) }
    
    let(:vk_rshift_vsc) { api.MapVirtualKeyW(IRU::VK_RSHIFT, IRU::MapVK::VK_TO_VSC) }
    
    let(:lr_menu_dw_state_names) { host.dw_control_key_state_vks(dw_numlock + dw_lmenu + dw_rmenu) }
    
    let(:l_menu_dw_state_names) { host.dw_control_key_state_vks(dw_numlock + dw_lmenu) }
    
    let(:dw_state_names_w_shift) { host.dw_control_key_state_vks(dw_shift) }
    
    it 'gets the location info from virtual-key and dw_state_names' do
      expect(host.lr_not_in_name(:VK_MENU, vk_menu_vsc, 1, l_menu_dw_state_names)).to eql('l')
    end
    
    it 'gets the location info from the scan code' do
      expect(host.lr_not_in_name(:VK_SHIFT, vk_rshift_vsc, 1, dw_state_names_w_shift)).to eql('r')
    end
    
    context 'with current keys' do
      let!(:converted_result) { host.to_dom_key_event(event_record_lmenu) }
      
      it 'gets the location info from the #current keys' do
        expect(host.lr_not_in_name(:VK_MENU, vk_rmenu_vsc, 1, lr_menu_dw_state_names)).to eql('r')
      end
    end
    
    context 'CTRL' do
      
      after :each do
        host.current_keys.replace([])
      end
      
      let(:options) do
        {
          :key=>"Control", :code=>"ControlLeft", :location=>1, :repeat=>false, 
          :modifiers=>{
            :altKey=>false, :keyModifierStateAltGraph=>false, :keyModifierStateCapsLock=>false, :ctrlKey=>true, 
            :keyModifierStateFn=>false, :keyModifierStateFnLock=>false, :keyModifierStateHyper=>false, :metaKey=>false, 
            :keyModifierStateNumLock=>true, :keyModifierStateOS=>false, :keyModifierStateScrollLock=>false, :shiftKey=>false, 
            :keyModifierStateSuper=>false, :keyModifierStateSymbol=>false, :keyModifierStateSymbolLock=>false
          }, 
          :os_specific=>{ 
            :bKeyDown=>1, :wRepeatCount=>1, :wVirtualKeyCode=>17, :wVirtualScanCode=>29, 
            :uChar=>{:UnicodeChar=>0, :AsciiChar=>0}, 
            :dwControlKeyState=>40 # keyup 32
          }
        }
      end
      
      context 'keydown' do
        
        it 'left' do
          expect(host.lr_not_in_name(:VK_CONTROL, 29, 1, [:LEFT_CTRL_PRESSED])).to eql('l')
        end
        
        it 'right' do
          expect(host.lr_not_in_name(:VK_CONTROL, 29, 1, [:ENHANCED_KEY, :RIGHT_CTRL_PRESSED])).to eql('r')
        end
        
        it 'both pressed, left in current keys, right was pressed second' do
          host.current_keys << ::VDOM::KeyboardEvent.new('keydown', options)
          expect(host.lr_not_in_name(:VK_CONTROL, 29, 1, [:LEFT_CTRL_PRESSED, :ENHANCED_KEY, :RIGHT_CTRL_PRESSED])).to eql('r')
        end
        
        it 'left pressed, left in current keys, this is a repeat' do
          host.current_keys << ::VDOM::KeyboardEvent.new('keydown', options)
          expect(host.lr_not_in_name(:VK_CONTROL, 29, 1, [:LEFT_CTRL_PRESSED])).to eql('l')
        end
        
        it 'both pressed, right in current keys, left was pressed second' do
          options[:code] = "ControlRight"
          options[:location] = 2
          options[:os_specific][:dwControlKeyState] = 292
          host.current_keys << ::VDOM::KeyboardEvent.new('keydown', options)
          expect(host.lr_not_in_name(:VK_CONTROL, 29, 1, [:LEFT_CTRL_PRESSED, :ENHANCED_KEY, :RIGHT_CTRL_PRESSED])).to eql('l')
        end
        
        it 'right pressed, right in current keys, this is a repeat' do
          host.current_keys << ::VDOM::KeyboardEvent.new('keydown', options)
          expect(host.lr_not_in_name(:VK_CONTROL, 29, 1, [:ENHANCED_KEY, :RIGHT_CTRL_PRESSED])).to eql('r')
        end
      end
      
      context 'keyup' do
      
        it 'both pressed, both in current keys, left was released' do
          host.current_keys << ::VDOM::KeyboardEvent.new('keydown', options)
          options[:code] = "ControlRight"
          options[:location] = 2
          options[:os_specific][:dwControlKeyState] = 292
          host.current_keys << ::VDOM::KeyboardEvent.new('keydown', options)
          expect(host.lr_not_in_name(:VK_CONTROL, 29, 0, [:ENHANCED_KEY, :RIGHT_CTRL_PRESSED])).to eql('l')
        end
        
        it 'both pressed, both in current keys, right was released' do
          host.current_keys << ::VDOM::KeyboardEvent.new('keydown', options)
          options[:code] = "ControlRight"
          options[:location] = 2
          options[:os_specific][:dwControlKeyState] = 292
          host.current_keys << ::VDOM::KeyboardEvent.new('keydown', options)
          expect(host.lr_not_in_name(:VK_CONTROL, 29, 0, [:LEFT_CTRL_PRESSED])).to eql('r')
        end
      end
      
    end
    
  end
  
  describe '#dom_key' do
    
    let(:l_shift) { IRU::VK_LSHIFT }
    
    it 'converts modifier virtual-key to dom_key' do
      expect(host.dom_key(:VK_SHIFT, 0)).to eql('Shift')
    end
    
    it 'converts character virtual-key to dom_key' do
      expect(host.dom_key(:VK_A, 97)).to eql('a')
    end
  end
  
  describe '#dom_code' do
    
    it 'produces the code attribute for a modifier-less character key For DOM::Keyboard Event' do
      expect(host.dom_code(:VK_A, 65, 0)).to eql('KeyA')
    end
    
    it 'produces the code attribute for a modified character key For DOM::Keyboard Event' do
      expect(host.dom_code(:VK_A, 1, 0, :LEFT_CTRL_PRESSED)).to eql('KeyA')
    end
    
    it 'produces the code attribute for a modifier key For DOM::Keyboard Event' do
      expect(host.dom_code(:VK_MENU, 0, 'l')).to eql('AltLeft')
    end
    
    context 'modifier key that has a compliment' do
      
      it 'produces the code attribute for DOM::Keyboard Event for left' do
        expect(host.dom_code(:VK_CONTROL, 0, 1, :LEFT_CTRL_PRESSED)).to eql('ControlLeft')
      end
      
      it 'produces the code attribute for DOM::Keyboard Event for right' do
        expect(host.dom_code(:VK_CONTROL, 0, 2, :ENHANCED_KEY, :RIGHT_CTRL_PRESSED)).to eql('ControlRight')
      end
      
      it 'produces the code attribute for DOM::Keyboard Event for right when left is also pressed' do
        expect(host.dom_code(:VK_CONTROL, 0, 2, :LEFT_CTRL_PRESSED, :ENHANCED_KEY, :RIGHT_CTRL_PRESSED)).to eql('ControlRight')
      end
      
    end
    
    it 'produces the code attribute for a modifier key For DOM::Keyboard Event' do
      expect(host.dom_code(:VK_RETURN, 10, 3, :ENHANCED_KEY)).to eql('NumpadEnter')
    end
  end
  
  describe '#key_or_digit_code' do
    ('A'..'Z').each do |char|
      it "converts `#{char}' to Key#{char}" do
        expect(host.key_or_digit_code(char)).to eql("Key#{char}")
      end
    end
    
    (0..9).each do |digit|
      it "converts `#{digit}' to Digit#{digit}" do
        expect(host.key_or_digit_code(digit)).to eql("Digit#{digit}")
      end
    end
    
  end
  
  describe '#dom_modifiers' do
    
    it 'convert dw_control_names to more typical modifier names' do
      expect(::VDOM::KeyboardEvent).to receive(:shared_keyboard_and_mouse_event_init).with([:alt, :numlock])
      host.dom_modifiers(:LEFT_ALT_PRESSED, :NUMLOCK_ON)
    end
    it 'converts dw_control_state_names (alt, numlock) to an array of symbols' do
      expect(host.dom_modifiers(:LEFT_ALT_PRESSED, :NUMLOCK_ON)).to eql({ :altKey=>true, :keyModifierStateAltGraph=>false, :keyModifierStateCapsLock=>false,
                                            :ctrlKey=>false, :keyModifierStateFn=>false, :keyModifierStateFnLock=>false, :keyModifierStateHyper=>false,  
                                            :metaKey=>false, :keyModifierStateNumLock=>true, :keyModifierStateOS=>false, :keyModifierStateScrollLock=>false, 
                                            :shiftKey=>false, :keyModifierStateSuper=>false, :keyModifierStateSymbol=>false, :keyModifierStateSymbolLock=>false })
    end
    
    it 'converts dw_control_state_names (ctrl) to an array of symbols' do
      expect(host.dom_modifiers(:LEFT_CTRL_PRESSED)).to eql({ :altKey=>false, :keyModifierStateAltGraph=>false, :keyModifierStateCapsLock=>false,
                                            :ctrlKey=>true, :keyModifierStateFn=>false, :keyModifierStateFnLock=>false, :keyModifierStateHyper=>false,  
                                            :metaKey=>false, :keyModifierStateNumLock=>false, :keyModifierStateOS=>false, :keyModifierStateScrollLock=>false, 
                                            :shiftKey=>false, :keyModifierStateSuper=>false, :keyModifierStateSymbol=>false, :keyModifierStateSymbolLock=>false })
    end
    
  end
end