require "foobar_mod"

class Version < ApplicationRecord
  belongs_to :mod, touch: true
  has_many :dependencies, dependent: :destroy

  serialize :licenses

  validates :mod, presence: true
  validates :number, uniqueness: { scope: :mod_id }
  validates :number, format: { with: /\A#{FoobarMod::Version::VERSION_PATTERN}\z/ }
  validate :authors_format, on: :create

  after_save :reorder_versions, if: :saved_change_to_id?

  delegate :reorder_versions, to: :mod

  class AuthorType < ActiveModel::Type::String
    def cast_value(value)
      if value.is_a?(Array)
        value.join(', ')
      else
        super
      end
    end
  end
  attribute :authors, AuthorType.new

  def to_s
    number
  end

  def full_name
    "#{mod.identifier}-#{number}"
  end

  def self.latest
    where(latest: true)
  end

  def self.by_earliest_created_at
    order(created_at: :asc)
  end

  def self.most_recent
    latest.order(number: :desc).first || last
  end

  def payload
    {
      'authors'                    => authors,
      'created_at'                 => created_at,
      'summary'                    => summary,
      'download_count'             => download_count,
      'number'                     => number,
      'licenses'                   => licenses,
    }
  end

  def as_json(*)
    payload
  end

  def to_foobar_mod_version
    FoobarMod::Version.new(self)
  end

  def authors_format
    authors = authors_before_type_cast
    return unless authors
    string_authors = authors.is_a?(Array) && authors.grep(String)
    return unless string_authors.blank? || string_authors.size != authors.size
    errors.add :authors, "must be an Array of Strings"
  end

  def <=>(other)
    self_version  = to_foobar_mod_version
    other_version = other.to_foobar_mod_version

    self_version <=> other_version
  end
end
