require 'vigilem/win32_api/virtual_keys/map'

module Vigilem::Win32API

# 
module VirtualKeys
  Map.each {|num, name| const_set(name, num) unless const_defined?(name) }
end
end