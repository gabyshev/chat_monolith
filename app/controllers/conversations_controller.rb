class ConversationsController < ApplicationController
  def index
    @conversation = current_user.conversations
  end
end
