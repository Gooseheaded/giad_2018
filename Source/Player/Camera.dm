client
	perspective = EYE_PERSPECTIVE

	var
		camera/camera

camera
	parent_type = /obj

	density = 0
	invisibility = 101

	bound_width = 1
	bound_height = 1

	var
		atom/movable/target
		tweenSpeed = 0.5 * 1.8
		tweenThreshhold = 1
		client/parent

		vector/velocity = new(0,0,0)

		tmp
			subX
			subY

	New(client/client, atom/movable/A)
		target = A

		loc = A.loc

		step_x = A.step_x + A.bound_x + A.bound_width/2
		step_y = A.step_y + A.bound_y + A.bound_height/2


		parent = client

		parent.eye = src
		parent.camera = src

		appActiveAtoms += src

	Del()
		if(parent) parent.eye = target
		appActiveAtoms -= src
		.=..()

	TickUpdate()
		.=..()
		//move towards center
		if(!target) return

		if(z == target.z)

			var/targetCenter[] = target.pixelCenter()

			var/vector
				targetPosition = target.pixelCoordsVector()
				myPosition = pixelCoordsVector()

			targetPosition.x += targetCenter[1]
			targetPosition.y += targetCenter[2] + target.pixel_z

			var/minX = 1 + viewPWidth/2
			var/minY = 1 + viewPHeight/2
			var/maxX = world.maxx * ICON_WIDTH - viewPWidth/2
			var/maxY = world.maxy * ICON_HEIGHT - viewPHeight/2

			if(minX >= 0)
				if(targetPosition.x < minX)
					targetPosition.x = minX

			if(minY >= 0)
				if(targetPosition.y < minY)
					targetPosition.y = minY

			if(maxX >= 0)
				if(targetPosition.x > maxX)
					targetPosition.x = maxX

			if(maxY >= 0)
				if(targetPosition.y > maxY)
					targetPosition.y = maxY

			velocity = targetPosition.subtract(myPosition)

			if(velocity.magnitudeSquared() >= tweenThreshhold*tweenThreshhold)
				velocity = velocity.multiply(tweenSpeed)

				velocity.x = round(velocity.x,1)
				velocity.y = round(velocity.y,1)

				LinearStep()

			else
				if(velocity.x != 0 && velocity.y != 0)
					velocity.x = 0
					velocity.y = 0

					loc = target.loc
					step_x = target.step_x + target.bound_x + target.bound_width/2
					step_y = target.step_y + target.bound_y + target.bound_height/2 + target.pixel_z

		else
			z = target.z

			velocity.x = 0
			velocity.y = 0

			loc = target.loc
			step_x = target.step_x + target.bound_x + target.bound_width/2
			step_y = target.step_y + target.bound_y + target.bound_height/2 + target.pixel_z


	proc

		LinearStep(var/dt = deltaTime)
			var/velX = velocity.x * dt
			var/velY = velocity.y * dt

			var/subdx = round(subX + velX,1), subdy = round(subY + velY ,1)

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

			cOffsetX = 0
			cOffsetY = 0