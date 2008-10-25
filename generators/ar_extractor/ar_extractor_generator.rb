class ArExtractorGenerator < Rails::Generator::NamedBase
  def initialize(runtime_args, runtime_options = {})
    runtime_args = ["ar"]
    super
  end
  
  def manifest
    sources = []
    table_names = (ActiveRecord::Base.connection.tables - SKIP_TABLES).map!{|table_name| table_name.singularize.camelize}
    
    table_names.each do |table_name|
      source = "#{table_name}.populate 20 do |column|\n"
      columns = table_name.constantize.columns
      columns.each do |column|
        case column.type
        when :float
          value = "0.1..100.00"
        when :integer
          case column.name
          when /_id/
            value = "1..20"
          when /year/
            value = "1900..Time.now.year"
          else
            value = "1..10000"
          end
        when :string
          case column.name
          when "name"
            value = "Faker::Name.name"
          else
            value = "Populator.words(1..5).titleize"
          end
        when :text
          value = "Populator.sentences(2..10).titleize"
        when :date, :datetime
          value = "2.years.ago..Time.now"
        when :boolean
          value = "false"
        else
          value = "This column type is not supported. Write your own code."
        end
        
        unless column.name == "id" || column.name == "created_at" || column.name == "updated_at"
          source += "      column.#{column.name} = #{value}\n"
        end
      end
      sources << source
    end
    
    record do |m|
      m.template "population.rake", "lib/tasks/population.rake", :assigns => {:sources => sources, :table_names => table_names}
    end
  end
end

