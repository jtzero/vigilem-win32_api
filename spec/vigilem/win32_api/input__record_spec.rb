require 'spec_helper'

require 'vigilem/win32_api/types'
require 'vigilem/win32_api/console_input_events'

require 'vigilem/win32_api/input__record'

describe Vigilem::Win32API do
  
      
  describe 'constants' do
    specify { expect(described_class::INPUT_RECORD).to eql(described_class::InputRecord) }
  end
  
  describe described_class::INPUT_RECORD do
    
    it 'will create a shell object, when no arguments, without error' do
      expect { described_class.new }.to_not raise_error
    end
    
    describe '::EventType' do
      it 'will have an EventType' do
        expect(described_class.new).to respond_to(:EventType)
      end
      
      it 'return the ID representing the window event type' do
        expect(described_class[Vigilem::Win32API::KEY_EVENT, {:KeyEvent => [1, 1, 70, 33, {:UnicodeChar => 97 }, 32]}].EventType).to eql(1)
      end
    end
    
    describe '::Event' do
      it 'will be a union' do
        expect(subject.Event).to be_a(FFI::Union)
      end
    end
    
    let(:ir) { 
      ipt = Vigilem::Win32API::INPUT_RECORD.new()
      ipt.type_of(:Event).struct_class.new()
      ipt
    }
    
    describe described_class::Event do
      let(:correct) do
        { :KeyEvent => (api = Vigilem::Win32API)::KEY_EVENT_RECORD,
        :MouseEvent => api::MOUSE_EVENT_RECORD,
        :WindowBufferSizeEvent => api::WINDOW_BUFFER_SIZE_RECORD,
        :MenuEvent => api::MENU_EVENT_RECORD,
        :FocusEvent => api::FOCUS_EVENT_RECORD
        }
      end
      
      specify 'that fields in the the union match the correct class' do
        expect(ir.Event.class.layout.fields.all? {|fld| correct[fld.name].name == fld.type.struct_class.name }).to be_truthy
      end
    end
    
    describe '#to_h' do
        
      let(:hsh) { input_record.to_h }
      
      it 'converts the struct attributes into a Hash' do
        expect(hsh[:EventType]).to eq(1)
        expect(hsh[:Event]).to eql(:KeyEvent=>
                                    {
                                      :bKeyDown=>1, :wRepeatCount=>1, :wVirtualKeyCode=>70, :wVirtualScanCode=>33, 
                                      :uChar=>{:UnicodeChar=>97, :AsciiChar=>97}, :dwControlKeyState=>32
                                    }
                                  )
      end
    end
    
    describe '#type' do
      it 'returns the EventType' do
        expect(input_record.type).to eql(input_record.EventType)
      end
    end
    describe '#event_record' do
      
      it %q(returns the Event that's populated) do
        expect(input_record.event_record.bytes).to eql(input_record.Event.KeyEvent.bytes)
      end
    end
    
    let(:input_record) do
      described_class[Vigilem::Win32API::KEY_EVENT, {:KeyEvent => [1, 1, 70, 33, {:UnicodeChar => 97 }, 32]}]
    end
    
    let(:event_record_class) { 'Vigilem::Win32API::ConsoleInputEvents::KEY_EVENT_RECORD' }
    
    context 'class_methods' do
      
      describe '::event_record' do
        it %q(returns the Event that's populated) do
          expect(described_class.event_record(input_record).class.name).to eql(event_record_class)
        end
      end
    end
    
    context 'instance methods' do
      pending('@todo')
    end
    
  end
end