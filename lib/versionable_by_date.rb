require 'versionable_by_date/gem_version.rb'
require 'versionable_by_date/has_versions_by_date.rb'

module VersionableByDate
  class << self
    attr_writer :enabled

    def enabled?
      # Enabled by default
      @enabled.nil? ? true : @enabled
    end
  end
end

ActiveSupport.on_load(:active_record) do
  include VersionableByDate::HasVersionsByDate
end
