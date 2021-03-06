window.gmapLoaded = ->
    $(window).trigger('gmap-loaded')
    #alert 'gmap-loaded'

loadGmaps = ()->
	# Google MAPS Asynchrone
	script = document.createElement 'script'
	script.type = 'text/javascript'
	script.src = 'https://maps.googleapis.com/maps/api/js?v=3.exp&callback=gmapLoaded&libraries=geometry'
	document.head.appendChild(script)

jQuery ->
	loadGmaps()
	$('.notifications-list').notificationsManager();