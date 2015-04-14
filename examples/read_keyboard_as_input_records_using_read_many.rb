require 'pp'

require 'vigilem/win32_api'

handler = Vigilem::Win32API::InputSystemHandler.new

puts 'press a button, calling read_many(5)'
pp handler.read_many(5)
