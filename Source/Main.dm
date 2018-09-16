/*
	These are simple defaults for your project.
 */


world
	hub="Gooseheaded.TheShoresofAdora"


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
	AIpaused

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

		spawn(1)
			BuildTradeUpTable()
			BuildTradeDownTable()
			for(var/Dock/d)
				d.GenerateOffers(pick(1,2))

			RandomWorldEventLoop()
			BasicResourceGeneratorLoop()
			TextUpdateLoop()

		for(var/IslandCollider/I)
			I.Init()





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

			if(!AIpaused)
				for(var/TradeRoute/R in gameActiveAtoms)
					R.TickUpdate()

				for(var/AI/A in gameActiveAtoms)
					A.TickUpdate()

			for(var/atom/A in gameActiveAtoms)
				if(gameTime > A.tickUpdateTimer)
					A.TickUpdate()


client
	New()
		for(var/client/C)
			if(C != src)
				del src //THIS IS A FUCKIN SINGLEPLAYER GAME OK

		src << sound('OceanAmbiance.ogg', volume=10, repeat=1)

		.=..()

		var/obj/blackCounter = new()
		blackCounter.screen_loc = "NORTH,WEST"
		blackCounter.icon = 'Spices.dmi'
		blackCounter.icon_state = BLACK_SPICE
		blackCounter.maptext_x = 28
		blackCounter.maptext_width = 60
		blackCounter.layer = 50
		resourcesHud[BLACK_SPICE] = blackCounter
		screen.Add(blackCounter)

		var/obj/yellowCounter = new()
		yellowCounter.screen_loc = "NORTH,WEST+2"
		yellowCounter.icon = 'Spices.dmi'
		yellowCounter.icon_state = YELLOW_SPICE
		yellowCounter.maptext_x = 28
		yellowCounter.maptext_width = 60
		yellowCounter.layer = 50
		resourcesHud[YELLOW_SPICE] = yellowCounter
		screen.Add(yellowCounter)

		var/obj/redCounter = new()
		redCounter.screen_loc = "NORTH,WEST+4"
		redCounter.icon = 'Spices.dmi'
		redCounter.icon_state = RED_SPICE
		redCounter.maptext_x = 28
		redCounter.maptext_width = 60
		redCounter.layer = 50
		resourcesHud[RED_SPICE] = redCounter
		screen.Add(redCounter)

		var/obj/magentaCounter = new()
		magentaCounter.screen_loc = "NORTH,WEST+6"
		magentaCounter.icon = 'Spices.dmi'
		magentaCounter.icon_state = MAGENTA_SPICE
		magentaCounter.maptext_x = 28
		magentaCounter.maptext_width = 60
		magentaCounter.layer = 50
		resourcesHud[MAGENTA_SPICE] = magentaCounter
		screen.Add(magentaCounter)

		var/obj/blueCounter = new()
		blueCounter.screen_loc = "NORTH,WEST+8"
		blueCounter.icon = 'Spices.dmi'
		blueCounter.icon_state = BLUE_SPICE
		blueCounter.maptext_x = 28
		blueCounter.maptext_width = 60
		blueCounter.layer = 50
		resourcesHud[BLUE_SPICE] = blueCounter
		screen.Add(blueCounter)

		var/obj/cyanCounter = new()
		cyanCounter.screen_loc = "NORTH,WEST+10"
		cyanCounter.icon = 'Spices.dmi'
		cyanCounter.icon_state = CYAN_SPICE
		cyanCounter.maptext_x = 28
		cyanCounter.maptext_width = 60
		cyanCounter.layer = 50
		resourcesHud[CYAN_SPICE] = cyanCounter
		screen.Add(cyanCounter)

		var/obj/greenCounter = new()
		greenCounter.screen_loc = "NORTH,WEST+12"
		greenCounter.icon = 'Spices.dmi'
		greenCounter.icon_state = GREEN_SPICE
		greenCounter.maptext_x = 28
		greenCounter.maptext_width = 60
		greenCounter.layer = 50
		resourcesHud[GREEN_SPICE] = greenCounter
		screen.Add(greenCounter)

		screen.Add( new/obj/MapHudButton/ ())

		spawn(5)

			GameStart()

	proc
		GameStart()

			var/HomeIsland/H = locate()
			H.PixelCoordsUpdate()

			CreateStarterShip(vec2(H.pX, H.pY), H.z)

			screen += new/Tutorial/A()

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

