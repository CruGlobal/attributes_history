module AttributesHistory
  class HistoryRetriever
    def initialize(object)
      @object = object
      @cached_history = {}
    end

    def attribute_on_date(attribute, date)
      history_entry = @cached_history[date] ||= find_entry_on(date)
      history_entry.public_send(attribute)
    end

    private

    def find_entry_on(date)
      @object.public_send(@object.history_association)
        .where('recorded_on > ?', date).order(:recorded_on).first || @object
    end
  end
end
