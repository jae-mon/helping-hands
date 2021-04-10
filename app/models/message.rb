class Message < ApplicationRecord
  belongs_to :request
  belongs_to :user

  validates :content, presence: true
  validates :receiver_id, presence: true
end
