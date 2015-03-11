require 'test_after_commit/version'

module TestAfterCommit
end

ActiveRecord::ConnectionAdapters::DatabaseStatements.class_eval do
  def transaction_with_transactional_fixtures(*args)
    @test_open_transactions ||= 0
    transaction_without_transactional_fixtures(*args) do
      begin
        @test_open_transactions += 1
        if ActiveRecord::VERSION::MAJOR == 3
          @_current_transaction_records.push([]) if @_current_transaction_records.empty?
        end
        result = yield
      rescue Exception => e
        rolled_back = true
        raise e
      ensure
        begin
          @test_open_transactions -= 1
          if @test_open_transactions == 0 && !rolled_back
            test_commit_records
          end
        ensure
          result
        end
      end
    end
  end
  alias_method_chain :transaction, :transactional_fixtures

  def test_commit_records
    if ActiveRecord::VERSION::MAJOR == 3
      commit_transaction_records
    else
      # To avoid an infinite loop, we need to copy the transaction locally, and clear out
      # `records` on the copy that stays in the AR stack. Otherwise new
      # transactions inside a commit callback will cause an infinite loop.
      #
      # This is because we're re-using the transaction on the stack, before
      # it's been popped off and re-created by the AR code.
      original = @transaction || @transaction_manager.current_transaction
      transaction = original.dup
      transaction.instance_variable_set(:@records, transaction.records.dup) # deep clone of records array
      original.records.clear                                                # so that this clear doesn't clear out both copies
      transaction.commit_records
    end
  end
end

if ActiveRecord::VERSION::MAJOR >= 4
  # disable parts of the sync code that starts looping
  ActiveRecord::Base.class_eval do
    alias_method :sync_with_transaction_state_with_state, :sync_with_transaction_state
    def sync_with_transaction_state
      if @reflects_state
        @reflects_state[0] = true
      else
        @reflects_state = [true]
      end

      sync_with_transaction_state_with_state
    end
  end
end
