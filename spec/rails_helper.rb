# frozen_string_literal: true

require 'spec_helper'
require File.expand_path('../test/dummy/config/environment', __dir__)
require 'rspec/rails'
require 'pry'

RSpec.configure do |config|
  config.include ActiveSupport::Testing::TimeHelpers
end
