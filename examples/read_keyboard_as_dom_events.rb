require 'vigilem/win32_api/dom'

adapter = Vigilem::Win32API::DOM::Adapter.new

puts 'press a button calling read_one'

puts adapter.read_one.inspect
