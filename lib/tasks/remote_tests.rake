namespace :test do
  Rake::TestTask.new(:remote => 'test:prepare') do |t|
    t.libs << 'test'
    t.pattern = 'test/remote/**/*_test.rb'
    t.verbose = false
  end
  Rake::Task['test:remote'].comment = "Run tests that make calls to external services"
end
