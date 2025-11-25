class Wallet < ApplicationRecord
    validates :user_id, :currency, presence: true
    validates :balance, presence: true, numericality: { greater_than_or_equal_to: 0 }

    self.primary_keys = :user_id, :currency

    belongs_to :user
end
