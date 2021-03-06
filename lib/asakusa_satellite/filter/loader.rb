module AsakusaSatellite
  module Filter
    class Loader

      def self.load
        dirs = AsakusaSatellite::Filter::FilterConfig.plugins_dirs.map do |dir|
          File.join("plugins", dir)
        end
        load_dirs(dirs)
      end

      def self.load_all
        load_dirs(Dir.glob("#{Rails.root.to_s}/plugins/*"))
      end

      private
      def self.load_dirs(dirs)
        $: << "#{File.dirname(__FILE__)}/../../.."
        dirs.each do |dir|
          next unless File.directory?(dir)

          lib = File.join(dir, "lib")
          if File.directory?(lib)
            $:.unshift lib
            ActiveSupport::Dependencies.autoload_paths += [lib]
          end

          initrb = File.join(dir, "init.rb")
          require initrb if File.file?(initrb)

          locales = Dir.glob(File.join(dir, 'config', 'locales', '*.yml'))
          ::I18n.load_path += locales

          views = File.join(dir, "app", "views")
          ActionController::Base.prepend_view_path(views) if File.directory?(views)

          %w(models controllers helpers).each do |dirname|
            subdir = File.join(dir, "app", dirname)
            ActiveSupport::Dependencies.autoload_paths += [subdir] if File.directory?(subdir)
          end

          initializers = Dir.glob(File.join(dir, 'config', 'initializers', '*.rb'))
          initializers.each do |initializer|
            require initializer
          end

        end
      end
    end
  end
end
