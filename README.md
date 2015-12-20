# VersionableByDate

Provides date-granular versioning for specific fields on your models
(query-friendly history log).

## Usage

Include the gem: 

`gem 'versionable_by_date'`

Call `has_versions_by_date` in your model with the option `for_attributes` to
specify the attributes you want to version and `with_model` to specify the
versions model.

The versions model should have fields that match your `for_attributes` fields,
`versioned_on` field for the date, and a foreign key field to link back to your
versioned model.

## Example

Here's an example of how you could track the `status` and `pledge_amount` fields
for a ministry donor contact in a `PartnerStatusLog` table. This would then allow
you to easily query the ministry partner's status and commitment information
over time.

```
class Contact < ActiveRecord::Base
  has_versions_by_date for_attributes: [:status, :pledge_amount],
                       with_model: PartnerStatusLog
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
      t.decimal :pledge_amount
    end
  end
end

class CreatePartnerStatusLogs < ActiveRecord::Migration
  def change
    create_table :partner_status_logs do |t|
      t.integer :contact_id, null: false
      t.date :versioned_on, null: false
      t.string :status
      t.decimal :pledge_amount
    end

    add_index :partner_status_logs, :contact_id
    add_index :partner_status_logs, :versioned_on
  end
end
```

## Retrieving past values with  `#{versioned_attribute}_on_date` methods

To make retrieving previous values easy, the `versionable_by_date` defines a
`#{versioned_attribute}_on_date` method for each of your versioned-by-date
attributes which returns that value on the specified date based on the version
log.

For instance, in the ministry partner contact history example above, there would
be methods `status_on_date` and `pledge_amount_on_date` that would return the
`status` or `pledge_amount` for that given date.

The versioning is granular by date and so it makes the assumption that a change
any time during a date is effective for the whole of that date. The
`field_on_date` methods will use caching so if you look up multiple fields on
the same date only one query will be performed.

## Querying the versions table directly

You can also query the versions table directly. The `versioned_on` field in the
versions table represents the date that set of attributes was replaced by a new
set, either in a subsequent version record, or in the object itself.

So to look up the version for a particular date, do a query like this, assuming
you have a `current_contact_record`:
```
current_version = contact.partner_status_logs
  .where('versioned_on > ?', date).order(:versioned_on).first || contact
```
That will give either a `PartnerStatusLog` instance for the past, or the current
`Contact` instance for the present record, both of which will respond to the
versioned attributes of `status` and `pledge_frequency`.

This is similar to how [paper_trail](https://github.com/airblade/paper_trail)
works in that the versions represent past data, and the current versioned record
represents the current state.

## Enabling and disabling

By default the versioning is enabled once you set it up, but you can disable it
by setting `VersionableByDate.enabled = false` (and reset it back to `true`
also).

## Testing with RSpec

For testing with RSpec, you can `require 'versionable_by_date/rspec'` which will
disable versioning by default in your specs unless you specify `versioning: true`
in the spec metadata, or you explicitly set `VersionableByDate.enabled = true`.

## How it complements a full audit trail (more compact, easier querying)

This is designed to complement a full audit trail solution like
[paper_trail](https://github.com/airblade/paper_trail). The advantage of a full
audit trail is that you track every change in a consistent way across models.

But it's possible for the full audit trail to become large and it's often stored in
a less easily queryable way (object data stored in a generic `object` field as
YAML/JSON).

This `versionable_by_date` gem allows you to choose a subset of fields for a
particular model that will be versioned with at most one new version per day (to
limit growth and make time-series displaying of the versions easier), and is
designed to store the versions in specialized table(s) per model with fields that
parallel those in the model itself.

## License

MIT Licensed.
