require 'rails_helper'

RSpec.describe ConversationsController, type: :controller do
  let!(:user)  { create :user }
  let!(:user1) { create :user }

  describe '#index' do
    context 'unauthorized' do
      it 'should redirect to login page' do
        get :index
        should redirect_to(new_user_session_path)
      end
    end

    context 'authorized' do
      it 'should be success' do
        sign_in user
        get :index
        expect(response.status).to be(200)
        expect(user).to eq(subject.current_user)
      end

      it 'should return users list' do
        sign_in user
        get :index
        expect(assigns(:users)).to eq(User.where.not(id: user.id))
      end
    end
  end

  describe '#create' do
    before(:each) { sign_in user }

    it 'should return conversation id' do
      post :create, sender_id: user.id, recipient_id: user1.id
      expect(response.body).to eq(
        { id: Conversation.between(user.id, user1.id).first.id }.to_json
      )
    end
  end
end
