require 'spec_helper'

require 'vigilem/win32_api/constants'

require 'vigilem/win32_api/types'

require 'vigilem/win32_api/console_input_events'


describe Vigilem::Win32API::ConsoleInputEvents do
  
  describe described_class::MOUSE_EVENT_RECORD do
    it_behaves_like 'attributes_and_size_test' do
      let(:ary) { [:dwMousePosition, :dwButtonState, :dwControlKeyState, :dwEventFlags] }
      let(:sze) { 16 }
    end
  end
  
  describe described_class::WINDOW_BUFFER_SIZE_RECORD do
    it_behaves_like 'attributes_and_size_test' do
      let(:ary) { [:dwSize] }
      let(:sze) { 4 }
    end
  end
  
  describe described_class::MENU_EVENT_RECORD do
    it_behaves_like 'attributes_and_size_test' do
      let(:ary) { [:dwCommandId] }
      let(:sze) { 4 }
    end
  end
  
  describe described_class::FOCUS_EVENT_RECORD do
    it_behaves_like 'attributes_and_size_test' do
      let(:ary) { [:bSetFocus] }
      let(:sze) { 4 }
    end
  end
  
  describe described_class::KEY_EVENT_RECORD do
    it_behaves_like 'attributes_and_size_test' do
      let(:ary) { [:bKeyDown, :wRepeatCount, :wVirtualKeyCode, :wVirtualScanCode, :uChar, :dwControlKeyState] }
      let(:sze) { 16 }
    end
  end
  
  describe '::vk_names' do
    it 'has the list of events' do
      expect(described_class.vk_names).to eql([:KEY_EVENT, :MOUSE_EVENT, :WINDOW_BUFFER_SIZE_EVENT, :MENU_EVENT, :FOCUS_EVENT])
    end
  end
  
  describe '::vk_hash' do
    it 'to be a hash with keys equal to Constant values and values equal to constant names' do
      expect(described_class.vk_hash).to eql(described_class.vk_names.map.with_object({}) {|vk, hsh| hsh[Vigilem::Win32API::Constants::Events.const_get(vk)] = vk })
    end
  end
=begin
  describe '::structs' do
    it 'will return an array of the structs that are the event types' do
      expect(described_class.structs.sort).to eq([described_class::KEY_EVENT_RECORD,
                                    described_class::MOUSE_EVENT_RECORD, described_class::WINDOW_BUFFER_SIZE_RECORD,  
                                    described_class::MENU_EVENT_RECORD, described_class::FOCUS_EVENT_RECORD].sort)
    end
  end
=end
end