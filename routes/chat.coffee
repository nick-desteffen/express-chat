crypto = require('crypto')

exports.index = (request, response)->
  email = request.body.email
  baseURL = "https://secure.gravatar.com/avatar/"
  gravatar = baseURL + crypto.createHash('md5').update(email.toLowerCase().trim()).digest('hex')

  response.render('chat', {email: email, gravatar: gravatar})
