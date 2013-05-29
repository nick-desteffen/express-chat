ExpressChat = {}
ExpressChat.View = Backbone.View.extend

  el: "#application"

  events:
    "click input[type='submit']": "sendMessage"

  initialize: ()->
    room = $("#room").val()
    _.each window.messages, (message)=>
      @renderMessage(message)

    @faye = new Faye.Client('/faye')
    subscription = @faye.subscribe "/chat-messages/#{room}", (message)=>
      @renderMessage(message)

    @setupProfile()

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

  setupProfile: ()->
    if window.profile?.entry
      @profile = window.profile.entry[0]
      if @profile.name
        @name = @profile.name.formatted
      else
        @name = @profile.displayName

      @location = @profile.currentLocation || 'Unknown'
    else
      @name = "Anonymous"
      @location = "Unknown"

    $("#name").text("#{@name} (#{@location})")

$ ()->
  window.application = new ExpressChat.View()
