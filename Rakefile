require 'bundler/setup'
require 'bundler/gem_tasks'
require 'bump/tasks'
require 'wwtd/tasks'

task :spec do
  sh "rspec spec/"
end

task :default => "wwtd:local"
