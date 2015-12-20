require 'active_support'

module VersionableByDate
  module HasVersionsByDate
    extend ActiveSupport::Concern

    module ClassMethods
      # The options should include the keys :attributes and :version_class
      def has_versions_by_date(options)
        class_attribute :versions_by_date_model, :versions_by_date_fields,
                        :versions_by_date_foreign_key
        self.versions_by_date_model = options[:with_model]
        self.versions_by_date_fields = options[:for_attributes].map(&:to_s)
        self.versions_by_date_foreign_key = "#{name.underscore}_id"

        after_update :save_version_if_changed
        has_many versions_by_date_model.name.underscore.pluralize.to_sym
      end
    end

    private

    def save_version_if_changed
      save_version if versioned_fields_changed?
    end

    def versioned_fields_changed?
      (changed & self.class.versions_by_date_fields).present?
    end

    def save_version
      version = self.class.versions_by_date_model.find_or_initialize_by(
        self.class.versions_by_date_foreign_key => self[self.class.primary_key],
        versioned_on: Date.current
      )

      # If there is an existing version record for today, just leave it as is,
      # otherwise, save the newly created one.
      version.update!(version_params) if version.new_record?
    end

    def version_params
      Hash[
        self.class.versions_by_date_fields.map do |field|
          [field, version_value_for(field)]
        end
      ]
    end

    def version_value_for(field)
      # Use the previous value if it was changed, otherwise the current value
      if field.in?(changed)
        changes[field].first
      else
        public_send(field)
      end
    end
  end
end
