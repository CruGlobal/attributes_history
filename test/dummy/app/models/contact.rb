# frozen_string_literal: true

class Contact < ActiveRecord::Base
  has_attributes_history for: %i[status pledge_amount],
                         with_model: PartnerStatusLog

  has_attributes_history for: [:notes], with_model: ContactNotesLog
end
