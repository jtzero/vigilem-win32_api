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
      
      describe '::PeekConsoleInputW' do
        
        before :all do
          flush
          write_console_input_test
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
          expect(0.upto(4).map {|n| 2**n }).to include(@args[:lpBuffer].first.EventType)
        end
        
        it 'updates the [:lpBuffer].INPUT_RECORD.Event.KeyEvent passed in arguments' do
          expect(@args[:lpBuffer].first.Event.KeyEvent.uChar).to_not eql(0)
        end
        
      end
      
      describe '::ReadConsoleInputW' do
        context 'params lpBuffer.size and != (nLength == lpNumberOfEventsRead), 2 events written' do
          let(:args) do
            {
              :hConsoleInput => std_handle,
              :lpBuffer => described_class::PINPUT_RECORD.new(4),
              :nLength => 3,
              :lpNumberOfEventsRead => FFI::MemoryPointer.new(:dword, 3)
            }
          end
          
          before :each do
            flush
            write_console_input_test(2)
            described_class.ReadConsoleInputW(*args.values)
          end
          
          it ':lpBuffer will match the number of events' do
            expect(args[:lpBuffer].size).to eql(2)
          end
          
          it ':nLength will be the same after' do
            expect(args[:nLength]).to eql(3)
          end
          
          it ':lpNumberOfEventsRead will be the same as :lpBuffer.size' do
            expect(args[:lpNumberOfEventsRead].read_short).to eql(args[:lpBuffer].size)
          end
        end
        
        context 'params (lpBuffer.size == nLength) and != lpNumberOfEventsRead, 2 events written' do
          let(:args) do
            {
              :hConsoleInput => std_handle,
              :lpBuffer => described_class::PINPUT_RECORD.new(4),
              :nLength => 4,
              :lpNumberOfEventsRead => FFI::MemoryPointer.new(:dword, 3)
            }
          end
          
          before :each do
            flush
            write_console_input_test(2)
            described_class.ReadConsoleInputW(*args.values)
          end
          
          it ':lpBuffer will match the number of events' do
            expect(args[:lpBuffer].size).to eql(2)
          end
          
          it ':nLength will be the same after' do
            expect(args[:nLength]).to eql(4)
          end
          
          it ':lpNumberOfEventsRead will be the same as :lpBuffer.size' do
            expect(args[:lpNumberOfEventsRead].read_short).to eql(args[:lpBuffer].size)
          end
        end
        
        context 'params nLength and != (lpBuffer.size == lpNumberOfEventsRead), 2 events written' do
          let(:args) do
            {
              :hConsoleInput => std_handle,
              :lpBuffer => described_class::PINPUT_RECORD.new(4),
              :nLength => 3,
              :lpNumberOfEventsRead => FFI::MemoryPointer.new(:dword, 3)
            }
          end
          
          before :each do
            flush
            write_console_input_test(2)
            described_class.ReadConsoleInputW(*args.values)
          end
          
          it ':lpBuffer will match the number of events' do
            expect(args[:lpBuffer].size).to eql(2)
          end
          
          it ':nLength will be the same after' do
            expect(args[:nLength]).to eql(3)
          end
          
          it ':lpNumberOfEventsRead will be the same as :lpBuffer.size' do
            expect(args[:lpNumberOfEventsRead].read_short).to eql(args[:lpBuffer].size)
          end
        end
        
        context 'params (nLength != lpBuffer.size) and < 2 events written' do
          let(:args) do
            {
              :hConsoleInput => std_handle,
              :lpBuffer => described_class::PINPUT_RECORD.new(1),
              :nLength => 1,
              :lpNumberOfEventsRead => FFI::MemoryPointer.new(:dword, 3)
            }
          end
          
          before :each do
            flush
            write_console_input_test(2)
            described_class.ReadConsoleInputW(*args.values)
          end
          
          it ':lpBuffer will match the number of events' do
            expect(args[:lpBuffer].size).to eql(1)
          end
          
          it ':nLength will be the same after' do
            expect(args[:nLength]).to eql(1)
          end
          
          it ':lpNumberOfEventsRead will be the same as :lpBuffer.size' do
            expect(args[:lpNumberOfEventsRead].read_short).to eql(args[:lpBuffer].size)
          end
        end
        
        context 'params lpBuffer.size == nLength' do
          before :all do
            flush
            write_console_input_test(2)
            @rargs = {
              :hConsoleInput => std_handle,
              :lpBuffer => described_class::PINPUT_RECORD.new(len = 4),
              :nLength => len,
              :lpNumberOfEventsRead => FFI::MemoryPointer.new(:dword, 2)
            }
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
          
          # this can produce a false positive if the tester presses some buttons,
          # this test is one that needs to be isolatesd
          it %q<compacts the list so there aren't several empty INPUT_RECORDs> do
            expect(@rargs[:lpBuffer].all?(&:event_record)).to be_truthy
          end
        end
        
      end
      
      describe '::PeekConsoleInputW' do
        
        before :all do
          flush
          write_console_input_test
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