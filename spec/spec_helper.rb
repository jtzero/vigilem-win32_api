# @todo metal events need to be in another windows console
# @todo alot of the receive methods are too brittle

require 'bundler'
Bundler.setup

require 'timeout'

require 'vigilem/support/core_ext/debug_puts'

require 'vigilem/support/patch/ffi/pointer'

require 'attributes_and_size_test'

require 'input_helper'


#to discover when tests hang, which will happen because I have not correctly isolated the tests
# use `rspec -f d`

