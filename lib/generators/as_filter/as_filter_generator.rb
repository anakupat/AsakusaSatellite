class AsFilterGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)

  def create_as_filter_file
    template 'init.rb', 
             "vendor/plugins/as_#{file_name.underscore}_filter/init.rb"
    template 'as_filter.rb',
             "vendor/plugins/as_#{file_name.underscore}_filter/lib/#{file_name.underscore}_filter.rb"
    template 'spec.rb',
             "vendor/plugins/as_#{file_name.underscore}_filter/spec/lib/#{file_name.underscore}_filter.rb"
  end
end
