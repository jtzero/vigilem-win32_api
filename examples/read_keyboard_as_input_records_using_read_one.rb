require 'vigilem/win32_api'

handler = Vigilem::Win32API::InputSystemHandler.new

puts 'press a button, calling read_one'
puts handler.read_one.inspect