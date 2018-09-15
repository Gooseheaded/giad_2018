

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

		//rotation speeds are in units of "degrees per second"
		rotationSpeedLimit
		rotationSpeed


		//colliders is a list of collision objects.
		colliders

		tmp
			//sub pixel coordinates for step_x and step_y
			subX
			subY

			//velocity and speed are in terms of "pixels per second"
			vector/velocity = new(0,0)
			currentSpeed
			lastSpeed

			//angle is in terms of "degrees"
			angle
			lastAngle


	Del()
		for(var/Collider/C in colliders)
			del C
		..()

	proc
		LinearStep(var/dt = deltaTime)

			var/subdx = round(subX + velocity.x,1), subdy = round(subY + velocity.y,1)

			//run collision check
			cOffsetX = subdx
			cOffsetY = subdy

			if(GlobalCollision() != null)
				cOffsetX = 0
				cOffsetY = 0
				return 1

			//run phys
			subX += velocity.x
			subY += velocity.y

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

			return collisionState