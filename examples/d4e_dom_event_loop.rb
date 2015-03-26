require 'vigilem/win32_api/dom'

require 'vigilem/support/core_ext/debug_puts'

Signal.trap("INT") { exit 1 }

adapter = Vigilem::Win32API::DOM::Adapter.new

def checkmark
  "\u221A"
end

# ther is no ballot x on Code page 437
def ballot_x
  'x'
end

def empty_str_if_false(keyval, pad)
  half = pad / 2
  "#{' ' * half}#{if keyval
    checkmark
  else
    ballot_x
  end}#{' ' * half}"
end

puts 'https://dvcs.w3.org/hg/d4e/raw-file/tip/key-event-test.html'
puts 'Note the arrow keys in FF in the above link are wrong'
puts 'mash buttons!'
puts "Event type|shift|ctrl |alt|meta |key                 |code              |location|repeat|data"

while true
  event = adapter.read_one
  puts "#{'%-10s' % event.type}|#{empty_str_if_false(event.shiftKey, 5)}|"\
       "#{empty_str_if_false(event.ctrlKey, 5)}|#{empty_str_if_false(event.altKey, 3)}|"\
       "#{empty_str_if_false(event.metaKey, 5)}|#{'%-20s' % event.key.inspect}|#{'%-18s' % event.code}|"\
       "#{'%-8s' % event.location}|#{'%-6s' % event.repeat}|"
end
