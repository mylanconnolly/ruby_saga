# frozen_string_literal: true

module RubySaga
  # Transactions are the building blocks of sagas.
  class Transaction
    # Label is used to identify the transaction in the saga. When the
    # transaction is completed, the label will be used to identify the data
    # that was returned by the transaction. It should be a symbol. If it is not,
    # it will be converted to a symbol.
    def self.label = nil

    # Commit is the method used to execute the transaction.
    def self.commit(_data)
      raise NotImplementedError
    end

    # Compensate is the method used to undo the transaction if a failure
    # occurred in this transaction or any subsequent transactions.
    def self.compensate(_data)
      raise NotImplementedError
    end
  end
end
