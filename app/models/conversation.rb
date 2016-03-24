class Conversation < ActiveRecord::Base
  belongs_to :sender, foreign_key: :sender_id, class_name: 'User'
  belongs_to :recipient, foreign_key: :recipient_id, class_name: 'User'
  has_many :messages, dependent: :destroy

  validates_presence_of :sender, :recipient
  validate :recipient_and_sender

  scope :between, -> (sender_id, recipient_id) do
    where(
      "(conversations.sender_id = ? AND conversations.recipient_id =?)
        OR
      (conversations.sender_id = ? AND conversations.recipient_id =?)",
      sender_id, recipient_id, recipient_id, sender_id
    )
  end

  private

  def recipient_and_sender
    errors.add(:base, 'recipient and sender can\'t be same') if sender == recipient
  end
end
