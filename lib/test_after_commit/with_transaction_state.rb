# disable parts of the sync code that starts looping
module TestAfterCommit
  module WithTransactionState
    def sync_with_transaction_state
      @reflects_state ||= []
      @reflects_state[0] = true
      super
    end

    ActiveRecord::Base.__send__(:include, self)
  end
end
