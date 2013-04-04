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
      # open a transaction without using .transaction as activerecord use_transactional_fixtures does
      if ActiveRecord::VERSION::MAJOR > 3
        connection = ActiveRecord::Base.connection_handler.connection_pool_list.map(&:connection).first
        connection.begin_transaction joinable: false
      else
        connection = ActiveRecord::Base.connection_handler.connection_pools.values.map(&:connection).first
        connection.increment_open_transactions
        connection.transaction_joinable = false
        connection.begin_db_transaction
      end

      example.call

      connection.rollback_db_transaction
      if ActiveRecord::VERSION::MAJOR == 3
        connection.decrement_open_transactions
      end
    end
  end
end
