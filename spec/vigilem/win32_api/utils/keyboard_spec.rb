require 'vigilem/win32_api/utils/keyboard'

describe (KB = Vigilem::Win32API::Utils::Keyboard) do
  
  let!(:arrows) { [KB::VK[:LEFT], KB::VK[:RIGHT], KB::VK[:UP], KB::VK[:DOWN]] }
  
  describe described_class::ControlPadKeys do
    describe '::control_pad_key?' do
      it 'returns true if a control key' do
        expect([KB::VK[:INSERT], KB::VK[:DELETE], 
                KB::VK[:PRIOR], KB::VK[:NEXT], KB::VK[:END], 
                KB::VK[:HOME]].all? {|vk| KB.control_pad_key?(vk) }).to be_truthy
      end
      
      it 'returns false if not a control key' do
        expect(KB.control_pad_key?(1)).to be_falsey
      end
    end
  end
  
  describe described_class::NavigationKeys do
    
    describe '::arrow_key?' do
      it 'returns true if code is any arrow key' do
        expect(arrows.all? do |vk|
          KB.arrow_key?(vk)
        end).to be_truthy
      end
      
      it 'returns false if code is not an arrow key' do
        expect(KB.arrow_key?(1)).to be_falsey
      end
    end
    
    describe '::nav_arrow_key?' do
      it 'returns true if the key is nav pad arrow key' do
        expect(arrows.all? do |vk|
          KB.nav_arrow_key?(vk, :ENHANCED_KEY)
        end).to be_truthy
      end
      
      it 'returns false if the key is not a nav pad arrow key' do
        expect(KB.nav_arrow_key?(KB::VK[:UP])).to be_falsey
      end
    end
    
    describe '::nav_control_pad_key?' do
      it 'returns true if the key is one that is above the nav arrow pad' do
        expect(KB.nav_control_pad_key?(KB::VK[:NEXT], :ENHANCED_KEY, :SOME_OTHER_KEY)).to be_truthy
      end
      
      it 'returns false if the key is one that is not above the nav arrow pad' do
        expect(KB.nav_control_pad_key?(1, :ENHANCED_KEY)).to be_falsey
      end
    end
    
  end
  
  describe described_class::NumpadKeys do
    
    describe '::numlock?' do
      it 'will be true when given numlock id' do
        expect(KB.numlock?(KB::VK[:NUMLOCK])).to be_truthy
      end
      
      it 'will be false when not given numlock num id' do
        expect(KB.numlock?(12)).to be_falsey
      end
    end
    
    describe '::numpad_return?' do
      it 'will be true when given numpad return id and :ENHANCED_KEY symbol' do
        expect(KB.numpad_return?(0x0D, :ENHANCED_KEY, :SOME_OTHER_KEY)).to be_truthy
      end
      
      it 'will be false when not given numlock num id' do
        expect(KB.numpad_return?(0x0D)).to be_falsey
      end
    end
    
    describe '::numpad_number_functions?' do
      
      let(:numbers) { 10.times.map {|n| KB::VK[:"NUMPAD#{n}"] } }
      
      it 'will be true when given keycode is a NUMPAD number' do
        expect(numbers.all? {|n| KB::numpad_number_function?(n) }).to be_truthy
      end
      
      it 'will be false when given keycode not is a NUMPAD number' do
        expect(KB.numpad_number_function?(5)).to be_falsey
      end
    end
    
    describe '::numpad_arrow?' do
      it 'returns true if the keycode is a numpad arrow' do
        expect(arrows.all? {|vk| KB.numpad_arrow?(vk) }).to be_truthy
      end
      
      it 'returns false if the keycode is not a numpad arrow' do
        expect(arrows.all? {|vk| KB.numpad_arrow?(vk, :ENHANCED_KEY) }).to be_falsey
      end
    end
    
    describe '::numpad_control_pad_key?' do
      it 'returns whether or not the keycode is a control key on the numpad , HOME, Page UP etc' do
        expect(KB.numpad?(KB::VK[:HOME])).to be_truthy
      end
      
      it 'will return false when the keycode is not a control key on the numpad, :ENHANCED_KEY refers to the nav control pad ' do
        expect(KB.numpad?(KB::VK[:HOME], :ENHANCED_KEY)).to be_falsey
      end
    end
    
    describe '::numpad?' do
      it 'returns true if the keycode is a numpad' do
        expect(KB.numpad?(KB::VK[:HOME])).to be_truthy
      end
      
      it 'returns false if the keycode is not a numpad' do
        expect(KB.numpad?(KB::VK[:A])).to be_falsey
      end
    end
    
  end
  
end