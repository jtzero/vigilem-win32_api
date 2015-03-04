# Vigilem::Win32API
  Provides DOM conversion and ruby binding for the Win32API
  
## Installation
  $ gem install vigilem-win32_api
  
## Usage
```ruby
  require 'vigilem/win32_api/dom'
  
  adapter = Vigilem::Win32API::DOM::Adapter.new
  
  puts adapter.read_one.inspect
```

## tested on
  ruby 2.0.0 [x64-mingw32] mri

## Roadmap
 + 1.0.0:
   - mouse
   - jettison 'system' items into own gem
   - less brittel tests
 + next
   - complete ffi items