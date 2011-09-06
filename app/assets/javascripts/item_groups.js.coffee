$('#item_group_key').bind 'keyup', (ev) ->
  this.value = this.value.replace(/[\W\-]+/g, '-')
