require 'spec_helper'

require 'vigilem/win32_api/input_system_handler'

describe Vigilem::Win32API::InputSystemHandler do
  
  describe '#GetStdHandle' do
    
    it 'forwards the call to the underlying system' do
      expect(subject.send(:link)).to receive(:GetStdHandle)
      subject.GetStdHandle(Vigilem::Win32API::STD_INPUT_HANDLE)
    end
  end
  
  context 'private' do
    
    let(:input_record)  { Vigilem::Win32API::INPUT_RECORD[Vigilem::Win32API::KEY_EVENT, {:KeyEvent => [1, 1, 70, 33, {:UnicodeChar => 97}, 32]}] }
    let(:input_record2) { Vigilem::Win32API::INPUT_RECORD[Vigilem::Win32API::KEY_EVENT, {:KeyEvent => [1, 1, 70, 33, {:UnicodeChar => 97}, 32]}] }
    
    let(:events) { [input_record, input_record2] }
    
    let(:lpBuffer) { Vigilem::Win32API::PINPUT_RECORD.new(3) }
    
    let(:lpNumberOfEventsRead) { FFI::MemoryPointer.new(:dword, 1) }
    
    describe '#_update_out_args' do
      
      let!(:input_system) do
        allow(subject).to receive(:_update_out_args).and_call_original
        subject
      end
      
      let!(:result) { input_system.send(:_update_out_args, lpBuffer, lpNumberOfEventsRead, events) }
      
      it 'updates lpNumberOfEventsRead' do
        expect(FFIUtils.read_typedef(lpNumberOfEventsRead, :dword)).to eql(events.size)
      end
      
    end
  end
  
  describe '#PeekConsoleInput' do
    context 'empty buffer' do
      let(:args) do 
        {
          :hConsoleInput => Vigilem::Win32API.GetStdHandle(Vigilem::Win32API::STD_INPUT_HANDLE),
          :lpBuffer => Vigilem::Win32API::PINPUT_RECORD.new(len = 1),
          :nLength => len,
          :lpNumberOfEventsRead => FFI::MemoryPointer.new(:dword, 1)
        }
      end
      
      let!(:input_system) do
        lnk = spy(subject.send(:link), :semaphore => @monitor ||= Monitor.new)
        subject.send(:link=, lnk)
        allow(subject).to receive(:buffer).and_call_original
        allow(subject).to receive(:PeekConsoleInput).and_call_original
        subject.PeekConsoleInput(*args.values)
        subject
      end
      
      it 'checks the buffer first' do
        expect(input_system).to have_received(:buffer).at_least(1).times
      end
      
      it 'calls the link#PeekConsoleInput' do
        expect(input_system.send(:link)).to have_received(:PeekConsoleInputW)
      end
    end
    context 'buffer > length' do
      let(:input_record) { Vigilem::Win32API::INPUT_RECORD[Vigilem::Win32API::KEY_EVENT, {:KeyEvent => [1, 1, 70, 33, {:UnicodeChar => 97}, 32]}] }
      let!(:input_system) do
        subject.buffer.concat(3.times.map { input_record.dup })
        lnk = spy(subject.send(:link), :semaphore => @monitor ||= Monitor.new)
        subject.send(:link=, lnk)
        allow(subject).to receive(:buffer).and_call_original
        allow(subject).to receive(:PeekConsoleInput).and_call_original
        subject.PeekConsoleInput(*args.values)
        subject
      end
      
      let(:args) do 
        {
          :hConsoleInput => Vigilem::Win32API.GetStdHandle(Vigilem::Win32API::STD_INPUT_HANDLE),
          :lpBuffer => Vigilem::Win32API::PINPUT_RECORD.new(len = 1),
          :nLength => len,
          :lpNumberOfEventsRead => FFI::MemoryPointer.new(:dword, 1)
        }
      end
      
      it 'checks the buffer first then call the system' do
        expect(subject).to receive(:buffer).and_call_original
        subject.PeekConsoleInput(*args.values)
      end
      
      it %q{doesn't call link#PeekConsoleInput} do
        expect(input_system.send(:link)).not_to have_received(:PeekConsoleInputW)
      end
      
    end
    
  end
  
  describe '#ReadConsoleInput' do
    context 'empty buffer' do
      let(:args) do 
        {
          :hConsoleInput => Vigilem::Win32API.GetStdHandle(Vigilem::Win32API::STD_INPUT_HANDLE),
          :lpBuffer => Vigilem::Win32API::PINPUT_RECORD.new(len = 3),
          :nLength => len,
          :lpNumberOfEventsRead => FFI::MemoryPointer.new(:dword, 1)
        }
      end
      
      let(:input_record) { Vigilem::Win32API::INPUT_RECORD[Vigilem::Win32API::KEY_EVENT, {:KeyEvent => [1, 1, 70, 33, {:UnicodeChar => 97}, 32]}] }
      
      let!(:input_system) do
        lnk = spy(subject.send(:link), :semaphore => @monitor ||= Monitor.new)
        subject.send(:link=, lnk)
        allow(subject).to receive(:buffer).and_call_original
        allow(subject).to receive(:ReadConsoleInput).and_call_original
        subject.ReadConsoleInput(*args.values)
        subject
      end
      
      it 'checks the buffer first' do
        expect(input_system).to have_received(:buffer).at_least(:once)
      end
      
      it 'calls the link#ReadConsoleInput' do
        expect(input_system.send(:link)).to have_received(:ReadConsoleInputW).at_least(:once)
      end
    end
    
    context 'buffer > length' do
      let(:input_record) { Vigilem::Win32API::INPUT_RECORD[Vigilem::Win32API::KEY_EVENT, {:KeyEvent => [1, 1, 70, 33, {:UnicodeChar => 97}, 32]}] }
      let!(:input_system) do
        subject.buffer.concat(3.times.map { input_record.dup })
        lnk = spy(subject.send(:link), :semaphore => @monitor ||= Monitor.new)
        subject.send(:link=, lnk)
        allow(subject).to receive(:buffer).and_call_original
        allow(subject).to receive(:PeekConsoleInput).and_call_original
        subject.ReadConsoleInput(*args.values)
        subject
      end
      
      let(:args) do 
        {
          :hConsoleInput => Vigilem::Win32API.GetStdHandle(Vigilem::Win32API::STD_INPUT_HANDLE),
          :lpBuffer => Vigilem::Win32API::PINPUT_RECORD.new(len = 1),
          :nLength => len,
          :lpNumberOfEventsRead => FFI::MemoryPointer.new(:dword, 1)
        }
      end
      
      it 'checks the buffer first then call the system' do
        expect(subject).to receive(:buffer).at_least(:once).and_call_original
        subject.ReadConsoleInput(*args.values)
      end
    end
    
  end
  
end