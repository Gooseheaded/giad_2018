
#define DEBUG
#define DEBUGPRINT



//show the debugging window upon client login

client
	New()
		.=..()
		winset(src,"_DEBUG","is-visible=true")

	verb
		newship()
			CreateStarterShip()

		testQuadTree()
			quadtreeRoots[1].ToString()

		worldinit()
			WorldInit()

		GAMEPAUSE()
			gamePaused = !gamePaused
			if(gamePaused)
				world<<"GAME PAUSED"
			else
				world<<"GAME UNPAUSED"


		AIPAUSE()
			AIpaused = !AIpaused
			if(AIpaused)
				world<<"AI PAUSED"
			else
				world<<"AI UNPAUSED"

		setFrameSpeed(var/speed as num)
			frameSpeed = speed
			world<<"FRAME SPEED SET TO: [speed]"

	var
		AI/myAI

	verb
		SpawnAI()
			myAI = new()
			myAI.myShip = new/Ship/StarterCaravel()

			myAI.myShip.loc = locate(15,15,1)
			myAI.myShip.PixelCoordsUpdate()
			myAI.myShip.CollidersUpdate()

			gameActiveAtoms += myAI
			gameActiveAtoms += myAI.myShip

		SpawnPirateAI()
			var/AI/PirateAI/AI = new()
			AI.myShip = new/Ship/PirateSchooner()

			AI.myShip.loc = locate(20,20,1)
			AI.myShip.PixelCoordsUpdate()
			AI.myShip.CollidersUpdate()

			gameActiveAtoms += AI
			gameActiveAtoms += AI.myShip


turf
	DblClick(loc, con, params)
		.=..()
		var/client/client = usr.client
		if(client)
			if(client.myAI)
				PixelCoordsUpdate()
				client.myAI.longDestination = vec2(src.pX, src.pY)
				world<<"TRYING TO MOVE THE AI?: [client.myAI.longDestination.toString()]"