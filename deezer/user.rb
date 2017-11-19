module Deezer

	class User < Base

    def initialize(options = {})
      credentials = options['credentials']
      options     = options['info'] if options['info']

      @country      ||= options['country']
      @display_name ||= options['display_name']
      @email        ||= options['email']
      @followers    ||= options['followers']
      @images       ||= options['images']

      super(options)

      if credentials
        @@users_credentials ||= {}
        @@users_credentials[@id] = credentials
        @credentials = @@users_credentials[@id]
      end
    end
	
    class << self
	    
      ##Get User Info
      def get_user_info(token)
        url = "user/me"
        request_data = {:params=>{'access_token' => token }}
        Deezer.oauth_get(url,request_data)
      end
    
      ##Get User Tracks
      def user_tracks
        ##favorite tracks
        url = "user/me/tracks"
        request_data = {:params=>{'access_token' => Setting.access_token }}
        @user_track_data = Deezer.oauth_get(url,request_data)
        
        #Track Artists and Track Albums
        
        @artists = User.user_track_artists( @user_track_data['data']) 

        @albums = User.user_track_albums(@user_track_data['data'])

        return @artists,@albums
      end

      
      

      ## Create User Playlist
      def create_playlist(title="MyPlaylist")
        url = "user/me/playlists"	
        request_data = {:params=>{'access_token' => Setting.access_token ,:title=>title}}
        Deezer.oauth_post(url,request_data)
  
      end 
  
  
      ##Get User Tracks artists
      def user_track_artists(user_tracks)
      	@artists = []
      	user_tracks.each do |artist|
          @artists << artist['artist'] if artist['artist']
        end
        @artists 
      end	
  
      ##Get User Tracks albums

      def user_track_albums(user_tracks)
      	@albums = []
      	user_tracks.each do |album|
          @albums << album['album'] if album['album']
        end
        @albums 

      end
  	
   
      ##Get User Playlists
      def user_playlists
        url = "user/me/playlists"
        request_data = {:params=>{'access_token' => Setting.access_token }}
        @user_playlists_data = Deezer.oauth_get(url,request_data)
        ##Playlist Tracks
        
        User.user_playlist_tracks(@user_playlists_data['data'])
        
      end

      ##Get User Playlist tracks
      def user_playlist_tracks(user_playlists)
      	@playlist_tracks = []
    	  request_data = {:params=>{'access_token' => Setting.access_token }}

      	user_playlists.each do |playlist|
      		url = "playlist/#{playlist['id']}/tracks"
      		@playlists = Deezer.oauth_get(url)
      		@playlist_tracks << @playlists['data'] 
      		while @playlists['next'].present?
      			
      			url = "playlist/#{playlist['id']}/tracks?"+@playlists['next'].split("?")[1]
      			@playlists = Deezer.oauth_get(url,request_data) 
            @playlist_tracks << @playlists['data'] if @playlists['data']

          end 
        end
        
      end	
  
    end 

    def saved_tracks(limit: 25, index: 0)
      url = "user/me/tracks"
      request_data = {:params=>{'access_token' => @credentials['token'] }}
      @user_track_data = Deezer.oauth_get(url,request_data)
      @user_track_data['data'].map!{ |i| Track.new i.merge!({'added_at' => i['added_at']}) }
      
    end  

  end	
end

