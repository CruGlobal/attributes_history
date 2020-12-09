module AttributesHistory
  class HistoryRetriever
    def initialize(object)
      @object = object
      @cached_history = {}
    end

    def attribute_on_date(attribute, date)
      history_association = @object.class.history_association(attribute)

      history_entry = @cached_history[[history_association, date]] ||=
                        find_entry_on(history_association, date)

      history_entry.public_send(attribute)
    end

    private

    def find_entry_on(history_association, date)
      @object.public_send(history_association)
             .where('recorded_on > ?', date).order(:recorded_on).first || @object
    end
  end
end
