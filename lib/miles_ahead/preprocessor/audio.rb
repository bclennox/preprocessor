module MilesAhead
  module Preprocessor
    module Audio
      class << self
        attr_accessor :options
      end
      
      @options = { :default_path => '/audio' }
      
      def audio(options)
        src = absolutize(options[:src], MilesAhead::Preprocessor::Audio.options[:default_path])
        %{<audio controls><source src="#{src}.oga" type="audio/ogg" /><source src="#{src}.mp3" type="audio/mpeg" /></audio>}
      end
    end
  end
end
