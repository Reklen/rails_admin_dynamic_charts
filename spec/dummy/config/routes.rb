Rails.application.routes.draw do

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  mount RailsAdminDynamicCharts::Engine => "/rails_admin_dynamic_charts"
end
