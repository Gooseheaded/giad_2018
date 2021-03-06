
proc/IsPlayerAtHome(client/c, HomeIsland/home)
	var/speedLimit = 0.25
	if (get_dist(c.myShip, home) > 3)
		throw EXCEPTION("Cannot homebank: too far away.")
	if (c.myShip.currentSpeed > speedLimit || c.myShip.currentSpeed < -speedLimit)
		throw EXCEPTION("Cannot homebank: too fast.")

	return get_dist(c.myShip, home) < 3 && c.myShip.currentSpeed < speedLimit && c.myShip.currentSpeed > -speedLimit

proc/DisplayHomebankingMenu(client/c, HomeIsland/home)
	if (c == null)
		throw EXCEPTION("client cannot be null.")

	if (home == null)
		throw EXCEPTION("dock cannot be null.")

	if (!IsPlayerAtHome(c, home))
		return

	c.myShip.isDocked = 1
	c.myShip.Repair()

	//32 x 18
	var/list/toClear = DisplaySlicedHud(c, 'Assets/HUD.dmi', 9,15, 23,3 ,5)

	var/obj/windowTitle = new()
	windowTitle.screen_loc = "10,14"
	windowTitle.layer = 6
	windowTitle.maptext_width = 400
	windowTitle.maptext_height = 64
	if (lowertext(copytext(c.key, length(c.key))) == "s")
		windowTitle.maptext = MAPTEXT_COLOR + "<b><font size=4>[c.key]' home island</font></b>"
	else
		windowTitle.maptext = MAPTEXT_COLOR + "<b><font size=4>[c.key]'s home island</font></b>"
	toClear.Add(windowTitle)
	c.screen.Add(windowTitle)

	var/obj/shipTitle = new()
	shipTitle.screen_loc = "11:-5,13:5"
	shipTitle.layer = 6
	shipTitle.maptext_width = 256
	shipTitle.maptext_height = 64
	shipTitle.maptext = MAPTEXT_COLOR + "<b>Ship cargo</b>"
	toClear.Add(shipTitle)
	c.screen.Add(shipTitle)

	var/obj/bankTitle = new()
	bankTitle.screen_loc = "16:-15,13:5"
	bankTitle.layer = 6
	bankTitle.maptext_width = 256
	bankTitle.maptext_height = 64
	bankTitle.maptext = MAPTEXT_COLOR + "<b>Home bank</b>"
	toClear.Add(bankTitle)
	c.screen.Add(bankTitle)

	var/list/spices = list(BLACK_SPICE, YELLOW_SPICE, RED_SPICE, MAGENTA_SPICE, BLUE_SPICE, CYAN_SPICE, GREEN_SPICE)
	var/screenOffset = 0
	for (var/spice in spices)
		var/obj/placeholderLeft = new()
		placeholderLeft.screen_loc = "11:15,[12-screenOffset]"
		placeholderLeft.icon = 'Spices.dmi'
		placeholderLeft.icon_state = spice
		placeholderLeft.maptext = MAPTEXT_COLOR + "x[c.myShip.cargo[spice]]"
		placeholderLeft.maptext_x = 28
		placeholderLeft.layer = 6
		placeholderLeft.name = "Cargo [spice]"
		toClear.Add(placeholderLeft)
		c.screen.Add(placeholderLeft)

		var/obj/placeholderRight = new()
		placeholderRight.screen_loc = "16:5,[12-(screenOffset)]"
		placeholderRight.icon = 'Spices.dmi'
		placeholderRight.icon_state = spice
		placeholderRight.maptext = MAPTEXT_COLOR + "x[c.homebank[spice]]"
		placeholderRight.maptext_x = 28
		placeholderRight.layer = 6
		placeholderRight.name = "Homebank [spice]"
		toClear.Add(placeholderRight)
		c.screen.Add(placeholderRight)

		var/obj/placeholderPrice = new()
		placeholderPrice.icon = 'Placeholders.dmi'
		placeholderPrice.icon_state = "Coin"
		placeholderPrice.screen_loc = "18:-10,[12-(screenOffset)]"
		placeholderPrice.maptext_width = 200
		placeholderPrice.maptext_height = 60
		placeholderPrice.maptext = MAPTEXT_COLOR + "[sellingFunction(spice)] each"
		placeholderPrice.maptext_y = 6
		placeholderPrice.maptext_x = 24
		placeholderPrice.layer = 6
		placeholderPrice.name = "Price [spice]"
		toClear.Add(placeholderPrice)
		c.screen.Add(placeholderPrice)

		var/obj/placeholderCoin = new()
		placeholderCoin.icon = 'Placeholders.dmi'
		placeholderCoin.icon_state = "Big coin"
		placeholderCoin.screen_loc = "18,4"
		placeholderCoin.maptext_width = 200
		placeholderCoin.maptext_height = 60
		placeholderCoin.maptext = MAPTEXT_COLOR + "<font size=3><b>[c.coins]"
		placeholderCoin.maptext_y = 6
		placeholderCoin.maptext_x = 30
		placeholderCoin.layer = 6
		placeholderCoin.name = "Coin"
		toClear.Add(placeholderCoin)
		c.screen.Add(placeholderCoin)

		var/SellButton/sbtn = new(spice)
		sbtn.screen_loc = "20:15,[12-(screenOffset)]"
		toClear.Add(sbtn)
		c.screen.Add(sbtn)

		var/DepositButton/dbtn = new(spice)
		dbtn.screen_loc = "14:15,[12-(screenOffset)]"
		toClear.Add(dbtn)
		c.screen.Add(dbtn)

		var/WithdrawButton/wbtn = new(spice)
		wbtn.screen_loc = "13:15,[12-(screenOffset)]"
		toClear.Add(wbtn)
		c.screen.Add(wbtn)


		screenOffset ++

	var/CloseButton/closeBtn = new()
	closeBtn.clear = toClear
	closeBtn.screen_loc = "13,4"
	closeBtn.layer = 6
	c.screen.Add(closeBtn)
	toClear.Add(closeBtn)


	var/obj/o = new /obj/BuyTradeShip()
	o.screen_loc = "24,12"
	o.layer = 10
	c.screen.Add(o)
	toClear.Add(o)

	o = new /obj/BuyEscortShip()
	o.screen_loc = "24,10"
	o.layer = 10
	c.screen.Add(o)
	toClear.Add(o)


	o = new /obj/OpenTradeRoutes()
	o:clear = toClear
	o.screen_loc = "24,8"
	o.layer = 10
	c.screen.Add(o)
	toClear.Add(o)

WithdrawButton
	parent_type = /obj
	icon = 'LeftArrowButton.png'
	layer = 6
	var/spice = ""

	New(spice)
		src.spice = spice

	Click()
		if (usr.client.homebank[spice] < 1)
			displayText("You don't have enough [spice] to withdraw.")
			return

		if(usr.client.myShip.GetCurrentCargo() >= usr.client.myShip.cargoCapacity)
			displayText("You don't have enough cargo space to withdraw.")
			return


		usr.client.homebank[spice] --
		usr.client.myShip.cargo[spice] ++

		for(var/obj/o in usr.client.screen)
			if (o.name == "Homebank [spice]")
				o.maptext = MAPTEXT_COLOR + "x[usr.client.homebank[spice]]"
			else if(o.name == "Cargo [spice]")
				o.maptext = MAPTEXT_COLOR + "x[usr.client.myShip.cargo[spice]]"

		usr.client.UpdateResourcesHud()

SellButton
	parent_type = /obj
	icon = 'SellButton.png'
	layer = 6
	var/spice = ""

	New(spice)
		src.spice = spice

	Click()
		if (usr.client.homebank[spice] < 1)
			world << "Not enough [spice] to sell."
			return


		usr << sound('SellSound.wav', volume=25)
		usr.client.homebank[spice] --
		usr.client.coins += sellingFunction(spice)

		for(var/obj/o in usr.client.screen)
			if (o.name == "Homebank [spice]")
				o.maptext = MAPTEXT_COLOR + "x[usr.client.homebank[spice]]"
			else if(o.name == "Cargo [spice]")
				o.maptext = MAPTEXT_COLOR + "x[usr.client.myShip.cargo[spice]]"
			else if(o.name == "Coin")
				o.maptext = MAPTEXT_COLOR + "<font size=3><b>[usr.client.coins]"

		usr.client.UpdateResourcesHud()

DepositButton
	parent_type = /obj
	icon = 'RightArrowButton.png'
	layer = 6
	var/spice = ""

	New(spice)
		src.spice = spice

	Click()
		if (usr.client.myShip.cargo[spice] < 1)
			world << "Not enough [spice] to deposit."
			return

		usr.client.homebank[spice] ++
		usr.client.myShip.cargo[spice] --

		for(var/obj/o in usr.client.screen)
			if (o.name == "Homebank [spice]")
				o.maptext = MAPTEXT_COLOR + "x[usr.client.homebank[spice]]"
			else if(o.name == "Cargo [spice]")
				o.maptext = MAPTEXT_COLOR + "x[usr.client.myShip.cargo[spice]]"

		usr.client.UpdateResourcesHud()

obj
	BuyTradeShip
		icon = 'TradeShip.png'
		layer = 12

		Click()
			.=..()
			if(usr.client.coins < 1000)
				world << "Not enough coin to buy a trade ship."
				return

			usr.client.coins -= 1000

			var/HomeIsland/H = locate()
			H.PixelCoordsUpdate()

			BuyAIShip(usr.client, /Ship/Trader, vec2(H.pX, H.pY), H.z)

	BuyEscortShip
		icon = 'EscortShip.png'
		layer = 12

		Click()
			.=..()
			if(usr.client.coins < 1000)
				world << "Not enough coin to buy a escort ship."
				return

			usr.client.coins -= 1000

			var/HomeIsland/H = locate()
			H.PixelCoordsUpdate()

			BuyAIShip(usr.client, /Ship/Escort, vec2(H.pX, H.pY), H.z)

	OpenTradeRoutes
		icon = 'TradeRoutes.png'
		layer = 12
		var/clear[0]
		Click()
			.=..()
			var/HomeIsland/h = locate()
			OpenTradeRouteWindow(usr.client, h)
			usr.client.myShip.isDocked = 1
			for(var/i in clear) del i

proc
	BuyAIShip(client/c, shipType, vector/location, z)
		var/AI/PlayerAI/AI = new ()
		AI.myShip = new shipType()

		location = GetEmptyLocation(vec2(location.x, location.y), z, AI.myShip.bigRadius, 1, 3)

		AI.myShip.loc = locate(location.x / ICON_WIDTH,location.y / ICON_HEIGHT,1)
		AI.myShip.step_x = location.x % ICON_WIDTH
		AI.myShip.step_y = location.y % ICON_HEIGHT

		AI.myShip.PixelCoordsUpdate()
		AI.myShip.CollidersUpdate()

		gameActiveAtoms += AI
		gameActiveAtoms += AI.myShip

		if(c)
			c.myAIs += AI