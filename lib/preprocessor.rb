require 'preprocessor/utilities'
require 'preprocessor/image'
require 'preprocessor/audio'
require 'preprocessor/video'
require 'preprocessor/footnote'

module Preprocessor
  def self.included(base)
    base.class_eval do
      def preprocessed
        @preprocessed ||= BasicPreprocessor.new(self)
      end
    end
  end

  class BasicPreprocessor
    attr_accessor :delegate

    include ::Preprocessor::Utilities
    include ::Preprocessor::Image
    include ::Preprocessor::Audio
    include ::Preprocessor::Video
    include ::Preprocessor::Footnote

    TAG_REGEX = /(.)?\{\{(\S+?)(?:\s+(.*?))?\}\}/
    REPLACEMENT_REGEX = /\{-\{-(.*?)-\}-\}/

    def initialize(delegate)
      self.delegate = delegate
    end

    def method_missing(sym, *args)
      text = delegate.send(sym, *args)

      while text.match(TAG_REGEX)
        text.sub!(TAG_REGEX, replacement_for($2, $3, $1 || ''))
      end

      text.gsub!(REPLACEMENT_REGEX, '{{\1}}')
      text
    end

  private

    def replacement_for(message, options_string, antecedant)
      if escape?(antecedant)
        antecedant = ''
        replacement = replacement_placeholder(message, options_string)
      else
        replacement = if respond_to?(message)
          send(message, options_from_string(options_string))
        elsif delegate.respond_to?(message)
          delegate.send(message)
        else
          replacement_placeholder(message, options_string)
        end
      end

      antecedant + replacement
    end

    def replacement_placeholder(text, options)
      "{-{-#{[text, options].compact.join(' ')}-}-}"
    end

    def escape?(char)
      char == '\\'
    end

    def options_from_string(options_string)
      return {} if options_string.nil?

      # replace strings first
      re = /:(["'|])(.*?)(\1)/
      string_refs = []
      while options_string.match(re)
        options_string.sub!(re, ":ppstringref#{string_refs.length}")
        string_refs.push($2)
      end

      options_string.split(/\s+/).inject({}) do |memo, o|
        q = o.split(/:/, 2)
        memo[q.first.to_sym] = q.last.match(/ppstringref(\d+)/) ? string_refs[$1.to_i] : q.last
        memo
      end
    end
  end
end
