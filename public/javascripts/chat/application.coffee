ExpressChat = {}
ExpressChat.View = Backbone.View.extend

  el: "#application"

  events:
    "click .submit": "sendMessage"

  initialize: ()->
    _.each window.messages, (message)->
      $("#messages").append("<p>#{message.message}</p>")

  sendMessage: (event)->
    event.preventDefault()
    message = @$el.find("#message").val()
    email   = @$el.find("#email").val()

    $.ajax '/message',
      data: {email: email, message: message},
      type: 'POST',
      success: (a,b,c)->
        alert("Success!")

$ ()->
  window.application = new ExpressChat.View()
