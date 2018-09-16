
Cannon
	var
		name = "Cannon"

		angle //this isn't fixed. this is relative to parent forward

		fireDelay = 4
		fireTimer

		fireArc = 90

		fireDamage = 10

		fireInaccuracy = 3
		range = 400

		projSpeed = 300

		Ship/parent

		fireSound

	New(Ship/S, nAngle)
		.=..()
		parent = S
		if(S == null)
			if(usr && istype(usr, /Ship))
				parent = usr

		angle = nAngle

	proc
		CanFireAt(Ship/target)
			if(gameTime < fireTimer) return 0

			var/dx = target.pX - parent.pX
			var/dy = target.pY - parent.pY

			if(dx*dx+dy*dy > range*range) return 0
			//out of range. no pewpew

			var/vector/difVec = vec2(dx,dy)
			var/fAngle = difVec.toYaw()
			var/cAngle = angle + parent.angle
			var/dAngle = fAngle-cAngle

			if(dAngle > 180) dAngle -= 360
			if(dAngle < -180) dAngle += 360

			if(!(dAngle < fireArc && dAngle > -fireArc))
				return 0
			return 1

		FireAt(Ship/target)
			if(!CanFireAt(target)) return 0

			var/dx = target.pX - parent.pX
			var/dy = target.pY - parent.pY

			var/vector/difVec = vec2(dx,dy)
			var/fAngle = difVec.toYaw()
			//Im in range and in arc
			var/random = rand(-fireInaccuracy, fireInaccuracy)

			var/obj/Cannonball/O = new/obj/Cannonball(parent, fAngle + random, projSpeed, fireDamage)
			O.deathTimer = gameTime + projSpeed / range

			//play the fire sound
			if(fireSound)
				Play_Sound(fireSound, parent, 5, 100, 1800, 64) //This is for playing one-off 3d sounds

			fireTimer = gameTime + fireDelay
			return


	Basic
		name = "Basic Cannon"
		fireDelay = 3
		fireInaccuracy = 2
		fireDamage = 10
		fireArc = 45
		range = 400

	Pirate
		name = "Pirate Cannon"

		fireDelay = 4
		fireInaccuracy = 5
		fireDamage = 10
		range = 250
		fireArc = 67.5



obj/Cannonball
	animate_movement = 0
	icon = 'Cannonball.dmi'
	blend_mode = BLEND_ADD

	pixel_x = -15
	pixel_y = -15

	var
		damage
		Ship/parent

		radius = 2

		deathTimer = -1

		hitSound
		splashSound

		tmp
			vector/velocity
			subY
			subX

	New(Ship/s, angle, speed, ndamage)
		.=..()
		parent = s

		layer = parent.layer + 2

		loc = parent.loc
		step_x = parent.step_x
		step_y = parent.step_y

		damage = ndamage


		velocity = vec2(speed * cos(angle), speed * sin(angle))
		velocity = velocity.add(s.velocity)

		filters = filter(type="motion_blur", velocity.x / 2, velocity.y / 2)

		gameActiveAtoms += src

	Del()
		gameActiveAtoms -= src
		..()

	TickUpdate()
		LinearStep()


		if(deathTimer - gameTime < 0.25)
			src.alpha = 255 * (deathTimer - gameTime) / 0.25

		if(gameTime > deathTimer && deathTimer > 0)
			new/Wake(src)

			if(splashSound)
				Play_Sound(splashSound, src, 5, 100, 1800, 64)

			del src


	proc
		HitShip(Ship/S)

			if(S.health > 0)
				S.health -= damage

				if(S.health <= 0)
					S.Sink()

			if(hitSound)
				Play_Sound(hitSound, S, 5, 100, 1800, 64)

			world<<"HIT [S]: [S.health]"

			var/Explosion/E = new(src)
			var/matrix/M = new()
			M.Scale(0.5, 0.5)
			E.transform = M

			del src

		LinearStep(var/dt = deltaTime)
			if(velocity.x == 0 && velocity.y == 0) return

			var/velX = velocity.x * dt
			var/velY = velocity.y * dt

			var/subdx = round(subX + velX,1), subdy = round(subY + velY ,1)

			//run collision check
			cOffsetX = subdx
			cOffsetY = subdy

			var/colliders[] = quadtreeRoots[z].GetCircleContents(pX + cOffsetX, pY+cOffsetY, radius)

			for(var/Collider/C in colliders)
				if(C.parent == parent) continue
				if(!istype(C.parent, /Ship)) continue
				var/dx = C.pX - pX
				var/dy = C.pY - pY
				if(dx*dx+dy*dy < (radius+C.radius)*(radius+C.radius))
					HitShip(C.parent)

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

