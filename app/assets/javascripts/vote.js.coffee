# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$('.vote_box').each ->
  $this = $(this)
  $this.click (ev) -> ev.preventDefault()
  $this.find('.overlay').animate {width: 0}, 2000, ->
    $this.unbind('click').one 'click', (ev) ->
      ev.preventDefault()
      $this = $(this).find('a')
      url = $this.attr("href")
      dfd = $.post(url+'.json')
      dfd.success (data) ->
        document.location.href = "/#{data.group_key}/vote"
    
