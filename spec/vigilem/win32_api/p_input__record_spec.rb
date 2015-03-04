require 'spec_helper'

require 'vigilem/win32_api/p_input__record'

describe Vigilem::Win32API::PINPUT_RECORD do
  
  let(:api) { Vigilem::Win32API }
  
  before :each do
    @pir = described_class.new(3, 
              api::INPUT_RECORD[:EventType => 0x0001, :Event => api::INPUT_RECORD::Event.new], 
              api::INPUT_RECORD[:EventType => 0x0008, :Event => api::INPUT_RECORD::Event.new])
  end
  
  subject { @pir }
  
  context 'when first created' do
    
    specify { expect(subject.first).to be_a api::INPUT_RECORD }
    
    specify { expect(subject.first.values.first).to eql(0x0001) }
    
    specify { expect(subject[1].values.first).to eql(0x0008) }
    
    it 'will update the underlying ptr' do
      expect(api::INPUT_RECORD.new(subject.ptr).values.first).to eql(1)
    
      #::Win32API::INPUT_RECORD.new(@pir.ptr.read_pointer).values #causes segfault because it 
      # wasnt saved as a pointer, it was saved as bytes, maybe subclass pointer? to get around this
    end
  end
  
  describe 'update-able' do
    
    it 'will increase size' do 
      expect((subject << api::INPUT_RECORD.new).length).to eql(3)
    end
    
    it %q(won't allow a length more than the init max value) do
      expect { subject.concat [api::INPUT_RECORD.new, api::INPUT_RECORD.new ] }.to raise_error
    end
  end
end