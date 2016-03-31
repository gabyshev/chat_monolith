require 'rails_helper'

RSpec.describe MessagesController, type: :controller do
  let(:user)          { create :user }
  let!(:conversation) { create :conversation, sender: user }
  let!(:message)      { create :message, conversation: conversation }
  before(:each)       { sign_in user }

  describe '#index' do
    context 'invalid conversation_id' do
      before(:each) { get :index, conversation_id: 77 }

      it 'returns 404' do
        expect(response.status).to eq(404)
      end

      it 'returns empty json' do
        expect(response.body).to eq '{}'
      end
    end

    context 'valid conversation_id' do
      before(:each) { get :index, conversation_id: conversation.id }

      it 'returns 200' do
        expect(response.status).to eq(200)
      end

      it 'returns messages' do
        messages = conversation.messages.map{ |m| { body: m.body, from: m.user.email }}
        expect(response.body).to eq(messages.to_json)
      end
    end
  end

  describe '#create' do
    it 'does create message' do
      params = {
        conversation_id: conversation.id,
        message: { user_id: user.id, body: 'Sup?' }
      }
      expect {
        post :create, params
      }.to change{ Message.count }.from(1).to(2)
    end
  end
end
