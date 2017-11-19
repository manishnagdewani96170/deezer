module Deezer
  class Track < Base
    
    def initialize(options = {})
      @available_markets = options['available_countries']
      @disc_number       = options['disc_number']
      @duration_ms       = options['duration']
      @explicit          = options['explicit_lyrics']
      @name              = options['title']
      @popularity        = options['popularity']
      @preview_url       = options['preview']
      @track_number      = options['track_position']
      @added_at          = options['added_at']
      @is_playable       = options['is_readable']

      @album = if options['album']
        Album.new options['album']
      end

      @artists = if options['artists']
        options['artists'].map { |a| Artist.new a }
      end

      super(options)
    end

    class << self
      
      ##Add Track to Favourite Tracks
      def add_track_to_fav_tracks(track_id=123456) 
     
        url = "user/me/tracks"
        request_data = {'access_token' => Setting.access_token,"track_id"=>track_id} 
        Deezer.oauth_post(url,request_data)
   
      end 

      ## Remove Track
      def remove_track(track_id=123456) 
        url = "user/me/tracks"
        request_data = {:params=>{'access_token' => Setting.access_token,"track_id"=>track_id}} 
        Deezer.oauth_delete(url,request_data)
      
      end 

      ##Find Track by ISRC
      def find_track_by_ISRC_code(isrc='GBDUW0000059')
        url = "track/isrc:#{isrc}"
        request_data = {:params=>{'access_token' => Setting.access_token}}
        Deezer.oauth_get(url,request_data)    
      end    

    end
  end
end 