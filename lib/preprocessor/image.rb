module Preprocessor
  module Image
    class << self
      attr_accessor :options
    end

    @options = { :default_path => '/images' }

    def image(options)
      attrs = {
        :src => absolutize(options[:src], ::Preprocessor::Image.options[:default_path]),
        :alt => options[:alt] || "",
        :title => options[:title] == "alt" ? options[:alt] : options[:title]
      }

      caption_text = case options[:caption]
      when "alt"
        attrs[:alt]
      when "title"
        attrs[:title]
      else
        options[:caption]
      end

      caption = %{<span class="caption">#{caption_text}</span>}
      attr_str = attrs.map { |k, v| %{#{k}="#{v}"} }.join(' ')

      %{<p class="image"><img #{attr_str} />#{caption}</p>}
    end
  end
end
