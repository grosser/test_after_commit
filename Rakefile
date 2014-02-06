require 'bundler/setup'
require 'bundler/gem_tasks'
require 'appraisal'
require 'bump/tasks'
require 'wwtd/tasks'

task :spec do
  sh "rspec spec/"
end

task :default => "appraisal:install" do
  Rake::Task[:wwtd].execute

  puts "REAL=1"
  ENV["REAL"] = "1"
  Rake::Task[:wwtd].execute
end
