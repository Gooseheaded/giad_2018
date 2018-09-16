
var/list/messages = new/list()
var/messageTtl = 10 // 10s

proc/displayText(var/text)

	for (var/chatMessage/m in messages)
		world << m
		m.shiftMessageUp()

	var/chatMessage/msg = new()
	initiate_maptext(msg, 0, 0, 512, 64)
	Maptext(msg, txt = text, color = "#ffffff", add_outline = 1, outline_color = "#000000")

	messages.Add(msg)
	for (var/client/c)
		c.screen.Add(msg)

var/textUpdateLoop = FALSE
proc/TextUpdateLoop()
	if (textUpdateLoop) return
	textUpdateLoop = TRUE

	while (TRUE)
		for(var/chatMessage/m in messages)
			m.age ++
			if (m.age >= messageTtl)
				for(var/client/c)
					c.screen.Remove(m)
				del m
		sleep(10)

chatMessage
	parent_type = /obj
	maptext_width = 512
	maptext_height = 96

	var/screen_y = 3
	var/age = 0

	proc/shiftMessageUp(var/amt=1)
		screen_y += abs(amt)
		screen_loc = "9,[screen_y]"

		if (screen_y > 12)
			for(var/client/c)
				c.screen.Remove(src)
				del src

	New(var/text)
		maptext = text
		screen_loc = "9,[screen_y]"

		// Messages last longer the longer the text
		age -= round(length(text) / 5)