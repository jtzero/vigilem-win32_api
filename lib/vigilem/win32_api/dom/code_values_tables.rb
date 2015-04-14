module Vigilem
module Win32API::DOM
  # http://www.w3.org/TR/2014/WD-DOM-Level-3-Events-code-20140612/
  module CodeValuesTables
    
    code_values = Vigilem::DOM::CodeValues
    
    WritingSystemKeys = Support::KeyMap.new({
      :VK_OEM_3      => 'Backquote',
      :VK_OEM_5      => 'Backslash',
      :VK_BACK       => 'Backspace', 
      :VK_OEM_4      => 'BracketLeft', 
      :VK_OEM_6      => 'BracketRight', 
      :VK_OEM_COMMA  => 'Comma',
      :VK_OEM_PLUS   => 'Equal',
      #'IntlBackslash', 'IntlHash', 'IntlRo', 'IntlYen', 
      :VK_OEM_MINUS  => 'Minus', 
      :VK_OEM_PERIOD => 'Period', 
      :VK_OEM_7      => 'Quote', 
      :VK_OEM_1      => 'Semicolon', 
      :VK_OEM_2      => 'Slash'
    })
                      
    FunctionalKeys = Support::KeyMap.new({
      :VK_MENU                     => %w(AltLeft AltRight),
      [:ENHANCED_KEY, :VK_MENU]    => 'AltRight',
      :VK_LMEMU                    => 'AltLeft',
      :VK_RMEMU                    => 'AltRight',
      :VK_CAPITAL                  => 'CapsLock', 
      :VK_APPS                     => 'ContextMenu', 
      [:ENHANCED_KEY, :VK_APPS]    => 'ContextMenu', 
      :VK_CONTROL                  => %w(ControlLeft ControlRight),
      [:ENHANCED_KEY, :VK_CONTROL] => 'ControlRight',
      :VK_LCONTROL                 => 'ControlLeft', 
      :VK_RCONTROL                 => 'ControlRight',
      :VK_RETURN                   => 'Enter', 
      [:ENHANCED_KEY, :VK_LWIN]    => 'OSLeft', 
      [:ENHANCED_KEY, :VK_RWIN]    => 'OSRight', 
      :VK_SHIFT                    => %w(ShiftLeft ShiftRight),
      :VK_LSHIFT                   => 'ShiftLeft',
      :VK_RSHIFT                   => 'ShiftRight',
      :VK_SPACE                    => 'Space',
      :VK_TAB                      => 'Tab',
      :VK_KANA                     => 'KanaMode',
      :VK_NONCONVERT               => 'NonConvert' 
    })
      #'Lang1', 'Lang2', 'Lang3', 'Lang4', 'Lang5' eh?
    
    ControlPadSection = Support::KeyMap.new({
      [:ENHANCED_KEY, :VK_DELETE] => 'Delete',
      [:ENHANCED_KEY, :VK_END]    => 'End',
      :VK_HELP                    => 'Help',
      [:ENHANCED_KEY, :VK_HOME]   => 'Home',
      [:ENHANCED_KEY, :VK_INSERT] => 'Insert',
      [:ENHANCED_KEY, :VK_NEXT]   => 'PageDown',
      [:ENHANCED_KEY, :VK_PRIOR]  => 'PageUp'
    })
    
    ArrowPadSection = Support::KeyMap[[
        [:ENHANCED_KEY, :VK_DOWN],
        [:ENHANCED_KEY, :VK_LEFT],
        [:ENHANCED_KEY, :VK_RIGHT],
        [:ENHANCED_KEY, :VK_UP]
      ].zip(code_values::ArrowPadSection)
    ]
    
    NumpadSection = Support::KeyMap.new({
      [:ENHANCED_KEY, :VK_NUMLOCK] => 'NumLock',
      :VK_NUMPAD0                  => 'Numpad0',
      :VK_INSERT                   => 'Numpad0',
      :VK_NUMPAD1                  => 'Numpad1',
      :VK_END                      => 'Numpad1',
      :VK_NUMPAD2                  => 'Numpad2',
      :VK_DOWN                     => 'Numpad2',
      :VK_NUMPAD3                  => 'Numpad3',
      :VK_NEXT                     => 'Numpad3',
      :VK_NUMPAD4                  => 'Numpad4',
      :VK_LEFT                     => 'Numpad4',
      :VK_NUMPAD5                  => 'Numpad5',
      :VK_NUMPAD6                  => 'Numpad6',
      :VK_RIGHT                    => 'Numpad6',
      :VK_NUMPAD7                  => 'Numpad7',
      :VK_HOME                     => 'Numpad7',
      :VK_NUMPAD8                  => 'Numpad8',
      :VK_UP                       => 'Numpad8',
      :VK_NUMPAD9                  => 'Numpad9',
      :VK_PRIOR                    => 'Numpad9',
      :VK_ADD                      => 'NumpadAdd',
      :'?'                         => 'NumpadBackspace',
      :VK_DELETE                   => 'NumpadDecimal',
      :VK_DECIMAL                  => 'NumpadDecimal',
      [:ENHANCED_KEY, :VK_DIVIDE]  => 'NumpadDivide',
      [:ENHANCED_KEY, :VK_RETURN]  => 'NumpadEnter',
      :VK_MULTIPLY                 => 'NumpadMultiply',
      :VK_SUBTRACT                 => 'NumpadSubtract'
    })
    #'NumpadClear', 'NumpadClearEntry', 'NumpadComma', 'NumpadEqual', 'NumpadMemoryAdd', 'NumpadMemoryClear', 'NumpadMemoryRecall', 'NumpadMemoryStore', 'NumpadMemorySubtract', 'NumpadParenLeft', 'NumpadParenRight'
    
    FunctionSection = Support::KeyMap.new({
      :VK_ESCAPE   => 'Escape',
      :VK_F1       => 'F1',
      :VK_F2       => 'F2',
      :VK_F3       => 'F3',
      :VK_F4       => 'F4',
      :VK_F5       => 'F5',
      :VK_F6       => 'F6',
      :VK_F7       => 'F7',
      :VK_F8       => 'F8',
      :VK_F9       => 'F9',
      :VK_F10      => 'F10',
      :VK_F11      => 'F11',
      :VK_F12      => 'F12',
                   #=> 'Fn',
                   #=> 'FLock',
      :VK_SNAPSHOT => 'PrintScreen',
      :VK_SCROLL   => 'ScrollLock',
      :VK_PAUSE    => 'Pause'
    })
    
    MediaKeys = Support::KeyMap.new({ 
      :VK_MEDIA_NEXT_TRACK    => 'MediaTrackNext',
      :VK_MEDIA_PREV_TRACK    => 'MediaTrackPrevious',
      :VK_LAUNCH_MEDIA_SELECT => 'MediaSelect'
    })
      #'Eject', 'Power', 'WakeUp'
    
    LegacyKeysandNon_StandardKeys = Support::KeyMap.new({:VK_SELECT => 'Select'})
      
    #['Hyper', 'Super', 'Turbo', 'Abort', 'Resume', 'Suspend', 'Again', 'Copy', 'Cut', 'Find', 'Open', 'Paste', 'Props', 'Undo', 'Hiragana', 'Katakana']
  end
  CodeTable = CodeValuesTables.constants.each_with_object(Support::KeyMap.new()) do |table_name, memo| 
    table = CodeValuesTables.const_get(table_name)
    table.right_side_alias(:dom_code)
    table.right_side_alias(:dom_codes)
    table.left_side_alias(:win_vk)
    table.left_side_alias(:win_vks)
    memo.merge! table
  end
  
  CodeTable.right_side_alias(:dom_code)
  CodeTable.right_side_alias(:dom_codes)
  CodeTable.left_side_alias(:win_vk)
  CodeTable.left_side_alias(:win_vks)
end
end