# Ruby-Clean-CSS compressor

This gem provides a Ruby interface to the
[Clean-CSS](https://github.com/GoalSmashers/clean-css) Node library for
minifying CSS files.

Ruby-Clean-CSS provides much more modern and compatible minification of
stylesheets than the old [YUI
compressor](https://github.com/sstephenson/ruby-yui-compressor) (which was 
[discontinued](http://www.yuiblog.com/blog/2012/10/16/state-of-yui-compressor)
by Yahoo in 2012).


## Usage

You can use this library with Rails, or with Sprockets in non-Rails projects,
or simply as a standalone library.


### As a plain Ruby library:

Here's the simplest thing that could possibly work:

    >> require 'ruby-clean-css'
    >> RubyCleanCSS::Compressor.new.compress('a { color: chartreuse; }')
    => "a{color:#7fff00}"


### With Sprockets:

You can register the Compressor as Sprocket's default CSS compressor like this:

    require 'ruby-clean-css'
    require 'ruby-clean-css/sprockets' 
    RubyCleanCSS::Sprockets.register(sprockets_env)


### With Rails 3 or Rails 4:

Just add this gem to the `:assets` group of your `Gemfile`. Ruby-Clean-CSS
will automatically become the default compressor for CSS files.

If you prefer, you can make it explicit in `config/environments/production.rb`:

    config.assets.css_compressor = :cleancss

Alternatively, if you want to customize the compressor with options, 
you can assign an instance of the compressor to that setting:

    config.assets.css_compressor = RubyCleanCSS::Compressor.new(
      rebase_urls: false,
      keep_breaks: true
    )


## Options

This library supports the following [Clean-CSS
options](https://github.com/GoalSmashers/clean-css#how-to-use-clean-css-programmatically):

- `keep_special_comments` - A "special comment" is one that begins with `/*!`.
    You can keep them all with `:all`, just the first with `:first`, or
    remove them all with `:none`. The default is `:all`.
- `keep_breaks` - By default, all linebreaks are stripped. Set to `true` to 
    retain them.
- `root` - This is the path used to resolve absolute `@import` rules and rebase
    relative URLS. A string. Defaults to the present working directory.
- `relative_to` - This path is used to resovle relative `@import` rules and
    URLs. A string. No default.
- `rebase_urls` - By default, all URLs are rebased to the root. Set to `false` 
    to prevent rebasing.
- `advanced` - By default, Clean-CSS applies some advanced optimizations,
    like selector and property merging, reduction, etc). Set to `false` to
    prevent these optimizations. 
- `rounding_precision` - The rounding precision on measurements in your CSS.
    An integer, defaulting to `2`.
- `compatibility` - Use this to force Clean-CSS to be compatible with `ie7`
    or `ie8`. Default is neither. Supply as a symbol (`:ie7`) or 
    string (`'ie7'`).

The following options are not yet supported by this library:

- `process_import`
- `benchmark`
- `debug`

In keeping with the Node library's interface, there are some synonyms available:

- `:no_rebase => true` is the same as `:rebase_urls => false`.
- `:no_advanced => true` is the same as `:advanced => false`.
- `:keep_special_comments` has an alternative syntax: `'*'` means  `:all`, 
    `1` means `:first` and `0` means `:none`.


## License

Ruby-Clean-CSS is released under the [MIT
Licence](https://github.com/joseph/ruby-clean-css/blob/master/LICENSE).
