module VersionableByDate
  class VersionFinder
    def initialize(object)
      @object = object
      @versions_on_cache = {}
    end

    def versioned_field_on(field, date)
      version_on(date).public_send(field)
    end

    private

    def version_on(date)
      @versions_on_cache[date] ||= find_version_on(date)
    end

    def find_version_on(date)
      versions.where('versioned_on > ?', date).order(:versioned_on).first ||
        @object
    end

    def versions
      @object.public_send(@object.versions_by_date_association)
    end
  end
end
