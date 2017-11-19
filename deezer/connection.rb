require 'json'
require 'restclient'

module Deezer

  API_URI       = 'https://api.deezer.com/'
  VERBS         = %w(get post delete)

  class << self

    ##Get authenticate by code
    def authenticate(code)
      begin
      Rails.logger.info "Deezer token request url ===== #{Setting.token_url} , code  ==== #{code}"
        response = JSON.parse RestClient.get(Setting.token_url, {:params=>{:app_id=>Setting.app_id,:secret=>Setting.secret,:code=>code,:output=>"json"}})
        
        Rails.logger.info "Deezer response ===== #{response}"
        return response['access_token'] if response.present?
      rescue StandardError => e
        Rails.logger.error "Access token not found with code ===== #{code} ======== BackTrace #{e.backtrace}"
      end
      true
    end

      
      VERBS.each do |verb|
        define_method verb do |path, *params|
          #Its kind of hack, we need to simplyfy place where we will do encode only once, so no need to decode here.
          tries_remaining, sleep_time = 15, 1

          path = URI.decode(path) if path.include?("%2")
          @caller_method =  caller[1][/`([^']*)'/, 1]
          puts @caller_method
          begin
            response = RestClient.send(verb, api_url(path), *params)
            Resque.logger.info "Going to Deezer for request type #{verb} ========== Parameters #{params} =========== URL #{path}"
            
            if (verb == "delete" || verb == "post") && !response['error'].present? 
              response 
            elsif !response.empty?
              JSON.parse response
            end  

          rescue RestClient::RequestFailed => e
            if (([429, 420].include?(e.response.code) && tries_remaining > 0) rescue false)
              if e.response.headers[:retry_after].to_i != 0
                Resque.logger.info "Inside #{@caller_method} retry_after #{e.response.headers[:retry_after]}"
                sleep_time = e.response.headers[:retry_after].to_f + rand
              else
                sleep_time = (sleep_time.to_f  + rand) * 2
              end

              Resque.logger.info "going to sleep for #{sleep_time} seconds while processing #{@caller_method}  because of a 429.Tries remaining are #{tries_remaining}"
              Kernel.sleep(sleep_time)
              Resque.logger.info "WOKE UP after #{sleep_time}seconds while processing #{@caller_method}."
              
              tries_remaining -= 1

              retry
              else
                Resque.logger.error "Inside #{@caller_method} RestClient::RequestFailed message======= #{e.message} backtrace ==== #{e.backtrace}"
              end
      
        
          rescue URI::InvalidURIError => e
            Resque.logger.error "Invalid URI"
            Resque.logger.error "Inside #{@caller_method} RestClient::RequestFailed message======= #{e.message} backtrace ==== #{e.backtrace}"

      

          rescue StandardError => e
            Rails.logger.error "Inside #{@caller_method} something went wrong."
            puts e['message']
          end 

          
        end

        
        define_method "oauth_#{verb}" do |path, *params|
          
          # params << auth_header 
          send(verb, URI.encode(path), *params)
        end
        
          
      end


    private

    def api_url(path)
      path.start_with?("http") ? path : API_URI + path
    end

    def auth_header
      {params: { 'access_token' => Setting.access_token }}
    end

  end
end
