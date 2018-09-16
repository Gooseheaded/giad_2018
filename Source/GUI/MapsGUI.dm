
var
	mapGuiObj[0]

proc
	ShowMap(client/c)
		if(mapGuiObj.len > 0) return CloseMap()

		var/list/toClear = DisplaySlicedHud(c, 'Assets/HUD.dmi', 8,16, 26,2 ,10)
		for(var/obj/o in toClear)
			del mapGuiObj["mapWindow [o.screen_loc]"]
			mapGuiObj["mapWindow [o.screen_loc]"] = o


		var/obj/o

		o = new()
		o.screen_loc = "9,15"
		o.layer = 11
		o.maptext_width = 400
		o.maptext_height = 64
		if (lowertext(copytext(c.key, length(c.key))) == "s")
			o.maptext = MAPTEXT_COLOR + "<b><font size=3>MAP</font></b>"
		else
			o.maptext = MAPTEXT_COLOR + "<b><font size=3>MAP</font></b>"

		del mapGuiObj["routeWindowTitle"]
		mapGuiObj["routeWindowTitle"] = o

		spawn(0)
			while(mapGuiObj.len > 0)
				MapUpdate(c)
				sleep(10)
				sleep(0)

	MapUpdate(client/c, mTag = "mapTag")
		var/obj/MapHudObj/o

		var/sx = 8+1
		var/sy = 2+1

		var/scaleX = (26-8-2) / world.maxx
		var/scaleY = (16-2-2) / world.maxx

		for(var/HomeIsland/S)
			o = new()
			o.icon_state = "home"

			S.PixelCoordsUpdate()
			var/ox = round(S.pX * scaleX)
			var/oy = round(S.pY * scaleY)

			o.screen_loc = "[sx]:[ox],[sy]:[oy]"
			o.mouseText = "Home"

			var/tag = mTag + S.name + "\ref[S]"
			del mapGuiObj[tag]
			mapGuiObj[tag] = o
			c.screen += o


		for(var/Ship/S)
			if(S.isHostile) continue
			o = new()
			o.icon_state = "npc"

			if(S.client)
				o.icon_state = "player"

			S.PixelCoordsUpdate()
			var/ox = round(S.pX * scaleX)
			var/oy = round(S.pY * scaleY)

			o.screen_loc = "[sx]:[ox],[sy]:[oy]"
			o.mouseText = S.name
			o.layer ++

			var/tag = mTag + S.name + "\ref[S]"
			del mapGuiObj[tag]
			mapGuiObj[tag] = o
			c.screen += o


		for(var/Dock/D)
			o = new()
			o.icon_state = "unexplored"

			if(D in discoveredPorts)
				o.icon_state = "dock"
			D.PixelCoordsUpdate()
			var/ox = round(D.pX * scaleX)
			var/oy = round(D.pY * scaleY)

			o.screen_loc = "[sx]:[ox],[sy]:[oy]"
			o.mouseText = D.name

			var/tag = mTag + D.name + "\ref[D]"
			del mapGuiObj[tag]
			mapGuiObj[tag] = o
			c.screen += o


	CloseMap()
		for(var/i in mapGuiObj)
			del mapGuiObj[i]

		mapGuiObj.Cut()


obj
	MapHudObj
		icon = 'MapGui.dmi'
		layer = 15
		var/mouseText

		maptext_width = 200
		maptext_height = 30
		maptext_x = 30


		MouseEntered()
			.=..()
			maptext = "<b>[mouseText]"

		MouseExited()
			.=..()
			maptext = ""

	CloseMapButton
		layer = 15


	MapHudButton
		icon = 'MapGui.dmi'
		icon_state = "button"
		screen_loc = "EAST, NORTH"
		layer = 50
		Click()
			.=..()
			ShowMap(usr.client)