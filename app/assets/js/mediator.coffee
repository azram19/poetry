###
This class is responsible for delegating events in modules.
Its main role is to provide communication between routers and interested
modules
###
class Mediator
  constructor: ( @modules ) ->
    @channel = window.Poetry.channel

  getChannel: =>
    #Limit channel API to triggerring events
    self = @
    return {
      'trigger' : (ev, d, d1, d2, d3) ->
        self.channel.trigger ev, d, d1, d2, d3
    }
  eventHandler: ( eventName ) =>
    console.log "[Mediator] - event", eventName

    eventPath = pathElements = eventName.split ":"
    eventPath = _.filter eventPath, ( path ) ->
      path isnt '/' and path isnt ''

    eventArguments = arguments

    ###
    handles an event by breaking a path inside the event -
    "cat:dog:monkey" by calling a function (only one)

    1. handlers is a function and gets called
    2. handlers is an object
      a) handlers.cat.dog.monkey()
      b) path is broken at some point
        i) handlers.cat()
        ii) handlers.cat.dog.default()

    ###
    handleEvent = ( moduleName, module ) =>
      #get a handler object from the module
      handlers = module.handlers

      #if it is a function - call it and pass all the arguments
      if _.isFunction handlers
        handlers eventArguments
      else
        #break the path into subelements
        currentHandler = handlers

        (
          ###
          If there is an element matching our subpath, enter the subpath and
          continue processing.
          Otherwise call default handler for this step.
          ###
          if currentHandler[pathEl]?

            currentHandler = currentHandler[pathEl]

            #console.log "[Mediator]", currentHandler

            if _.isFunction currentHandler
              #console.log "[Mediator] - call", currentHandler
              currentHandler.apply null, eventArguments
              break
            else if i == eventPath.length - 1
              currentHandler.default?.apply null, eventArguments
              break

          else
            currentHandler.default?.apply null, eventArguments
            break ) for pathEl, i in eventPath
      null

    #call handleEvent on each module registered in dontbeazebra
    for moduleName, module of @modules
      handleEvent moduleName, module

    null

  start: () =>
    #Captures all events and processes the internally
    @channel.on "all", @eventHandler

#Export to the global scope
window.Mediator = Mediator
