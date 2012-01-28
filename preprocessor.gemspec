# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "preprocessor/version"

Gem::Specification.new do |s|
  s.name        = "preprocessor"
  s.version     = Preprocessor::VERSION
  s.authors     = ["Brandan Lennox"]
  s.email       = ["brandan@bclennox.com"]
  s.homepage    = "https://github.com/bclennox/preprocessor"
  s.date        = "2012-01-28"
  s.summary     = %q{Ruby text munger}
  s.description = %q{Ruby module that I use on a couple of blogs as a shortcut to reference images, audio, footnotes, etc. It's very specific to my needs, but you might find something useful in it.}

  s.rubyforge_project = "preprocessor"

  s.files = %w{
    preprocessor.gemspec
    Gemfile
    MIT-LICENSE
    README.markdown

    lib/preprocessor.rb
    lib/preprocessor/audio.rb
    lib/preprocessor/footnote.rb
    lib/preprocessor/image.rb
    lib/preprocessor/utilities.rb
    lib/preprocessor/video.rb
  }

  s.test_files = %w{
    spec/preprocessor_spec.rb
    spec/spec_helper.rb
  }

  s.require_paths = ["lib"]

  s.add_development_dependency "rspec"
end
