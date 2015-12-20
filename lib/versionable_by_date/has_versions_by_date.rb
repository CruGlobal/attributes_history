require 'active_support'
require_relative 'version_saver'

module VersionableByDate
  module HasVersionsByDate
    extend ActiveSupport::Concern

    module ClassMethods
      # The options should include the keys :attributes and :version_class
      def has_versions_by_date(options)
        class_attribute :versions_by_date_model, :versions_by_date_fields
        self.versions_by_date_model = options[:with_model]
        self.versions_by_date_fields = options[:for_attributes].map(&:to_s)

        has_many versions_by_date_model.name.underscore.pluralize.to_sym

        after_update do
          VersionSaver.new(self, versions_by_date_fields, versions_by_date_model)
            .save_if_needed
        end
      end
    end
  end
end
