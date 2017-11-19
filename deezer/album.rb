module Deezer

  class Album < Base
    
    def initialize(options = {})
      @album_type             = options['album_type']
      @available_markets      = options['available_markets']
      @copyrights             = options['copyrights']
      @external_ids           = options['external_ids']
      @genres                 = options['genres']
      @images                 = options['images']
      @name                   = options['name']
      @popularity             = options['popularity']
      @release_date           = options['release_date']
      @release_date_precision = options['release_date_precision']

      @artists = if options['artists']
        options['artists'].map { |a| Artist.new a }
      end

      @tracks_cache = if options['tracks'] && options['tracks']['items']
        options['tracks']['items'].map { |i| Track.new i }
      end

      super(options)
    end

    class << self

      ##Find Album by UPC code
      def find_album_by_UPC_code(upc=724384960650)
        url = "album/upc:#{upc}"
        request_data = {:params=>{'access_token' => Setting.access_token}}
        Deezer.oauth_get(url,request_data)
      end  
    end 
  end
end