# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$ ->
  $('.vote_action').click (ev) ->
    ev.preventDefault()
    console.log('prev')
    $this = $(this)
    url = $this.attr("href")
    dfd = $.post(url+'.json')
    dfd.success ->
      console.log("Success",arguments)
