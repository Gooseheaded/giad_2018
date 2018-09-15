

client
	var
		Ship/myShip

		keys[0]

		speedMode = 0

	proc
		CreateStarterShip()
			if(mob) mob.loc = null

			if(myShip) del myShip

			world<<"CREATED A NEW SHIP THO"

			myShip = new/Ship/StarterCaravel()
			myShip.client = src

			myShip.loc = locate(10,10,1)
			myShip.PixelCoordsUpdate()
			myShip.CollidersUpdate()

			world<<"NEW SHIP: '[myShip]'"

			//set the camera
			camera = new(src, myShip)

			gameActiveAtoms += myShip
			gameActiveAtoms += src

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
