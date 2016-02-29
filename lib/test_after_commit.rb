require 'test_after_commit/version'

if ActiveRecord::VERSION::MAJOR >= 5
  raise 'after_commit testing is baked into rails 5, you no longer need test_after_commit gem'
end

if ActiveRecord::VERSION::MAJOR >= 4
  require 'test_after_commit/with_transaction_state'
  ActiveRecord::Base.send(:prepend, TestAfterCommit::WithTransactionState)
end

require 'test_after_commit/database_statements'
ActiveRecord::ConnectionAdapters::AbstractAdapter.send(:prepend, TestAfterCommit::DatabaseStatements)

module TestAfterCommit
  @enabled = true
  class << self
    attr_accessor :enabled

    def with_commits(value = true)
      old = enabled
      self.enabled = value
      yield
    ensure
      self.enabled = old
    end
  end
end
