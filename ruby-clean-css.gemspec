# -*- encoding: utf-8 -*-
require File.expand_path('../lib/ruby-clean-css/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors = ['Joseph Pearson']
  gem.email = ['jpearson@overdrive.com']
  gem.description = 'A Ruby interface to the Clean-CSS minifier for Node.'
  gem.summary = 'Clean-CSS for Ruby.'
  gem.homepage = 'https://github.com/joseph/ruby-clean-css'
  gem.files = `git ls-files`.split($\)
  gem.executables = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files = gem.files.grep(%r{^test/})
  gem.name = 'ruby-clean-css'
  gem.require_paths = ['lib']
  gem.version = RubyCleanCSS::VERSION
  gem.add_dependency('therubyracer')
  gem.add_dependency('commonjs')
end
