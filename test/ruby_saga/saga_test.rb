# frozen_string_literal: true

# rubocop:disable Style/GlobalVars
require 'test_helper'

class WriteFileFailure < StandardError; end
class WriteSizeFailure < StandardError; end

# We should never use global variables, however this is a relatively simple way
# to track the file paths that were created in the test. Don't ever do this in
# actual code.
$write_file_path = nil
$write_size_path = nil

class WriteFileTransaction < RubySaga::Transaction
  def self.label = :write_file

  def self.commit(data)
    raise WriteFileFailure if data[:initial_data] == 'crash_write_file'

    dir = Dir.mktmpdir('ruby_saga')
    FileUtils.mkdir_p(dir)

    path = File.join(dir, 'file.json')
    File.write(path, JSON.pretty_generate(data[:initial_data]))
    path
  end

  def self.compensate(data)
    return if data[:write_file].nil? || !File.exist?(data[:write_file])

    $write_file_path = data[:write_file]

    FileUtils.rm_rf(data[:write_file])
  end
end

class WriteSizeTransaction < RubySaga::Transaction
  def self.label = :write_size

  def self.commit(data)
    raise WriteSizeFailure if data[:initial_data] == 'crash_write_size'

    original_path = data[:write_file]
    dir = File.dirname(original_path)

    path = File.join(dir, 'size.txt')
    File.write(path, File.size(original_path).to_s)
    path
  end

  def self.compensate(data)
    return if data[:write_size].nil? || !File.exist?(data[:write_size])

    $write_size_path = data[:write_size]

    FileUtils.rm_rf(data[:write_size])
  end
end

class SampleSaga < RubySaga::Saga
  def self.transactions = [WriteFileTransaction, WriteSizeTransaction]
end

module RubySaga
  class SagaTest < Minitest::Test
    def setup
      @data = { 'a' => 'b' }
    end

    def test_success
      result = SampleSaga.new(@data).run
      assert File.exist?(result[:write_file])
      assert File.exist?(result[:write_size])
    end

    def test_compensate_first_step
      assert_raises(WriteFileFailure) do
        SampleSaga.new('crash_write_file').run
      end

      assert $write_file_path.nil?
      assert $write_size_path.nil?

      assert_raises(WriteSizeFailure) do
        SampleSaga.new('crash_write_size').run
      end

      assert !File.exist?($write_file_path)
      assert $write_size_path.nil?
    end
  end
end
# rubocop:enable Style/GlobalVars
