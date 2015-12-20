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
  end
end
```

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
