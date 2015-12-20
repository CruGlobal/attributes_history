require 'rails_helper'

describe VersionableByDate do
  it 'is enabled by default when the rspec helper is not required' do
    expect(VersionableByDate).to be_enabled
  end
end

require 'versionable_by_date/rspec'

describe VersionableByDate do
  it 'is disabled by default when rspec helper required' do
    expect(VersionableByDate).to_not be_enabled
  end

  it 'is enabled if versioning metadata flag set', versioning: true do
    expect(VersionableByDate).to be_enabled
  end
end
