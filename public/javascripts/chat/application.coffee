ExpressChat = {}
ExpressChat.View = Backbone.View.extend

  el: "#application"

  events:
    "click input[type='submit']": "sendMessage"

  initialize: ()->
    @room = $("#room").val()

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

    $.ajax '/message',
      data: payload,
      type: 'POST',
      success: (data, status, xhr)->
        #@renderMessage(data)

  renderMessage: (message)->
    html = new EJS(url: '/javascripts/chat/_message.ejs').render(message: message)
    $("#messages").append(html)

  renderPerson: (person)->
    unless $("#people").find("[data-email='#{person.email}']").length > 0
      html = new EJS(url: '/javascripts/chat/_person.ejs').render(person: person)
      $("#people").append(html)

$ ()->
  window.application = new ExpressChat.View()
