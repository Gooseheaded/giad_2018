
Cannon
	var
		angle //this isn't fixed. this is relative to parent forward

		fireDelay
		fireTimer

		fireArc

		fireDamage

		fireInaccuracy
		range

		projSpeed

		Ship/parent

	proc
		FireAt(Ship/target)

			var/dx = target.pX - parent.pX
			var/dy = target.pY - parent.pY

			if(dx*dx+dy*dy > range*range) return 0
			//out of range. no pewpew

			var/vector/difVec = vec2(dx,dy)
			var/fAngle = difVec.toYaw()
			var/cAngle = angle + parent.angle

			if(!(fAngle-cAngle < fireArc && fAngle-cAngle > -fireArc))
				return 0

			//Im in range and in arc

			var/obj/Cannonball/O = new(parent, fAngle, projSpeed)


			fireTimer = gameTime + fireDelay



obj/Cannonball
	var
		damage
		Ship/parent

		radius = 4

		deathTimer = -1
		deathDelay = 5

		tmp
			vector/velocity
			subY
			subX

	New(Ship/s, angle, speed)
		parent = s

		loc = parent.loc
		step_x = parent.step_x
		step_y = parent.step_y

		gameActiveAtoms += src

	Del()
		gameActiveAtoms -= src
		..()

	TickUpdate()
		LinearStep()

		if(gameTime > deathTimer && deathTimer > 0)
			del src


	proc
		LinearStep(var/dt = deltaTime)
			if(velocity.x == 0 && velocity.y == 0) return

			var/velX = velocity.x * dt
			var/velY = velocity.y * dt

			var/subdx = round(subX + velX,1), subdy = round(subY + velY ,1)

			//run collision check
			cOffsetX = subdx
			cOffsetY = subdy

			var/colliders[] = quadtreeRoots[z].GetCircleContents(pX + cOffsetX, pY+cOffsetY, radius)
			var/atom/collided = null

			for(var/Collider/C in colliders)
				if(C.parent == parent) continue
				if(!istype(C, /Ship)) continue
				collided = C.parent

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

			cOffsetX = 0
			cOffsetY = 0

