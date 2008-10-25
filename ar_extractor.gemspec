Gem::Specification.new do |s|
  s.name = %q{ar_extractor}
  s.version = "1.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["abikounso"]
  s.date = %q{2008-10-25}
  s.description = %q{FIX (describe your package)}
  s.email = ["abikounso@gmail.com"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.txt"]
  s.files = ["History.txt", "MIT-LICENSE", "Manifest.txt", "README.txt", "Rakefile", "init.rb", "generators/ar_extractor/ar_extractor_generator.rb", "generators/ar_extractor/templates/population.rake", "lib/ar_extractor.rb", "rails/init.rb", "tasks/ar_extractor_tasks.rake", "test/ar_extractor_test.rb"]
  s.has_rdoc = true
  s.homepage = %q{FIX (url)}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{ar_extractor}
  s.rubygems_version = %q{1.2.0}
  s.summary = %q{FIX (describe your package)}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if current_version >= 3 then
      s.add_development_dependency(%q<hoe>, [">= 1.8.0"])
    else
      s.add_dependency(%q<hoe>, [">= 1.8.0"])
    end
  else
    s.add_dependency(%q<hoe>, [">= 1.8.0"])
  end
end
