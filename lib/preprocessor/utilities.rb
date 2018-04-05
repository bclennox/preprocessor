module Preprocessor
  module Utilities
    def absolutize(src, path)
      absolute?(src) ? src : "#{path}/#{src}"
    end

    def absolute?(src)
      src =~ /^\/|https?:\/\//
    end
  end
end
