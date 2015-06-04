#require 'lazy_high_charts/engine'
require 'rails_admin_dynamic_charts/engine'

module RailsAdminDynamicCharts
  module Datetime
    def self.included(base)
       base.extend(ClassMethods)
    end

    module ClassMethods

      def data_by(set, base_cal, date_field, calculation, acumulate = nil, type)
        #if date_field == :created_at || date_field == :updated_at
        #  set = set.group_by { |o| acumulate.present? ? o.send(date_field).send(acumulate) : o.send(date_field) }
         # met = attribute_method?(base_cal) ? "(&:#{base_cal})" : "send(#{base_cal})"
        #  proc = eval "lambda { |collection| collection.map#{met}.#{calculation} }"
        #  set = acumulate =~ /^beginning_of/ ? set.map {|k,v| [k,proc.call(v)]} : set.sort.map {|c| [ send(acumulate)[c[0]], proc.call(c[1]) ]}
        #  [{:data => set}]
        #else
        if type == :date || type == :datetime
          set = set.group_by { |o| acumulate.present? ? o.send(date_field).send(acumulate) : o.send(date_field) }
        else
          set = set.group_by { |o| o.send(date_field)}
        end
        set.map { |k,v| [k,v.map { |array| array[base_cal]}.send(calculation)]}
      end
    
      def wday
       Date::DAYNAMES
      end

      def hour
        %w(12am 1am 2am 3am 4am 5am 6am 7am 8am 9am 10am 11am 12m 1pm 2pm 3pm 4pm 5pm 6pm 7pm 8pm 9pm 10pm 11pm)      
      end

      def parse_date(date)
        new_fecha = ""
        new_fecha[0] = date[3]
        new_fecha[1] = date[4]
        new_fecha[2] = "-"
        new_fecha[3] = date[0]
        new_fecha[4] = date[1]
        new_fecha[5] = "-"
        new_fecha[6] = date[6]
        new_fecha[7] = date[7]
        new_fecha[8] = date[8]
        new_fecha[9] = date[9]
        return new_fecha
      end

      def created_advanced_filter(a, b, c, not_a, not_b)

        new_filter = {}

        x = Filter.where(" #{"name"} LIKE '#{a}'")
        y = Filter.where(" #{"name"} LIKE '#{b}'")

        x1 = nil
        y1 = nil

        x.each { |x| x1 = JSON.parse(x.filter) }
        y.each { |y| y1 = JSON.parse(y.filter) }
        #- #puts x.name
        #- #puts x.filter

        if not_a == true
          new_filter["not_0"] = x1.to_hash
        else
          new_filter["0"] = x1.to_hash
        end

        if not_b == true
          new_filter["not_2"] = y1.to_hash
        else
          new_filter["2"] = y1.to_hash
        end

        #new_filter["0"] = x1.to_hash
        #new_filter["2"] = y1.to_hash
        new_filter["1"] = c

        return new_filter

      end

      def advanced_query(query, model)
        if !query.keys.include?("1")
          #for index in query.values do
            return "(#{parse_query_f(query, model)})"
          #end
        else
          if query.keys.include?("not_0") && query.keys.include?("not_2")
            return "(NOT #{advanced_query(query["not_0"], model)} #{query["1"]} NOT #{advanced_query(query["not_2"], model)})"
          elsif query.keys.include?("not_0") && query.keys.include?("2")
            return "(NOT #{advanced_query(query["not_0"], model)} #{query["1"]} #{advanced_query(query["2"], model)})"
          elsif query.keys.include?("0") && query.keys.include?("not_2")
            return "( #{advanced_query(query["0"], model)} #{query["1"]} NOT #{advanced_query(query["not_2"], model)})"
          else
            return "( #{advanced_query(query["0"], model)} #{query["1"]} #{advanced_query(query["2"], model)} )"
          end
        end
      end

      def parse_query_f(f, model)

        my_query = []
        today = Date.today.to_datetime
        this_week = Date.today.next_week
        last_week = Date.today.last_week
        yesterday = Date.yesterday
        query = ""

        f.map do |k1,v1|
          v1.map do |v2|        # v2 es un arreglo donde el la pos 0 esta la llave del hash y en la 1 un hash que es el valor
            my_hash = v2[1]
            oper1 = nil
            oper2 = nil

            if my_hash["o"].nil?
              if my_hash["v"] == "true"
                my_query << "(#{k1} = 't' )"
              elsif my_hash["v"] == "false"
                my_query << "(#{k1} = 'f' )"
              elsif my_hash["v"] == "_blank"
                my_query << "(#{k1} IS NULL OR #{k1} = '')"
              elsif my_hash["v"] == "_present"
                my_query << "(#{k1} IS NOT NULL AND #{k1} != '')"
              else
                my_query << "(id NOT NULL)"
              end


             elsif my_hash["o"] == "between"
              my_hash["v"].each do |value|
                if value.present? && oper1.nil?
                    oper1 = value
                elsif value.present?
                  oper2 = value
                end
              end
              if oper1.include?("/")
                oper1 = parse_date(oper1).to_date
                oper2 = parse_date(oper2).to_date
                my_query << "(#{k1} BETWEEN '#{oper1}' AND '#{oper2.next_day}')"
              else
                my_query << "(#{k1} >= #{oper1} AND #{k1} <= #{oper2} )"
              end
            elsif my_hash["o"] == "default"
              my_hash["v"].each do |value|
                if value.present? && oper1.nil?
                  oper1 = value
                end
              end
              if oper1.include?("/")
                oper1 = parse_date(oper1).to_date
                my_query << "(#{k1} BETWEEN '#{oper1}' AND  '#{oper1.next_day}')"
              else
                my_query << "(#{k1} = #{oper1})"
              end
            elsif my_hash["o"] == "today"
              my_query << "(#{k1} BETWEEN '#{today}' AND  '#{today.next_day}')"
            elsif my_hash["o"] == "yesterday"
              my_query << "(#{k1} BETWEEN '#{yesterday}' AND  '#{yesterday.next_day}')"
            elsif my_hash["o"] == "this_week"
              my_query << "( #{k1} BETWEEN '#{this_week - 7.day}' AND '#{this_week}' )"
            elsif my_hash["o"] == "last_week"
              my_query << "( #{k1} BETWEEN '#{last_week}' AND '#{this_week + 7.day}' )"
            elsif my_hash["o"] == "is"
              my_query << "(#{k1} LIKE '#{my_hash["v"]}')"
            elsif my_hash["o"] == "starts_with"
              my_query << "(#{k1} LIKE '#{my_hash["v"]}%')"
            elsif my_hash["o"] == "ends_with"
              my_query << "(#{k1} LIKE '%#{my_hash["v"]}')"
            elsif my_hash["o"] == "like"
              my_query << "(#{k1} LIKE '%#{my_hash["v"]}%')"
            elsif my_hash["o"] == "_null"
              my_query << "(#{k1} IS NULL )"
            elsif my_hash["o"] == "_not_null"
              my_query << "(#{k1} IS NOT NULL )"
            end
          end
        end
        i = 0
        my_query.each do |index|
          if i <= my_query.length - 2
            query += index + "AND"
            i += 1
          else
            query += index
        end
        end
        query
      end
    end
  end
end