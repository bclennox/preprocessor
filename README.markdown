Text Preprocessor
=================

Ruby module that I use on a couple of blogs as a shortcut to reference images, audio, footnotes, etc. It's very specific to my needs, but you might find something useful in it.

Basic Usage
-----------

By including the Preprocessor module, your class will have a `preprocessed` method that returns an object capable of filtering the return values of instance methods of that class:

    class Article
      attr_accessor :title, :body
      include MilesAhead::Preprocessor
    end
    
    a = Article.new
    a.body = 'Have some {{audio src:/files/audio/fun}}'
    
    a.body              #=> 'Have some {{audio src:/files/audio/fun}}'
    a.preprocessed.body #=> 'Have some <audio controls><source ... /></audio>'

Tags
----

Substitutable tags are surrounded by double curly braces: `{{tag}}`. Options to the tag vary and are given as space-separated name-value pairs, where the name and value are separated by a colon:

    {{image src:photo.png alt:"Me at the Brandenburg Gate"}}
    {{footnotes}}

Option values may be unquoted, single-quoted, double-quoted, or pipe-quoted. Quotes are needed if the option value contains whitespace. Other quote styles may be useful if the option value contains e.g. a double quote:

    {{footnote ref:1 text:|So I said, "Don't shoot the messenger HAHAHLOLOL"|}}

### Footnotes

I like to use footnotes, but they're a pain in the ass to manage. Simple footnotes were my main motivation in creating this module.

    {{footnote ref:1 text:"Disclaimer: Although I made this statement, it may not be true."}}
    {{footnote ref:2 text:"Full disclosure: I own stock in buntaluffigus skins."}}
    {{footnotes}}

Create footnote references using the `{{footnote}}` tag. Create the list of footnotes at the end of your document via the `{{footnotes}}` tag (it's an HTML ordered list).

See [one of my articles with footnotes](http://bclennox.com/moving-to-html-5) if you're interested in the markup.

### Images

Creates an HTML paragraph and image and optional caption:

    {{image src:jade-plant.png alt:"My beautiful jade plant" title:alt caption:title}}

becomes:

    <p class="image"><img ... /><span class="caption">...</span></p>

Options:

* `src`: the URL of the image. If it's not an absolute path/URL, prepends a default path, which you can change by setting `MilesAhead::Preprocessor::Image.options[:default_path]`.
* `alt`: alt attribute of the `<img>`
* `title`: title attribute of the `<img>`. If the value of the `title` option is `"alt"`, it will use the value of the `alt` option.
* `caption`: a `<span class="caption">` will be added after the image. Also accepts the values `"alt"` and `"title"` to use those values.

### Audio

Creates an HTML 5 `<audio>` element with Ogg and MP3 sources:

    {{audio src:funky-jam}}

becomes:

    <audio controls><source src="/audio/funky-jam.oga" type="audio/ogg" /><source src="/audio/funky-jam.mp3" type="audio/mpeg" /></audio>

You can set the default path for non-absolute paths via `MilesAhead::Preprocessor::Audio.options[:default_path]`.

### Video

Creates an HTML 5 `<video>` element with Ogg and MP4 sources:
    
    {{video src:kitty-in-the-window poster:/images/kitty-in-the-window.png}}

becomes:

    <video controls poster="/images/kitty-in-the-window.png"><source src="/video/kitty-in-the-window.ogv" type="video/ogg" /><source src="/video/kitty-in-the-window.mp4" type="video/mp4" /></video>

You can set the default path for non-absolute paths via `MilesAhead::Preprocessor::Video.options[:default_path]`.

Also handles embedding YouTube videos via a URL:

    {{video src:"http://www.youtube.com/watch?v=jHyC0ggI3Ow"}}

Todo
====

* Audio and video elements need Flash fallbacks.
* Audio and video elements should probably have options for `autobuffer` and `controls`.
* Video could support other sites like Vimeo, etc.
