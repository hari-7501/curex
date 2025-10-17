class User < ApplicationRecord
    validates :first_name, :last_name, presence: true, length: { minimum: 3 }
    validates :age, presence: true, numericality: { only_integer: true, less_than: 120, greater_than: 0 }
    validates :mobile, presence: true, uniqueness: true, length: { is: 10 }

    has_many :wallets, foreign_key: :user_id
    has_many :sent_transactions, class_name: 'Transaction', foreign_key: :sender_user_id
    has_many :received_transactions, class_name: 'Transaction', foreign_key: :receiver_user_id
end
