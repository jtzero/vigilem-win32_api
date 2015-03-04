require 'spec_helper'

require 'vigilem/win32_api'

require 'timeout'

describe Vigilem::Win32API do
  
  after(:example) do
    flush
  end
  
  context '::GetStdHandle' do
    it 'will return STD_INPUT_HANDLE' do
      expect(subject.GetStdHandle(described_class::STD_INPUT_HANDLE)).to eql(std_handle)
    end
  end
  
  
  context 'methods except GetStdHandle,' do
    
    describe '::PeekConsoleInputW' do
      
      let(:args) do 
        {
          :hConsoleInput => described_class.GetStdHandle(described_class::STD_INPUT_HANDLE),
          :lpBuffer => described_class::PINPUT_RECORD.new(len = 1),
          :nLength => len,
          :lpNumberOfEventsRead => FFI::MemoryPointer.new(:dword, 1)
        }
      end
      
      it %q(won't block when the queue is empty) do
        flush
        expect do 
          Timeout::timeout(5) do 
            subject.PeekConsoleInputW(*args.values)
          end
        end.to_not raise_error
      end
      
      it 'will return one when it executes correctly' do 
        expect(subject.PeekConsoleInputW(*args.values)).to eql 1
      end
    end
    
    context 'user input' do
      
      before :each do
        flush
        write_console_input_test
      end
      
      describe '::PeekConsoleInputW' do
        
        before :all do 
          @args = {
            :hConsoleInput => std_handle,
            :lpBuffer => described_class::PINPUT_RECORD.new(len = 1),
            :nLength => len,
            :lpNumberOfEventsRead => FFI::MemoryPointer.new(:dword, 1)
          }
        end
        
        it 'updates lpNumberOfEventsRead passed in arguments' do  
          expect do 
            Timeout::timeout(5) do 
              subject.PeekConsoleInputW(*@args.values) until @args[:lpNumberOfEventsRead].read_short > 0
            end
          end.to_not raise_error
        end
        
        it 'updates the [:lpBuffer].INPUT_RECORD.EventType passed in arguments' do
          #puts ">#{@args[:lpBuffer].first}"
          #  expected [] to respond to `a??`
          #expect(args[:lpBuffer]).to be_a?(described_class::PINPUT_RECORD)
          
          expect(0.upto(4).map {|n| 2**n }).to include(@args[:lpBuffer].first.EventType)
        end
        
        it 'updates the [:lpBuffer].INPUT_RECORD.Event.KeyEvent passed in arguments' do
          expect(@args[:lpBuffer].first.Event.KeyEvent.uChar).to_not eql(0)
        end
        
      end
      
      describe '::ReadConsoleInputW' do
        
        before :all do
          @rargs = {
            :hConsoleInput => std_handle,
            :lpBuffer => described_class::PINPUT_RECORD.new(len = 2),
            :nLength => len,
            :lpNumberOfEventsRead => FFI::MemoryPointer.new(:dword, 1)
          }
          write_console_input_test
          described_class.ReadConsoleInputW(*@rargs.values)
        end
        
        it 'pulls input_records from queue' do 
          expect(@rargs[:lpNumberOfEventsRead].read_short).to be > 1
        end
        
        it 'updates the [:lpBuffer].INPUT_RECORD.EventType passed in arguments' do 
          expect(@rargs[:lpBuffer].first.EventType).to eql(1)
        end
        
        it 'updates the [:lpBuffer].INPUT_RECORD.Event.KeyEvent passed in arguments' do 
          expect(@rargs[:lpBuffer].first.Event.KeyEvent.uChar).to_not be_nil
        end
        
      end
      
      describe '::PeekConsoleInputW' do
        
        before :all do 
          @pargs = {
            :hConsoleInput => std_handle,
            :lpBuffer => described_class::PINPUT_RECORD.new(len = 1),
            :nLength => len,
            :lpNumberOfEventsRead => FFI::MemoryPointer.new(:dword, 1)
          }
          @prargs = {
            :hConsoleInput => std_handle,
            :lpBuffer => described_class::PINPUT_RECORD.new(len = 1),
            :nLength => len,
            :lpNumberOfEventsRead => FFI::MemoryPointer.new(:dword, 1)
          }
        end
        
        it 'does not effect the queue' do
          expect(subject.PeekConsoleInputW(*@pargs.values)).to be == subject.ReadConsoleInputW(*@prargs.values)
        end
        
      end
      
    end
  end
end