module RubyCleanCSS::Sprockets

  LABEL = :cleancss

  def self.register(sprockets)
    klass = RubyCleanCSS::Compressor
    if sprockets.respond_to?(:register_compressor)
      sprockets.register_compressor('text/css', LABEL, klass.new)
      sprockets.css_compressor = LABEL
    else
      Sprockets::Compressors.register_css_compressor(
        LABEL,
        klass.to_s,
        :default => true
      )
    end
  end

end
