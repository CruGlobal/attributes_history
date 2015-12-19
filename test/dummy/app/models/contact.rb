class Contact < ActiveRecord::Base
  has_versions_by_date for_attributes: [:status, :pledge_amount],
                       with_model: PartnerStatusLog
end
