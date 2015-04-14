require 'spec_helper'

require 'vigilem/win32_api/eventable'

require 'vigilem/win32_api/input_system_handler'

require 'vigilem/core/adapters/adapter'

describe Vigilem::Win32API::Eventable do
  
  before :all do
    EventableAdapter = Class.new do
      include Vigilem::Core::Adapters::Adapter
      include Vigilem::Win32API::Rubyized
      include Vigilem::Win32API::Eventable
      def initialize(lnk=Vigilem::Win32API::InputSystemHandler.new)
        initialize_adapter(lnk)
        self.win32_api_rubyized_source = link()
      end
    end
  end
  
  let(:adapt) do
    EventableAdapter.new
  end
  
  describe 'has_any?' do
    
    it 'checks peek_console_input and if the lpBuffer has any messages' do
      allow(adapt).to receive(:peek_console_input) { %w(a b c) }
      expect(adapt.has_any?).to be_truthy
    end
    
    it 'returns false when peek_console_input lpBuffer is empty' do
      allow(adapt).to receive(:peek_console_input) { [] }
      expect(adapt.has_any?).to be_falsey
    end
  end
  
  describe '#read_many_nonblock' do
    
    it 'reads many messages from the input buffer returning if it would block/stopping at limit' do
      allow(adapt).to receive(:peek_console_input) { %w(a b c) }
      allow(adapt).to receive(:read_console_input).with(:nLength => 1, :blocking => false) { %w(a) }
      expect(adapt.read_many_nonblock).to eql(%w(a))
    end
  end
  
  describe '#read_many' do
    
    it 'reads the default amount of messages from the input buffer' do
      allow(adapt).to receive(:read_console_input).with(:nLength => 1, :blocking => true) { %w(a) }
      Timeout::timeout(4) {
        expect(adapt.read_many).to eql(%w(a))
      }
    end
    
    it 'blocks until the number passed in is reached' do
      allow(adapt).to receive(:read_console_input).with(:nLength => 3, :blocking => true).and_call_original
      allow(adapt.send(:link)).to receive(:ReadConsoleInput) { %w(a) }
      expect do
        Timeout::timeout(4) {
          adapt.read_many(3)
        }
      end.to raise_error(Timeout::Error)
    end
    
    it 'reads many messages from the input_buffer' do
      allow(adapt).to receive(:read_console_input).with(:nLength => 3, :blocking => true) { %w(a b c) }
      Timeout::timeout(4) {
        expect(adapt.read_many(3)).to eql(%w(a b c))
      }
    end
  end
  
  describe 'read_one_nonblock' do
    
    it 'reads one message off the input buffer' do
      allow(adapt).to receive(:peek_console_input) { %w(a) }
      allow(adapt).to receive(:read_console_input) { %w(a) }
      expect(adapt.read_one_nonblock).to eql('a')
    end
    
    it %q(doesn't block) do
      allow(adapt).to receive(:peek_console_input) { [] }
      expect(adapt.read_one_nonblock).to eql(nil)
    end
  end
  
  describe '#read_one' do
    it 'reads one message off the input buffer' do
      allow(adapt).to receive(:read_console_input) { %w(a) }
      expect(adapt.read_one).to eql('a')
    end
    
    it %q(blocks when no messages are in the buffer) do
      allow(adapt).to receive(:read_console_input).and_call_original
      allow(adapt.send(:link)).to receive(:ReadConsoleInput) { sleep 4 }
      expect do
        Timeout::timeout(3) do
          adapt.read_one
        end
      end.to raise_error(Timeout::Error)
    end
    
    context 'event_loop' do
      
      let(:eventable_adapter) do
        input_sys = double('InputSystem', :GetStdHandle => 3)
        @incr = 0
        allow(input_sys).to receive(:PeekConsoleInputW) do |hConsoleInput, lpBuffer, nLength, lpNumberOfEventsRead|
          if @incr == 0
            lpBuffer.replace(Vigilem::Win32API::PINPUT_RECORD.new(3, 
              Vigilem::Win32API::INPUT_RECORD[Vigilem::Win32API::KEY_EVENT, {:KeyEvent => [1, 1, 70, 33, {:UnicodeChar => 97}, 32]}]
            ))
            @incr += 1
          end
          1
        end
        allow(input_sys).to receive(:ReadConsoleInputW) do |hConsoleInput, lpBuffer, nLength, lpNumberOfEventsRead|
          lpBuffer.replace(Vigilem::Win32API::PINPUT_RECORD.new(3, 
            Vigilem::Win32API::INPUT_RECORD[Vigilem::Win32API::KEY_EVENT, {:KeyEvent => [1, 1, 70, 33, {:UnicodeChar => 97}, 32]}]
          ))
          1
        end
        EventableAdapter.new(Vigilem::Win32API::InputSystemHandler.new(input_sys))
      end
      
      it 'will return one event per event in the win32 event queue' do # to check that there is parity between the input_system and here
        expect([eventable_adapter.read_one_nonblock, eventable_adapter.read_one_nonblock]).to match [
          instance_of(Vigilem::Win32API::INPUT_RECORD), nil
        ]
      end
    end
    
  end
  
end
