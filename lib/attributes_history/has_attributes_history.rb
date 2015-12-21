require 'active_support'
require_relative 'history_saver'
require_relative 'history_retriever'

module AttributesHistory
  module HasAttributesHistory
    extend ActiveSupport::Concern

    module ClassMethods
      # The options should include the keys :attributes and :version_class
      def has_attributes_history(options)
        class_attribute :history_model, :history_attributes, :history_association
        self.history_model = options[:with_model]
        self.history_attributes = options[:for].map(&:to_s)
        self.history_association = history_model.name.underscore.pluralize.to_sym

        has_many history_association
        after_update { HistorySaver.new(self).save_if_needed }
        define_verisons_by_date_lookups
      end

      private

      def define_verisons_by_date_lookups
        define_method :attribute_on_date do |attribute, date|
          @history_retriever ||= HistoryRetriever.new(self)
          @history_retriever.attribute_on_date(attribute, date)
        end

        history_attributes.each do |attribute|
          define_method "#{attribute}_on_date" do |date|
            attribute_on_date(attribute, date)
          end
        end
      end
    end
  end
end
