exports.index = (request, response)->
  email = request.body.email
  response.render('chat', {email: email})
