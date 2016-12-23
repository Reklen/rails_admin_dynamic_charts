module RailsAdmin
  module Config
    module Actions
      class Index < RailsAdmin::Config::Actions::Base
        RailsAdmin::Config::Actions.register(self)

        register_instance_option :controller do
          proc do
            @objects ||= list_entries

            if (@filter_names1 = params[:filter_names1]).present? && (@filter_names2 = params[:filter_names2]).present? && (@oper_logic = params[:oper_logic]).present?
              @not_filter1 = false
              @not_filter2 = false
              if params[:not_filter_name1] == "1" && params[:not_filter_name2] == "1"
                @not_filter1 = true
                @not_filter2 = true
              elsif params[:not_filter_name1] == "1" && params[:not_filter_name2] != "1"
                @not_filter1 = true
                @not_filter2 = false
              elsif params[:not_filter_name1] != "1" && params[:not_filter_name2] == "1"
                @not_filter1 = false
                @not_filter2 = true
              end
            end

            #filter_names1 = params[:filter_names1]
            #filter_names2 = params[:filter_names2]
            #oper_logic = params[:oper_logic]
            #not_filter_names1 =

            #pass = false

            if (filter_name = params[:filter_name_to_save]).present? && (filters = params[:f]).present?

             # query = Filter.where(" name LIKE '#{filter_name}' ")
              #if query.present?
              #  query.each do |index|
               #   if index.present? && index.name == filter_name
              #      flash[:error] = "Name Filter Exist"
              #    end
              #  end

             # else
                filters = filters.to_hash
                json_filters = filters.to_json
                filter_save = Filter.new(name: filter_name, filter: json_filters, class_name: @abstract_model.model_name)
                if filter_save.save
                  flash[:success] = "Successful Save Filter"
                else
                  flash[:error] = filter_save.errors.full_messages
                end
              #end

            else
              if params[:advanced_filter] == "1"
                if (filter_name = params[:filter_name_to_save]).present? && (@filter_names1.present? && @filter_names2.present? && @oper_logic.present?)
                  #query = Filter.where(" name LIKE '#{filter_name}' ")
                  #if query.present?
                   # query.each do |index|
                   #   if index.present? && index.name == filter_name
                    #    flash[:error] = "Name Filter Exist"
                    #  end
                   # end

                 # else
                    klass = @abstract_model.model_name.constantize
                    new_filter = klass.created_advanced_filter(@filter_names1, @filter_names2, @oper_logic, @not_filter1, @not_filter2)
                    if new_filter[0] == false
                      flash[:error] = "#{new_filter[1]}"
                    else
                      json_filters = new_filter[1].to_json
                      filter_save = Filter.new(name: filter_name, filter: json_filters, class_name: @abstract_model.model_name)
                      if filter_save.save
                        flash[:success] = "Successful Save Filter"
                      else
                        flash[:error] = filter_save.errors.full_messages
                      end
                    end
                  end
                end
              end
            # end

            unless @model_config.list.scopes.empty?
              if params[:scope].blank?
                unless @model_config.list.scopes.first.nil?
                  @objects = @objects.send(@model_config.list.scopes.first)
                end
              elsif @model_config.list.scopes.collect(&:to_s).include?(params[:scope])
                @objects = @objects.send(params[:scope].to_sym)
              end
            end

            respond_to do |format|

              format.html do
                render @action.template_name, status: (flash[:error].present? ? :not_found : 200)
              end

              format.json do
                output = begin
                  if params[:compact]
                    primary_key_method = @association ? @association.associated_primary_key : @model_config.abstract_model.primary_key
                    label_method = @model_config.object_label_method
                    @objects.collect { |o| {id: o.send(primary_key_method).to_s, label: o.send(label_method).to_s} }
                  else
                    @objects.to_json(@schema)
                  end
                end
                if params[:send_data]
                  send_data output, filename: "#{params[:model_name]}_#{DateTime.now.strftime('%Y-%m-%d_%Hh%Mm%S')}.json"
                else
                  render json: output, root: false
                end
              end

              format.xml do
                output = @objects.to_xml(@schema)
                if params[:send_data]
                  send_data output, filename: "#{params[:model_name]}_#{DateTime.now.strftime('%Y-%m-%d_%Hh%Mm%S')}.xml"
                else
                  render xml: output
                end
              end

              format.csv do
                header, encoding, output = CSVConverter.new(@objects, @schema).to_csv(params[:csv_options])
                if params[:send_data]
                  send_data output,
                            type: "text/csv; charset=#{encoding}; #{'header=present' if header}",
                            disposition: "attachment; filename=#{params[:model_name]}_#{DateTime.now.strftime('%Y-%m-%d_%Hh%Mm%S')}.csv"
                else
                  render text: output
                end
              end

            end

          end
        end


      end
    end
  end
end
