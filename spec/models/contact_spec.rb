require 'rails_helper'

describe Contact do
  # around do |example|
  #   VersionableByDate.enable!
  #   example.run
  #   VersionableByDate.disable!
  # end

  it 'creates a version when relevant fields (status and pledge_amount) change' do
    contact = Contact.create(status: 'Call for Appointment', pledge_amount: nil)

    expect do
      contact.update(status: 'Partner - Financial', pledge_amount: 50)
    end.to change(PartnerStatusLog, :count).by(1)

    log = PartnerStatusLog.last
    expect(log.status).to eq 'Call for Appointment'
    expect(log.pledge_amount).to be_nil
  end

  it 're-uses the existing version record if change made in same day' do
    contact = Contact.create(status: 'Call for Appointment', pledge_amount: nil)

    expect do
      contact.update(pledge_amount: 50)
      expect(PartnerStatusLog.last.status).to eq 'Call for Appointment'
      expect(PartnerStatusLog.last.pledge_amount).to eq nil

      contact.update(status: 'Partner - Financial')
      expect(PartnerStatusLog.last.status).to eq 'Call for Appointment'
      expect(PartnerStatusLog.last.pledge_amount).to eq nil
    end.to change(PartnerStatusLog, :count).by(1)
  end

  it 'makes a new version record if change made in a different day' do
  end

  # it 'does not create a new record when contact update called with same vals' do
  #   contact = create(:contact, status: 'Partner - Financial',
  #                    pledge_frequency: 1, pledge_amount: 50)

  #   expect do
  #     contact.update(status: 'Partner - Financial',
  #                    pledge_frequency: 1, pledge_amount: 50)
  #   end.to_not change(PartnerStatusLog, :count)
  # end

  # it 'does not create a new record when non-partner status fields change' do
  # end
end
