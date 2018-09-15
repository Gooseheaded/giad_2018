client
	var
		fullscreen = 0
		lastWindowX = 980
		lastWindowY = 540

	verb
		FullScreen()
			set hidden = 1

			if(fullscreen)

				fullscreen = 0

				winset(src, "default", "border=line")
				winset(src, "default", "titlebar=true")
				winset(src, "default", "can-resize=true")
				winset(src, "default", "is-maximized=false")
				winset(src, "default", "size=[lastWindowX]x[lastWindowY]")
				return

			var/sizeStr = winget(src, "default", "size")
			var/nWindowX = text2num(substringTo(sizeStr,"x"))
			var/nWindowY = text2num(substringPast(sizeStr,"x"))

			if(nWindowX != 0)
				lastWindowX = nWindowX
			if(nWindowY != 0)
				lastWindowY = nWindowY

			winset(src, "default", "menu=")
			winset(src, "default", "border=sunken")
			winset(src, "default", "titlebar=false")
			winset(src, "default", "can-resize=false")
			winset(src, "default", "is-maximized=true")

			fullscreen = 1