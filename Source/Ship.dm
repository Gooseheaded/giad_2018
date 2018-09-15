

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
		list/cargo = list() //This is just a list of the items in the cargo
		cargoCapacity
		cannons[0]

		//linear speeds are in units of "Pixels per second"
		revSpeedLimit
		passiveSpeedLimit
		windSpeedBonusMult

		//rotation speeds are in units of "degrees per second"
		rotationSpeedLimit


		//colliders is a list of collision objects.
		list/colliders[]

		shadowHeight = 5

		client/client

		tmp
			//sub pixel coordinates for step_x and step_y
			subX = 0
			subY = 0

			//velocity and speed are in terms of "pixels per second"
			vector/velocity = new(0,0,0)
			currentSpeed
			lastSpeed

			rotationSpeed

			//angle is in terms of "degrees"
			angle
			lastAngle


			wakeTimer
			wakeDelay = 0.25
			wakeLongDelay = 0.6

			drag = 0.75

			vector/forward = new(1,0,0)

			bigRadius = 70 //this is for wide collision checks.

	New()
		.=..()
		CreateShadow()

		// Initial loadout
		cargo[RED_SPICE] = rand(10,20)
		cargo[YELLOW_SPICE] = rand(10,20)
		cargo[BLUE_SPICE] = rand(10,20)
		cargo[CYAN_SPICE] = rand(10,20)
		cargo[MAGENTA_SPICE] = rand(10,20)
		cargo[GREEN_SPICE] = rand(10,20)
		cargo[BLACK_SPICE] = rand(10,20)

		for(var/Collider/C in colliders)
			C.parent = src

		PixelCoordsUpdate()
		CollidersUpdate()

	Del()
		for(var/Collider/C in colliders)
			del C

		gameActiveAtoms -= src
		..()

	TickUpdate()
		//handle accelerations here
		var/vector/acceleration = new(currentSpeed,0,0)
		acceleration = acceleration.rotateAboutAxis(vec3(0,0,1) , angle)

		velocity = velocity.multiply(1-drag)
		velocity = velocity.add(acceleration)

		if(forward.dot(windVector) > 0)
			acceleration = new(windSpeedBonusMult * forward.dot(windVector),0,0)
			velocity = velocity.add(acceleration)


		//run the physics
		PhysicsStep()

		//if the physics failed, do a collision event?


	proc
		SetSpeedMode(mode)
			switch(mode)
				if(-1) currentSpeed = revSpeedLimit
				if(0) currentSpeed = 0
				if(1) currentSpeed = passiveSpeedLimit / 4
				if(2) currentSpeed = passiveSpeedLimit / 2
				if(3) currentSpeed = passiveSpeedLimit

		SetRotationMode(rotationMode, speedMode)
			var/rSpeed = rotationSpeedLimit * rotationMode
			if(speedMode < 1)
				rSpeed /= 2

			rotationSpeed = rSpeed

		CreateShadow()
		/*
			ship.filters = filter(type="drop_shadow", x=shadowHeight, y=-shadowHeight,\
				size = 2, offset=2, color="F000000")
		*/

			overlays.Cut()

			var/mutable_appearance/ma = new(src)
			ma.layer -= 0.1
			ma.color = "#000000"
			ma.alpha = 160
			ma.pixel_x = shadowHeight
			ma.pixel_y = -shadowHeight
			ma.blend_mode = BLEND_MULTIPLY
			ma.appearance_flags |= RESET_COLOR | RESET_ALPHA
			ma.filters += filter(type="blur", size = 2)

			overlays += ma



		LinearStep(var/dt = deltaTime)
			if(velocity.x == 0 && velocity.y == 0) return

			var/velX = velocity.x * dt
			var/velY = velocity.y * dt

			var/subdx = round(subX + velX,1), subdy = round(subY + velY ,1)

			//run collision check
			cOffsetX = subdx
			cOffsetY = subdy

			var/atom/collided = GlobalCollision()

			if(collided != null)
				cOffsetX = 0
				cOffsetY = 0
				return collided

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
			if(rotationSpeed == 0) return

			angle += rotationSpeed * dt

			CollidersUpdate()

			var/atom/collided = GlobalCollision()
			if(collided != null)
				//if the rotation causes a collision, undo the rotation and return
				angle = lastAngle
				CollidersUpdate()
				return collided

			forward = vec3(1,0,0)
			forward = forward.rotateAboutAxis(vec3(0,0,1), angle)

			var/matrix/M = new()
			M.Turn(-angle)

			transform = M
			lastAngle = angle


		CollidersUpdate()
			//this function updates collider positions

			for(var/Collider/C in colliders)

				if(C.quadtree) C.quadtree.RemoveCollider(C)

				var/vector/cCoord = vec3(pX, pY, 0)
				cCoord = cCoord.add(C.absoluteOffset)
				cCoord = cCoord.add(C.offset.rotateAboutAxis(vec3(0,0,1), angle))

				C.pX = cCoord.x
				C.pY = cCoord.y
				C.z = src.z

				if(z > 0 && quadtreeRoots.len >= z && quadtreeRoots[z] != null)
					quadtreeRoots[z].AddCollider(C)


		PhysicsStep(var/dt = deltaTime)
			//this function returns a nonzero if this physics step caused a collision.
			var/collisionState = 0


			var/atom/collideLinear = LinearStep(dt)
			var/atom/collideRotation = RotationStep(dt)

			if(collideLinear)
				velocity.x = 0
				velocity.y = 0
				collisionState |= 1

				currentSpeed = 0
				if(client) client.speedMode = 0

				var/vector/accel = vec2(src.pX - collideLinear.pX, src.pY - collideLinear.pY)
				accel.scaleToMagnitude(20)

				velocity = velocity.add(accel)


			if(collideRotation)
				rotationSpeed = 0
				collisionState |= 2

				velocity.x = 0
				velocity.y = 0

				currentSpeed = 0
				if(client) client.speedMode = 0

				var/vector/accel = vec2(src.pX - collideRotation.pX, src.pY - collideRotation.pY)
				accel.scaleToMagnitude(10)

				velocity = velocity.add(accel)


			if(gameTime > wakeTimer)
				wakeTimer = gameTime + wakeDelay + wakeLongDelay * (1 - currentSpeed / passiveSpeedLimit)

				new /Wake(src)

			return collisionState

		GetCurrentCargo()
			var/sum = 0
			for(var/i in cargo)
				sum += cargo[i]
			return sum

		CanMakeTrade(TradeOffer/offer)
			if(cargo[offer.inputProduct] < offer.inputAmount) return 0
			var/cargoAmount = GetCurrentCargo()

			if(cargoAmount - offer.inputAmount + offer.outputAmount > cargoCapacity) return 0

			return 1


Wake //this is the wake particle that is emitted by ships
	parent_type = /obj
	blend_mode = BLEND_ADD

	mouse_opacity = 0

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

		WaterEffect()


		spawn(duration * 10)
			del src