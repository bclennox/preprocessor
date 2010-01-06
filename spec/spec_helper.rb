require 'spec'
  
$: << File.join(File.dirname(__FILE__), '../lib')

require 'miles_ahead/preprocessor'

# for video embedders
Spec::Matchers.define :recognize do |src|
  match do |embedder|
    embedder.recognizes?(src)
  end
  
  failure_message_for_should do |embedder|
    "#{embedder} should recognize #{src} and doesn't"
  end
  
  failure_message_for_should_not do |embedder|
    "#{embedder} should not recognize #{src} and does"
  end
  
  description do
    "whatever"
  end
end
