flashMessagesFunctions = () ->

  clearFlashMessages = () ->
    setTimeout( ()->
      $('.flash-messages').addClass('fadeOut')
    , 3000)
    setTimeout( ()->
      $('#flash-messages-container').html("")
    , 3000)

  if $('.flash-messages').length > 0
    clearFlashMessages()

$(document).on 'turbolinks:load', flashMessagesFunctions
