$LOAD_PATH.unshift 'lib'
require File.expand_path '../database', __FILE__

if ENV['REAL']
  puts 'using real transactions'
else
  require 'test_after_commit'
end

RSpec.configure do |config|
  unless ENV['REAL']
    config.around do |example|
      ActiveRecord::Base.transaction do # simulate transactional fixtures
        example.call
      end
    end
  end
end
