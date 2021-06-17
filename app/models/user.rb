class User < ApplicationRecord
  # encrypt password
  has_secure_password

  # Model associations
  # rubocop:disable Rails/InverseOf
  has_many :todos, dependent: :destroy, foreign_key: :created_by
  # rubocop:enable Rails/InverseOf

  # Validations
  validates :name, :email, :password_digest, presence: true
end
