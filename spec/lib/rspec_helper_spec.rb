require 'rails_helper'

describe AttributesHistory, order: :defined do
  describe 'without rspec helper enabled' do
    it 'is enabled by default when the rspec helper is not required' do
      expect(AttributesHistory).to be_enabled
    end
  end

  require 'attributes_history/rspec'

  describe 'with rspec helper required' do
    it 'is disabled by default when rspec helper required' do
      expect(AttributesHistory).to_not be_enabled
    end

    it 'is enabled if versioning metadata flag set', versioning: true do
      expect(AttributesHistory).to be_enabled
    end
  end
end
