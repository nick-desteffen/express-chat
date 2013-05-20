crypto = require('crypto')
redis  = require('redis')

db = redis.createClient()

exports.index = (request, response)->
  email = request.body.email
  baseURL = "https://secure.gravatar.com/avatar/"
  gravatar = baseURL + crypto.createHash('md5').update(email.toLowerCase().trim()).digest('hex')

  db.llen "chat", (error, message_count)->
    db.lrange "chat", 0, message_count, (error, messages)->
      response.render('chat', {email: email, gravatar: gravatar, messages: messages})

exports.message = (request, response)->
  email   = request.body.email
  message = request.body.message

  payload = {
    email:   email,
    message: message
  }

  db.lpush('chat', JSON.stringify(payload))

  response.send(200)
