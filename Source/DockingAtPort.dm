world
	icon_size = 30
	view = "32x18"
mob/verb/dock()
	var/Dock/testDock = new()
	testDock.GenerateOffers(1)

	DisplayTradingMenu(client, testDock)

proc/IsPlayerDocked(client/c, Dock/dock)
	// TODO: pls
	return TRUE

proc/DisplayTradingMenu(client/c, Dock/dock)
	if (c == null)
		throw EXCEPTION("client cannot be null.")

	if (dock == null)
		throw EXCEPTION("dock cannot be null.")

	if (!IsPlayerDocked(c, dock))
		return

	//32 x 18
	var/list/toClear = DisplaySlicedHud(c, 'Assets/HUD.dmi', 8,12, 18,6 ,5)

	var/obj/windowTitle = new()
	windowTitle.icon = 'TradeOffersTitle.png'
	windowTitle.screen_loc = "9,11"
	windowTitle.layer = 6
	toClear.Add(windowTitle)
	c.screen.Add(windowTitle)

	var/screenOffset = 0
	for (var/TradeOffer/offer in dock.offers)
		var/obj/placeholderIn = new()
		placeholderIn.screen_loc = "9,[9+(screenOffset)]"
		placeholderIn.icon = 'Spices.dmi'
		placeholderIn.icon_state = offer.inputProduct
		placeholderIn.maptext = "x[offer.inputAmount]"
		placeholderIn.maptext_x = 28
		placeholderIn.layer = 6
		toClear.Add(placeholderIn)
		c.screen.Add(placeholderIn)

		var/obj/placeholderFor = new()
		placeholderFor.screen_loc = "11,[9+(screenOffset)]"
		placeholderFor.maptext = "<b>for</b>"
		placeholderFor.maptext_y = 5
		placeholderFor.maptext_x = -5
		placeholderFor.layer = 6
		toClear.Add(placeholderFor)
		c.screen.Add(placeholderFor)

		var/obj/placeholderOut = new()
		placeholderOut.screen_loc = "12,[9+(screenOffset)]"
		placeholderOut.icon = 'Spices.dmi'
		placeholderOut.icon_state = offer.outputProduct
		placeholderOut.maptext = "x[offer.outputAmount]"
		placeholderOut.maptext_x = 28
		placeholderOut.layer = 6
		toClear.Add(placeholderOut)
		c.screen.Add(placeholderOut)

		var/TradeButton/btn = new()
		btn.screen_loc = "15,[9+(screenOffset)]"
		btn.offer = offer
		toClear.Add(btn)
		c.screen.Add(btn)

		screenOffset ++

	var/CloseTradeButton/closeBtn = new()
	closeBtn.clear = toClear
	closeBtn.screen_loc = "12,7"
	closeBtn.layer = 6
	c.screen.Add(closeBtn)

TradeButton
	parent_type = /obj
	icon = 'TradeButton.png'
	layer = 6
	var/TradeOffer/offer = null

	Click()
		world << "Player wants to trade x[offer.inputAmount] [offer.inputProduct] for x[offer.outputAmount] [offer.outputProduct]!"

CloseTradeButton
	parent_type = /obj
	icon = 'CloseButton.png'
	layer = 6
	var
		list/clear = list()

	Click()
		usr.client.screen.Remove(clear)
		del src