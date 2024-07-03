# Sidekiq::SilentRetry

`sidekiq-silent-retry` is a middleware for Sidekiq that allows for silent retries of jobs. This gem intercepts exceptions raised during job execution and re-raises under a different exception class, so that tracing services can ignore them. Only the last exception is raised with the original exception.

## Instalation

Add this line to your application's Gemfile:

```ruby
gem 'sidekiq-silent-retry'
```

And then execute:

```shell
$ bundle install
```

## Usage

### Configuration

#### 1. Specify the error class for Silent Retry (optional)

You can specify a custom error class for silent retries. This is useful for making error tracing services ignore these errors.

Create an initializer file (e.g., config/initializers/sidekiq_silent_retry.rb) and add the following:

```ruby
Sidekiq::Silent::Retry.silent_retry_error_class = MySilentRetryError
```

#### 2. Mark jobs for Silent Retry

In your Sidekiq job class, configure the silent_retry option to control silent retries. The silent_retry option can be:

- `false` / `nil`: Disabled (default).
- `true`: Always enabled, no matter the error.
- Some class / Array of classes: Only exceptions of said class(es) will be silently retried.

```ruby
class MyJob
  include Sidekiq::Job

  sidekiq_options silent_retry: true

  def perform(*args)
    # Your job logic here
  end
end

class MyJob
  include Sidekiq::Job

  sidekiq_options silent_retry: [VeryCommonNotImportantError, VeryCommonNotImportantError2]

  def perform(*args)
    # Your job logic here
  end
end
```


## Dependencies

- [Sidekiq](https://github.com/mperham/sidekiq) 6.0 or later


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/trusted/sidekiq-silent-retry. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/trusted/sidekiq-silent-retry/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Sidekiq::Silent::Retry project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/trusted/sidekiq-silent-retry/blob/main/CODE_OF_CONDUCT.md).
