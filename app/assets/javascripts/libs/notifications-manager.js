!function( $ ) {

	var notificationsManager = function(element, options) {
		this.element = $(element);
		this.notifications = this.element.find('.notification')
		this.label = this.element.closest('.dropdown-menu').siblings('.dropdown-toggle').find('.label')
		this.default_notification_layout = $('<div/>', {'class': 'notification'}).append($('<div/>', {'class': 'notification-title'})).append($('<div/>', {'class': 'notification-description'})).append($('<div/>', {'class': 'notification-ago'})).append($('<div/>', {'class': 'notification-icon fa'}))



			/*<div class="notification">
											<div class="notification-title"></div>
											<div class="notification-description"></div>
											<div class="notification-ago"></div>
											<div class="notification-icon fa" ></div>
										</div>*/

		this.init();
	};

	notificationsManager.prototype = {
		constructor: notificationsManager,

		init: function() {
			var _this = this;
			this.eventsListeners();
			this.print('counter');
			this.timestamp = new Date();
			this.timer = null;
			this.interval = 10000;
			timer = setInterval(function(){_this.element.trigger('ajax.notification.get_all')}, this.interval);
		},

		eventsListeners: function() {
			var _this = this
			this.element.on('click', '.notification', function(e) {
				var element = $(this)
				_this.update('seen', element);
			});
			this.element.on('ajax.notification.set_seen.success', function(e) {
				_this.clickedElement.remove();
				_this.print('counter');
			});
			this.element.on('ajax.notification.get_all', function(e) {
				_this.get('all');
			});
			this.element.on('ajax.notification.get.success', function(e) {
				_this.print('list')
			});
		},
		get: function(id) {
			var _this = this
			Tools.fastAjax('/ajax/notifications',
	        {
	            notif_action: 'get',
	            id:id
	        }, function(response){_this.list = response; _this.element.trigger('ajax.notification.get.success')});
		},
		update: function(what, element) {
			var _this = this
			switch(what) {
				case 'seen':
					this.clickedElement = element;
					Tools.fastAjax('/ajax/notifications',
			        {
			            notif_action: 'set_seen',
			            id: element.attr('data-id')
			        }, function(){_this.element.trigger('ajax.notification.set_seen.success')});
				break;
			}
		},
		print: function(what) {
			switch(what) {
				case 'counter':
					var count = this.getNotifsCounter()
					if (count != 0) {
						this.label.html(count);
						this.label.show();
					}
					else {
						this.label.hide();
					}
				break;
				case 'list':
					this.clean('list');
					this.element.append(this.buildList());
					this.print('counter');
				break;
			}
		},
		clean: function(what) {
			switch(what) {
				case 'list':
					this.element.find('.notification').remove();
				break;
			}
		},
		buildList: function() {
			var buildList = []
			for (var i=0; i<this.list.length; i++) {
				newNotificationDiv = this.default_notification_layout.clone();
				newNotificationDiv.find('.notification-title').text(this.list[i].title)
				newNotificationDiv.find('.notification-description').text(this.list[i].content)
				newNotificationDiv.find('.notification-ago').text(this.list[i].created_at)
				newNotificationDiv.find('.notification-icon').addClass('fa-'+this.list[i].icon).addClass('bg-'+this.list[i].background)
				buildList.push(newNotificationDiv);
			}
			return buildList;
		},
		getNotifsCounter: function() {
			return this.element.find('.notification').length
		}
	}

	$.fn.notificationsManager = function ( option ) {
		return this.each(function () {
			var $this = $(this),
				data = $this.data('notificationsManager'),
				options = typeof option === 'object' && option;
			if (!data)  {
				$this.data('notificationsManager', (data = new notificationsManager(this, $.extend({}, $.fn.notificationsManager.defaults,options))));
			}
			if (typeof option == 'string') {
				data[option]();
			}
		})
	};


	$.fn.notificationsManager.defaults = {
		
	};

	$.fn.notificationsManager.Constructor = notificationsManager;

}( window.jQuery );