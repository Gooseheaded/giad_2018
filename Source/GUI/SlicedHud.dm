
proc/DisplaySlicedHud(client/c, icon/icon, topLeftX, topLeftY, bottomRightX, bottomRightY, layer=10)
	if (c == null)
		throw EXCEPTION("Client cannot be null.")

	if (icon == null)
		throw EXCEPTION("Icon cannot be null.")

	if (topLeftX < 1 || topLeftX > 32) // 960 / 30 = 32
		throw EXCEPTION("topLeftX cannot be less than 1 or greater than 32.")

	if (topLeftY < 1 || topLeftY > 18) // 540 / 30 = 18
		throw EXCEPTION("topLeftY cannot be less than 1 or greater than 18.")

	if (bottomRightX < 1 || bottomRightX > 32) // 960 / 30 = 32
		throw EXCEPTION("bottomRightX cannot be less than 1 or greater than 32.")

	if (bottomRightY < 1 || bottomRightY > 18) // 540 / 30 = 18
		throw EXCEPTION("bottomRightY cannot be less than 1 or greater than 18.")

	if (bottomRightX <= topLeftX)
		throw EXCEPTION("bottomRightX cannot be less than or equal to topLeftX.")

	if (bottomRightY >= topLeftY)
		throw EXCEPTION("topLeftY cannot be greater than or equal to topLeftY.")

	if (layer < 1)
		throw EXCEPTION("layer cannot be less than 1.")

	var/list/slicedHudPieces = list()

	var/obj/nwCorner = new()
	nwCorner.icon = icon
	nwCorner.icon_state = "Border"
	nwCorner.dir = NORTHWEST
	nwCorner.screen_loc = "[topLeftX],[topLeftY]"
	nwCorner.name = nwCorner.screen_loc
	nwCorner.layer = layer
	slicedHudPieces.Add(nwCorner)
	c.screen.Add(nwCorner)

	var/obj/neCorner = new()
	neCorner.icon = icon
	neCorner.icon_state = "Border"
	neCorner.dir = NORTHEAST
	neCorner.screen_loc = "[bottomRightX],[topLeftY]"
	neCorner.name = neCorner.screen_loc
	neCorner.layer = layer
	slicedHudPieces.Add(neCorner)
	c.screen.Add(neCorner)

	var/obj/swCorner = new()
	swCorner.icon = icon
	swCorner.icon_state = "Border"
	swCorner.dir = SOUTHWEST
	swCorner.screen_loc = "[topLeftX],[bottomRightY]"
	swCorner.name = swCorner.screen_loc
	swCorner.layer = layer
	slicedHudPieces.Add(swCorner)
	c.screen.Add(swCorner)

	var/obj/seCorner = new()
	seCorner.icon = icon
	seCorner.icon_state = "Border"
	seCorner.dir = SOUTHEAST
	seCorner.screen_loc = "[bottomRightX],[bottomRightY]"
	seCorner.name = seCorner.screen_loc
	seCorner.layer = layer
	slicedHudPieces.Add(seCorner)
	c.screen.Add(seCorner)

	var/list/nCorner = list()
	for (var/x = topLeftX + 1; x < bottomRightX; x ++)
		var/obj/o = new()
		o.icon = icon
		o.icon_state = "Border"
		o.dir = NORTH
		o.screen_loc = "[x],[topLeftY]"
		o.name = o.screen_loc
		nwCorner.layer = layer
		nCorner.Add(o)
	slicedHudPieces.Add(nCorner)
	c.screen.Add(nCorner)

	var/list/sCorner = list()
	for (var/x = topLeftX + 1; x < bottomRightX; x ++)
		var/obj/o = new()
		o.icon = icon
		o.icon_state = "Border"
		o.dir = SOUTH
		o.screen_loc = "[x],[bottomRightY]"
		o.name = o.screen_loc
		nwCorner.layer = layer
		sCorner.Add(o)
	slicedHudPieces.Add(sCorner)
	c.screen.Add(sCorner)

	var/list/wCorner = list()
	for (var/y = bottomRightY + 1; y < topLeftY; y ++)
		var/obj/o = new()
		o.icon = icon
		o.icon_state = "Border"
		o.dir = WEST
		o.screen_loc = "[topLeftX],[y]"
		o.name = o.screen_loc
		nwCorner.layer = layer
		wCorner.Add(o)
	slicedHudPieces.Add(wCorner)
	c.screen.Add(wCorner)

	var/list/eCorner = list()
	for (var/y = bottomRightY + 1; y < topLeftY; y ++)
		var/obj/o = new()
		o.icon = icon
		o.icon_state = "Border"
		o.dir = EAST
		o.screen_loc = "[bottomRightX],[y]"
		o.name = o.screen_loc
		nwCorner.layer = layer
		eCorner.Add(o)
	slicedHudPieces.Add(eCorner)
	c.screen.Add(eCorner)

	var/list/filler = list()
	for (var/x = topLeftX + 1; x < bottomRightX; x ++)
		for (var/y = bottomRightY + 1; y < topLeftY; y ++)
			var/obj/o = new()
			o.icon = icon
			o.icon_state = "Filler"
			o.screen_loc = "[x],[y]"
			o.name = o.screen_loc
			nwCorner.layer = layer
			filler.Add(o)
	slicedHudPieces.Add(filler)
	c.screen.Add(filler)

	return slicedHudPieces