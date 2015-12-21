require 'attributes_history/gem_version.rb'
require 'attributes_history/has_attributes_history.rb'

module AttributesHistory
  class << self
    attr_writer :enabled

    def enabled?
      # Enabled by default
      @enabled.nil? ? true : @enabled
    end
  end
end

ActiveSupport.on_load(:active_record) do
  include AttributesHistory::HasAttributesHistory
end
