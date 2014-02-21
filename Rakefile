require 'rspec/core/rake_task'
require 'rubocop/rake_task'

task :default => :spec
task :test => :spec

desc "Run spec tests"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = "--color"
end

desc 'Run RuboCop on the lib directory'
Rubocop::RakeTask.new(:rubocop) do |task|
  task.patterns = ['lib/**/*.rb']
  # only show the files with failures
  task.formatters = ['progress']
  # don't abort rake on failure
  task.fail_on_error = false
end
