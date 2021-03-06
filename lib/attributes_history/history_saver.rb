# frozen_string_literal: true

module AttributesHistory
  class HistorySaver
    def initialize(changed_object, history_attributes, history_model)
      @object = changed_object
      @history_attributes = history_attributes
      @history_model = history_model
    end

    def save_if_needed
      save_history_entry if ::AttributesHistory.enabled? &&
                            history_attributes_changed?
    end

    private

    def history_attributes_changed?
      (changes.keys & @history_attributes).present?
    end

    def save_history_entry
      history_association =
        @object.class.history_association(@history_attributes.first)

      history_entry = @object.public_send(history_association)
                             .find_or_initialize_by(recorded_on: Date.current)

      # If there is an existing history record for today, just leave it as is,
      # otherwise, save the newly initialized one.
      history_entry.update!(history_params) if history_entry.new_record?
    end

    def history_params
      Hash[@history_attributes.map { |f| [f, history_value_for(f)] }]
    end

    def history_value_for(attribute)
      # Use the previous value if it was changed, otherwise the current value
      if changes[attribute]
        changes[attribute].first
      else
        @object.public_send(attribute)
      end
    end

    def changes
      if Gem::Version.new(Rails.version) >= Gem::Version.new('5.1.0')
        @object.saved_changes
      else
        @object.changes
      end
    end
  end
end
