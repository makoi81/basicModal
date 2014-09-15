this.modal =

	_valid: (data) ->

		if data?

			###
			# Set defaults
			###

			if not data.body? then		data.body = ''
			if not data.class? then		data.class = ''
			if not data.closable? then	data.closable = true

			if data.buttons?.action?

				if not data.buttons.action.class? then	data.buttons.action.class = ''
				if not data.buttons.action.title? then	data.buttons.action.title = 'OK'

			if data.buttons?.cancel?

				if not data.buttons.cancel.title? then	data.buttons.cancel.title = 'Cancel'

			else

				data.buttons.action.class += ' button--full'

			return true

		return false

	_build: (data) ->

		html =	"""
				<div class='modalContainer fadeIn' data-closable='#{ data.closable }'>
					<div class='modal fadeIn #{ data.class }'>
						#{ data.body }
				"""

		if data.buttons?.cancel?
			if data.class.indexOf('login') is -1
				html += "<a id='cancel' class='button'>#{ data.buttons.cancel.title }</a>"
			else
				html += "<div id='cancel' class='button'><a class='ion-close' href='#'></a></div>"

		if data.buttons?.action?
			html += "<a id='action' class='button #{ data.buttons.action.class }'>"
			if data.buttons?.action?.icon? then html += "<span class='#{ data.buttons.action.icon }'></span>"
			html += "#{ data.buttons.action.title }</a>"

		html +=	"""
					</div>
				</div>
				"""

		return html

	_getValues: ->

		values = null

		if $(".modalContainer input, .modalContainer .dropdown").length isnt 0

			values = {}

			$(".modalContainer input").each ->
				name	= $(this).attr('data-name')
				value	= $(this).val()
				values[name] = value

			$(".modalContainer .dropdown").each ->
				name	= $(this).attr('data-name')
				value	= $(this).attr('data-value')
				values[name] = value

		return values

	_bind: (data) ->

		# Bind cancel button
		if data.buttons?.cancel?.fn?
			$('.modalContainer #cancel').click data.buttons.cancel.fn

		# Bind action button
		if data.buttons?.action?.fn?
			$('.modalContainer #action').click -> data.buttons.action.fn modal._getValues()

		# Bind input
		$('.modalContainer input').keydown -> $(this).removeClass 'error'

		###
		# Bind dropdown
		###

		dropdownTimeout = null

		$('.modal .dropdown .front').click ->

			dropdown = $(this).parent()

			clearTimeout dropdownTimeout

			dropdown.find('.back').show()
			dropdown.addClass 'flip'

		$('.modal .dropdown .back ul li[class!="separator"]').click ->

			dropdown = $(this).parent().parent().parent()

			value = $(this).clone()
			value.find('span').remove()
			value = value.html().trim()

			dropdown.find('.front span').html value
			dropdown.attr 'data-value', $(this).data('value')
			dropdown.removeClass 'flip'
			dropdownTimeout = setTimeout ->
				dropdown.find('.back').hide()
			, 3000

	show: (data) ->

		# Validate data
		return false if not modal._valid data

		# Remove open modal
		if $(".modalContainer").length isnt 0
			modal.close true
			setTimeout ->
				modal.show data
			, 301
			return false

		# Build and append
		$('body').append modal._build(data)

		# Bind elements
		modal._bind data

		# Call callback
		if data.callback?
			callback()
			return true

		return true

	error: (input) ->

		# Reactive button
		$('.modalContainer #action').removeClass 'active'

		# Remove old error
		$('.modalContainer input, .modalContainer .dropdown').removeClass 'error'

		# Focus input
		$(".modalContainer input[data-name='#{ input }'], .modalContainer .dropdown[data-name='#{ input }']")
			.addClass 'error'
			.focus().select()

		# Shake
		$('.modalContainer .modal').removeClass 'fadeIn shake'
		setTimeout ->
			$('.modalContainer .modal').addClass 'shake'
		, 1

	visible: ->

		if $('.modalContainer').length is 0 then return false
		return true

	action: ->

		if $('.modalContainer .modal #action').length isnt 0

			$('.modalContainer .modal #action').click()
			return true

		return false

	cancel: ->

		if $('.modalContainer .modal #cancel').length isnt 0

			$('.modalContainer .modal #cancel').click()
			return true

		return false

	close: (force) ->

		###
		Close modal if force is not set or true,
		or mouse is not over modal.
		###
		if	not force? or
			force is true

				# Don't close when not closable
				return false if $('.modalContainer[data-closable=true]').length is 0 and force isnt true

				$('.modalContainer').removeClass('fadeIn').addClass('fadeOut')
				setTimeout ->
					$(".modalContainer").remove()
					return true
				, 300

				return true

		return false