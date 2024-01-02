# frozen_string_literal: true

module RubySaga
  # A saga is a collection of transactions that are executed in a specific
  # order. If any transaction fails, the saga will attempt to compensate for
  # the failure by executing the compensate method of each transaction in
  # reverse order.
  class Saga
    attr_reader :initial_data, :transaction_data

    def initialize(data)
      @initial_data = data
      @transaction_data = []
    end

    def self.transactions = []

    def run
      self.class.transactions.each_with_index.reduce(initial_data:) do |data, (transaction, index)|
        label = transaction.label.to_sym
        result = transaction.commit(data)
        new_data = data.merge(label => result)
        transaction_data << new_data
        new_data
      rescue StandardError => e
        compensate(index)
        raise e
      end
    end

    private

    def compensate(index)
      self.class.transactions[..index].each_with_index.to_a.reverse.each do |transaction, i|
        transaction.compensate(transaction_data[i] || { initial_data: })
      end
    end
  end
end
