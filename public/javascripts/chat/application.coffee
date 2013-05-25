ExpressChat = {}
ExpressChat.View = Backbone.View.extend

  el: "#application"

  events:
    "click input[type='submit']": "sendMessage"

  initialize: ()->
    _.each window.messages, (message)=>
      @renderMessage(message)

    faye = new Faye.Client('/faye');
    subscription = faye.subscribe '/chat-messages', (message)=>
      @renderMessage(message)

  sendMessage: (event)->
    event.preventDefault()
    emailField   = @$el.find("#email")
    messageField = @$el.find("#message")

    payload = {
      email: emailField.val(),
      body:  messageField.val()
    }

    messageField.val("")

    $.ajax '/message',
      data: payload,
      type: 'POST',
      success: (data, status, xhr)->
        #@renderMessage(data)

  renderMessage: (message)->
    html = new EJS(url: '/javascripts/chat/_message.ejs').render(message: message)
    $("#messages").append(html)

$ ()->
  window.application = new ExpressChat.View()
