require "rake/testtask"

Rake::TestTask.new :unit do |t|
  t.description = "Run unit tests"
  t.test_files  = FileList["test/*.rb"]
  t.warning     = false

  t.libs << "."
  t.libs << "lib"
end
