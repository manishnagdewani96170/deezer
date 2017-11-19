module Deezer

	class Playlist < Base


    class << self
  	  
      ##Add Tracks to Playlist
      def add_track_to_playlist(playlist_id=1439475515)
     
        url = "playlist/#{playlist_id}/tracks"
        request_data = {'access_token' => Setting.access_token,'songs'=>'118584990'}
        Deezer.oauth_post(url,request_data)
            
      end

      #3Remove Tracks from Playlist
      def remove_track_from_tracklist(playlist_id=1439475515)
     	  url = "playlist/#{playlist_id}/tracks"
        request_data = {:params=>{'access_token' => Setting.access_token,"songs"=>"118584990"}}
        Deezer.oauth_delete(url,request_data)
     
  	  end

    end
  end	
end		