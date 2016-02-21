# отправляем сообщение в канал чата с информациоей о свежесозданном сообщении
publisher = client.publish "/conversation/<%= @conversation.id %>",
  body: "<%= @message.body %>",
  from: "<%= @message.user.email %>"

# в случае ошибки показываем алерт
publisher.errback () ->
  alert "We got some problems. Try later."

# очищаем форму, чтобы можно было дальше вводить сообщения
$('#new_message')[0].reset();
