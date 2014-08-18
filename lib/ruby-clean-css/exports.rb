# Attribution: much of this stubby code is drawn from
# https://github.com/cowboyd/less.rb/blob/master/lib/less/loader.rb
#
# Thanks!
#


require 'pathname'
require 'net/http'
require 'uri'

module RubyCleanCSS::Exports

  class Process # :nodoc:
    def nextTick
      lambda { |global, fn|
        fn.call
      }
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
      puts msgs.join(', ')
    end

    def warn(*msgs)
      $stderr.puts msgs.join(', ')
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

    def self.basename(path)
      File.basename(path)
    end

    def self.extname(path)
      File.extname(path)
    end

    def self.resolve(path)
      File.basename(path)
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
      File.stat(path)
    end

    def self.readFile(path, encoding, callback)
      callback.call(nil, File.read(path))
    end

    def self.readFileSync(path, encoding = nil)
      buf = Buffer.new(File.read(path),  encoding)
      encoding.nil? ? buf : buf.toString(encoding)
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
      result['protocol'] = u.scheme  + ':' if u.scheme
      result['hostname'] = u.host if u.host
      result['pathname'] = u.path if u.path
      result['port']     = u.port if u.port
      result['query']    = u.query if u.query
      result['search']   = '?' + u.query if u.query
      result['hash']     = '#' + u.fragment if u.fragment
      result
    end

  end


  module Http # :nodoc:
    # TODO! Implement #get
  end


  module Https # :nodoc:
    # TODO! Implement #get
  end

end
