require 'vigilem/win32_api'

module Vigilem::Win32API
  # @abstract 
  # @see      http://msdn.microsoft.com
  module Rubyized
    
    include Vigilem::Win32API::Constants
    
    # 
    # @param  [Integer] handle defaults to Vigilem::Win32API::STD_INPUT_HANDLE
    # @return [Integer]
    def get_std_handle(handle=Vigilem::Win32API::STD_INPUT_HANDLE)
      win32_api_rubyized_src.GetStdHandle(handle)
    end
    
    # 
    # @param  [Hash] 
    # @option opts [Integer] :hConsoleInput
    # @option opts [PINPUT_RECORD || Array] :lpBuffer
    # @option opts [Integer] :nLength
    # @option opts [Integer] :lpNumberOfEventsRead
    # @return [PINPUT_RECORD]
    def peek_console_input(opts={})
      _options(opts)
      win32_api_rubyized_src.PeekConsoleInput(opts[:hConsoleInput], opts[:lpBuffer], opts[:nLength], opts[:lpNumberOfEventsRead])
      opts[:lpBuffer]
    end
    
    # default behaviour is that of read_console_input (block if no msgs in the buffer, 
    # if opts[:blocking] == true, the method will block until lpBuffer full
    # if opts[:blocking] == false, there will be no blocking
    # @param  [Hash] 
    # @option opts [Integer] :hConsoleInput
    # @option opts [PINPUT_RECORD || Array] :lpBuffer
    # @option opts [Integer] :nLength
    # @option opts [Integer] :lpNumberOfEventsRead
    # @return [PINPUT_RECORD]
    def read_console_input(opts={})
      _options(opts)
      
      lp_buffer = []
      
      if (default = (blocking = opts[:blocking]).nil?) or blocking
        begin
          win32_api_rubyized_src.ReadConsoleInput(opts[:hConsoleInput], opts[:lpBuffer], opts[:nLength], opts[:lpNumberOfEventsRead])
          lp_buffer += opts[:lpBuffer]
        end while (not default) and lp_buffer.size < opts[:nLength]
        opts[:lpBuffer].replace(lp_buffer)
      elsif not peek_console_input.empty?
        win32_api_rubyized_src.ReadConsoleInput(opts[:hConsoleInput], opts[:lpBuffer], opts[:nLength], opts[:lpNumberOfEventsRead])
        opts[:lpBuffer]
      end
    end
    
    # Translates (maps) a virtual-key code into a scan code or character 
    # value, or translates a scan code into a virtual-key code. 
    # @param  [Integer] code, the uCode
    # @param  [Symbol || Integer] conversion, the uMapType, Vigilem::Win32API::Constants::MapType
    # @raise  ArgumentError when conversion is a Symbol and not a valid uMapType name
    # @raise  ArgumentError when conversion is a Integer and not a valid uMapType code
    # @return [Integer] 
    def map_virtual_key(code, conversion)
      conversion_value = if conversion.is_a? Symbol
        raise ArgumentError, "`#{conversion}' is not an available uMapType name" unless MapType.constants.include? conversion
        API::Rubyized.const_get(conversion)
      elsif not (@uMapeTypes ||= MapType.constants.map {|const| Vigilem::Win32API::Rubyized.const_get(const) }).include? conversion
        raise ArgumentError, "`#{conversion}' is not an available uMapType" 
      end
      win32_api_rubyized_src.MapVirtualKey(code, conversion_value || conversion)
    end
    
   private
    
    # sets up default options for peek and read based 
    # on user input
    # @note   default nLength is 1
    # @param  [Hash] opts
    # @option opts [Integer] :hConsoleInput 
    # @option opts [Integer] :nLength 
    # @option opts [Win32API::PINPUT_RECORD || Array] :lpBuffer
    # @option opts [NilClass || Integer] :lpNumberOfEventsRead
    # @option opts [NilClass || TrueClass || FalseClass] :blocking
    # @return [Hash]
    def _options(opts={})
      opts[:hConsoleInput] ||= get_std_handle()
      
      if opts[:lpBuffer].is_a? Array
        opts[:nLength] = opts[:lpBuffer].size
        opts[:lpBuffer] = Vigilem::Win32API::PINPUT_RECORD.new(opts[:nLength], *opts[:lpBuffer])
      else 
        opts[:nLength] ||= 1
        opts[:lpBuffer] ||= Vigilem::Win32API::PINPUT_RECORD.new(opts[:nLength])
      end
      opts[:lpNumberOfEventsRead] ||= FFI::MemoryPointer.new(:DWORD, 1)
      
      opts
    end
    
    attr_writer :win32_api_rubyized_source
    
    alias_method :win32_api_rubyized_src=, :win32_api_rubyized_source=
    
    # 
    # @raise  [NotImplementedError]
    # @return 
    def win32_api_rubyized_source
      @win32_api_rubyized_source ||= self
    end
    
    alias_method :win32_api_rubyized_src, :win32_api_rubyized_source
    
  end
end
