namespace :db do
  namespace :fixtures do
    desc "Extract DB to YAML fixtures."
    task :extract => :environment do
      table = []
      tables = {}
      open("#{RAILS_ROOT}/db/schema.rb") do |io|
        while line = io.gets
          next if line.blank?
          case line
          when /create_table/
            table = []
            table << line.split(/"/)[1]
            has_id = line.split(/,/).detect { |l| /:id => false/ =~ l }
            table << "id" unless has_id
          when /t\./
            column = line.split(/"/)[1]
            table << column unless /created_at|updated_at/ =~ column
          when /  end/
            tables[table.shift] = table unless table.blank?
          end
        end
      end

      fixtures_dir = db_connection

      tables.each do |table_name, columns|
        next if ENV["FIXTURES"] && !ENV["FIXTURES"].split(/,/).include?(table_name)
        order = columns.include?("id") ? " ORDER BY id" : ""
        records = execute_sql(table_name, order)
        write_fixtures("w", fixtures_dir + table_name, records, columns) { |record, column, i| entry_fixture(column, record[column]) }
      end
    end


    task :convert => :environment do
      desc "Convert data from legacy schema to another."
      CONFIG_FILE = "config/tables.yml"
      if    ENV["DB"].nil?            then raise ArgumentError, "Set argument DB.\ne.g. rake db:fixtuers:convert DB=foo"
      elsif !File.exist?(CONFIG_FILE) then raise IOError      , "Doesn't exist config/tables.yml"
      end

      require "find"
      fixtures_dir = db_connection(ENV["DB"])

      table_list = YAML::load_file(CONFIG_FILE)

      files = []
      Find::find("#{fixtures_dir}") { |path| files << path }

      table_list.each do |before_table, after_tables|
        before_table = before_table.split(/::/)
        model = before_table.map { |table| table.camelize }.join("::").constantize
        records = execute_sql(before_table[-1], " ORDER BY #{model.primary_key}")

        after_tables.each do |after_table, column_map|
          delete_file = files.detect { |file| %r(#{after_table}.yml$) =~ file }
          if delete_file
            FileUtils.rm(delete_file)
            files.reject! { |file| file == delete_file }
          end

          write_fixtures("a", fixtures_dir + after_table, records, model.columns) do |record, column, i|
            next unless column_map[column.name]
            entry_fixture(column_map[column.name], record[column.name])
          end
        end
      end
    end
  end
end

private
def db_connection(db = nil)
  ActiveRecord::Base.establish_connection(db)
  FileTest.exist?("spec") ? fixtures_dir = "spec" : fixtures_dir = "test"
  fixtures_dir += "/fixtures/"
  FileUtils.mkdir_p(fixtures_dir)
  fixtures_dir
end

def execute_sql(table_name, order)
  sql = "SELECT * FROM %s" + order
  records = ActiveRecord::Base.connection.select_all(sql % table_name)
  records.empty? ? next : records
end

def write_fixtures(mode, file_name, records, columns)
  open("#{file_name}.yml", mode) do |file|
    i = 0
    records.each do |record|
      rec = ["data#{i += 1}:"]
      columns.each do |column|
        r = yield record, column, i
        rec << r
      end
      file.write rec.compact.join("\n") + "\n" * 2
    end
  end
end

def entry_fixture(column, value)
  if value.nil? || (value == "0" && column =~ /_id$|^type$/)
    nil
  else
    value.gsub!(/\t|\?/, "")
    value.gsub!(/\[/, "［")
    value.gsub!(/\]/, "］")
    "  #{column}: #{value}"
  end
end