# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'coveralls'
Coveralls.wear!('rails')

ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

require 'factory_girl_rails'
require 'mongoid-rspec'

# for mocking external API calls
require 'webmock/rspec'

# for mocking external API calls
require 'vcr'
require 'webmock/rspec'

RSpec.configure do |config|
  config.include Mongoid::Matchers

  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  # VCR uses this
  # see https://www.relishapp.com/myronmarston/vcr/v/2-2-3/docs/test-frameworks/usage-with-rspec-metadata
  config.treat_symbols_as_metadata_keys_with_true_values = true

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  #config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  #config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  config.after(:each) do
    # DatabaseCleaner can't switch sessions, so we implement it ourselves.
    Mongoid.sessions.each do |session,_|
      Mongoid::Sessions.with_name(session).collections.each do |collection|
        collection.drop
      end
    end

    # Restore the default session.
    Mongoid.override_session(nil)
  end
end

VCR.configure do |c|
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :webmock
  c.configure_rspec_metadata!
  # c.allow_http_connections_when_no_cassette = false
  c.default_cassette_options = {
    match_requests_on: [:method, VCR.request_matchers.uri_without_param(:apikey)]
  }
end