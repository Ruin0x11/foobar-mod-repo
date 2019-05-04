class User < ApplicationRecord
  include Clearance::User

  has_many :mods

  validates :handle, uniqueness: true
  validates :handle, format: { with: /\A[A-Za-z][A-Za-z_\-0-9]*\z/ }
  validates_formatting_of :email, using: :email
  validates :password, length: { within: 10..200 }
end
