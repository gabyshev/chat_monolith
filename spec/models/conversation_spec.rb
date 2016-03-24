require 'rails_helper'

RSpec.describe Conversation, type: :model do
  let(:sender) { create :user }
  let(:recipient) { create :user }

  describe '#validations' do
    it { should validate_presence_of(:recipient) }
    it { should validate_presence_of(:sender) }
  end

  describe '#associations' do
    it { should have_many(:messages) }

    it 'sender and recipient can\'t be same' do
      conversation = Conversation.new(sender: sender, recipient: sender)
      expect(conversation).to_not be_valid
    end

    it 'sender and recipient are different' do
      conversation = Conversation.new(sender: sender, recipient: recipient)
      expect(conversation).to be_valid
    end

    context '.between' do

    end
  end
end
