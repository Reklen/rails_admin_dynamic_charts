module RailsAdmin
  module Config
    module Actions
      class LaunchFilter < RailsAdmin::Config::Actions::Base

        register_instance_option :member do
          true
        end

        register_instance_option :http_methods do
          [:post, :get]
        end

        register_instance_option :controller do
          proc do
            puts @object.class_name
            redirect_to rails_admin.index_path(@object.class_name.underscore.gsub('/', '~'), filter: JSON.parse(@object.filter), name: @object.name)

          end
        end

        register_instance_option :link_icon do
          'icon-filter'
        end

      end
    end
  end
end