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
    expect(PartnerStatusLog.last.recorded_on).to eq Date.new(2015, 12, 19)

    travel_to Time.new(2015, 12, 20) do
      expect do
        contact.update(pledge_amount: 20)
      end.to change(PartnerStatusLog, :count).by(1)
    end
    expect(PartnerStatusLog.last.recorded_on).to eq Date.new(2015, 12, 20)
  end

  it 'only creates versions if enabled is set to true' do
    contact = Contact.create

    AttributesHistory.enabled = false
    expect(AttributesHistory).to_not be_enabled
    expect do
      contact.update(pledge_amount: 1)
    end.to_not change(PartnerStatusLog, :count)

    AttributesHistory.enabled = true
    expect(AttributesHistory).to be_enabled
    expect do
      contact.update(pledge_amount: 2)
    end.to change(PartnerStatusLog, :count).by(1)
  end

  it 'allows retrieval of versioned field values' do
    contact = nil
    travel_to Time.new(2015, 12, 17) do
      contact = Contact.create(pledge_amount: 5, status: 'Partner - Financial')
    end
    travel_to Time.new(2015, 12, 19) do
      contact.update(pledge_amount: 10)
    end
    travel_to Time.new(2015, 12, 21) do
      contact.update(pledge_amount: 20)
    end

    # For dates before the first change, return the original value

    # For a time before the object was created, just default to the first value
    # we have

    days_to_expected_pledge_amounts = {
      # For the 16th (before the object was created), just default to the first
      # value for the object
      16 => 5,

      # On the 17th the object was first created with pledge of 5, and stayed 5
      # on the 18th.
      17 => 5,
      18 => 5,

      # On the 19th it was changed to 10, and stayed that through the 20th
      19 => 10,
      20 => 10,

      # On the 21st it was changed to 20
      21 => 20,

      # For a date after the last change, take the current value
      22 => 20
    }

    days_to_expected_pledge_amounts.each do |day, expected_pledge_amount|
      expect(contact.pledge_amount_on_date(Date.new(2015, 12, day)))
        .to eq expected_pledge_amount
    end

    # Check that status_on also works
    expect(contact.status_on_date(Date.new(2015, 12, 19)))
      .to eq 'Partner - Financial'
  end
end
