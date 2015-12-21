# AttributesHistory

Date-granular history for specified model fields. Compact & easy to query.

[![Build Status](https://travis-ci.org/CruGlobal/attributes_history.svg)](https://travis-ci.org/CruGlobal/attributes_history)

## Usage

Include the gem: 

`gem 'attributes_history'`

Call `has_attributes_history for: [attributes], with_model: AttributesLog` where
`attributes` are the ones you want to track and `AttributesLog` will contain the
history entries. Your `AttributesLog` model should have a field `recorded_on`
which tracks the date when those attributes changed to the values in the next
recorded entry (or to the current attribute values).

## Example

Here's an example of how you could track the `status` and `pledge` fields
for a ministry donor contact in a `PartnerStatusLog` table. This would then allow
you to easily query the ministry partner's status and commitment information
over time.

```
class Contact < ActiveRecord::Base
  has_attributes_history for: [:status, :pledge], with_model: PartnerStatusLog
end
```

Here would be the `ParterStatusLog` model and relevant migrations:

```
class PartnerStatusLog < ActiveRecord::Base
end

class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.string :name
      t.string :status
      t.decimal :pledge
    end
  end
end

class CreatePartnerStatusLogs < ActiveRecord::Migration
  def change
    create_table :partner_status_logs do |t|
      t.integer :contact_id, null: false
      t.date :recorded_on, null: false
      t.string :status
      t.decimal :pledge
    end

    add_index :partner_status_logs, :contact_id
    add_index :partner_status_logs, :recorded_on
  end
end
```

## Retrieving past values with  `attribute_on_date` methods

To make retrieving previous values easy, `attributes_history` defines an
`attribute_on_date(attribute, date)` method, as well as specific 
`#{attribute}_on_date` method for each of your histroy-tracked attributes
which returns that value on the specified date based on the log.

For instance, in the ministry partner history example, there would
be methods `status_on_date` and `pledge_on_date` that would return the
`status` or `pledge` for a contact for that given date. You could also call
`attribute_on_date(:pledge, date)` to get the pledge value for a given date.

The log is granular by date and so it makes the assumption that a change
any time during a date is effective for the whole of that date. The
`attribute_on_date` methods will use caching so if you look up multiple fields on
the same date only one query will be performed.

## Querying the log table directly

You can also query the history log table directly. The `recorded_on` field in the
table represents the date that set of attributes was replaced by a new
set, either in a subsequent history record, or in the object itself.

So to look up the version for a particular date, do a query like this:
```
current_version = contact.partner_status_logs
  .where('recorded_on > ?', date).order(:recorded_on).first || contact
```
That will give either a `PartnerStatusLog` instance for the past, or the current
`Contact` instance for the present record, both of which will respond to the
history-tracked attributes of `status` and `pledge`.

This is similar to how [paper_trail](https://github.com/airblade/paper_trail)
works in that the versions represent past data, and only the current regular
model record (contact in this case) has the current state.

## Multiple `has_attributes_history` calls per class

If you want to have some attributes (or groups of attributes) stored in
different tables grouped by semantic meaning or because their size or rate of
change is different, you can specify multiple `has_attributes_history` calls per
class. The lists of attributes for the different calls can't have any
overlapping attributes though or that will confuse the lookup logic.

Here's an example of tracking `notes` in a separate log from `status` and
`pledge`:

```
class Contact < ActiveRecord::Base
  has_attributes_history for: [:status, :pledge], with_model: PartnerStatusLog
  has_attributes_history for: [:notes], with_model: ContactNotesLog
end
```

## Enabling and disabling

By default the history logging is enabled once you set it up, but you can
disable it by setting `AttributesHistory.enabled = false` (and reset it back to
`true` also).

## Testing with RSpec

For testing with RSpec, you can `require 'attributes_history/rspec'` which will
disable attribute history by default in your specs unless you specify
`versioning: true` in the spec metadata, or you explicitly set
`AttributesHistory.enabled = true`.

## Designed to complement (not replace) a full audit trail

This is intended to augment a full audit trail solution like
[paper_trail](https://github.com/airblade/paper_trail). The advantage of a full
audit trail is that you track every change in a consistent way across models.

But it's possible for the full audit trail to become large and it's often stored in
a less easily queryable way (object data stored in a generic `object` field as
YAML/JSON).

If you use auto-saving or make single attribute changes easy, then you may get a
lot of updates in the same day which semantically represent a single update.

This `attributes_history` gem allows you to choose a subset of fields for a
particular model that will be tracked with at most one new version per day to
limit growth and make time-series displaying of the versions easier. And is
designed to store the versions in specialized table(s) per model with fields that
parallel those in the model itself so you can more easily query the historical
fields.

## Acknowledgement and License

Credit to [Spencer Oberstadt](https://github.com/soberstadt) for coming up with
the idea of versioning our partner status log with date level granularity to
keep it compact and easy to query.

AttributesHistory is [MIT Licensed](https://github.com/CruGlobal/attributes_history/blob/master/MIT-LICENSE).
