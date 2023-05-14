require "csv"

class Select
    def initialize(file_name, where_columns, select_columns)
        @file_name = file_name
        @where_columns = where_columns
        @select_columns = select_columns
        self.select()
    end

    def where_select_request(data)
        result = []
        data.each_with_index do |item, i|
            @where_columns.each do |where_col|
                if(item[where_col[0]] == where_col[1])
                    if @select_columns.length > 0
                        result << item.to_hash.slice(*@select_columns)
                    else 
                        result << item.to_hash 
                    end
                end
            end
        end
        result
    end

    def select
        result = []
        data = CSV.parse(File.read(@file_name), headers: true)
        return p where_select_request(data) if @where_columns.length > 0
        data.each_with_index do |item, i|
            if(@select_columns.length > 0) 
                result << item.to_hash.slice(*@select_columns)
            else
                result << item.to_hash
            end
        end
        puts result
        result
    end
end

class Insert
    def initialize(file_name, values)
        @file_name = file_name
        @values = values
        self.insert()
    end

    def my_data_process(param_1)
        my_main_key = { "Gender" => {}, "Email" => {}, "Age"=> {}, "City" => {}, "Device" => {}, "Order At" => {}} 
    
        for items in param_1.drop(1)
            element = items.split(",")
            for key in my_main_key.keys()
                if my_main_key[key].include?(element[param_1[0].split(',').find_index(key.to_s)])
                    my_main_key[key][element[param_1[0].split(",").find_index(key)]] += 1
                else
                    my_main_key[key][element[param_1[0].split(",").find_index(key)]] = 1 
                end
            end
        end
        return my_main_key
    end

    def find_error(csv_keys, values_result)
        errors = []
        values_result.each_with_index do |value, index|
          if(value == nil) 
            errors << csv_keys[index]
          end
        end
        raise "These columns don't exists in your insert values #{errors.map { |error| "`#{error}`" }.join(', ')}" if(errors.length > 0)
        return true
    end

    def parse_hash_value(csv_keys, values) 
        result = []
        result[csv_keys.length - 1] = nil
        values.keys.each do |value_key|
            if(values[value_key].is_a? Integer) 
                result[csv_keys.index(value_key)] = values[value_key]
            elsif(values[value_key].split(' ').length > 1)
                result[csv_keys.index(value_key)] = "\"#{values[value_key]}\""
            else
                result[csv_keys.index(value_key)] = values[value_key]
            end
            
        end
        find_error(csv_keys, result)
        result
    end

    def result_put_in_file(file_name, values)
        File.open(file_name, 'a+') {|f| f.write("#{values.join(',')}\r\n")}
    end

    def insert
        result = []
        data = CSV.parse(File.read(@file_name))
        parse_values = parse_hash_value(data[0], @values);
        result_put_in_file(@file_name, parse_values)
    end
end

class Update
    def initialize(table_name, values, where_col)
        @table_name = table_name
        @values = values
        @where_col = where_col
        self.update()
    end

    def where_find(where_col, item)
        where_col.each do |where_item|
            if(item[where_item[0]] == where_item[1])
                return true
            end
        end
        false
    end

    def update_item(item, values)
        result = item
        values.keys.each do |key|
            result[key] = values[key]    
        end
        result
    end

    def hash_to_csv(data)
        hashes = data
        column_names = hashes.first.keys
        result = CSV.generate do |csv|
            csv << column_names
            hashes.each do |x|
                csv << x.values
            end
        end
        result
    end

    def update
        result = []
        data = CSV.parse(File.read(@table_name), headers: true)
        for item in data do
            if(where_find(@where_col, item))
                result.push(update_item(item.to_hash, @values))
                next
            end
            result.push(item.to_hash)
        end
        File.write(@table_name, hash_to_csv(result))
    end
end

class Delete
    def initialize(table_name, where_col)
        @table_name = table_name
        @where_col = where_col
        self.delete()
    end

    def where_find(where_col, item)
        where_col.each do |where_item|
            if(item[where_item[0]] == where_item[1])
                return true
            end
        end
        false
    end

    def hash_to_csv(data)
        hashes = data
        column_names = hashes.first.keys
        result = CSV.generate do |csv|
            csv << column_names
            hashes.each do |x|
                csv << x.values
            end
        end
        result
    end

    def delete
        result = []
        data = CSV.parse(File.read(@table_name), headers: true)
        for item in data do
            if(!where_find(@where_col, item))
                result.push(item.to_hash)
            end
        end
        File.write(@table_name, hash_to_csv(result))
    end
end

class MySqliteRequest
    def initialize()
        @csv_name = ""
        @select_columns = []
        @where_columns = []
        @type_of_request = :none
        @values_for_insert = {}
        @values_for_update = {}
    end

    def from(csv_name)
        @csv_name = csv_name
        self
    end

    def select(select_columns = nil)
        @type_of_request = :select
        return self if select_columns == nil
        if select_columns.kind_of?(Array)
            @select_columns = [*@select_columns, *select_columns]
        else
            @select_columns = [*@select_columns, select_columns]
        end
        self
    end

    def update(table_name)
        @type_of_request = :update
        @csv_name = table_name
        self
    end

    def insert(table_name)
        @type_of_request = :insert
        @csv_name = table_name
        self
    end

    def delete
        @type_of_request = :delete
        self
    end

    def values(data)
        @values_for_insert = data
        self
    end

    def insert_cli(values)
        File.open(@csv_name, 'a+') {|f| f.write("#{values}\r\n")}
        p "Success"
    end

    def set(data)
        @values_for_update = data
        self
    end

    def where(column_name, criteria)
        @where_columns << [ column_name, criteria ]
        self
    end

    def run
        case @type_of_request
        when :select
            Select.new(@csv_name, @where_columns, @select_columns)
        when :insert
            Insert.new(@csv_name, @values_for_insert)
        when :update
            Update.new(@csv_name, @values_for_update, @where_columns)
        when :delete
            Delete.new(@csv_name, @where_columns)
        else
            p "Wrong type of request #{$type_of_request}."
        end
    end
end

# request = MySqliteRequest.new
# request = request.insert('nba_player_data.csv')
# request = request.values({
#         "name" => "allaa", 
#         "year_start" => 1234, 
#         "year_end" => 1234, 
#         "position" => "sad", 
#         "height" => "123",
#         "weight" => 124,
#         "birth_date" => "June 24, 1968",
#         "college" => "dasds"
#     })
# request.run

# request = MySqliteRequest.new
# request = request.from('nba_player_data.csv')
# request = request.select()
# request = request.where('name', 'Zaid Abdul-Aziz')
# request.run

# request = MySqliteRequest.new
# request = request.update('nba_player_data.csv')
# request = request.set({"college" => "Duke University22", "year_start" => 2000})
# request = request.where('name', 'Zaid Abdul-Aziz')
# request.run

# request = MySqliteRequest.new
# request = request.from('nba_player_data.csv')
# request = request.delete()
# request = request.where('name', 'John')
# request.run()