module Preprocessor
  module Video
    class << self
      attr_accessor :options
    end

    @options = { :default_path => '/video' }

    class YouTube
      attr_accessor :src, :width, :height
      URL_REGEXP = /youtube\.com\/(?:watch\?v=|v\/)([^\/?&]+)/i

      def initialize(options)
        self.src = options[:src]
        self.width = options[:width] || 465
        self.height = options[:height] || 344
      end

      def tag
        if src =~ URL_REGEXP
          %{<iframe width="#{width}" height="#{height}" src="https://www.youtube-nocookie.com/embed/#{$1}" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>}
        end
      end

      def self.recognizes?(src)
        src =~ URL_REGEXP
      end
    end

    class Default
      attr_accessor :src, :poster

      # lame
      include ::Preprocessor::Utilities

      def initialize(options)
        self.src = options[:src]
        self.poster = options[:poster]
      end

      def tag
        src = absolutize(self.src, ::Preprocessor::Video.options[:default_path])
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
