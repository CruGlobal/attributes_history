module VersionableByDate
  class VersionSaver
    def initialize(changed_object)
      @changed_object = changed_object
      @versioned_fields = @changed_object.versions_by_date_fields
      @version_model = @changed_object.versions_by_date_model
      @versions_association = @changed_object.versions_by_date_association
    end

    def save_if_needed
      save_version if ::VersionableByDate.enabled? && versioned_fields_changed?
    end

    private

    def versioned_fields_changed?
      (@changed_object.changed & @versioned_fields).present?
    end

    def save_version
      version = @changed_object.public_send(@versions_association)
        .find_or_initialize_by(versioned_on: Date.current)

      # If there is an existing version record for today, just leave it as is,
      # otherwise, save the newly created one.
      version.update!(version_params) if version.new_record?
    end

    def version_params
      Hash[@versioned_fields.map { |f| [f, version_value_for(f)] }]
    end

    def version_value_for(field)
      # Use the previous value if it was changed, otherwise the current value
      if field.in?(@changed_object.changed)
        @changed_object.changes[field].first
      else
        @changed_object.public_send(field)
      end
    end
  end
end
