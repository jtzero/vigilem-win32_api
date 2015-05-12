
module Coveralls
  class API

    def self.post_json(endpoint, hash)
      disable_net_blockers!
      url = endpoint_to_url(endpoint)
      Coveralls::Output.puts("#{ JSON.pretty_generate(hash) }", :color => "green") if ENV['COVERALLS_DEBUG']
      hash = apified_hash hash
      Coveralls::Output.puts("[My Coveralls] Submitting to #{API_BASE}", :color => "cyan")
      response = RestClient::Request.execute(:method => :post, :url => url, :payload => { :json_file => hash_to_file(hash) }, :version => :TLSv1)
      response_hash = JSON.load(response.to_str)
      Coveralls::Output.puts("[Coveralls] #{ response_hash['message'] }", :color => "cyan")
      if response_hash['message']
        Coveralls::Output.puts("[Coveralls] #{ Coveralls::Output.format(response_hash['url'], :color => "underline") }", :color => "cyan")
      end
    rescue RestClient::ServiceUnavailable
      Coveralls::Output.puts("[Coveralls] API timeout occured, but data should still be processed", :color => "red")
    rescue RestClient::InternalServerError
      Coveralls::Output.puts("[Coveralls] API internal error occured, we're on it!", :color => "red")
    end
  end
end

puts 'loaded'
