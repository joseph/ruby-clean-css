require 'action_controller/railtie'
require 'ruby-clean-css/sprockets'

class RubyCleanCSS::Railtie < ::Rails::Railtie

  initializer(
    'ruby-clean-css.environment',
    :after => 'sprockets.environment'
  ) { |app|
    RubyCleanCSS::Sprockets.register(app.assets)
  }


  initializer(
    'ruby-clean-css.setup',
    :after => :setup_compression,
    :group => :all
  ) { |app|
    if app.config.assets.enabled
      curr = app.config.assets.css_compressor
      unless curr.respond_to?(:compress)
        app.config.assets.css_compressor = RubyCleanCSS::Sprockets::LABEL
      end
    end
  }

end
