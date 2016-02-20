publisher = client.publish "/conversation/<%= @conversation.id %>",
  body: "<%= @message.body %>",
  from: "<%= @message.user.email %>"

publisher.errback () ->
  alert "We got some problems. Try later."

$('#new_message')[0].reset();
