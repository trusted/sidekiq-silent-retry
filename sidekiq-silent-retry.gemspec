# frozen_string_literal: true

require_relative "lib/sidekiq/silent_retry/version"

Gem::Specification.new do |spec|
  spec.name = "sidekiq-silent-retry"
  spec.version = Sidekiq::SilentRetry::VERSION
  spec.authors = ["Gustavo Diel"]
  spec.email = ["gustavo.diel@trustedhealth.com"]

  spec.summary = "Silence all but last retry in Sidekiq jobs."
  spec.description = <<~DESC
    This gems silences all of Sidekiq exceptions in retryable jobs, except the last one.
    Specially useful when you know you job is most likely going to fail often (scrapers, api calls, etc)
  DESC
  spec.homepage = "https://github.com/trusted/sidekiq-silent-retry"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "https://github.com/trusted/sidekiq-silent-retry/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ spec/ .git .github .rspec .rubocop.yml Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'sidekiq', '~> 6.0'
end
