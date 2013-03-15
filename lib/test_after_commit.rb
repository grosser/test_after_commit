require 'test_after_commit/version'

module TestAfterCommit
end

# https://gist.github.com/1305285 + removed RSpec specific code
ActiveRecord::ConnectionAdapters::DatabaseStatements.class_eval do
  #
  # Run the normal transaction method; when it's done, check to see if there
  # is exactly one open transaction. If so, that's the transactional
  # fixtures transaction; from the model's standpoint, the completed
  # transaction is the real deal. Send commit callbacks to models.
  #
  # If the transaction block raises a Rollback, we need to know, so we don't
  # call the commit hooks. Other exceptions don't need to be explicitly
  # accounted for since they will raise uncaught through this method and
  # prevent the code after the hook from running.
  #
  #def transaction_with_transactional_fixtures(*args)
  #  return_value = nil
  #  rolled_back  = false
  #
  #  transaction_without_transactional_fixtures(*args) do
  #    begin
  #      return_value = yield
  #    rescue ActiveRecord::Rollback
  #      rolled_back = true
  #      raise
  #    end
  #  end
  #
  #  commit_transaction_records(false) if not rolled_back and open_transactions == 1
  #
  #  return_value
  #end
  #alias_method_chain :transaction, :transactional_fixtures

  if ActiveRecord::VERSION::MAJOR > 3
    require 'active_record/connection_adapters/abstract/transaction'
    ActiveRecord::ConnectionAdapters::SavepointTransaction.class_eval do
      def perform_commit_with_transactional_fixtures
        commit_records if number == 1
        perform_commit_without_transactional_fixtures
      end

      alias_method_chain :perform_commit, :transactional_fixtures
    end
  else
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
  end

  def preserving_current_transaction_records
    old_current_transaction_records = @_current_transaction_records.dup
    yield
  ensure
    @_current_transaction_records = old_current_transaction_records
  end
end
