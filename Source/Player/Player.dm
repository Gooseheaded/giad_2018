

client
	var
		Ship/myShip

		keys[0]

		speedMode = 0

		list/resourcesHud = list()

	proc
		CreateStarterShip()
			if(mob) mob.loc = null

			if(myShip) del myShip

			world<<"CREATED A NEW SHIP THO"

			myShip = new/Ship/StarterCaravel()

			myShip.loc = locate(10,10,1)

			world<<"NEW SHIP: '[myShip]'"

			//set the camera
			camera = new(src, myShip)

			gameActiveAtoms += myShip
			gameActiveAtoms += src
			UpdateResourcesHud()

		UpdateResourcesHud()
			if (myShip == null)
				throw EXCEPTION("myShip cannot be null.")

			world << "Updating..."
			resourcesHud[RED_SPICE].maptext = "<b>x[myShip.cargo[RED_SPICE]]</b>"
			resourcesHud[GREEN_SPICE].maptext = "<b>x[myShip.cargo[GREEN_SPICE]]</b>"
			resourcesHud[BLUE_SPICE].maptext = "<b>x[myShip.cargo[BLUE_SPICE]]</b>"
			resourcesHud[CYAN_SPICE].maptext = "<b>x[myShip.cargo[CYAN_SPICE]]</b>"
			resourcesHud[MAGENTA_SPICE].maptext = "<b>x[myShip.cargo[MAGENTA_SPICE]]</b>"
			resourcesHud[BLACK_SPICE].maptext = "<b>x[myShip.cargo[BLACK_SPICE]]</b>"
			resourcesHud[YELLOW_SPICE].maptext = "<b>x[myShip.cargo[YELLOW_SPICE]]</b>"

	New()
		var/obj/redCounter = new()
		redCounter.screen_loc = "NORTH,WEST"
		redCounter.icon = 'Spices.dmi'
		redCounter.icon_state = RED_SPICE
		redCounter.maptext_x = 28
		resourcesHud[RED_SPICE] = redCounter
		screen.Add(redCounter)

		var/obj/greenCounter = new()
		greenCounter.screen_loc = "NORTH,WEST+2"
		greenCounter.icon = 'Spices.dmi'
		greenCounter.icon_state = GREEN_SPICE
		greenCounter.maptext_x = 28
		resourcesHud[GREEN_SPICE] = greenCounter
		screen.Add(greenCounter)

		var/obj/blueCounter = new()
		blueCounter.screen_loc = "NORTH,WEST+4"
		blueCounter.icon = 'Spices.dmi'
		blueCounter.icon_state = BLUE_SPICE
		blueCounter.maptext_x = 28
		resourcesHud[BLUE_SPICE] = blueCounter
		screen.Add(blueCounter)

		var/obj/cyanCounter = new()
		cyanCounter.screen_loc = "NORTH,WEST+6"
		cyanCounter.icon = 'Spices.dmi'
		cyanCounter.icon_state = CYAN_SPICE
		cyanCounter.maptext_x = 28
		resourcesHud[CYAN_SPICE] = cyanCounter
		screen.Add(cyanCounter)

		var/obj/magentaCounter = new()
		magentaCounter.screen_loc = "NORTH,WEST+8"
		magentaCounter.icon = 'Spices.dmi'
		magentaCounter.icon_state = MAGENTA_SPICE
		magentaCounter.maptext_x = 28
		resourcesHud[MAGENTA_SPICE] = magentaCounter
		screen.Add(magentaCounter)

		var/obj/yellowCounter = new()
		yellowCounter.screen_loc = "NORTH,WEST+10"
		yellowCounter.icon = 'Spices.dmi'
		yellowCounter.icon_state = YELLOW_SPICE
		yellowCounter.maptext_x = 28
		resourcesHud[YELLOW_SPICE] = yellowCounter
		screen.Add(yellowCounter)

		var/obj/blackCounter = new()
		blackCounter.screen_loc = "NORTH,WEST+12"
		blackCounter.icon = 'Spices.dmi'
		blackCounter.icon_state = BLACK_SPICE
		blackCounter.maptext_x = 28
		resourcesHud[BLACK_SPICE] = blackCounter
		screen.Add(blackCounter)

		..()

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