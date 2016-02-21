# вебсокет клиент, который предоставляет одноименный гем
window.client = new Faye.Client('/faye')

# расширение для Faye чтобы вшивать в каждый вебсокет запрос Base64 представление CSRF токена
client.addExtension
  outgoing: (message, callback) ->
    message.ext = message.ext || {}
    message.ext.csrfToken = $('meta[name=csrf-token]').attr('content')
    callback(message)

Chat = {}

class Chat.UI
  constructor: (@user_list) ->
    @bindStartConversation(@user_list)

  # вешаем событие на клик по email'у пользователя
  bindStartConversation: ->
    self = @
    @user_list.find(".start_chat").click ->
      # если существует подписка отменяем ее
      window.subscription.cancel() if window.subscription
      self.fetchConversation($(@)).done(
        (conversation) ->
          # рисуем окно чата
          conversation.renderChatWindow()
          # запрашиваем с сервера сообщения и отрисовываем их
          conversation.renderMessages()
      )

  # запрос на сервер чтобы получить ID'шник чата между пользователями
  # когда приходит ответ от сервера создаем объект Chat.Conversation
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

# Объект "Чат между пользователями"
# при инициализации срразу же создается подписка на канал вида "/conversation/#{@id}"
# где @id - это id'шник модели Conversation с сервера
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

  # Сообщение состоит из body и from
  # На самом деле туда можно было бы передавать больше информации, например Дата создания сообщения и никнейм пользователя
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
