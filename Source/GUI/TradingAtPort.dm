/*
world
	icon_size = 30
	view = "32x18"
mob/verb/dock()
	var/Dock/testDock = new()
	testDock.GenerateOffers(1)

	DisplayTradingMenu(client, testDock)
*/
proc/IsPlayerDocked(client/c, Dock/dock)
	var/speedLimit = 0.25
	if (get_dist(c.myShip, dock) > 3)
		throw EXCEPTION("Cannot dock: too far away.")
	if (c.myShip.currentSpeed > speedLimit || c.myShip.currentSpeed < -speedLimit)
		throw EXCEPTION("Cannot dock: too fast.")

	return get_dist(c.myShip, dock) < 3 && c.myShip.currentSpeed < speedLimit && c.myShip.currentSpeed > -speedLimit

proc/DisplayTradingMenu(client/c, Dock/dock)
	if (c == null)
		throw EXCEPTION("client cannot be null.")

	if (dock == null)
		throw EXCEPTION("dock cannot be null.")

	if (!IsPlayerDocked(c, dock))
		return

	c.myShip.isDocked = 1
	discoveredPorts |= dock

	//32 x 18
	var/list/toClear = DisplaySlicedHud(c, 'Assets/HUD.dmi', 11,12, 21,6 ,5)

	var/obj/windowTitle = new()
	windowTitle.screen_loc = "12,11"
	windowTitle.layer = 6
	windowTitle.maptext_width = 275
	windowTitle.maptext_height = 64
	windowTitle.maptext = MAPTEXT_COLOR + "<b><font size=4>[dock.name]</font></b>"
	if (length(dock.name) >= 20)
		windowTitle.maptext_y = -7

	toClear.Add(windowTitle)
	c.screen.Add(windowTitle)

	var/pixelOffset = dock.offers.len > 1 ? ":-15" : ""

	var/screenOffset = 0
	for (var/TradeOffer/offer in dock.offers)
		var/obj/placeholderIn = new()
		placeholderIn.screen_loc = "12,[9+(screenOffset)][pixelOffset]"
		placeholderIn.icon = 'Spices.dmi'
		placeholderIn.icon_state = offer.inputProduct
		placeholderIn.maptext = MAPTEXT_COLOR + "x[offer.inputAmount]"
		placeholderIn.maptext_x = 28
		placeholderIn.layer = 6
		toClear.Add(placeholderIn)
		c.screen.Add(placeholderIn)

		var/obj/placeholderFor = new()
		placeholderFor.screen_loc = "14,[9+(screenOffset)][pixelOffset]"
		placeholderFor.maptext = MAPTEXT_COLOR + "<b>for</b>"
		placeholderFor.maptext_y = 5
		placeholderFor.maptext_x = -5
		placeholderFor.layer = 6
		toClear.Add(placeholderFor)
		c.screen.Add(placeholderFor)

		var/obj/placeholderOut = new()
		placeholderOut.screen_loc = "15,[9+(screenOffset)][pixelOffset]"
		placeholderOut.icon = 'Spices.dmi'
		placeholderOut.icon_state = offer.outputProduct
		placeholderOut.maptext = MAPTEXT_COLOR + "x[offer.outputAmount]"
		placeholderOut.maptext_x = 28
		placeholderOut.layer = 6
		toClear.Add(placeholderOut)
		c.screen.Add(placeholderOut)

		var/TradeButton/btn = new()
		btn.screen_loc = "18,[9+(screenOffset)][pixelOffset]"
		btn.offer = offer
		toClear.Add(btn)
		c.screen.Add(btn)

		screenOffset ++

	var/CloseButton/closeBtn = new()
	closeBtn.clear = toClear
	closeBtn.screen_loc = "15,7"
	closeBtn.layer = 6
	c.screen.Add(closeBtn)

TradeButton
	parent_type = /obj
	icon = 'TradeButton.png'
	layer = 6
	var/TradeOffer/offer = null

	Click()
		var/Ship/s = usr.client.myShip

		if (s.cargo[offer.inputProduct] < offer.inputAmount)
			world << "You can't afford that! The offer requires [offer.inputAmount], but you only have [s.cargo[offer.inputProduct]]."
			return

		s.cargo[offer.inputProduct] -= offer.inputAmount
		s.cargo[offer.outputProduct] += offer.outputAmount

		usr.client.UpdateResourcesHud()

		world << "You traded x[offer.inputAmount] [offer.inputProduct] for x[offer.outputAmount] [offer.outputProduct]!"

CloseButton
	parent_type = /obj
	icon = 'CloseButton.png'
	layer = 6
	var
		list/clear = list()

	Click()
		usr.client.screen.Remove(clear)
		usr.client.myShip.isDocked = 0
		del src