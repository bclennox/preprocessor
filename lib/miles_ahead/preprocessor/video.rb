module MilesAhead
  module Preprocessor
    module Video
      class << self
        attr_accessor :options
      end
      
      @options = { :default_path => '/video' }
      
      class YouTube
        attr_accessor :src
        URL_REGEXP = /youtube\.com\/(?:watch\?v=|v\/)([^\/?&]+)/i
        
        def initialize(options)
          self.src = options[:src]
        end
        
        def tag
          if src =~ URL_REGEXP
            url = "http://www.youtube.com/v/#{$1}"
            %{<object width="425" height="344"><param name="movie" value="#{url}"></param><param name="allowFullScreen" value="true"></param><param name="allowscriptaccess" value="always"></param><embed src="#{url}" type="application/x-shockwave-flash" allowscriptaccess="always" allowfullscreen="true" width="425" height="344"></embed></object>}
          end
        end
        
        def self.recognizes?(src)
          src =~ URL_REGEXP
        end
      end
      
      class Default
        attr_accessor :src, :poster
        
        # lame
        include MilesAhead::Preprocessor::Utilities
        
        def initialize(options)
          self.src = options[:src]
          self.poster = options[:poster]
        end
        
        def tag
          src = absolutize(self.src, MilesAhead::Preprocessor::Video.options[:default_path])
          poster = self.poster && %{poster="#{self.poster}"}
          
          # eventually should use http://camendesign.com/code/video_for_everybody
          %{<video controls #{poster}><source src="#{src}.ogv" type="video/ogg" /><source src="#{src}.mp4" type="video/mp4" /></video>}
        end
      end
      
      CUSTOM_EMBEDDERS = [YouTube]
      
      def video(options)
        embedder = CUSTOM_EMBEDDERS.detect { |e| e.recognizes?(options[:src]) } || Default
        embedder.new(options).tag
      end
    end
  end
end
