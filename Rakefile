namespace :cfndslpipeline do
  task :build do
    `gem build cfndsl-pipeline.gemspec`
  end

  task :install do
  end
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

task :default => [:spec]
