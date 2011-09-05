VRD.fbInit = new Tal.Event(once: true);
VRD.fbInit.once = true;
window.fbAsyncInit = ->
  FB.init({appId: VRD.fbAppID, status: true, cookie: true, xfbml: true});
  VRD.fbInit.fire();

(->
  e = document.createElement('script');
  e.async = true;
  e.src = document.location.protocol +
    '//connect.facebook.net/en_US/all.js';
  document.getElementById('fb-root').appendChild(e);
)()

VRD.fbInit.push ->
  if session = FB.getSession()
    VRD.setFbSession(session)
  else
    VRD.logout.ev.fire()

VRD.logout = ->
  dfd = $.ajax
    url: '/logout.json',
    type: 'POST',
    dataType: 'json'
  VRD.fbInit.push FB.logout
  dfd.success (data) ->
    VRD.logout.ev.fire()

VRD.logout.ev = new Tal.Event(once: true)
VRD.logout.ev.bind ->
  $('#member_bar .login').remove()
  $('#member_bar .logout').remove()
  $('#member_bar').append("""<a href="#" class="login">Login</a>""")

VRD.login = ->
  VRD.fbInit.push ->
    FB.login (data) ->
      if data.status is 'connected'
        VRD.setFbSession data.session

VRD.login.ev = new Tal.Event(once: true)
VRD.login.ev.bind ->
  $('#member_bar .login').remove()
  $('#member_bar .logout').remove()
  $('#member_bar').append("""<a href="#" class="logout">Logout</a>""")

VRD.setFbSession = (session) ->
  dfd = $.ajax
    url: '/login.json',
    type: 'POST',
    dataType: 'json',
    data: {fb_session: session}
  
  dfd.success (data) ->
    VRD.login.ev.fire data

$('body').delegate '.login', 'click', (ev) ->
  ev.preventDefault()
  VRD.login()
$('body').delegate '.logout', 'click', (ev) ->
  ev.preventDefault()
  VRD.logout()

