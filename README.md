## Sample monolith chat application using websockets

This repo contains first part of assessment. Second part [here](https://github.com/gabyshev/microservices_chat).

### Assessment

Functions:
- User can register in the app.
- User can login in the app.
- Logged user can chat with other users.
- Chat allow user to send and receive messages

Realization:
- one RoR application

###  Realization

There is no requirement about software version, so I have used the latest possible.

Software requirements:
- Ruby 2.3.0
- Rails 4.2.5
- Devise
- Faye
- Docker
- Thin Webserver


- `Devise` for user management.
- Websockets chat with [Faye](faye.jcoglan.com)
- Thin Webserver to be able to support asynchronous requests.
- Application is putted inside Docker container.

Due to testing purposes there are some simplifications:
- application runs in development environment inside docker container
- used standard Sqlite3 database
- no CSS

### Tests

I have used
- `rspec`
- `factory_girl`
- `shoulda-matchers`

To run:

```
  $ rake spec
```

### Logic

For security reasons all frontend websocket requests have CSRF token. That token is decoded on backend side and compared with the value on the server.

#### Backend

User can have several chats with other users.
Chat (or conversion) can consist only 2 members (sender and recipient).
All messages stored in the database.
When the new message is created it is published in websocket channel `/conversion/CONVERSATION_ID`

#### Frontend

Page opened with other user's list.
When user clicks on username several actions will be triggered:
- creation of object `Chat.Conversation`
- render of the chat window
- subscribing to channel `/conversation/CONVERSATION_ID`
- loading stored messages from the database and rendering them in the view

Every new message will be sent to server via AJAX where `publish` event will be triggered and clients subscribed to that channel will receive a new message.

When other chat is opened the previous one is canceled and new subscription is created.

### Running application

```
cd ../path/to/app
docker build --rm -t chat .
docker run -p 80:3000 -d chat
```

If you run application from OS X check your env var `$DOCKER_HOST` and open it.
From Linux just open `localhost`

### Suggested improvements

1. Storing messages in relational database is a bottleneck. Here is what should you do in production environment:
 - cache messages in fast in-memory DB like Redis
 - if your server will experience high load use delayed write to the database
 - if necessary, use Redis database sharding technology
 - do not query all messages, use pagination and query data partially
2. User Interface :)
