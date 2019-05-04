class Dependency < ApplicationRecord
  belongs_to :mod
  belongs_to :version

  before_validation :use_foobar_dependency,
    :use_existing_mod,
    :parse_foobar_dependency

  validates :mod, presence: true
  validates :version, presence: true
  validates :requirements, presence: true

  delegate :name, to: :version
  delegate :identifier, to: :mod

  attr_accessor :foobar_dependency

  def to_s
    "#{name} #{clean_requirements}"
  end

  def payload
    {
      'identifier'   => identifier,
      'requirements' => requirements
    }
  end

  def as_json(*)
    payload
  end

  private

  def use_foobar_dependency
    return if mod

    if foobar_dependency.class != FoobarMod::Dependency
      errors.add :mod, message: :dependency_class
      throw :abort
    end

    if foobar_dependency.identifier.empty?
      errors.add :mod, message: :dependency_blank_id
      throw :abort
    end
  end

  def use_existing_mod
    return if mod

    self.mod = Mod.find_by_identifier(foobar_dependency.identifier)
  end

  def parse_foobar_dependency
    return if requirements

    self.requirements = foobar_dependency.requirements_list.join(', ')
  end
end
