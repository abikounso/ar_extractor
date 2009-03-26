def entry_fixture(io, record, table_name, columns, i)
  rec = []
  rec << "#{table_name.singularize}#{i}:"
  columns.each do |column|
    value = record[column]
    value ? value.gsub!(/\t|\?/, "") : next
    rec << " #{column}: #{value}"
  end
  rec.join("\n") + "\n" * 2
end
   
namespace :db do
  namespace :fixtures do
    desc "Extract database data to YAML fixtures."
    task :extract => :environment do
      table = []
      tables = {}
      open("#{RAILS_ROOT}/db/schema.rb") do |io|
        while line = io.gets
          next if line.blank?
          case line
          when /create_table/
            tables[table.shift] = table unless table.blank?
            table = []
            table << line.split('"')[1]
            has_id = line.split(",").detect { |l| /:id => false/ =~ l }
            table << "id" unless has_id
          when /t\./
            column = line.split('"')[1]
            table << column unless /created_at|updated_at/ =~ column
          end
        end
      end

      ActiveRecord::Base.establish_connection

      fixtures_dir = "#{RAILS_ROOT}/spec"
      fixtures_dir.gsub!("spec", "test") unless FileTest.exist?(fixtures_dir)
      fixtures_dir = fixtures_dir + "/fixtures/"
      FileUtils.mkdir_p(fixtures_dir)
      
      tables.each do |table_name, columns|
        next if ENV["FIXTURES"] && !ENV["FIXTURES"].split(",").include?(table_name)
        sql = "SELECT * FROM %s"
        sql += " ORDER BY id" if columns.include?("id")
        records = ActiveRecord::Base.connection.select_all(sql % table_name)
        next if records.empty?
        open("#{fixtures_dir}#{table_name}.yml", "w") do |io|
          i = 0
          records.each { |record| io.write entry_fixture(io, record, table_name, columns, i += 1) }
        end
      end
    end
  end
end
