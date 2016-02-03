module Pay2go
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('../templates', __FILE__)

      desc "Creates a Pay2go initialize"
      class_option :orm

      def copy_initializer
        template "pay2go.rb", "config/initializers/pay2go.rb"
      end

      def show_readme
        readme "README" if behavior == :invoke
      end

    end
  end
end
