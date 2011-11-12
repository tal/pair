# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$('.item.voteable .body').each ->
  $this = $(this)
  $this.click (ev) -> ev.preventDefault()
$('.vote_action.skip .overlay').animate {width: 0}, 2000, ->
  fn = (ev) ->
    ev.preventDefault()
    $this = $(this)
    url = $this.attr("href")
    dfd = $.post(url+'.json')
    dfd.success (data) ->
      document.location.href = "/#{data.group_key}/vote"
  $('.vote_action.skip').one('click', fn)
  $('.item.voteable .body').addClass('clickable').unbind('click').one('click', fn)
