require 'spec_helper'

require 'vigilem/dom'

require 'vigilem/win32_api'

require 'vigilem/win32_api/input_system_handler'

require 'vigilem/win32_api/dom/input_record_utils'


describe Vigilem::Win32API::DOM::InputRecordUtils do
  
  let(:api) { Vigilem::Win32API }
  
  let(:dw_numlock) { 0x0020 }
  
  let(:dw_lmenu) { 0x0002 }
  
  let(:dw_rmenu) { 0x0001 }
  
  let(:dw_shift) { 0x0010 }
  
  let(:key_event_record) { api::KEY_EVENT_RECORD[1, 1, 0x41, 30, {:UnicodeChar => 65 }, dw_numlock] }
  
  let(:event_record_lmenu)  { api::KEY_EVENT_RECORD[1, 1, 0x12, 30, {:UnicodeChar => 0 }, dw_numlock + dw_lmenu] }
  
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
    
    def key_event(type, opts={})
      {
        bubbles: false, cancelable: false, code: "KeyA", detail: 0, isTrusted: true, 
        isComposing: false, key: "A", location: 0, 
        modifier_state: {"Accel"=>false, "Alt"=>false, "AltGraph"=>false, "CapsLock"=>false, "Control"=>false, 
                         "Fn"=>false, "FnLock"=>false, "Hyper"=>false, "Meta"=>false, "NumLock"=>false, "OS"=>false, 
                         "ScrollLock"=>false, "Shift"=>false, "Super"=>false, "Symbol"=>false, "SymbolLock"=>false}, 
        os_specific: {:bKeyDown=>1, :wRepeatCount=>1, :wVirtualKeyCode=>65, :wVirtualScanCode=>30, 
                                                  :uChar=>{:UnicodeChar=>65, :AsciiChar=>65}, :dwControlKeyState=>dw_numlock}, 
        repeat: false, timeStamp: kind_of(Numeric), type: type, view: nil
      }.merge(opts)
    end
    
    context 'simple conversion' do
      
      let!(:result) { host.to_dom_key_event(key_event_record) }
      
      it 'converts an input_record to a DOM Event' do
        expect(result).to match [
            an_object_having_attributes(key_event('keydown')),
            an_object_having_attributes(key_event('keypress'))
          ]
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
            [an_object_having_attributes(key_event('keydown')),   # its wrongly making this repeat
             an_object_having_attributes(key_event('keypress'))], # its wrongly making this repeat
            [an_object_having_attributes(key_event('keydown', repeat: true)), 
            an_object_having_attributes(key_event('keypress', repeat: true))] # chrome 39.0.2171.95 m produces `false'
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
        expect(host.dom_location(:VK_MENU, vk_menu_vsc, dw_state_names)).to eql(1)
      end
      
      it 'will get right the location from the dw_state_name' do
        expect(host.dom_location(:VK_MENU, vk_menu_vsc, dw_state_names_right)).to eql(2)
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
      expect(host.lr_not_in_name(:VK_MENU, vk_menu_vsc, l_menu_dw_state_names)).to eql('l')
    end
    
    it 'gets the location info from the scan code' do
      expect(host.lr_not_in_name(:VK_SHIFT, vk_rshift_vsc, dw_state_names_w_shift)).to eql('r')
    end
    
    context 'with current keys' do
      let!(:converted_result) { host.to_dom_key_event(event_record_lmenu) }
      
      it 'gets the location info from the #current keys' do
        expect(host.lr_not_in_name(:VK_MENU, vk_rmenu_vsc, lr_menu_dw_state_names)).to eql('r')
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
    it 'produces the code attribute for a character key For DOM::Keyboard Event' do
      expect(host.dom_code(:VK_A, 65, 0)).to eql('KeyA')
    end
    
    it 'produces the code attribute for a modifier key For DOM::Keyboard Event' do
      expect(host.dom_code(:VK_MENU, 0, 'l')).to eql('AltLeft')
    end
    
    it 'produces the code attribute for a modifier key For DOM::Keyboard Event' do
      expect(host.dom_code(:VK_RETURN, 10, 3, :ENHANCED_KEY)).to eql('NumpadEnter')
    end
  end
  
  describe '#dom_modifiers' do
    
    it 'convert dw_control_names to more typical modifier names' do
      expect(::VDOM::KeyboardEvent).to receive(:shared_keyboard_and_mouse_event_init).with([:alt, :numlock])
      host.dom_modifiers(:LEFT_ALT_PRESSED, :NUMLOCK_ON)
    end
    it 'converts dw_control_state_names to an array of symbols' do
      expect(host.dom_modifiers(:LEFT_ALT_PRESSED, :NUMLOCK_ON)).to eql({ :altKey=>true, :keyModifierStateAltGraph=>false, :keyModifierStateCapsLock=>false,
                                            :ctrlKey=>false, :keyModifierStateFn=>false, :keyModifierStateFnLock=>false, :keyModifierStateHyper=>false,  
                                            :metaKey=>false, :keyModifierStateNumLock=>true, :keyModifierStateOS=>false, :keyModifierStateScrollLock=>false, 
                                            :shiftKey=>false, :keyModifierStateSuper=>false, :keyModifierStateSymbol=>false, :keyModifierStateSymbolLock=>false })
    end
  end
end