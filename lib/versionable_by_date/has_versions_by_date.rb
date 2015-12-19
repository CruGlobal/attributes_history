require 'active_support'

module VersionableByDate
  module Model
    extend ActiveSupport::Concern

    module ClassMethods
      # The options should include the keys :attributes and :version_class
      def has_versions_by_date(options)
        # Set a class-level instance variable for the version options
        @versions_by_date_options = options

        include VersionableByDate::Model
      end

      def versions_by_date_fields
        @versions_by_date_fields ||=
          @versions_by_date_options[:for_attributes].map(&:to_s)
      end

      def versions_by_date_model
        @versions_by_date_options[:with_model]
      end

      def versions_by_date_foreign_key
        "#{self.name.underscore}_id"
      end
    end

    included do
      after_update :save_version_by_date
      # has_many versions_by_date_model.name.underscore.pluralize.to_sym
    end

    private

    def save_version_by_date
      # return if VersionableByDate.disabled?
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
      version.update!(version_params)
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
