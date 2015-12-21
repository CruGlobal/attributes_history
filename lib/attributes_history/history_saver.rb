module AttributesHistory
  class HistorySaver
    def initialize(changed_object)
      @object = changed_object
    end

    def save_if_needed
      save_history_entry if ::AttributesHistory.enabled? &&
                            history_attributes_changed?
    end

    private

    def history_attributes_changed?
      (@object.changed & @object.history_attributes).present?
    end

    def save_history_entry
      history_entry = @object.public_send(@object.history_association)
                      .find_or_initialize_by(recorded_on: Date.current)

      # If there is an existing history record for today, just leave it as is,
      # otherwise, save the newly initialized one.
      history_entry.update!(history_params) if history_entry.new_record?
    end

    def history_params
      Hash[@object.history_attributes.map { |f| [f, history_value_for(f)] }]
    end

    def history_value_for(attribute)
      # Use the previous value if it was changed, otherwise the current value
      if attribute.in?(@object.changed)
        @object.changes[attribute].first
      else
        @object.public_send(attribute)
      end
    end
  end
end
