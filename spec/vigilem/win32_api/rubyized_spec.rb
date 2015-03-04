require 'spec_helper'

require 'vigilem/win32_api'

# @todo brittle and hags, need to use a double for the brittle calls, and 
# seperate out teh os specific stuff
describe Vigilem::Win32API::Rubyized do
  
  after(:example) do
    flush
  end
  
  let(:handler_class) { ::Vigilem::Win32API::InputSystemHandler }
  let(:handler) { handler_class.new }
  
  let(:adapt) do
    class WinRubyAPIAdapter
      include Vigilem::Core::Adapters::Adapter
      include Vigilem::Win32API::Rubyized
      def initialize(lnk=Vigilem::Win32API::InputSystemHandler.new)
        initialize_adapter(lnk)
        self.win32_api_rubyized_source = lnk
      end
    end
    WinRubyAPIAdapter.new.attach(handler)
  end
  
  describe '#get_std_handle' do
    it 'calls link.GetStdHandle' do
      expect(adapt.send(:win32_api_rubyized_source)).to receive(:GetStdHandle).with(Vigilem::Win32API::STD_INPUT_HANDLE)
      adapt.get_std_handle()
    end
  end
  
  context 'methods except #get_std_handle,' do
    let(:pointer_args) do
      { 
        :lpBuffer => Vigilem::Win32API::PINPUT_RECORD.new(1),
        :lpNumberOfEventsRead => FFI::MemoryPointer.new(:DWORD, 1) 
      }
    end
    
    let(:non_pointer_args) do
      { 
        :hConsoleInput => adapt.get_std_handle,
        :nLength => 1, 
      }
    end
    
    let(:all_non_pointer_args) do
      non_pointer_args.merge( :blocking => nil )
    end
    
    let(:all_args) do
      non_pointer_args.merge(pointer_args)
    end
    
    context 'private' do
      describe '#_options' do
        it 'returns default arguments' do
          arg = adapt.send(:_options)
          
          # @todo
          expect(arg).to match a_hash_including(
              #{ :lpBuffer => instance_of(Vigilem::Win32API::PINPUT_RECORD),
              #  :lpNumberOfEventsRead => kind_of(FFI::MemoryPointer)
              #}.merge(non_pointer_args)
              non_pointer_args
            )
          
          #expect(arg).to include(:lpBuffer => instance_of(Vigilem::Win32API::PINPUT_RECORD))
          #expect(arg).to include(non_pointer_args)
            # a_kind_of/instance_of(FFI::MemoryPointer) throws `Invalid Memory'
          #expect(arg[:lpNumberOfEventsRead]).to be_a(FFI::MemoryPointer)
        end
        
        it 'configures the default lpBuffer based on nLength' do
          args = adapt.send(:_options, :nLength => 3)
          expect([args[:lpBuffer].max_size, args[:nLength]]).to eql([3, 3])
        end
        
        it 'configures the default nLength based on lpBuffer.size' do
          args = adapt.send(:_options, :lpBuffer => [nil] * 4)
          expect([args[:lpBuffer].size, args[:nLength]]).to eql([4, 4])
        end
      end
    end
    
    describe '#peek_console_input' do
      it %q(won't block when the queue is empty) do
        flush
        expect do 
          Timeout::timeout(5) do 
            adapt.peek_console_input()
          end
        end.to_not raise_error
      end
    
      it 'calls link.PeekConsoleInput' do
        expect(adapt.send(:win32_api_rubyized_source)).to receive(:PeekConsoleInput)
        adapt.peek_console_input()
      end
    end
    
    describe '#read_console_input' do
      # need to allocConsole so it's isolated
=begin
      it %q(will block when the queue is empty) do
        flush
        expect do 
          Timeout::timeout(5) do 
            adapt.read_console_input()
          end
        end.to raise_error(Timeout::Error)
      end
=end
      it %q(won't block when the buffer has somthing in it) do
        write_console_input_test
        expect do 
          Timeout::timeout(5) do 
            adapt.read_console_input()
          end
        end.to_not raise_error
      end
      
      it 'calls link.ReadConsoleInput' do
        expect(adapt.send(:win32_api_rubyized_source)).to receive(:ReadConsoleInput)
        adapt.read_console_input()
      end
    end
    
  end
  
end