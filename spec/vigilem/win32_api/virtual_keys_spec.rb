require 'spec_helper'

require 'vigilem/win32_api/virtual_keys'

describe Vigilem::Win32API::VirtualKeys do
  
  describe '::[]' do
    it 'converts the current side to the opposite' do
      expect(described_class::Map[0x10]).to eql(:VK_SHIFT)
    end
    
    it 'shorthand for Map so that VK_ prefix isn;t needed' do
      expect(described_class::VK[:SHIFT]).to eql(0x10)
    end
  end
  
  describe '::virtual_key' do
    
    it 'convert Integer vk-code to vk Symbol' do
      expect(described_class::Map.virtual_keyname(0x10)).to eql(:VK_SHIFT)
    end
    
    it 'short hand for Map returns without the VK prefix ' do
      expect(described_class::VK.virtual_keyname(0x10)).to eql(:SHIFT)
    end
  end
  
end