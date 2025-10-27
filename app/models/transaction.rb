class Transaction < ApplicationRecord
    validates :currency_conversion_rate, presence: true
    validates :transaction_amount, presence: true, numericality: { greater_than: 0 }
    validates :currency_conversion_fee, presence: true, numericality: { greater_than_or_equal_to: 0 }
    
    belongs_to :sender_user, class_name: 'User', foreign_key: :sender_user_id, optional: true
    belongs_to :receiver_user, class_name: 'User', foreign_key: :receiver_user_id, optional: true
end
