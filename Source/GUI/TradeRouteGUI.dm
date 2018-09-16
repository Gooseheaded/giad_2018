

var
	traderouteWindow[0]

	discoveredPorts[0]

	TradeRoute/selectedRoute
	tradeMenuIndex = 1

proc
	OpenTradeRouteWindow(client/c, HomeIsland/home)

		if(traderouteWindow.len > 0) return CloseTradeRouteWindow(c)
		if(!c.myShip) return
		/*
		if (c == null)
			throw EXCEPTION("client cannot be null.")

		if (home == null)
			throw EXCEPTION("dock cannot be null.")

		if (!IsPlayerAtHome(c, home))
			return
		*/

		c.myShip.isDocked = 1
		c.myShip.Repair()

		var/list/toClear = DisplaySlicedHud(c, 'Assets/HUD.dmi', 8,16, 26,1 ,10)
		for(var/obj/o in toClear)
			traderouteWindow["routeWindow [o.screen_loc]"] = o


		var/obj/o = new()
		o.screen_loc = "9,15"
		o.layer = 11
		o.maptext_width = 400
		o.maptext_height = 64
		if (lowertext(copytext(c.key, length(c.key))) == "s")
			o.maptext = MAPTEXT_COLOR + "<b><font size=4>TRADE ROUTES</font></b>"
		else
			o.maptext = MAPTEXT_COLOR + "<b><font size=4>TRADE ROUTES</font></b>"
		traderouteWindow["routeWindowTitle"] = o
		c.screen.Add(o)

		o = new/obj/CloseTradeRouteWindowbutton()
		o.screen_loc = "10,1"
		o.layer = 14
		traderouteWindow["routeWindowClose"] = o
		c.screen.Add(o)


		ShowTradeRouteMenu(c,1)

	ShowTradeRouteMenu(client/c, listIndex = tradeMenuIndex, tag = "routeMenu")
		var/obj/o = new()
		o.screen_loc = "8,3"
		o.icon = 'Menu.dmi'
		o.mouse_opacity = 0
		var/matrix/M = new()
		M.Translate(45,45)
		M.Scale( 120 / 90, 300 / 90) //11 tall
		o.transform = M
		o.layer = 11

		del traderouteWindow["routesMenuBack"]
		traderouteWindow["routesMenuBack"] = o
		c.screen.Add(o)

		for(var/i in traderouteWindow)
			if(!findtext(i, "routeMenuItem")) continue
			del traderouteWindow[i]
			traderouteWindow -= i

		var/sy = 13
		var/upperListIndex = listIndex + 6
		if(upperListIndex > c.tradeRoutes.len) upperListIndex = c.tradeRoutes.len

		for(var/i = listIndex; i <= upperListIndex; i++)
			if(i < 1) i = 1
			if(c.tradeRoutes[i] == null) continue;

			o = new/obj/RouteSelect()
			o:item = c.tradeRoutes[i]
			c.tradeRoutes[i].name = "Route #[i]"
			o.maptext = "Route #[i]"
			o.screen_loc = "10, [sy--]"
			o.layer = 13
			traderouteWindow["routeMenuItem #[i]"] = o
			c.screen.Add(o)

		o = new/obj/RouteMenuNext()
		o.screen_loc = "12,3"
		del traderouteWindow["routesMenuNext"]
		traderouteWindow["routesMenuNext"] = o
		c.screen.Add(o)

		o = new/obj/RouteMenuPrev()
		del traderouteWindow["routesMenuPrev"]
		traderouteWindow["routesMenuPrev"] = o
		o.screen_loc = "10,3"
		c.screen.Add(o)

		o = new/obj/AddRouteButton()
		del traderouteWindow["routesMenuAdd"]
		traderouteWindow["routesMenuAdd"] = o
		o.screen_loc = "10,5"
		c.screen.Add(o)

		ShowTradeRouteDetails(c,1)

	ShowTradeRouteDetails(client/c, listIndex = 1, tag = "routeDetails")

		if(!selectedRoute)
			for(var/i in traderouteWindow)
				if(!findtext(i, tag)) continue
				del traderouteWindow[i]
				traderouteWindow -= i
			return

		var/obj/o = new()
		o.screen_loc = "14,14"
		o.layer = 11
		o.maptext_width = 400
		o.maptext_height = 64
		if (lowertext(copytext(c.key, length(c.key))) == "s")
			o.maptext = MAPTEXT_COLOR + "<b><u><font size=3>[selectedRoute.name]</font></b>"
		else
			o.maptext = MAPTEXT_COLOR + "<b><u><font size=3>[selectedRoute.name]</font></b>"
		del traderouteWindow["routeDescTitle"]
		traderouteWindow["routeDescTitle"] = o
		c.screen.Add(o)

		o = new()
		o.screen_loc = "15,13"
		o.layer = 11
		o.maptext_width = 400
		o.maptext_height = 64
		o.maptext = MAPTEXT_COLOR + "<b><font size=2>Starting\nCargo << \t >> Home"
		del traderouteWindow["routeDesc2"]
		traderouteWindow["routeDesc2"] = o
		c.screen.Add(o)


		var/list/spices = list(BLACK_SPICE, YELLOW_SPICE, RED_SPICE, MAGENTA_SPICE, BLUE_SPICE, CYAN_SPICE, GREEN_SPICE)
		var/screenOffset = 0
		for (var/spice in spices)
			var/num = 0
			if(selectedRoute.startCargo[spice]) num = selectedRoute.startCargo[spice]

			var/obj/placeholderLeft = new()
			placeholderLeft.screen_loc = "14:15,[12-screenOffset]"
			placeholderLeft.icon = 'Spices.dmi'
			placeholderLeft.icon_state = spice
			placeholderLeft.maptext = MAPTEXT_COLOR + "x[num]"
			placeholderLeft.maptext_x = 28
			placeholderLeft.layer = 6
			placeholderLeft.name = "Cargo [spice]"
			del traderouteWindow["routeDescCargo [spice]"]
			traderouteWindow["routeDescCargo [spice]"] = placeholderLeft
			c.screen.Add(placeholderLeft)

			var/obj/placeholderRight = new()
			placeholderRight.screen_loc = "19:5,[12-(screenOffset)]"
			placeholderRight.icon = 'Spices.dmi'
			placeholderRight.icon_state = spice
			placeholderRight.maptext = MAPTEXT_COLOR + "x[c.homebank[spice]]"
			placeholderRight.maptext_x = 28
			placeholderRight.layer = 6
			placeholderRight.name = "Homebank [spice]"
			del traderouteWindow["routeDescHomebank [spice]"]
			traderouteWindow["routeDescHomebank [spice]"] = placeholderRight
			c.screen.Add(placeholderRight)

			var/RouteDepositButton/dbtn = new(spice)
			dbtn.screen_loc = "17:15,[12-(screenOffset)]"
			del traderouteWindow["routeDeposit [spice]"]
			traderouteWindow["routeDeposit [spice]"] = dbtn
			c.screen.Add(dbtn)

			var/RouteWithdrawButton/wbtn = new(spice)
			wbtn.screen_loc = "16:15,[12-(screenOffset)]"
			del traderouteWindow["routeWithdraw [spice]"]
			traderouteWindow["routeWithdraw [spice]"] = wbtn
			c.screen.Add(wbtn)

			screenOffset ++

		o = new()
		o.screen_loc = "21,14"
		o.layer = 11
		o.maptext_width = 400
		o.maptext_height = 64
		o.maptext = MAPTEXT_COLOR + "<b><font size=2>Number of Ships: [selectedRoute.ais.len]"
		del traderouteWindow["routeDesc3"]
		traderouteWindow["routeDesc3"] = o
		c.screen.Add(o)


		var/cargoCapacity = 0
		for(var/AI/AI in selectedRoute.ais)
			cargoCapacity += AI.myShip.cargoCapacity

		o = new()
		o.screen_loc = "21,13"
		o.layer = 11
		o.maptext_width = 400
		o.maptext_height = 64
		o.maptext = MAPTEXT_COLOR + "<b><font size=2>Cargo Capacity: [cargoCapacity]"
		del traderouteWindow["routeDesc4"]
		traderouteWindow["routeDesc4"] = o
		c.screen.Add(o)


	ClearTradeRouteDetails(tag = "routeDetails")
		for(var/i in traderouteWindow)
			if(!findtext(i, tag)) continue
			del traderouteWindow[i]
			traderouteWindow -= i

	TradeRouteAddNode(client/c, listIndex = 1, tag = "nodeMenu")

	TradeRouteCloseAddNode(var/tag = "nodeMenu")
		for(var/i in traderouteWindow)
			if(!findtext(i, tag)) continue
			del traderouteWindow[i]
			traderouteWindow -= i

	TradeRouteAddShipMenu(client/c, listIndex = 1, tag = "shipMenu")


	TradeRouteRemoveShipMenu(client/c, listIndex = 1, tag = "shipMenu")



	TradeRouteCloseSelectShip(var/tag = "shipMenu")
		for(var/i in traderouteWindow)
			if(!findtext(i, tag)) continue
			del traderouteWindow[i]
			traderouteWindow -= i

	CloseTradeRouteWindow(client/c)
		for(var/i in traderouteWindow)
			del traderouteWindow[i]

		selectedRoute = null

		c.myShip.isDocked = 0

		traderouteWindow.Cut()

obj
	OpenTradeRouteButton
		Click()
			.=..()
			OpenTradeRouteWindow(usr.client, locate(/HomeIsland) in world)

	CloseTradeRouteWindowbutton
		icon = 'CloseButton.png'
		Click()
			.=..()
			CloseTradeRouteWindow(usr.client)
			del src

	RouteMenuNext
		icon = 'RightArrowButton.png'
		layer = 12
		Click()
			.=..()
			tradeMenuIndex += 5
			if(tradeMenuIndex >= usr.client.tradeRoutes.len)
				tradeMenuIndex = usr.client.tradeRoutes.len - 1

			if(tradeMenuIndex < 1) tradeMenuIndex = 1
			ShowTradeRouteMenu(usr.client)

	RouteMenuPrev
		icon = 'LeftArrowButton.png'
		layer = 12
		Click()
			.=..()
			tradeMenuIndex -= 5
			if(tradeMenuIndex <= 0)
				tradeMenuIndex = 1
			ShowTradeRouteMenu(usr.client)

	RouteSelect
		icon = 'Route.dmi'
		icon_state = "small"
		maptext_width = 120
		maptext_height = 30
		maptext_x = 30

		var/TradeRoute/item

		Click()
			.=..()
			selectedRoute = item
			ShowTradeRouteMenu(usr.client)

	AddRouteButton
		icon = 'NewRoute.png'
		layer = 13

		Click()
			.=..()
			var/TradeRoute/route = new()
			usr.client.tradeRoutes += route
			ShowTradeRouteMenu(usr.client)

RouteWithdrawButton
	parent_type = /obj
	icon = 'LeftArrowButton.png'
	layer = 6
	var/spice = ""

	New(spice)
		src.spice = spice

	Click()
		if(!selectedRoute) return

		if (usr.client.homebank[spice] < 1)
			return

		usr.client.homebank[spice] --
		selectedRoute.startCargo[spice] ++

		for(var/obj/o in usr.client.screen)
			if (o.name == "Homebank [spice]")
				o.maptext = MAPTEXT_COLOR + "x[usr.client.homebank[spice]]"
			else if(o.name == "Cargo [spice]")
				o.maptext = MAPTEXT_COLOR + "x[selectedRoute.startCargo[spice]]"

		usr.client.UpdateResourcesHud()

RouteDepositButton
	parent_type = /obj
	icon = 'RightArrowButton.png'
	layer = 6
	var/spice = ""

	New(spice)
		src.spice = spice

	Click()
		if(!selectedRoute) return

		if (selectedRoute.startCargo[spice] < 1)
			return

		usr.client.homebank[spice] ++
		selectedRoute.startCargo[spice] --

		for(var/obj/o in usr.client.screen)
			if (o.name == "Homebank [spice]")
				o.maptext = MAPTEXT_COLOR + "x[usr.client.homebank[spice]]"
			else if(o.name == "Cargo [spice]")
				o.maptext = MAPTEXT_COLOR + "x[selectedRoute.startCargo[spice]]"

		usr.client.UpdateResourcesHud()