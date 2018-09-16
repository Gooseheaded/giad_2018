
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

	//32 x 18
	var/list/toClear = DisplaySlicedHud(c, 'Assets/HUD.dmi', 9,15, 23,3 ,5)

	var/obj/windowTitle = new()
	windowTitle.screen_loc = "10,14"
	windowTitle.layer = 6
	windowTitle.maptext_width = 400
	windowTitle.maptext_height = 64
	if (lowertext(copytext(c.key, length(c.key))) == "s")
		windowTitle.maptext = "<b><font size=4>[c.key]' home island</font></b>"
	else
		windowTitle.maptext = "<b><font size=4>[c.key]'s home island</font></b>"
	toClear.Add(windowTitle)
	c.screen.Add(windowTitle)

	var/obj/shipTitle = new()
	shipTitle.screen_loc = "11:-5,13:5"
	shipTitle.layer = 6
	shipTitle.maptext_width = 256
	shipTitle.maptext_height = 64
	shipTitle.maptext = "<b>Ship cargo</b>"
	toClear.Add(shipTitle)
	c.screen.Add(shipTitle)

	var/obj/bankTitle = new()
	bankTitle.screen_loc = "16:-15,13:5"
	bankTitle.layer = 6
	bankTitle.maptext_width = 256
	bankTitle.maptext_height = 64
	bankTitle.maptext = "<b>Home bank</b>"
	toClear.Add(bankTitle)
	c.screen.Add(bankTitle)

	var/list/spices = list(RED_SPICE, BLUE_SPICE, GREEN_SPICE, YELLOW_SPICE, MAGENTA_SPICE, CYAN_SPICE, BLACK_SPICE)
	var/screenOffset = 0
	for (var/spice in spices)
		var/obj/placeholderLeft = new()
		placeholderLeft.screen_loc = "11:15,[12-screenOffset]"
		placeholderLeft.icon = 'Spices.dmi'
		placeholderLeft.icon_state = spice
		placeholderLeft.maptext = "x[c.myShip.cargo[spice]]"
		placeholderLeft.maptext_x = 28
		placeholderLeft.layer = 6
		placeholderLeft.name = "Cargo [spice]"
		toClear.Add(placeholderLeft)
		c.screen.Add(placeholderLeft)

		var/obj/placeholderRight = new()
		placeholderRight.screen_loc = "16:5,[12-(screenOffset)]"
		placeholderRight.icon = 'Spices.dmi'
		placeholderRight.icon_state = spice
		placeholderRight.maptext = "x[c.homebank[spice]]"
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
		placeholderPrice.maptext = "[rand(50,150)] each" // TODO: Market price
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
		placeholderCoin.maptext = "<font size=3><b>[c.coins]"
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

WithdrawButton
	parent_type = /obj
	icon = 'LeftArrowButton.png'
	layer = 6
	var/spice = ""

	New(spice)
		src.spice = spice

	Click()
		if (usr.client.homebank[spice] < 1)
			world << "Not enough [spice] to withdraw."
			return

		usr.client.homebank[spice] --
		usr.client.myShip.cargo[spice] ++

		for(var/obj/o in usr.client.screen)
			if (o.name == "Homebank [spice]")
				o.maptext = "x[usr.client.homebank[spice]]"
			else if(o.name == "Cargo [spice]")
				o.maptext = "x[usr.client.myShip.cargo[spice]]"

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
		usr.client.coins += 100 // TODO: Market price

		for(var/obj/o in usr.client.screen)
			if (o.name == "Homebank [spice]")
				o.maptext = "x[usr.client.homebank[spice]]"
			else if(o.name == "Cargo [spice]")
				o.maptext = "x[usr.client.myShip.cargo[spice]]"
			else if(o.name == "Coin")
				o.maptext = "<font size=3><b>[usr.client.coins]"

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
				o.maptext = "x[usr.client.homebank[spice]]"
			else if(o.name == "Cargo [spice]")
				o.maptext = "x[usr.client.myShip.cargo[spice]]"

		usr.client.UpdateResourcesHud()