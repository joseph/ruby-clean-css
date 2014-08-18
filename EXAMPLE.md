#!/usr/bin/env ruby

#### If you wanted to create a Ruby script that took raw CSS from STDIN and
#### emitted the minified result to STDOUT, here's how you might do it. (Errors
#### and warnings are sent to STDERR.)

    require 'ruby-clean-css'

    begin
      compressor = RubyCleanCSS::Compressor.new
      compressor.compress(ARGV[0] || ARGF.read)
    rescue => e
      STDERR.puts("FAILED: #{e.inspect}")
      STDERR.puts(e.backtrace.join("\n") + "\n")
    ensure
      out = compressor.last_result
      STDERR.puts(out[:errors].join("\n"))  if out[:errors].any?
      STDERR.puts(out[:warnings].join("\n"))  if out[:warnings].any?
      STDOUT.puts(out[:min])
    end


#### This example itself is runnable. For example, try:
####
####     cat raw.css | ruby EXAMPLE.md > min.css
