class MessagesController < ApplicationController
  respond_to :json

  def index
    render json: {}, status: :not_found and return unless conversation
    @messages = conversation.messages
    render json: @messages.map{ |m| { body: m.body, from: m.user.email }}
  end

  def create
    @message = conversation.messages.create(message_params)
  end

  private

  def conversation
    @conversation = Conversation.find(params[:conversation_id])
  rescue ActiveRecord::RecordNotFound
    nil
  end

  def message_params
    params.require(:message).permit(:body, :user_id)
  end

end
