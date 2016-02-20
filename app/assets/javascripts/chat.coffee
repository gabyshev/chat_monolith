window.client = new Faye.Client('/faye')

client.addExtension
  outgoing: (message, callback) ->
    message.ext = message.ext || {}
    message.ext.csrfToken = $('meta[name=csrf-token]').attr('content')
    callback(message)

Chat = {}

class Chat.UI
  constructor: (@user_list) ->
    @bindStartConversation(@user_list)

  bindStartConversation: ->
    self = @
    @user_list.find(".start_chat").click ->
      window.subscription.cancel() if window.subscription
      self.fetchConversation($(@)).done(
        (conversation) ->
          conversation.renderChatWindow()
          conversation.renderMessages()
      )

  fetchConversation: (user) ->
    sender_id    = user.data 'sender-id'
    recipient_id = user.data 'recipient-id'
    $.post
      url: '/conversations'
      data:
        recipient_id: recipient_id
        sender_id: sender_id
    .then(
      (response) ->
        new Chat.Conversation(response.id, sender_id, recipient_id)
    )

class Chat.Conversation
  constructor: (@id, @sender_id, @recipient_id) ->
    self = @
    @chat = $('#chat')
    window.subscription = client.subscribe "/conversation/#{@id}", (message) ->
      self.chat.find('ul').append(
        "<li>#{message.body}  <i>#{message.from}</i></li>"
      )

  renderChatWindow: =>
    @chat
      .empty()
      .append("<ul> </ul>
        <form class='new_message' id='new_message' action='/conversations/#{@id}/messages' accept-charset='UTF-8' data-remote='true' method='post'>
          <input name='utf8' type='hidden' value='✓'>
          <input type='hidden' name='message[user_id]' value='#{@sender_id}'>
          <input type='text' name='message[body]' id='message_body'>
          <input type='submit' name='commit' value='Send'>
        </form>")

  renderMessages: =>
    @fetchMessages().done(
      (response) =>
        for index, message of response
          @chat.find('ul').append(
            "<li>#{message.body}  <i>#{message.from}</i></li>"
          )
    )

  fetchMessages: =>
    $.get
      url: "/conversations/#{@id}/messages"
    .then((response) -> response)

$ ->
  chat = new Chat.UI($(".user_list"))
  chat.bindStartConversation
