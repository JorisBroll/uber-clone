#class JSON_to_input
	#constructor: (@json_string) ->

	#transform: (json_string) ->
	#	console.log json_string
	#	json_object = JSON.parse json_string

	#	inputs = []
	#	inputs.push @make_input value for value in json_object
	#	return inputs


	#make_input: (value) ->
	#	a = @container.clone()
	#	a.find('input[name="course[stops][]"]').val(value)
	#	return a

	#output: ->
	#	@transform @json_string

	

$(".courses.edit, .courses.new").ready ->

	#if(stopsValues = stop.val())
	#	stop.val('').attr('value', '')
	#	stopInputs_from_json = new JSON_to_input stopsValues
	#	stopInputs_from_json.container = stopContainer.clone()
	#	$('label[for="course_stops"]').after(stopInputs_from_json.output())
	#stopContainer.detach()

	# Init 
	stopContainer = $(".stop-container:first").clone()
	stop = stopContainer.find('input')
	stop.val('').attr('value', '')

	init.push ->
		datepickerOptions =
			daysOfWeekDisabled: "6"
			todayHighlight: true

		timepickerOptions =
			minuteStep: 1
			showMeridian: false

		$('.date').datepicker
		$('.time').timepicker timepickerOptions


	# Events
	$("body").on "click", "#add-stops", ->
		stopContainer_tmp = stopContainer.clone()
		$('label[for="course_stops"]').after(stopContainer_tmp)

	$("body").on "click", ".stop-container .close-btn", ->
		$(this).closest(".stop-container").remove()
