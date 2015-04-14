require 'spec_helper'

require 'vigilem/win32_api/dom'

describe Vigilem::Win32API::DOM::Adapter do
  
  let(:api) { Vigilem::Win32API }
  
  after(:example) do
    flush
  end
  
  let(:a_dw_numlock) { 0x0020 }
  
  let(:ctrl_dw_numlock) { 0x0028 }
  
  let(:a_key_input_record) do
    api::INPUT_RECORD[api::KEY_EVENT, {:KeyEvent => [1, 1, 0x41, 30, {:UnicodeChar => 65 }, a_dw_numlock]}]
  end
  
  let(:ctrl_key_input_record) do
    api::INPUT_RECORD[api::KEY_EVENT, {:KeyEvent => [1, 1, 0x11, 29, {:UnicodeChar => 0 }, ctrl_dw_numlock]}]
  end
  
  def key_event_template(type, opts={})
    mod_state = opts[:modifier_state] || {}
    opts.delete(:modifier_state)
    os_specific = opts[:os_specific] || {}
    opts.delete(:os_specific)
    {
      :bubbles=>false, :cancelable=>false, :code=>"KeyA", :detail=>0, :isTrusted=>true, :isComposing=>false,
      :key=>"A", :location=>0,
      :modifier_state=>{"Accel"=>false, "Alt"=>false, "AltGraph"=>false, "CapsLock"=>false, 
                        "Control"=>false, "Fn"=>false, "FnLock"=>false, "Hyper"=>false, "Meta"=>false, 
                        "NumLock"=>false, "OS"=>false, "ScrollLock"=>false, "Shift"=>false, "Super"=>false, 
                        "Symbol"=>false, "SymbolLock"=>false}.merge(mod_state),
      :os_specific=>{:bKeyDown=>1, :wRepeatCount=>1, :wVirtualKeyCode=>65, :wVirtualScanCode=>30, 
                                    :uChar=>{:UnicodeChar=>65, :AsciiChar=>65}, :dwControlKeyState=>32},
      :repeat=>false, :timeStamp=>kind_of(Numeric), :type=>type,
      :view=>nil
    }.merge(opts)
  end
  
  describe '#handle' do
    it 'sends Win32API::KEY_EVENT_RECORD events to #to_dom_key_event' do
      allow(subject).to receive(:to_dom_key_event)
      expect(subject).to receive(:to_dom_key_event)
      subject.handle(a_key_input_record.event_record)
    end
  end
  
  describe '#read_many' do
    it 'blocks until the number passed in is reached' do
      allow(subject.send(:link)).to receive(:ReadConsoleInput) { [a_key_input_record] }
      expect do
        Timeout::timeout(4) {
          subject.read_many(3)
        }
      end.to raise_error(Timeout::Error)
    end
    
    it 'retrieves multiple dom message' do
      allow(subject.send(:link)).to receive(:read_many_nonblock).and_return([a_key_input_record, a_key_input_record])
      Timeout::timeout(4) {
        expect(subject.read_many(2)).to contain_exactly(
            an_object_having_attributes(key_event_template("keydown", modifier_state: { "NumLock"=>true })),
            an_object_having_attributes(key_event_template("keypress", modifier_state: { "NumLock"=>true }))
          )
      }
    end
    
    it 'will fill the buffer with the leftovers' do
      allow(subject.send(:link)).to receive(:read_many_nonblock).and_return([a_key_input_record, a_key_input_record])
      Timeout::timeout(4) {
        subject.read_many(2)
        expect(subject.buffer.to_a).to contain_exactly(
            an_object_having_attributes(key_event_template("keydown", modifier_state: { "NumLock"=>true }, repeat: true)),
            an_object_having_attributes(key_event_template("keypress", modifier_state: { "NumLock"=>true }, repeat: true))
          )
       }
    end
  end
  
  describe '#read_many_nonblock' do
    
    it %q{doesn't block and returns nil when nothing in the queue} do
      allow(subject.send(:link)).to receive(:read_console_input).with(:nLength => 1, :blocking => true).and_call_original
      allow(subject.send(:link)).to receive(:ReadConsoleInput) { sleep 3.5 }
      expect do
        Timeout::timeout(3) {
          subject.read_many_nonblock(3)
        }
      end.not_to raise_error
    end
    
    it 'retrieves multiple dom messages' do
      allow(subject.send(:link)).to receive(:read_many_nonblock).and_return([a_key_input_record, a_key_input_record])
      expect(subject.read_many_nonblock(2)).to contain_exactly(
          an_object_having_attributes(key_event_template("keydown", modifier_state: { "NumLock"=>true })),
          an_object_having_attributes(key_event_template("keypress", modifier_state: { "NumLock"=>true }))
        )
    end
    
    it 'will fill the buffer with the leftovers' do
      allow(subject.send(:link)).to receive(:read_many_nonblock).and_return([a_key_input_record, a_key_input_record])
      subject.read_many_nonblock(2)
      expect(subject.buffer.to_a).to contain_exactly(
          an_object_having_attributes(key_event_template("keydown", repeat: true, modifier_state: { "NumLock"=>true })),
          an_object_having_attributes(key_event_template("keypress", repeat: true, modifier_state: { "NumLock"=>true }))
        )
    end
    
    class UnknownEvent
      def event_record
      end
    end
    
    it 'will return emty array if none of the events are handled' do
      allow(subject.send(:link)).to receive(:read_many_nonblock).and_return([UnknownEvent.new])
      expect(subject.read_many_nonblock(2)).to eql([])
    end
    
  end
  
  describe '#read_one' do
    
    it 'retrieves one dom message' do
      allow(subject.send(:link)).to receive(:read_many_nonblock).and_return([a_key_input_record])
      Timeout::timeout(4) {
        expect(subject.read_one).to be_a(Vigilem::DOM::KeyboardEvent) and
            have_attributes(key_event_template("keydown", modifier_state: { "NumLock"=>true }))
      }
    end
    
    it 'will block when no messages in buffer and non in the windows message queue' do
      allow(subject.send(:link)).to receive(:read_many_nonblock).and_call_original
      allow(subject.send(:link)).to receive(:ReadConsoleInput) { sleep 2.5 }
      expect do
        Timeout::timeout(2) {
          subject.read_one
        }
      end.to raise_error(Timeout::Error)
    end
    
  end
  
  describe '#read_one_nonblock' do
    
    it 'retrieves one dom message' do
      allow(subject.send(:link)).to receive(:read_many_nonblock).and_return([a_key_input_record])
      Timeout::timeout(4) {
        ret = subject.read_one_nonblock
        expect(ret).to be_a(Vigilem::DOM::KeyboardEvent) and
            have_attributes(key_event_template("keydown", modifier_state: { "NumLock"=>true }))
      }
    end
    
    it 'retrieves one dom message with modifiers' do
      allow(subject.send(:link)).to receive(:read_many_nonblock).and_return([ctrl_key_input_record])
      Timeout::timeout(4) {
        expect(subject.read_one_nonblock).to be_a(Vigilem::DOM::KeyboardEvent) and
            have_attributes(key_event_template("keydown", modifier_state: { "NumLock"=>true }))
      }
    end
    
    it 'will fill the buffer with the leftovers' do
      allow(subject.send(:link)).to receive(:read_many_nonblock).and_return([a_key_input_record])
      subject.read_one_nonblock
      expect(subject.buffer.to_a).to contain_exactly(
          an_object_having_attributes(key_event_template("keypress", modifier_state: { "NumLock"=>true }))
        )
    end
    
    it %q{will not block when no messages in buffer} do
      allow(subject.send(:link)).to receive(:read_console_input).with(:nLength => 1, :blocking => false).and_call_original
      allow(subject.send(:link)).to receive(:ReadConsoleInput) { sleep 2.5 }
      expect do
        Timeout::timeout(2) {
          subject.read_one_nonblock
        }
      end.not_to raise_error
    end
    
  end
  
end