module RailsAdminDynamicCharts
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    def install
      run("rails generate model Filter name:string filter:string class_name:string")
      run("rake db:migrate")
      copy_file "filter.rb", "app/models/filter.rb"

    end

  end
end