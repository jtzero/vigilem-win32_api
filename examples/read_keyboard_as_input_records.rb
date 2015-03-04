require 'vigilem/win32_api'

handler = Vigilem::Win32API::InputSystemHandler.new

puts 'press a button, calling read_console_input'

puts handler.read_console_input({:nLength => 1}).inspect
