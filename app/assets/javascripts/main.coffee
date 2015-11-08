# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
jQuery ->
  $('body').delegate "a[data-js], button[data-js], input[data-js]", 'click', (e) ->
    e.preventDefault()
    message = $(this).data('confirm-message')
    action = $(this).data('js')
    if message
      $.showConfirm action, message
    else
      eval(action)
