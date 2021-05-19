# frozen_string_literal: true

require 'rspec/core'

RSpec.configure do |config|
  config.before(:each) do
    ::AttributesHistory.enabled = false
  end

  config.before(:each, versioning: true) do
    ::AttributesHistory.enabled = true
  end
end
