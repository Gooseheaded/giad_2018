

client
	var
		Ship/myShip

		keys[0]

		speedMode = 0

		list/resourcesHud = list()

		list/homebank = list()
		coins = 100

	proc
		CreateStarterShip()
			if(mob) mob.loc = null

			if(myShip) del myShip


			myShip = new/Ship/StarterCaravel()
			myShip.client = src

			myShip.loc = locate(60,85,1)
			myShip.PixelCoordsUpdate()
			myShip.CollidersUpdate()

			//set the camera
			camera = new(src, myShip)

			gameActiveAtoms += myShip
			gameActiveAtoms += src
			UpdateResourcesHud()

			homebank[BLACK_SPICE] = 100
			homebank[YELLOW_SPICE] = 50
			homebank[RED_SPICE] = 10
			homebank[MAGENTA_SPICE] = 10
			homebank[BLUE_SPICE] = 0
			homebank[CYAN_SPICE] = 0
			homebank[GREEN_SPICE] = 0

		UpdateResourcesHud()
			if (myShip == null)
				throw EXCEPTION("myShip cannot be null.")

			resourcesHud[RED_SPICE].maptext = "<b>x[myShip.cargo[RED_SPICE]]</b>"
			resourcesHud[GREEN_SPICE].maptext = "<b>x[myShip.cargo[GREEN_SPICE]]</b>"
			resourcesHud[BLUE_SPICE].maptext = "<b>x[myShip.cargo[BLUE_SPICE]]</b>"
			resourcesHud[CYAN_SPICE].maptext = "<b>x[myShip.cargo[CYAN_SPICE]]</b>"
			resourcesHud[MAGENTA_SPICE].maptext = "<b>x[myShip.cargo[MAGENTA_SPICE]]</b>"
			resourcesHud[BLACK_SPICE].maptext = "<b>x[myShip.cargo[BLACK_SPICE]]</b>"
			resourcesHud[YELLOW_SPICE].maptext = "<b>x[myShip.cargo[YELLOW_SPICE]]</b>"

	verb
		KeyDown(var/char as text)
			keys[char] = 1

		KeyUp(var/char as text)
			keys[char] = 0

	proc
		TickUpdate()
			if(!myShip) return

			var/rotationMode = 0
			//read input
			if(keys["W"])
				speedMode ++
				KeyUp("W")
			if(keys["S"])
				speedMode --
				KeyUp("S")

			if(keys["A"])
				rotationMode += 1
			if(keys["D"])
				rotationMode -= 1


			//affect the ship

			if(speedMode > 3) speedMode = 3
			if(speedMode < -1) speedMode = -1
			myShip.SetSpeedMode(speedMode)

			myShip.SetRotationMode(rotationMode, speedMode)


Ship
	Click(loc, con, params)
		.=..()
		var/client/C = usr.client


		if(C && src.isHostile)
			if(src in C.myShip.fireTargets)
				C.myShip.fireTargets -= src
			else
				C.myShip.fireTargets |= src

		if(C && src == C.myShip)
			C.myShip.fireTargets.Cut()