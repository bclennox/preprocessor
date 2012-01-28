require File.dirname(__FILE__) + '/spec_helper'

class PreprocessorTester
  def initialize(options = {})
    options.each do |message, value|
      self.class.class_eval { attr_accessor message }
      send("#{message}=", value)
    end
  end

  include ::Preprocessor
end

describe Preprocessor do
  it 'should ignore escaped curlies' do
    tester = PreprocessorTester.new(:name => 'Munge', :title => 'Remember my \{{name with:"a mnemonic"}}')
    tester.preprocessed.title.should == 'Remember my {{name with:"a mnemonic"}}'
  end

  it 'should substitute method return values if the delegate responds_to?' do
    tester = PreprocessorTester.new(:name => 'Fooject', :title => 'This is the {{name}}')
    tester.preprocessed.title.should == 'This is the Fooject'
  end

  it 'should prioritize sub-module methods over delegate methods' do
    tester = PreprocessorTester.new(:image => 'paperclip', :text => 'Look! My new Zune: {{image src:shit-brown.png}}')
    tester.preprocessed.text.should_not =~ /paperclip/
  end

  it 'should return the unchanged string if neither it nor the delegate responds_to?' do
    tester = PreprocessorTester.new(:text => "I don't understand {{anything}}")
    tester.preprocessed.text.should == "I don't understand {{anything}}"
  end

  describe "parsing option strings" do
    before(:each) do
      @tester = PreprocessorTester.new
    end

    def options_from_string(string)
      @tester.preprocessed.send(:options_from_string, string)
    end

    it 'should parse unquoted option values' do
      options_from_string('arg:simple').should == { :arg => 'simple' }
    end

    it 'should parse single-quoted option values' do
      options_from_string(%{arg:'Not so much "fat" as "dumb".'}).should == { :arg => 'Not so much "fat" as "dumb".' }
    end

    it 'should parse double-quoted option values' do
      options_from_string(%{arg:"D'oh!"}).should == { :arg => "D'oh!" }
    end

    it 'should parse piped option values' do
      options_from_string(%{arg:|And I said, "Frankly, my dear, I don't give a damn!"|}).should == { :arg => %{And I said, "Frankly, my dear, I don't give a damn!"} }
    end

    it 'should parse option values with special characters' do
      options_from_string(%{arg:http://www.example.com/}).should == { :arg => 'http://www.example.com/' }
    end
  end

  describe "utilities" do
    class UtilitiesTester
      include ::Preprocessor::Utilities
    end

    it 'should ignore absolute paths' do
      UtilitiesTester.new.absolutize('/my/stuff/me.png', '/where/ever').should == '/my/stuff/me.png'
    end

    it 'should not prepend the default path to URLs' do
      UtilitiesTester.new.absolutize('http://example.com/illicit.png', '/lalala').should == 'http://example.com/illicit.png'
    end
  end

  describe "#image" do
    it 'should have src, alt, title attributes and a caption' do
      tester = PreprocessorTester.new(:text => 'This chick is mad hot: {{image src:chick.png alt:"Chicken in the oven" title:"No title necessary" caption:"Look how hot yah"}}')
      tester.preprocessed.text.should =~ /src="\/images\/chick.png"/
      tester.preprocessed.text.should =~ /alt="Chicken in the oven"/
      tester.preprocessed.text.should =~ /title="No title necessary"/
      tester.preprocessed.text.should =~ /Look how hot yah/
    end

    it 'should allow shortcutting title and caption' do
      tester = PreprocessorTester.new(:text => 'Lazy {{image src:foo.png alt:"Required" title:alt caption:title}}')
      tester.preprocessed.text.should =~ /title="Required"/
      tester.preprocessed.text.should =~ /<span class="caption">Required<\/span>/
    end

    it 'should set the default path' do
      ::Preprocessor::Image.options[:default_path] = '/system/assets'
      tester = PreprocessorTester.new(:text => 'Hope it works: {{image src:boo.png alt:"Whatevs"}}')
      tester.preprocessed.text.should =~ /src="\/system\/assets\/boo.png"/
    end
  end

  describe "#audio" do
    before(:each) do
      @tester = PreprocessorTester.new(:text => 'Peep this sweet cut: {{audio src:piano-rock}}')
    end

    it 'should contain a source for the MP3 file' do
      @tester.preprocessed.text.should =~ /piano-rock.mp3/
    end

    it 'should contain a source for the Ogg file' do
      @tester.preprocessed.text.should =~ /piano-rock.oga/
    end

    it 'should set the default path' do
      ::Preprocessor::Audio.options[:default_path] = '/somewhere/else'
      @tester.preprocessed.text.should =~ /\/somewhere\/else\/piano-rock/
    end

    it 'should not prepend the default path to absolute paths' do
      tester = PreprocessorTester.new(:text => 'Baddies: {{audio src:/i/love/bob}}')
      tester.preprocessed.text.should =~ /\/i\/love\/bob/
    end
  end

  describe "#video" do
    describe 'YouTube videos' do
      it 'should recognize a "watch" URL with a query string' do
        ::Preprocessor::Video::YouTube.should recognize('http://www.youtube.com/watch?v=jHyC0ggI3Ow&feature=player_embedded')
      end

      it 'should recognize a "/v/" URL with a query string' do
        ::Preprocessor::Video::YouTube.should recognize('http://www.youtube.com/v/jHyC0ggI3Ow&hl=en_US&fs=1&rel=0')
      end

      it 'should include the object and embed shit' do
        tester = PreprocessorTester.new(:text => 'LOLOL {{video src:"http://www.youtube.com/watch?v=jHyC0ggI3Ow"}}')
        tester.preprocessed.text.should =~ /param name="movie" value="http:\/\/www.youtube.com\/v\/jHyC0ggI3Ow"/
        tester.preprocessed.text.should =~ /embed src="http:\/\/www.youtube.com\/v\/jHyC0ggI3Ow"/
      end
    end

    describe "HTML 5 videos" do
      it 'should include the MP4 source' do
        tester = PreprocessorTester.new(:text => '{{video src:/videos/dancedancedance}}')
        tester.preprocessed.text.should =~ /dancedancedance.mp4/
      end

      it 'should include the Ogg source' do
        tester = PreprocessorTester.new(:text => '{{video src:/videos/ooouuuuttttt}}')
        tester.preprocessed.text.should =~ /ooouuuuttttt.ogv/
      end

      it 'should include an optional poster' do
        tester = PreprocessorTester.new(:text => '{{video src:/videos/help poster:/images/posse.png}}')
        tester.preprocessed.text.should =~ /poster="\/images\/posse.png"/
      end
    end
  end

  describe "#footnote" do
    before(:each) do
      @tester = PreprocessorTester.new(:text => 'Surprised kitten is surprised.{{footnote ref:1 text:"Not for resale."}} Some more content{{footnote ref:2 text:"Is there more?"}} haha. Content sucks. {{footnotes}}', :slug => 'slug-boat')
    end

    it 'should contain reference links' do
      [1, 2].each do |i|
        @tester.preprocessed.text.should =~ /<a href="#fn-slug-boat-#{i}".*id="ref-slug-boat-#{i}".*?>#{i}/
      end
    end

    it 'should contain the footnotes in a Textile list' do
      @tester.preprocessed.text.should =~ /#\(#fn-slug-boat-1\)\s+Not for resale./
      @tester.preprocessed.text.should =~ /#\(#fn-slug-boat-2\)\s+Is there more?/
    end

    it 'should not explode if {{footnotes}} is called without any footnotes' do
      tester = PreprocessorTester.new(:text => 'There are no {{footnotes}}.')
      tester.preprocessed.text.should == 'There are no .'
    end
  end
end
