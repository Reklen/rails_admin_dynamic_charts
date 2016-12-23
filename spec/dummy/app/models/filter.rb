class Filter < ActiveRecord::Base
  before_save do
    unless new_record?
      old_name = Filter.find(id).name
      RailsAdmin::Config.navigation_static_links.delete(old_name)
    end
  end

  after_save :add_link

  def add_link
    RailsAdmin::Config.navigation_static_links[name] = "filter/#{id}/launch_filter"
  end

  RailsAdmin::config.navigation_static_label = "Filters Links"

  Filter.all.each { |filter| filter.add_link }


  rails_admin do
    edit do
      field :name
    end
    show do
      field :name
      #field :filter do
      # pretty_value do
      #   json = JSON.pretty_generate(JSON.parse(value))
      #  "<pre>#{json}</pre>".html_safe
      field :class_name
    end
  end
  validates :name, presence: true,
            uniqueness: true
  validates :filter, presence: true,
            uniqueness: true
  validates :class_name, presence: true
end

