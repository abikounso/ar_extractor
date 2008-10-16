def fixture_entry(table_name, obj)
  res = []
  klass = table_name.singularize.camelize.constantize
  res << "#{table_name.singularize}#{obj['id']}:"
  klass.columns.each do |column|
    res << "  #{column.name}: #{obj[column.name]}"
  end
  res.join("\n")
end
   
namespace :db do
  namespace :fixtures do
    desc "Extract database data to the spec(or test)/fixtures/ directory.
          Use FIXTURES=table_name[,table_name...] to specify table names to extract.
          Otherwise, all the table data will be extracted."
    task :extract => :environment do
      sql = "SELECT * FROM %s ORDER BY id"
      skip_tables = ['schema_info', 'schema_migrations']
      ActiveRecord::Base.establish_connection
      fixtures_dir = "#{RAILS_ROOT}/spec/fixtures/"
      fixtures_dir = "#{RAILS_ROOT}/test/fixtures/" unless FileTest.exist?(fixtures_dir)
      FileUtils.mkdir_p(fixtures_dir)

      if ENV['FIXTURES']
        table_names = ENV['FIXTURES'].split(/,/)
      else
        table_names = (ActiveRecord::Base.connection.tables - skip_tables)
      end

      table_names.each do |table_name|
        File.open("#{fixtures_dir}#{table_name}.yml", "w") do |file|
          objects  = ActiveRecord::Base.connection.select_all(sql % table_name)
          objects.each do |obj|
            file.write  fixture_entry(table_name, obj) + "\n\n"
          end
        end
      end
    end
  end
end
