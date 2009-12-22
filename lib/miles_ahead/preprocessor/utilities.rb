module MilesAhead
  module Preprocessor
    module Utilities
      def absolutize(src, path)
        absolute?(src) ? src : "#{path}/#{src}"
      end
      
      def absolute?(src)
        src[0, 1] == '/'
      end
    end
  end
end