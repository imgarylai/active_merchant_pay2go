module Pay2go
  module Generators
    class Pay2goGenerator < Rails::Generators::NamedBase

      source_root File.expand_path('../templates', __FILE__)
      namespace :pay2go

      desc "Generates Pay2go initializer"

      def copy_initializer
        template "pay2go.rb", "config/initializers/pay2go.rb"
      end

    end
  end
end
