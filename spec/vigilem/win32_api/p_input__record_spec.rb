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
  
  describe '::ary_of_type' do
    
    let(:a_key_input_record) do
      api::INPUT_RECORD[api::KEY_EVENT, {:KeyEvent => [1, 1, 0x41, 30, {:UnicodeChar => 65 }, 0x0020]}]
    end
    
    let(:ctrl_key_input_record) do
      api::INPUT_RECORD[api::KEY_EVENT, {:KeyEvent => [1, 1, 0x11, 29, {:UnicodeChar => 0 }, 0x0028]}]
    end
    
    let(:ir_a_bytes) { a_key_input_record.to_ptr.get_bytes(0, a_key_input_record.size) }
    
    let(:ir_ctrl_bytes) { ctrl_key_input_record.to_ptr.get_bytes(0, ctrl_key_input_record.size) }
    
    let(:ir_a_pointer) do 
      ptr = FFI::MemoryPointer.new(api::INPUT_RECORD, 4)
      ptr.put_bytes(0, ir_a_bytes)
      ptr
    end
    
    let(:ir_a_ctrl_pointer) do 
      ptr = FFI::MemoryPointer.new(api::INPUT_RECORD, 4)
      ptr.put_bytes(0, ir_a_bytes + ir_ctrl_bytes)
      ptr
    end
    
    it %q<will return an array of Input_Record's> do
      expect(described_class.ary_of_type(ir_a_pointer)).to match [instance_of(api::INPUT_RECORD)]
    end
    
    it %q<will return a compact array of Input_Record's> do
      expect(described_class.ary_of_type(ir_a_ctrl_pointer).size).to eql(2)
    end
    
    it %q<will return a fully fledged Input_Record> do
      expect(described_class.ary_of_type(ir_a_ctrl_pointer).map(&:to_h)).to eql([a_key_input_record.to_h, ctrl_key_input_record.to_h])
    end
  end
  
end