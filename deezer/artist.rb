module Deezer

  class Artist < Base

    def initialize(options = {})
      @followers  = options['followers']
      @genres     = options['genres']
      @images     = options['picture']
      @name       = options['name']
      @popularity = options['nb_fan']
      @top_tracks = {}

      super(options)
    end

  
  end
  
end    