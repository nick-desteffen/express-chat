ExpressChat = {}
ExpressChat.View = Backbone.View.extend

  el: "#application"

  events:
    "click input[type='submit']": "sendMessage"

  initialize: ()->
    @room = $("#room").val()

    window.messages.sort (a, b) ->
      a = moment(a.timestamp).toDate()
      b = moment(b.timestamp).toDate()
      (if a < b then -1 else (if a > b then 1 else 0))

    _.each window.messages, (message)=>
      @renderMessage(message)

    _.each window.people, (person)=>
      @renderPerson(person)

    @faye = new Faye.Client('/faye')
    @messagesSubscription = @faye.subscribe "/chat-messages/#{@room}", (message)=>
      @renderMessage(message)

    @peopleSubscription = @faye.subscribe "/people/#{@room}", (person)=>
      @renderPerson(person)

  sendMessage: (event)->
    event.preventDefault()
    emailField   = @$el.find("#email")
    messageField = @$el.find("#message")
    roomField    = @$el.find("#room")

    payload = {
      email:    emailField.val(),
      body:     messageField.val(),
      name:     @name,
      location: @location,
      room:     roomField.val()
    }

    messageField.val("")
    $.post '/message', payload

  renderMessage: (message)->
    html = new EJS(url: '/javascripts/chat/_message.ejs').render(message: message)
    $("#messages").append(html)

  renderPerson: (person)->
    unless $("#people").find("[data-email='#{person.email}']").length > 0
      html = new EJS(url: '/javascripts/chat/_person.ejs').render(person: person)
      $("#people").append(html)

$ ()->
  window.application = new ExpressChat.View()
