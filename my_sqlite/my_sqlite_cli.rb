require "readline"
require "./my_sqlite_request"

class SelectCli
    def initialize(query)
        @query = query
        self.select()
    end

    def parse_select_query(cmd)
        _result = []
        result = cmd.slice(0, cmd.index("FROM"))
        result.each do |item|
            split_item = item.split(',')
            if(split_item.length > 0)
                _result = [*_result, *split_item]
            else
                _result << item
            end
        end
        _result = _result.map { |item| item.gsub(/[\s,]/, '') }
        _result
    end

    def parse_where_query(cmd)
        _result = []
        result = cmd.join(' ').split(',').map { |item| item.split('=') }
        result.each do |i|
            item = []
            i.each do |j|
                item << j.strip.gsub(/[\'\"]/, '')
            end
            _result << item
        end
        _result
    end

    def select
        request = MySqliteRequest.new
        @query.each_with_index do |cmd, index|
            if(index == 1)
                if(cmd == "*")
                    request = request.select()
                else
                    request = request.select(
                        parse_select_query(@query.slice(index, @query.length - 1))
                    )
                end
            elsif(cmd.downcase == "from")
                request = request.from(@query[index + 1])
            elsif(cmd.downcase == "where")
                parse_where = parse_where_query(@query.slice(index + 1, @query.length - 1))
                parse_where.each do |item|
                    request = request.where(item[0], item[1])
                end
            end
        end
        request.run()
    end
end

class DeleteCli
    def initialize(query)
        @query = query
        self.delete()
    end

    def parse_where_query(cmd)
        _result = []
        result = cmd.join(' ').split(',').map { |item| item.split('=') }
        result.each do |i|
            item = []
            i.each do |j|
                item << j.strip.gsub(/[\'\"]/, '')
            end
            _result << item
        end
        _result
    end

    def delete
        request = MySqliteRequest.new
        @query.each_with_index do |cmd, index|
            if(cmd.downcase == "from")
                request = request.from(@query[index + 1])
                request = request.delete()
            elsif(cmd.downcase == "where")
                parse_where = parse_where_query(@query.slice(index + 1, @query.length - 1))
                parse_where.each do |item|
                    request = request.where(item[0], item[1])
                end
            end
        end
        request.run()
    end
end

class UpdateCli
    def initialize(query)
        @query = query
        self.update()
    end

    def parse_where_query(cmd)
        _result = []
        result = cmd.join(' ').split(',').map { |item| item.split('=') }
        result.each do |i|
            item = []
            i.each do |j|
                item << j.strip.gsub(/[\'\"\;]/, '')
            end
            _result << item
        end
        _result
    end

    def update
        request = MySqliteRequest.new
        start_index_set = -1
        @query.each_with_index do |cmd, index|
            if(cmd.downcase == "update")
                request = request.update(@query[index + 1])
            elsif(cmd.downcase == "set")
                start_index_set = index + 1
            elsif(cmd.downcase == "where")
                parse_set = parse_where_query(@query.slice(start_index_set, index - 3))
                parse_set = parse_set.to_h
                request = request.set(parse_set)
                parse_where = parse_where_query(@query.slice(index + 1, @query.length - 1))
                parse_where.each do |item|
                    request = request.where(item[0], item[1])
                end
            end
        end
        request.run()
    end
end

class InsertCli
    def initialize(query)
        @query = query
        self.insert()
    end

    def insert
        # INSERT INTO students.db VALUES (John, john@johndoe.com, A, https://blog.johndoe.com);
        request = MySqliteRequest.new
        @query.each_with_index do |cmd, index|
            if(index == 2)
                request = request.insert(@query[index])
            elsif(cmd.downcase == 'values')
                request = request.insert_cli(
                    @query.slice(index + 1, @query.length - 1).map { |item| item.gsub(/[\(\)\;\,]/, "") }.join(',')
                )
            end
        end
    end
end

class SqliteCli
    def initialize(cmd)
        @query = cmd.split(' ')
        self.run()
    end

    def run()
        case @query[0].downcase
        when "select"
            SelectCli.new(@query)
        when "insert"
            InsertCli.new(@query)
        when "update"
            UpdateCli.new(@query)
        when "delete"
            DeleteCli.new(@query)
        else
            puts "Wrong type of request #{@query[0]}."
        end
    end
end

exitcmds = [".exit", ".quit"]
while buf = Readline.readline("> ", true)
    break if exitcmds.include?(buf)
    SqliteCli.new(buf) if(buf.length > 0)
end