# RubySaga

This library is a relatively simple workflow implementation that approximates
the Saga pattern. It does not have any dependencies outside of the standard
library and does not rely on (for example) Dry-RB or ActiveSupport. This is also
based around OOP and inheritance rather than a DSL.

An (very elaborate) example is shown below. Note that this sample is pulled from
the test cases.

```ruby
class WriteFileTransaction < RubySaga::Transaction
  def self.label = :write_file

  def self.commit(data)
    dir = Dir.mktmpdir('ruby_saga')
    FileUtils.mkdir_p(dir)

    path = File.join(dir, 'file.json')
    File.write(path, JSON.pretty_generate(data[:initial_data]))
    path
  end

  def self.compensate(data)
    return if data[self.class.label].nil? || !File.exist?(data[self.class.label])

    FileUtils.rm_rf(data[self.class.label])
  end
end

class WriteSizeTransaction < RubySaga::Transaction
  def self.label = :write_size

  def self.commit(data)
    original_path = data[:write_file]
    dir = File.dirname(original_path)

    path = File.join(dir, 'size.txt')
    File.write(path, File.size(original_path).to_s)
    path
  end

  def self.compensate(data)
    return if data[self.class.label].nil? || !File.exist?(data[self.class.label])

    FileUtils.rm_rf(data[self.class.label])
  end
end

class SampleSaga < RubySaga::Saga
  def self.transactions = [WriteFileTransaction, WriteSizeTransaction]
end
```

Usage of the above saga would be something like:

```ruby
result = WriteFileTransaction.new('a' => 'b').run
puts result[:write_file]
# ...would print the path for the data file
puts result[:write_size]
# ...would print the path for the file containing the file size
```

If for whatever reason something goes wrong, the `compensate` step would be run
for that transaction and any previous transactions in reverse order. For example
in our step if the write size step failed, `compensate` would ensure that the
file does not exist and then compensate would be run on the write data step and
that file would be deleted.

Note the defensive programming around checking if the filename variable exists.
This is because compensate could be run if the step itself failed (at which
point we wouldn't have the filename yet), but it could fail if a subsequent step
failed (in which case the filename would be available).
