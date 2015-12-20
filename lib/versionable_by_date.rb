Dir[File.join(File.dirname(__FILE__), 'versionable_by_date', '*.rb')].each do |file|
  require File.join('versionable_by_date', File.basename(file, '.rb'))
end

module VersionableByDate
  # This allows you to use VersionableByDate.disable! to stop versioning
  class << self
    def disable!
      Thread.current[:by_date_versions_disabled] = true
    end

    def enable!
      Thread.current[:by_date_versions_disabled] = false
    end

    def disabled?
      Thread.current[:by_date_versions_disabled]
    end
  end
end

ActiveSupport.on_load(:active_record) do
  include VersionableByDate::HasVersionsByDate
end
