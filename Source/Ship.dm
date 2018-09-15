

/*
This file contains definitions for the Ship class
Author: Anthony SuVasquez


*/

/*

A Ship has a left cannon and a right cannon, as well as a cargo hold.

It also has: Passive speed, Rotation Speed, and Wind Speed Bonus

*/

Ship
	step_size = 1

	parent_type = /obj
	animate_movement = 0

	appearance_flags = PIXEL_SCALE

	pixel_x = -45
	pixel_y = -45

	var
		cargo[0] //This is just a list of the items in the cargo
		cargoCapacity
		leftCannon
		rightCannon

		//linear speeds are in units of "Pixels per second"
		passiveSpeedLimit
		windSpeedBonusMult

		//rotation speeds are in units of "degrees per second"
		rotationSpeedLimit
		rotationSpeed


		//colliders is a list of collision objects.
		colliders

		shadowHeight = 5

		tmp
			//sub pixel coordinates for step_x and step_y
			subX = 0
			subY = 0

			//velocity and speed are in terms of "pixels per second"
			vector/velocity = new(75,0,0)
			currentSpeed
			lastSpeed

			//angle is in terms of "degrees"
			angle
			lastAngle


			wakeTimer
			wakeDelay = 0.25

	New()
		.=..()
		CreateShadow()

		spawn
			rotationSpeed = 100

			while(src)
				PhysicsStep()
				sleep(world.tick_lag)

	Del()
		for(var/Collider/C in colliders)
			del C
		..()

	proc
		CreateShadow()
			overlays.Cut()

			var/mutable_appearance/ma = new(src)
			ma.layer -= 0.1
			ma.color = "#000000"
			ma.alpha = 127
			ma.pixel_x = shadowHeight
			ma.pixel_y = -shadowHeight
			ma.blend_mode = BLEND_MULTIPLY
			ma.appearance_flags |= RESET_COLOR | RESET_ALPHA

			overlays += ma


		LinearStep(var/dt = deltaTime)

			var/velX = velocity.x * dt
			var/velY = velocity.y * dt

			var/subdx = round(subX + velX,1), subdy = round(subY + velY ,1)

			//run collision check
			cOffsetX = subdx
			cOffsetY = subdy

			if(GlobalCollision() != null)
				cOffsetX = 0
				cOffsetY = 0
				return 1

			//run phys
			subX += velX
			subY += velY

			subX -= subdx; subY -= subdy


			if(subdx > 0) step(src,EAST,subdx)

			if(subdx < 0) step(src,WEST,-subdx)

			if(subdy > 0) step(src,NORTH,subdy)

			if(subdy < 0) step(src,SOUTH,-subdy)


			pX = x * ICON_WIDTH + step_x
			pY = y * ICON_HEIGHT + step_y

			PixelCoordsUpdate()
			CollidersUpdate()

			cOffsetX = 0
			cOffsetY = 0
			lastSpeed = currentSpeed


		RotationStep(var/dt = deltaTime)
			angle += rotationSpeed * dt

			CollidersUpdate()

			if(GlobalCollision() != null)
				//if the rotation causes a collision, undo the rotation and return
				angle = lastAngle
				CollidersUpdate()
				return 1

			var/matrix/M = new()
			M.Turn(-angle)

			transform = M
			lastAngle = angle


		CollidersUpdate()
			//this function updates collider positions
			for(var/Collider/C in colliders)
				var/vector/cCoord = vec2(pX, pY)
				cCoord = cCoord.add(C.absoluteOffset)
				cCoord = cCoord.add(C.offset.rotateAboutAxis(vec3(0,0,1), angle))


				C.quadtree.RemoveCollider(C)
				C.pX = cCoord.x
				C.pY = cCoord.y

				quadtreeRoots[z].AddCollider(C)


		PhysicsStep(var/dt = deltaTime)
			//this function returns a nonzero if this physics step caused a collision.
			var/collisionState = 0


			if(LinearStep(dt))
				velocity.x = 0
				velocity.y = 0
				collisionState |= 1

			if(RotationStep(dt))
				rotationSpeed = 0
				collisionState |= 2


			if(gameTime > wakeTimer)
				wakeTimer = gameTime + wakeDelay
				if(velocity.x == 0 && velocity.y == 0) wakeTimer += wakeDelay * 2

				new /Wake(src)

			return collisionState


Wake //this is the wake particle that is emitted by ships
	parent_type = /obj
	blend_mode = BLEND_ADD

	var
		duration = 5

	New(Ship/S)
		.=..()
		icon = S.icon
		icon_state = "wake"
		alpha = 64
		loc = S.loc
		step_x = S.step_x
		step_y = S.step_y
		pixel_x = S.pixel_x
		pixel_y = S.pixel_y
		blend_mode = BLEND_ADD
		layer = S.layer - 0.2

		var/matrix/M = new()
		var/angle = rand(-180,180)
		M.Turn(angle)
		transform = M

		M.Scale(3,3)
		angle += rand(-5,5)
		M.Turn(angle)
		animate(src, transform = M, alpha = 0, time=duration*10)

		spawn(duration * 10)
			del src