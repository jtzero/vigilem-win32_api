module Vigilem
module Win32API::DOM
  
  # converts Windows VK if available or VK
  # https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent.code
  # https://bugzilla.mozilla.org/show_bug.cgi?id=865649
  module KeyValuesTables
    key_values = Vigilem::DOM::KeyValues
    
    ModifierKeys = Support::KeyMap.new({
      :''          => 'Accel',
      :VK_MENU     => 'Alt',
      :VK_LMENU    => 'Alt',
      :''          => 'AltGraph',
      :VK_CAPITAL  => 'CapsLock',
      :VK_CONTROL  => 'Control',
      :VK_LCONTROL => 'Control',
      :VK_RCONTROL => 'Control',
      :''          => 'Fn',
      :''          => 'FnLock',
      :''          => 'Hyper',
      :VK_RMENU    => 'Meta',
      :VK_NUMLOCK  => 'NumLock',
      :VK_LWIN     => 'OS', #The operating system key (e.g. the "Windows Logo" key).
      :VK_SCROLL   => 'ScrollLock',
      :VK_SHIFT    => 'Shift',
      :VK_LSHIFT   => 'Shift',
      :VK_RSHIFT   => 'Shift',
      :''          => 'Super',
      :''          => 'Symbol',
      :VK_SYMBOL   => 'SymbolLock' #0x7A:VK_F11:VK_SYMBOL:Symbol (SYM) key.
    })
    
    WhitespaceKeys = Support::KeyMap[[:VK_RETURN, :VK_SEPARATOR, :VK_TAB].zip(key_values::WhitespaceKeys)]
    #The space or spacebar key is encoded as ' '.

    NavigationKeys = Support::KeyMap[[:VK_DOWN, :VK_LEFT, :VK_RIGHT, :VK_UP, 
                               :VK_END, :VK_HOME,:VK_NEXT, :VK_PRIOR].zip(key_values::NavigationKeys)]
    EditingKeys = Support::KeyMap[[:VK_BACK, :VK_CLEAR, :'', :VK_CRSEL, :'', :VK_DELETE, :VK_EREOF, 
                            :VK_EXSEL, :VK_INSERT, :'', :'', :''].zip(key_values::EditingKeys)]
    UIKeys = Support::KeyMap[[:VK_ACCEPT, #IME accept?
      :'', :VK_ATTN, :VK_CANCEL, :VK_APPS, :VK_ESCAPE, :VK_EXECUTE,
      :'', :VK_HELP, :VK_PAUSE, :'', :'',
      :VK_SCROLL, :VK_ZOOM, :VK_ZOOM].zip(key_values::UIKeys)]
    DeviceKeys = Support::KeyMap.new({
      :'' => ['BrightnessDown', 'BrightnessUp', 'Camera', 'Eject', 'LogOff', 'Power', 'PowerOff', 'Hibernate', 'Standby', 'WakeUp'],
      :VK_SNAPSHOT => 'PrintScreen' #doesn;t work with readconsoleinput
    })
    IMEandCompositionKeys = Support::KeyMap.new({
      :'' => ['AllCandidates', 'Alphanumeric', 'CodeInput', 'Compose', 'GroupFirst', 'GroupLast', 'GroupNext', 'GroupPrevious', 
                                                                          'NextCandidate', 'PreviousCandidate', 'SingleCandidate'],
      :VK_CONVERT    => 'Convert',
      :VK_FINAL      => 'FinalMode',
      :VK_MODECHANGE => 'ModeChange',
      :VK_NONCONVERT => 'NonConvert',
      :VK_PROCESSKEY => 'Process'
    })
    KeysspecifictoKoreankeyboards = Support::KeyMap.new({
      :VK_OEM_BACKTAB           => 'RomanCharacters', #"RomanCharacters" for Japanese keyboard layout, "Unidentified" for the others.
      :VK_HANGUEL               => 'HangulMode',
      :VK_HANGUEL               => 'HangulMode',
      :VK_HANJA                 => 'HanjaMode',
      :VK_JUNJA                 => 'JunjaMode'
    })
    KeysspecifictoJapanesekeyboards = Support::KeyMap.new({
      :VK_OEM_ENLW => 'Zenkaku',
      :VK_OEM_AUTO => 'Hankaku',
      :''          => ['ZenkakuHankaku', 'Katakana', 'HiraganaKatakana', 'Eisu'],
      :VK_KANA     => 'KanaMode',
      :VK_KANJI    => 'KanjiMode',
      :VK_OEM_COPY => 'Hiragana' #"Hiragana" for Japanese keyboard layout, "Unidentified" for the others.
    })
    General_PurposeFunctionKeys = Support::KeyMap.new({
      :VK_F1  => 'F1',
      :VK_F2  => 'F2',
      :VK_F3  => 'F3',
      :VK_F4  => 'F4',
      :VK_F5  => 'F5',
      :VK_F6  => 'F6',
      :VK_F7  => 'F7',
      :VK_F8  => 'F8',
      :VK_F9  => 'F9',
      :VK_F10 => 'F10',
      :VK_F11 => 'F11',
      :VK_F12 => 'F12',
      :'' => ['Soft1', 'Soft2', 'Soft3', 'Soft4']
    })
    #Mediamedia
    MultimediaKeys = Support::KeyMap.new({
    #These are extra keys found on "multimedia" keyboards.
      :''                      => ['Close', 'MailForward', 'MailReply', 'MailSend', 'New', 'Open', 'Save', 'SpellCheck'],
      :VK_MEDIA_PLAY_PAUSE    => 'MediaPlayPause',
      :VK_LAUNCH_MEDIA_SELECT => 'MediaSelect',
      :VK_MEDIA_STOP          => 'MediaStop',
      :VK_MEDIA_NEXT_TRACK    => 'MediaTrackNext',
      :VK_MEDIA_PREV_TRACK    => 'MediaTrackPrevious',
      :VK_PRINT               => 'Print',
      :VK_VOLUME_DOWN         => 'VolumeDown',
      :VK_VOLUME_UP           => 'VolumeUp',
      :VK_VOLUME_MUTE         => 'VolumeMute'
    })
    ApplicationKeys = Support::KeyMap.new({
      :'' => ['LaunchCalculator', 'LaunchCalendar', 'LaunchMediaPlayer', 'LaunchMusicPlayer', 
             'LaunchMyComputer', 'LaunchScreenSaver', 'LaunchSpreadsheet', 'LaunchWebBrowser', 
                                                          'LaunchWebCam', 'LaunchWordProcessor'],
      :VK_LAUNCH_MAIL => 'LaunchMail'
    })
    BrowserKeys = Support::KeyMap[key_values::BrowserKeys.zip([:VK_BROWSER_BACK, :VK_BROWSER_FAVORITES, :VK_BROWSER_FORWARD, :VK_BROWSER_HOME, :VK_BROWSER_REFRESH, :VK_BROWSER_SEARCH, :VK_BROWSER_STOP])]
    #The key values for media controllers (e.g. remote controls for 
    #television, audio systems, and set-top boxes) are 
    #derived in part from the consumer electronics technical specifications:
    MediaControllerKeys = Support::KeyMap[key_values::MediaControllerKeys.zip([:'']).reverse]
    
    SpecialKeyValues = Support::KeyMap.new({ :'' => 'Unidentified' })
    
  end
  KeyTable = KeyValuesTables.constants.each_with_object(Support::KeyMap.new()) {|table_name, memo| memo.merge! KeyValuesTables.const_get(table_name) }
  KeyTable.default = 'Unidentified'
  
  KeyTable.right_side_alias(:dom_key)
  KeyTable.left_side_alias(:win_vk)
end
end
