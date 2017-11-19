class DeezerApi

    def process_code_to_get_token(app_id,secret,code)
      begin
       Rails.logger.info "Deezer token request url ===== #{token_url} , code  ==== #{code}"
        response = JSON.parse RestClient.get(Setting.token_url, {:params=>{:app_id=>app_id,:secret=>secret,:output=>"json",:code=>code}})
        Rails.logger.info "Deezer response ===== #{response}"
        return response['access_token'] if response.present?
      rescue StandardError => e
        Rails.logger.error "Access token not found with code ===== #{code} ======== BackTrace #{e.backtrace}"
      end
      nil
    end


    def get_user_info(token=Setting.access_token)
     tries_remaining, sleep_time = 15, 1

     begin 
      @user  = JSON.parse RestClient.get "http://api.deezer.com/user/me",{:params=>{:access_token=>token}}
      
      # @user =  if @user['error'].present?
      #           raise @user_tracks['error']['message']
      #         else
      #            @user
      #         end   
      
      rescue RestClient::RequestFailed => e
        if (([429, 420].include?(e.response.code) && tries_remaining > 0) rescue false)
          if e.response.headers[:retry_after].to_i != 0
            Resque.logger.info "Inside get_user_info retry_after #{e.response.headers[:retry_after]}"
            sleep_time = e.response.headers[:retry_after].to_f + rand
          else
            sleep_time = (sleep_time.to_f  + rand) * 2
          end

          Resque.logger.info "going to sleep for #{sleep_time} seconds while processing get_user_info  because of a 429.Tries remaining are #{tries_remaining}"
          Kernel.sleep(sleep_time)
          Resque.logger.info "WOKE UP after #{sleep_time}seconds while processing get_user_info."
          
          tries_remaining -= 1

          retry
        else
          Resque.logger.error "Inside get_user_info RestClient::RequestFailed message======= #{e.message} backtrace ==== #{e.backtrace}"
        end
      
        
      rescue URI::InvalidURIError => e
        Resque.logger.error "Invalid URI"
        Resque.logger.error "RestClient::RequestFailed message======= #{e.message} backtrace ==== #{e.backtrace}"

      

      rescue StandardError => e
        Rails.logger.error "Something went wrong."
        puts e
      end 
    end

  def user_tracks(token=Setting.accesss_token)
    ##favorite tracks
    tries_remaining, sleep_time = 15, 1
    begin 
      @user_tracks = JSON.parse RestClient.get "http://api.deezer.com/user/me/tracks",{:params=>{:access_token=>token}}
      
      # raise @user_tracks['error']['message'] if @user_tracks['error'].present?
      #Track Artists and Track Albums
      @artists,@albums = [],[]
      @user_tracks['data'].each do |artist|
        @artists << artist['artist']
      end 

      @user_tracks['data'].each do |album|
        @albums << album['album']
      end
    
    rescue RestClient::RequestFailed => e
      if (([429, 420].include?(e.response.code) && tries_remaining > 0) rescue false)
        if e.response.headers[:retry_after].to_i != 0
          Resque.logger.info "Inside user_tracks retry_after #{e.response.headers[:retry_after]}"
          sleep_time = e.response.headers[:retry_after].to_f + rand
        else
          sleep_time = (sleep_time.to_f  + rand) * 2
        end

        Resque.logger.info "going to sleep for #{sleep_time} seconds while processing user_tracks  because of a 429.Tries remaining are #{tries_remaining}"
        Kernel.sleep(sleep_time)
        Resque.logger.info "WOKE UP after #{sleep_time}seconds while processing user_tracks."
        
        tries_remaining -= 1

        retry
      else
        Resque.logger.error "Inside user_tracks RestClient::RequestFailed message======= #{e.message} backtrace ==== #{e.backtrace}"
      end
      

    rescue URI::InvalidURIError => e
      Resque.logger.error "Invalid URI"
      Resque.logger.error "RestClient::RequestFailed message======= #{e.message} backtrace ==== #{e.backtrace}"
     

    rescue StandardError => e
      Rails.logger.error "Something went wrong."
      puts e
    end 
    
  end

  def user_playlists(token=Setting.accesss_token)
    tries_remaining, sleep_time = 15, 1
    begin
    @user_playlists = JSON.parse RestClient.get "http://api.deezer.com/user/me/playlists",{:params=>{:access_token=>token}}
    ##Playlist Tracks
    
    # raise @user_playlists['error']['message'] if @user_playlists['error']
    
    @playlist_tracks = []
    
    @user_playlists['data'].each do |tlist|
      @playlists = JSON.parse RestClient.get tlist['tracklist']
      raise @playlists['error']['message'] if @playlists['error']
      
      @playlist_tracks << @playlists['data']
      if @playlists['next'].present?  && @playlists['total'] > 25
        @playlist_tracks << (JSON.parse RestClient.get @playlists['next'])
      end  
    end

    rescue RestClient::RequestFailed => e
      if (([429, 420].include?(e.response.code) && tries_remaining > 0) rescue false)
        if e.response.headers[:retry_after].to_i != 0
          Resque.logger.info "Inside user_playlists retry_after #{e.response.headers[:retry_after]}"
          sleep_time = e.response.headers[:retry_after].to_f + rand
        else
          sleep_time = (sleep_time.to_f  + rand) * 2
        end

        Resque.logger.info "going to sleep for #{sleep_time} seconds while processing user_playlists  because of a 429.Tries remaining are #{tries_remaining}"
        Kernel.sleep(sleep_time)
        Resque.logger.info "WOKE UP after #{sleep_time}seconds while processing user_playlists."
        
        tries_remaining -= 1

        retry
      else
        Resque.logger.error "Inside user_playlists RestClient::RequestFailed message======= #{e.message} backtrace ==== #{e.backtrace}"
      end
    
    
    rescue URI::InvalidURIError => e
      Resque.logger.error "Invalid URI"
      Resque.logger.error "RestClient::RequestFailed message======= #{e.message} backtrace ==== #{e.backtrace}"
     


    rescue StandardError => e
      Rails.logger.error "Something went wrong."
      puts e
    end
  end

  def add_track_to_playlist(token=Setting.accesss_token)
    tries_remaining, sleep_time = 15, 1

    begin
      @status = RestClient.post "http://api.deezer.com/playlist/1439475515/tracks",{:access_token=>token,:songs=>"118584990"},:accept=>:json
      
    # raise @status['error']['message'] if @status['error']
    
    rescue RestClient::RequestFailed => e
      if (([429, 420].include?(e.response.code) && tries_remaining > 0) rescue false)
        if e.response.headers[:retry_after].to_i != 0
          Resque.logger.info "Inside add_track_to_playlist retry_after #{e.response.headers[:retry_after]}"
          sleep_time = e.response.headers[:retry_after].to_f + rand
        else
          sleep_time = (sleep_time.to_f  + rand) * 2
        end

        Resque.logger.info "going to sleep for #{sleep_time} seconds while processing add_track_to_playlist  because of a 429.Tries remaining are #{tries_remaining}"
        Kernel.sleep(sleep_time)
        Resque.logger.info "WOKE UP after #{sleep_time}seconds while processing add_track_to_playlist."
        
        tries_remaining -= 1

        retry
      else
        Resque.logger.error "Inside add_track_to_playlist RestClient::RequestFailed message======= #{e.message} backtrace ==== #{e.backtrace}"
      end
    

    rescue URI::InvalidURIError => e
      Resque.logger.error "Invalid URI"
      Resque.logger.error "RestClient::RequestFailed message======= #{e.message} backtrace ==== #{e.backtrace}"
      

    rescue StandardError => e
      Rails.logger.error "Something went wrong."
      puts e
    end   
  end

  def remove_track_from_tracklist(token=Setting.accesss_token)
       tries_remaining, sleep_time = 15, 1

   begin
      @status = RestClient.delete "http://api.deezer.com/playlist/1439475515/tracks",{params:{:access_token=>token,:songs=>"118584990"}}
      
    # raise @status['error']['message'] if @status['error']
    
    rescue RestClient::RequestFailed => e
      if (([429, 420].include?(e.response.code) && tries_remaining > 0) rescue false)
        if e.response.headers[:retry_after].to_i != 0
          Resque.logger.info "Inside remove_track_from_tracklist retry_after #{e.response.headers[:retry_after]}"
          sleep_time = e.response.headers[:retry_after].to_f + rand
        else
          sleep_time = (sleep_time.to_f  + rand) * 2
        end

        Resque.logger.info "going to sleep for #{sleep_time} seconds while processing remove_track_from_tracklist  because of a 429.Tries remaining are #{tries_remaining}"
        Kernel.sleep(sleep_time)
        Resque.logger.info "WOKE UP after #{sleep_time}seconds while processing remove_track_from_tracklist."
        
        tries_remaining -= 1

        retry
      else
        Resque.logger.error "Inside remove_track_from_tracklist RestClient::RequestFailed message======= #{e.message} backtrace ==== #{e.backtrace}"
      end
      

    rescue URI::InvalidURIError => e
      Resque.logger.error "Invalid URI"
      Resque.logger.error "RestClient::RequestFailed message======= #{e.message} backtrace ==== #{e.backtrace}"
        

    rescue StandardError => e
      Rails.logger.error "Something went wrong."
      puts e
    end  

  end

  def create_playlist(token=Setting.accesss_token)
        tries_remaining, sleep_time = 15, 1

    begin
      @status = RestClient.post "http://api.deezer.com/user/me/playlists",{:access_token=>token,:title=>"My Playlist"},:accept=>:json
    
    # raise @status['error']['message'] if @status['error']
    
    rescue RestClient::RequestFailed => e
      if (([429, 420].include?(e.response.code) && tries_remaining > 0) rescue false)
        if e.response.headers[:retry_after].to_i != 0
          Resque.logger.info "Inside create_playlist retry_after #{e.response.headers[:retry_after]}"
          sleep_time = e.response.headers[:retry_after].to_f + rand
        else
          sleep_time = (sleep_time.to_f  + rand) * 2
        end

        Resque.logger.info "going to sleep for #{sleep_time} seconds while processing create_playlist  because of a 429.Tries remaining are #{tries_remaining}"
        Kernel.sleep(sleep_time)
        Resque.logger.info "WOKE UP after #{sleep_time}seconds while processing create_playlist."
        
        tries_remaining -= 1

        retry
      else
        Resque.logger.error "Inside create_playlist RestClient::RequestFailed message======= #{e.message} backtrace ==== #{e.backtrace}"
      end
    
      
    rescue URI::InvalidURIError => e
      Resque.logger.error "Invalid URI"
      Resque.logger.error "RestClient::RequestFailed message======= #{e.message} backtrace ==== #{e.backtrace}"
      

    rescue StandardError => e
      Rails.logger.error "Something went wrong."
      puts e
    end   
  end 

  def add_track_to_fav_tracks(token=Setting.accesss_token) 
        tries_remaining, sleep_time = 15, 1

    begin
    @status = RestClient.post "http://api.deezer.com/user/me/tracks",{:access_token=>token,:track_id=>"123456"},:accept=>:json
    
    # raise @status['error']['message'] if @status['error']
    
    rescue RestClient::RequestFailed => e
      if (([429, 420].include?(e.response.code) && tries_remaining > 0) rescue false)
        if e.response.headers[:retry_after].to_i != 0
          Resque.logger.info "Inside add_track_to_fav_tracks retry_after #{e.response.headers[:retry_after]}"
          sleep_time = e.response.headers[:retry_after].to_f + rand
        else
          sleep_time = (sleep_time.to_f  + rand) * 2
        end

        Resque.logger.info "going to sleep for #{sleep_time} seconds while processing add_track_to_fav_tracks  because of a 429.Tries remaining are #{tries_remaining}"
        Kernel.sleep(sleep_time)
        Resque.logger.info "WOKE UP after #{sleep_time}seconds while processing add_track_to_fav_tracks."
        
        tries_remaining -= 1

        retry
      else
        Resque.logger.error "Inside add_track_to_fav_tracks RestClient::RequestFailed message======= #{e.message} backtrace ==== #{e.backtrace}"
      end
    
      
    rescue URI::InvalidURIError => e
      Resque.logger.error "Invalid URI"
      Resque.logger.error "RestClient::RequestFailed message======= #{e.message} backtrace ==== #{e.backtrace}"        

    rescue StandardError => e
      Rails.logger.error "Something went wrong."
      puts e
    end    
  end 

 def remove_track(token=Setting.accesss_token) 
      tries_remaining, sleep_time = 15, 1

  begin
    @status = RestClient.delete "http://api.deezer.com/user/me/tracks",{params:{:access_token=>token,:track_id=>"123456"}}
    # raise @status['error']['message'] if @status['error']
    
    rescue RestClient::RequestFailed => e
      if (([429, 420].include?(e.response.code) && tries_remaining > 0) rescue false)
        if e.response.headers[:retry_after].to_i != 0
          Resque.logger.info "Inside remove_track retry_after #{e.response.headers[:retry_after]}"
          sleep_time = e.response.headers[:retry_after].to_f + rand
        else
          sleep_time = (sleep_time.to_f  + rand) * 2
        end

        Resque.logger.info "going to sleep for #{sleep_time} seconds while processing remove_track  because of a 429.Tries remaining are #{tries_remaining}"
        Kernel.sleep(sleep_time)
        Resque.logger.info "WOKE UP after #{sleep_time}seconds while processing remove_track."
        
        tries_remaining -= 1

        retry
      else
        Resque.logger.error "Inside remove_track RestClient::RequestFailed message======= #{e.message} backtrace ==== #{e.backtrace}"
      end
    
    

    rescue URI::InvalidURIError => e
      Resque.logger.error "Invalid URI"
      Resque.logger.error "RestClient::RequestFailed message======= #{e.message} backtrace ==== #{e.backtrace}"      

    rescue StandardError => e
      Rails.logger.error "Something went wrong."
      puts e
    end      
  end     
end