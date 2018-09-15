

client
	var
		Ship/myShip

		keys[0]

	proc
		CreateStarterShip()
			if(mob) mob.loc = null

			myShip = new/Ship/StarterCaravel()

			myShip.loc = locate(2,2,1)

			//set the camera
			camera = new(myShip)

			gameActiveAtoms += myShip
			gameActiveAtoms += src

	proc
		KeyDown(char)
			keys[char] = 1

		KeyUp(char)
			keys[char] = 0

		TickUpdate()

			//read input


			//affect the ship
