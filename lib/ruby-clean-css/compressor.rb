class RubyCleanCSS::Compressor

  LIB_PATH = File.expand_path(File.dirname(__FILE__)+'/../javascript')

  attr_reader(:last_result)


  def initialize(options = {})
    @js_options = js_options_from_hash(options)
  end


  def compress(stream_or_string)
    begin
      out = minifier.minify(stream_or_string.to_s)
    rescue => e
      raise(e)
    ensure
      @last_result = {
        :min => out,
        :errors => minifier.context.errors,
        :warnings => minifier.context.warnings
      }
    end
    out
  end


  def minifier
    @minifier ||= minifier_class.call(@js_options)
  end


  protected

    def js_runtime
      if @js_runtime
        @js_runtime
      else
        @js_runtime = V8::Context.new
        @js_runtime['process'] = RubyCleanCSS::Exports::Process.new
        @js_runtime['console'] = RubyCleanCSS::Exports::Console.new
        @js_runtime['Buffer'] = RubyCleanCSS::Exports::Buffer.new
        @js_runtime
      end
    end


    def js_env
      if @js_env
        @js_env
      else
        @js_env = CommonJS::Environment.new(js_runtime, :path => LIB_PATH)
        @js_env.native('path', RubyCleanCSS::Exports::Path)
        @js_env.native('util', RubyCleanCSS::Exports::Util)
        @js_env.native('fs', RubyCleanCSS::Exports::FS)
        @js_env.native('url', RubyCleanCSS::Exports::Url)
        @js_env.native('http', RubyCleanCSS::Exports::Http)
        @js_env.native('https', RubyCleanCSS::Exports::Https)
        @js_env
      end
    end


    def minifier_class
      @minifier_class ||= js_env.require('clean-css/index')
    end


    # See README.md for a description of each option, and see
    # https://github.com/GoalSmashers/clean-css#how-to-use-clean-css-programmatically
    # for the JS translation.
    #
    def js_options_from_hash(options)
      js_opts = {}

      if options.has_key?(:keep_special_comments)
        js_opts['keepSpecialComments'] = {
          'all' => '*',
          'first' => 1,
          'none' => 0,
          '*' => '*',
          '1' => 1,
          '0' => 0
        }[options[:keep_special_comments].to_s]
      end

      if options.has_key?(:keep_breaks)
        js_opts['keepBreaks'] = options[:keep_breaks] ? true : false
      end

      if options.has_key?(:root)
        js_opts['root'] = options[:root].to_s
      end

      if options.has_key?(:relative_to)
        js_opts['relativeTo'] = options[:relative_to].to_s
      end

      if options.has_key?(:no_rebase)
        js_opts['noRebase'] = options[:no_rebase] ? true : false
      elsif !options[:rebase_urls].nil?
        js_opts['noRebase'] = options[:rebase_urls] ? false : true
      end

      if options.has_key?(:no_advanced)
        js_opts['noAdvanced'] = options[:no_advanced] ? true : false
      elsif !options[:advanced].nil?
        js_opts['noAdvanced'] = options[:advanced] ? false : true
      end

      if options.has_key?(:rounding_precision)
        js_opts['roundingPrecision'] = options[:rounding_precision].to_i
      end

      if options.has_key?(:compatibility)
        js_opts['compatibility'] = options[:compatibility].to_s
        unless ['ie7', 'ie8'].include?(js_opts['compatibility'])
          raise(
            'Ruby-Clean-CSS: unknown compatibility setting: '+
            js_opts['compatibility']
          )
        end
      end

      if options.has_key?(:process_import)
        raise('Ruby-Clean-CSS: processImport option is not yet supported')
      end

      if options.has_key?(:benchmark)
        raise('Ruby-Clean-CSS: benchmark option is not yet supported')
      end

      if options.has_key?(:debug)
        raise('Ruby-Clean-CSS: debug option is not yet supported')
      end

      js_opts
    end

end
