require 'rails_helper'

describe Contact, versioning: true do
  it 'does not make a version if non-versioned fields change' do
    contact = Contact.create
    expect do
      contact.update(name: 'Joe')
    end.to_not change(PartnerStatusLog, :count)
  end

  it 'creates a version when versioned fields (status,  pledge_amount) change' do
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

  it 'makes a new version record if change made on a different day' do
    contact = Contact.create
    travel_to Time.new(2015, 12, 19) do
      expect do
        contact.update(pledge_amount: 10) 
      end.to change(PartnerStatusLog, :count).by(1)
    end
    expect(PartnerStatusLog.last.versioned_on).to eq Date.new(2015, 12, 19)

    travel_to Time.new(2015, 12, 20) do
      expect do
        contact.update(pledge_amount: 20) 
      end.to change(PartnerStatusLog, :count).by(1)
    end
    expect(PartnerStatusLog.last.versioned_on).to eq Date.new(2015, 12, 20)
  end

  it 'only creates versions if enabled is set to true' do
    contact = Contact.create

    VersionableByDate.enabled = false
    expect(VersionableByDate).to_not be_enabled
    expect do
      contact.update(pledge_amount: 1)
    end.to_not change(PartnerStatusLog, :count)

    VersionableByDate.enabled = true
    expect(VersionableByDate).to be_enabled
    expect do
      contact.update(pledge_amount: 2)
    end.to change(PartnerStatusLog, :count).by(1)
  end
end
