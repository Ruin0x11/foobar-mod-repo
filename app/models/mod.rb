class Mod < ApplicationRecord
  belongs_to :user

  has_many :versions, dependent: :destroy
  has_one :latest_version, -> { where(latest: true).order(:position) }, class_name: "Version", inverse_of: :mod

  RESERVED_IDS = [
    "core",
    "base",
    "script",
    "console"
  ]

  validates :user, presence: true
  validates :identifier, uniqueness: true
  validates :identifier, format: { with: /\A[a-z][a-z0-9_]*\z/, message: :mod_identifier }
  validate :does_not_have_reserved_identifier

  paginates_per 20

  def to_s
    latest_version.try(:name) || identifier
  end

  alias name to_s

  def downloads
    latest_version.try(:download_count) || 0
  end

  def payload(version = versions.most_recent)
    deps = version.dependencies.to_a
    {
      'id'                => identifier,
      'name'              => name,
      'downloads'         => downloads,
      'version'           => version.number,
      'version_downloads' => version.download_count,
      'authors'           => version.authors,
      'summary'           => version.summary,
      'licenses'          => version.licenses,
      'dependencies'      => deps.select { |m| m.mod },
    }
  end

  def as_json(*)
    payload
  end


  def does_not_have_reserved_identifier
    errors.add :identifier, message: :mod_reserved_identifier if RESERVED_IDS.any? identifier
  end

  def first_created_date
    versions.by_earliest_created_at.first.created_at
  end

  def reorder_versions
    bulk_reorder_versions

    if last = versions.sort.last
      last.update_column(:latest, true)
    end
  end

  def bulk_reorder_versions
    numbers = reload.versions.sort.reverse.map(&:number).uniq

    ids = []
    positions = []
    versions.each do |version|
      ids << version.id
      positions << numbers.index(version.number)
    end

    update_sql = <<SQL
update versions
    set position = positions_data.position,
                   latest = false
    from (select unnest(array[?]) as id,
         unnest(array[?]) as position) as positions_data
    where versions.id = positions_data.id
SQL
    update_query = [update_sql, ids, positions]

    sanitized_query = ActiveRecord::Base.send(:sanitize_sql_array, update_query)
    ActiveRecord::Base.connection.execute(sanitized_query)
  end
end
