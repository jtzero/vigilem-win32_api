require 'spec_helper'

require 'vigilem/win32_api/dom'

describe Vigilem::Win32API::DOM::Adapter do
  
  let(:api) { Vigilem::Win32API }
  
  after(:example) do
    flush
  end
  
  let(:dw_numlock) { 0x0020 }
  
  let(:input_record) { 
     api::INPUT_RECORD[api::KEY_EVENT, {:KeyEvent => [1, 1, 0x41, 30, {:UnicodeChar => 65 }, dw_numlock]}]
  }
  
  def key_event_template(type, opts={})
    {
      :bubbles=>false, :cancelable=>false, :code=>"KeyA", :detail=>0, :isTrusted=>true, :isComposing=>false,
      :key=>"A", :location=>0,
      :modifier_state=>{"Accel"=>false, "Alt"=>false, "AltGraph"=>false, "CapsLock"=>false, 
                        "Control"=>false, "Fn"=>false, "FnLock"=>false, "Hyper"=>false, "Meta"=>false, 
                        "NumLock"=>false, "OS"=>false, "ScrollLock"=>false, "Shift"=>false, "Super"=>false, 
                        "Symbol"=>false, "SymbolLock"=>false},
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
      subject.handle(input_record.event_record)
    end
  end
  
  describe '#read_many' do
    it 'blocks until the number passed in is reached' do
      allow(subject.send(:link)).to receive(:ReadConsoleInput) { [input_record] }
      expect do
        Timeout::timeout(4) {
          subject.read_many(3)
        }
      end.to raise_error(Timeout::Error)
    end
    
    it 'retrieves multiple dom message' do
      allow(subject.send(:link)).to receive(:read_many_nonblock).and_return([input_record, input_record])
      Timeout::timeout(4) {
        expect(subject.read_many(2)).to contain_exactly(
            an_object_having_attributes(key_event_template("keydown")),
            an_object_having_attributes(key_event_template("keypress"))
          )
      }
    end
    
    it 'will fill the buffer with the leftovers' do
      allow(subject.send(:link)).to receive(:read_many_nonblock).and_return([input_record, input_record])
      subject.read_many(2)
      Timeout::timeout(4) {
        expect(subject.buffer.to_a).to contain_exactly(
            an_object_having_attributes(key_event_template("keydown", repeat: true)),
            an_object_having_attributes(key_event_template("keypress", repeat: true))
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
      allow(subject.send(:link)).to receive(:read_many_nonblock).and_return([input_record, input_record])
      expect(subject.read_many_nonblock(2)).to contain_exactly(
          an_object_having_attributes(key_event_template("keydown")),
          an_object_having_attributes(key_event_template("keypress"))
        )
    end
    
    it 'will fill the buffer with the leftovers' do
      allow(subject.send(:link)).to receive(:read_many_nonblock).and_return([input_record, input_record])
      subject.read_many_nonblock(2)
      expect(subject.buffer.to_a).to contain_exactly(
          an_object_having_attributes(key_event_template("keydown", repeat: true)),
          an_object_having_attributes(key_event_template("keypress", repeat: true))
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
      allow(subject.send(:link)).to receive(:read_many_nonblock).and_return([input_record])
      Timeout::timeout(4) {
        expect(subject.read_one).to be_a(Vigilem::DOM::KeyboardEvent) and
            have_attributes(key_event_template("keydown"))
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
      allow(subject.send(:link)).to receive(:read_many_nonblock).and_return([input_record])
      Timeout::timeout(4) {
        expect(subject.read_one_nonblock).to be_a(Vigilem::DOM::KeyboardEvent) and
            have_attributes(key_event_template("keydown"))
      }
    end
    
    it 'will fill the buffer with the leftovers' do
      allow(subject.send(:link)).to receive(:read_many_nonblock).and_return([input_record])
      subject.read_one_nonblock
      expect(subject.buffer.to_a).to contain_exactly(
          an_object_having_attributes(key_event_template("keypress"))
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