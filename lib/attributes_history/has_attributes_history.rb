# frozen_string_literal: true

require 'active_support'
require_relative 'history_saver'
require_relative 'history_retriever'

module AttributesHistory
  module HasAttributesHistory
    extend ActiveSupport::Concern

    included do
      class_attribute :history_models, :history_associations
      self.history_models ||= {}
      self.history_associations ||= {}
    end

    module ClassMethods
      # The options should include the keys :attributes and :version_class
      def has_attributes_history(options)
        history_model = options[:with_model]
        history_attributes = options[:for].map(&:to_s)
        history_association = history_model.name.underscore.pluralize.to_sym

        has_many history_association

        store_history_options(history_model, history_attributes, history_association)
        setup_history_callback(history_attributes, history_model)
        define_attribute_on_date_methods(history_attributes)
      end

      def history_model(attribute)
        self.history_models[attribute]
      end

      def history_association(attribute)
        self.history_associations[attribute]
      end

      private

      def store_history_options(history_model, history_attributes, history_association)
        history_attributes.each do |attribute|
          self.history_associations[attribute] = history_association
          self.history_models[attribute] = history_model
        end
      end

      def setup_history_callback(history_attributes, history_model)
        after_update do
          HistorySaver.new(self, history_attributes, history_model)
                      .save_if_needed
        end
      end

      def define_attribute_on_date_methods(history_attributes)
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
