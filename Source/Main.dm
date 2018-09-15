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

world
	fps = 60
	icon_size = 30

proc
	MainLoop()

		while(1)


			sleep(0)
			sleep(frameDelay)

			appTime += deltaTime

			for(var/atom/A in appActiveAtoms)
				if(appTime > A.tickUpdateTimer)
					A.TickUpdate()

			if(gamePaused)
				continue;

			gameTime += deltaTime

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
		tickUpdateTimer
		//world pixel coordinates, where bottom left corner of the world is 1,1
		pX
		pY

	movable
		PixelCoordsUpdate()
			.=..()
			pX += step_x
			pY += step_y
