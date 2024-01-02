# frozen_string_literal: true

require_relative 'lib/ruby_saga/version'

Gem::Specification.new do |spec|
  spec.name = 'ruby_saga'
  spec.version = RubySaga::VERSION
  spec.authors = ['Mylan Connolly']
  spec.email = ['mylan@mylan.io']

  spec.summary = 'This is a simple implementation of the Saga pattern in Ruby.'
  spec.description = spec.summary
  spec.homepage = 'https://github.com/mylanconnolly/ruby_saga'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.2.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = 'https://github.com/mylanconnolly/ruby_saga/blob/main/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end

  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
  spec.metadata['rubygems_mfa_required'] = 'true'
end
