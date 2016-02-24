class ConversationsController < ApplicationController
  respond_to :json

  def index
    # Показать всех с пользователей с кем можно переписываться кроме текущего пользователя
    @users = User.where.not(id: current_user.id)
  end

  def create
    sender    = User.find(params[:sender_id])
    recipient = User.find(params[:recipient_id])

    # Conversation.between проверяет есть ли существующий чат между 2мя пользоателями
    # независимо от того кто первый создал чат, если такого нет то создает его
    @conversation = unless Conversation.between(sender.id, recipient.id).empty?
      Conversation.between(sender.id, recipient.id).first
    else
      Conversation.create(sender: sender, recipient: recipient)
    end
    render json: { id: @conversation.id }
  end
end
