# Google MAPS Asynchrone
script = document.createElement 'script'
script.type = 'text/javascript'
script.src = 'https://maps.googleapis.com/maps/api/js?v=3.exp&'+'callback=gmapLoaded'
document.head.appendChild(script)


window.gmapLoaded = ->
    $(window).trigger('gmap-loaded')

jQuery ->
    $('.notifications-list').notificationsManager();