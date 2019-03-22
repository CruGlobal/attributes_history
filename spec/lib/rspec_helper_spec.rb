require 'rails_helper'

describe 'with rspec helper required' do
  require 'attributes_history/rspec'
  it 'is disabled by default when rspec helper required' do
    expect(AttributesHistory).to_not be_enabled
  end

  it 'is enabled if versioning metadata flag set', versioning: true do
    expect(AttributesHistory).to be_enabled
  end
end
