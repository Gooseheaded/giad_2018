

/*
This file contains definitions for the Ship class
Author: Anthony SuVasquez


*/

/*

A Ship has a left cannon and a right cannon, as well as a cargo hold.

It also has: Passive speed, Rotation Speed, and Wind Speed Bonus

*/

Ship
	parent_type = /obj

	var
		cargo[0] //This is just a list of the items in the cargo
		cargoCapacity
		leftCannon
		rightCannon

		//linear speeds are in units of "Pixels per second"
		passiveSpeedLimit
		windSpeedBonusMult
		currentSpeed

		lastSpeed

		//rotation speeds are in units of "angles per second"
		rotationSpeedLimit
		rotationSpeed

		//angle is in terms of degrees
		angle
		lastAngle

		//colliders is a list of collision objects.
		colliders

		tmp
			//sub pixel coordinates for step_x and step_y
			subX
			subY

	Del()
		for(var/Collider/C in colliders)
			del C
		..()

	proc
		LinearStep(var/dt = deltaTime)
			var
				velX = cos(angle) * (currentSpeed + lastSpeed) / 2 * dt
				velY = cos(angle) * (currentSpeed + lastSpeed) / 2 * dt

			subX += velX
			subY += velY


			var/subdx = round(subX,1), subdy = round(subY,1)

			subX -= subdx; subY -= subdy

			var/success = 0

			if(subdx > 0)
				var/worked = !step(src,EAST,subdx)
				success |= worked

			if(subdx < 0)
				var/worked = !step(src,WEST,-subdx)
				success |= worked

			if(subdy > 0)
				var/worked = !step(src,NORTH,subdy)
				success |= worked

			if(subdy < 0)
				var/worked = !step(src,SOUTH,-subdy)
				success |= worked

			lastSpeed = currentSpeed

			pX = x * ICON_WIDTH + step_x
			pY = y * ICON_HEIGHT + step_y

			PixelCoordsUpdate()
			CollidersUpdate()

			return !success

		RotationStep(var/dt = deltaTime)
			angle += rotationSpeed * dt

			var/matrix/M = new()
			M.Turn(-angle)

			transform = M
			lastAngle = angle
			CollidersUpdate()

		CollidersUpdate()