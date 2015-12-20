require 'rspec/core'

RSpec.configure do |config|
  config.before(:each) do
    ::VersionableByDate.enabled = false
  end

  config.before(:each, versioning: true) do
    ::VersionableByDate.enabled = true
  end
end
