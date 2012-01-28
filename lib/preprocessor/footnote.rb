module Preprocessor
  module Footnote
    def self.included(base)
      base.class_eval do
        attr_accessor :footnote_refs
      end
    end

    def footnote(options)
      ref = options[:ref]
      add_footnote(ref, options[:text])

      id = "#{guid}-#{options[:ref]}"
      %{<a href="#fn-#{id}" class="footnote" id="ref-#{id}">#{ref}</a>}
    end

    def footnotes(options)
      footnote_refs.nil? ? "" : footnote_refs.map { |fn| footnote_content(fn) }.join
    end

  private

    def guid
      delegate.slug
    end

    def add_footnote(ref, text)
      @footnote_refs ||= {}
      @footnote_refs[ref] = text
    end

    def footnote_content(fn)
      id = "#{guid}-#{fn[0]}"
      %:#(#fn-#{id}) #{fn[1]} <a href="#ref-#{id}" class="returner" title="Return to where you left off">&#8617;</a>\n:
    end
  end
end
