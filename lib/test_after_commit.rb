require 'test_after_commit/version'

module TestAfterCommit
end

ActiveRecord::ConnectionAdapters::DatabaseStatements.class_eval do
  def transaction_with_transactional_fixtures(*args)
    @test_open_transactions ||= 0
    transaction_without_transactional_fixtures(*args) do
      begin
        @test_open_transactions += 1
        result = yield
      rescue ActiveRecord::Rollback => e
        rolled_back = true
        raise e
      ensure
        if @test_open_transactions == 1 && !rolled_back
          test_commit_records
        end
        @test_open_transactions -= 1
        result
      end
    end
  end
  alias_method_chain :transaction, :transactional_fixtures

  def test_commit_records
    if ActiveRecord::VERSION::MAJOR == 3
      commit_transaction_records(false)
    else
      @transaction.commit_records
      @transaction.records.clear # prevent duplicate .commit!
      @transaction.instance_variable_get(:@state).set_state(nil)
    end
  end

  if ActiveRecord::VERSION::MAJOR == 3
    # The @_current_transaction_records is a stack of arrays, each one
    # containing the records associated with the corresponding transaction
    # in the transaction stack. This is used by the
    # `rollback_transaction_records` method (to only send a rollback hook to
    # models attached to the transaction being rolled back) but is usually
    # ignored by the `commit_transaction_records` method. Here we
    # monkey-patch it to temporarily replace the array with only the records
    # for the top-of-stack transaction, so the real
    # `commit_transaction_records` method only sends callbacks to those.
    #
    def commit_transaction_records_with_transactional_fixtures(commit = true)
      return commit_transaction_records_without_transactional_fixtures if commit

      preserving_current_transaction_records do
        @_current_transaction_records = @_current_transaction_records.pop || []
        commit_transaction_records_without_transactional_fixtures
      end
    end
    alias_method_chain :commit_transaction_records, :transactional_fixtures

    def preserving_current_transaction_records
      old_current_transaction_records = @_current_transaction_records.dup
      yield
    ensure
      @_current_transaction_records = old_current_transaction_records
    end
  end
end
