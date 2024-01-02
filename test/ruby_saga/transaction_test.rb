# frozen_string_literal: true

require 'test_helper'
require 'json'
require 'fileutils'

# This serves as a sample transaction to illustrate the usage of the transaction
# functionality. Note that in a real transaction both commit and compensate need
# to be idempotent since they could theoretically be called multiple times.
class SampleTransaction < RubySaga::Transaction
  def self.label = :sample

  def self.commit(data)
    dir = Dir.mktmpdir('ruby_saga')
    FileUtils.mkdir_p(dir)

    path = File.join(dir, 'sample.json')
    File.write(path, JSON.pretty_generate(data[:initial_data]))
    path
  end

  def self.compensate(data)
    FileUtils.rm_rf(data[:sample])
  end
end

module RubySaga
  class TransactionTest < Minitest::Test
    def setup
      @data = { 'a' => 'b' }
    end

    # Note that this test is used to illustrate the usage of the transaction.
    def test_commit_rollback
      path = SampleTransaction.commit(initial_data: @data)
      assert File.exist?(path)
      SampleTransaction.compensate(initial_data: @data, sample: path)
      refute File.exist?(path)
    end
  end
end
