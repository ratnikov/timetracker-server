ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

require 'rack/test'

class ActiveSupport::TestCase
end

class RackTest < ActionDispatch::IntegrationTest
  include Rack::Test::Methods
end
