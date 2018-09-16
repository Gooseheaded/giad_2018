/*
	These are simple defaults for your project.
 */


//here are the global variables

var
	gameTime //This is the duration that the game has been running, not including pauses, in seconds
	appTime //This is the duration that the app has been running, in seconds

	deltaTime = 1/world.fps
	frameDelay = world.tick_lag

	gameActiveAtoms[0] //This is a list of game objects that need frame updates
	appActiveAtoms[0] //This is a list of app objects that need frame objects.

	//gameActiveAtoms do not update when the game is paused.
	//appActiveAtoms update EVERY FRAME regardless of paused status.
	gamePaused

	frameSpeed = 1

	viewPWidth = 960
	viewPHeight = 540

	vector/windVector = new(0,0,0)

world
	fps = 60
	icon_size = 30

	view = "32x18"//1920x1080 default

	New()
		//initialize the collision quadtree
		InitQuadTrees()

		gamePaused = 1

		.=..()

		WorldInit()

		gamePaused = 0

		MainLoop()

proc
	InitQuadTrees()
		//initialize the collision quadtree
		quadtreeRoots.len = world.maxz

		var
			worldWidth = world.maxx * ICON_WIDTH
			worldHeight = world.maxy * ICON_HEIGHT


		for(var/i = 1; i <= world.maxz; i++)
			var/quadtree/root = new()
			root.min_x = 1
			root.min_y = 1
			root.max_x = worldWidth
			root.max_y = worldHeight
			root.z = i
			root.ComputeDims()
			quadtreeRoots[i] = root


	WorldInit()
		for(var/obj/Terrain/Rock/R)
			quadtreeRoots[1].AddCollider(R.collider)

		BuildTradeUpTable()
		BuildTradeDownTable()

		for(var/Dock/d)
			d.GenerateOffers(pick(1,2))





	MainLoop()

		while(1)

			sleep(0)
			sleep(frameDelay * frameSpeed)

			appTime += deltaTime

			for(var/atom/A in appActiveAtoms)
				if(appTime > A.tickUpdateTimer)
					A.TickUpdate()

			if(gamePaused)
				continue;

			gameTime += deltaTime

			for(var/client/C in gameActiveAtoms)
				C.TickUpdate()

			for(var/TradeRoute/R in gameActiveAtoms)
				R.TickUpdate()

			for(var/AI/A in gameActiveAtoms)
				A.TickUpdate()

			for(var/atom/A in gameActiveAtoms)
				if(gameTime > A.tickUpdateTimer)
					A.TickUpdate()



atom
	proc
		TickUpdate()

		PixelCoordsUpdate()
			pX = (x-1) * ICON_WIDTH
			pY = (y-1) * ICON_HEIGHT

	var
		tmp
			tickUpdateTimer
			//world pixel coordinates, where bottom left corner of the world is 1,1
			pX
			pY

			//temporary offset variables for collision checking
			cOffsetX
			cOffsetY

	movable
		step_size = 1

		PixelCoordsUpdate()
			.=..()
			pX += step_x
			pY += step_y

