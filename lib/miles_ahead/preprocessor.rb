require 'miles_ahead/preprocessor/utilities'
require 'miles_ahead/preprocessor/audio'
require 'miles_ahead/preprocessor/footnote'
require 'miles_ahead/preprocessor/image'

module MilesAhead
  module Preprocessor
    def self.included(base)
      base.class_eval do
        def preprocessed
          @preprocessed ||= BasicPreprocessor.new(self)
        end
      end
    end
  end
  
  class BasicPreprocessor
    attr_accessor :delegate
    
    include MilesAhead::Preprocessor::Utilities
    include MilesAhead::Preprocessor::Audio
    include MilesAhead::Preprocessor::Footnote
    include MilesAhead::Preprocessor::Image
    
    TAG_REGEX = /\{\{(\S+?)(?:\s+(.*?))?\}\}/
    REPLACEMENT_REGEX = /\{-\{-(.*?)-\}-\}/

    def initialize(delegate)
      self.delegate = delegate
    end

    def method_missing(sym, *args)
      text = delegate.send(sym, *args)
      
      while text.match(TAG_REGEX)
        text.sub!(TAG_REGEX, replacement_for($1, $2))
      end
      
      text.gsub!(REPLACEMENT_REGEX, '{{\1}}')
      text
    end

    private

      def replacement_for(message, options_string)
        if delegate.respond_to?(message)
          delegate.send(message)
        elsif respond_to?(message)
          send(message, options_from_string(options_string))
        else
          "{-{-#{message}-}-}"
        end
      end
      
      def options_from_string(options_string)
        return {} if options_string.nil?
        
        # replace strings first
        re = /:(["'|])(.*?)(\1)/
        string_refs = []
        while options_string.match(re)
          options_string.sub!(re, ":ppstringref#{string_refs.count}")
          string_refs.push($2)
        end
        
        options_string.split(/\s+/).inject({}) do |memo, o|
          q = o.split(/:/)
          memo[q.first.to_sym] = q.last.match(/ppstringref(\d+)/) ? string_refs[$1.to_i] : q.last
          memo
        end
      end
  end
end
