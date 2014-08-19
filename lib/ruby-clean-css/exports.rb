# Attribution: much of this stubbly code is drawn from
# https://github.com/cowboyd/less.rb/blob/master/lib/less/loader.rb
#
# Thanks!
#


require 'net/http'
require 'pathname'
require 'uri'

module RubyCleanCSS::Exports

  class Process # :nodoc:

    def nextTick
      lambda { |global, fn| fn.call }
    end


    def cwd
      lambda { Dir.pwd }
    end


    def exit(*args)
      warn("JS process.exit(#{args.first}) called from: \n#{caller.join("\n")}")
    end

  end



  class Console # :nodoc:

    def log(*msgs)
      STDOUT.puts(msgs.join(', '))
    end


    def warn(*msgs)
      STDERR.puts(msgs.join(', '))
    end

  end



  module Path # :nodoc:

    def self.join(*components)
      # node.js expands path on join
      File.expand_path(File.join(*components))
    end


    def self.dirname(path)
      File.dirname(path)
    end


    def self.resolve(path)
      File.expand_path(path)
    end


    def self.relative(base, path)
      Pathname.new(path).relative_path_from(Pathname.new(base)).to_s
    end

  end



  module Util # :nodoc:

    def self.error(*errors)
      raise errors.join(' ')
    end


    def self.puts(*args)
      args.each { |arg| STDOUT.puts(arg) }
    end

  end



  module FS # :nodoc:

    def self.statSync(path)
      out = File.stat(path)
      if out.respond_to?(:define_singleton_method)
        out.define_singleton_method(:isFile) { lambda { File.file?(path) } }
      else
        out.instance_variable_set(:@isFile, File.file?(path))
        def out.isFile; lambda { @isFile }; end
      end
      out
    end


    def self.existsSync(path)
      File.exists?(path)
    end


    def self.readFile(path, encoding, callback)
      callback.call(nil, File.read(path))
    end


    def self.readFileSync(path, encoding = nil)
      IO.read(path)
    end

  end



  class Buffer # :nodoc:

    def isBuffer(data)
      false
    end

  end



  module Url # :nodoc:

    def self.resolve(*args)
      URI.join(*args)
    end


    def self.parse(url_string)
      u = URI.parse(url_string)
      result = {}
      result['protocol'] = u.scheme+':'  if u.scheme
      result['hostname'] = u.host  if u.host
      result['pathname'] = u.path  if u.path
      result['port'] = u.port  if u.port
      result['query'] = u.query  if u.query
      result['search'] = '?'+u.query  if u.query
      result['hash'] = '#'+u.fragment  if u.fragment
      result
    end

  end



  class Http # :nodoc:

    attr_reader :get

    def initialize
      @get = lambda { |global, options, callback|
        err = nil
        uri_hash = {}
        uri_hash[:host] = options['hostname'] || options['host']
        path = options['path'] || options['pathname'] || ''
        # We do this because node expects path and query to be combined:
        path_components = path.split('?', 2)
        if path_components.length > 1
          uri_hash[:path] = path_components[0]
          uri_hash[:query] = path_components[0]
        else
          uri_hash[:path] = path_components[0]
        end
        uri_hash[:port] = options['port'] ? options['port'] : Net::HTTP.http_default_port
        # We check this way because of node's http.get:
        uri_hash[:scheme] = uri_hash[:port] == Net::HTTP.https_default_port ? 'https' : 'http'
        case uri_hash[:scheme]
        when 'http'
          uri = URI::HTTP.build(uri_hash)
        when 'https'
          uri = URI::HTTPS.build(uri_hash)
        else
          raise(Exception, 'import only supports http and https')
        end
        http = Net::HTTP.new(uri.host, uri.port)
        if uri.scheme == 'https'
          # Hurrah for insecurity
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
          http.use_ssl = true
        end
        response = nil
        http.start { |req| response = req.get(uri.to_s) }
        begin
          callback.call(
            ServerResponse.new(response.read_body, response.code.to_i)
          )
        rescue => e
          err = e
        end
        HttpGetResult.new(err);
      }
    end



    class HttpGetResult

      attr_accessor :err


      def initialize(err)
        @err = err
      end


      def on(event, callback)
        if event == 'error' && @err
          callback.call(@err)
        end
        self
      end


      def setTimeout(timer, callback)
        # TODO?
      end

    end



    class ServerResponse

      attr_accessor :statusCode
      attr_accessor :data # faked because ServerResponse actually implements WriteableStream


      def initialize(data, status_code)
        @data = data
        @statusCode = status_code
      end


      def on(event, callback)
        case event
        when 'data'
          callback.call(@data)
        else
          callback.call()
        end
        self
      end

    end

  end

end
