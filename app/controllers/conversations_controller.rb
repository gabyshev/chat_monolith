class ConversationsController < ApplicationController
  respond_to :json

  def index
    # Show all users expect current because user can't chat with himself
    @users = User.where.not(id: current_user.id)
  end

  def create
    sender    = User.find(params[:sender_id])
    recipient = User.find(params[:recipient_id])

    # Conversation.between checks if there already existing conversation between two users
    # There is no dependency on who's first wrote to other
    @conversation = unless Conversation.between(sender.id, recipient.id).empty?
      Conversation.between(sender.id, recipient.id).first
    else
      Conversation.create(sender: sender, recipient: recipient)
    end
    render json: { id: @conversation.id }
  end
end
