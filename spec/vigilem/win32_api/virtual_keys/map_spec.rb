require 'vigilem/win32_api/virtual_keys/map'

describe Vigilem::Win32API::VirtualKeys::Map do
  
  describe '#virtual_key_name' do
    it 'returns the name of the virtual_key' do
      expect(described_class.virtual_keyname(65)).to eql(:VK_A)
    end
  end
end