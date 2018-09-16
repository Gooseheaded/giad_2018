

AI
	/*
	the AI actor  behaves like a client, in that it holds a reference to its ship and sends commands to it.
	*/
	var
		Ship/myShip
		Ship/attackTarget = null

		vector/avoidDestination = null //This is the immediate destination. For things like collision avoidance
		avoidTimer = 0

		vector/longDestination = null //This is the long destination. For things like
		navThreshold = 5

		maxSpeedMode = 3

		TradeRoute/tradeRoute

	Del()
		if(tradeRoute)
			tradeRoute.RemoveShip(src)

		gameActiveAtoms -= src

		..()

	proc
		TickUpdate()
			if(myShip.isDead) del src

			if(longDestination)
				var/dx = longDestination.x - myShip.pX
				var/dy = longDestination.y - myShip.pY
				if(dx*dx+dy*dy > navThreshold)
					NavToDest()
				else
					myShip.rotationSpeed = 0
					myShip.SetSpeedMode(0)
					longDestination = null


		SetDockDestination(Dock/D)
			if(myShip == null) return

			D.PixelCoordsUpdate()

			longDestination = vec2(D.pX, D.pY)

			//now do a collision check at the dock
			var/colliders[] = quadtreeRoots[myShip.z].GetCircleContents(D.pX, D.pY, myShip.bigRadius)
			for(var/Collider/C in colliders)
				if(C.parent == myShip) continue
				if((C.densityFlags & 1) == 0) continue
				//there's a collision there. Instead just wait around...
				longDestination = GetEmptyLocation(longDestination, myShip.bigRadius)


		GetEmptyLocation(vector/loc, radius, densityMask = 1, iterations = 1)
			//this function will find an empty position to put a circle of the given radius
			var/vector/dest = new(0, 0, loc.z)
			var/hasCollision = 0
			dest.x = loc.x + rand(-radius * iterations, radius * iterations)
			dest.y = loc.y + rand(-radius * iterations, radius * iterations)
			var/maxIterations = 50

			do{
				var/colliders[] = quadtreeRoots[myShip.z].GetCircleContents(dest.x, dest.y, radius)
				for(var/Collider/C in colliders)
					if(C.parent == myShip) continue
					if((C.densityFlags & densityMask) == 0) continue

					var/dx = C.pX - dest.x
					var/dy = C.pY - dest.y
					if(dx*dx+dy*dy > (C.radius + radius) * (C.radius + radius)) continue

					hasCollision = 1
					break


				if(hasCollision)
					iterations ++
					dest.x = loc.x + rand(-radius * iterations, radius * iterations)
					dest.y = loc.y + rand(-radius * iterations, radius * iterations)

			}while(hasCollision && iterations < maxIterations)

			return dest


		NavToDest(var/vector/destination = longDestination)
			if(myShip == null) return
			if(destination == null) return

			var/vector/forward = myShip.forward.multiply(1)
			var/vector/difVec = vec2(destination.x - myShip.pX, destination.y - myShip.pY)

			//navigate to destination.
			//This is an AI step that updates its commands to the ship to get to the destination...


			//first things first is to see if the ship is in any island colliders

			if(gameTime > avoidTimer)
				del avoidDestination

			var/allColliders[] =  quadtreeRoots[myShip.z].GetCircleContents(myShip.pX, myShip.pY, myShip.bigRadius)

			//if I have island colliders, I should move away from the island.
			for(var/Collider/C in allColliders)
				if(C.parent == myShip) continue
				if((C.densityFlags & 3) == 0) continue

				var/dx = C.pX - myShip.pX
				var/dy = C.pY - myShip.pY
				if(dx*dx+dy*dy > (myShip.bigRadius + C.radius) * (myShip.bigRadius + C.radius)) continue


				var/vector/avoidVec = vec2(C.pX - myShip.pX, C.pY - myShip.pY)
				if(difVec.magnitudeSquared() < avoidVec.magnitudeSquared()) continue
				if(myShip.velocity.dot(avoidVec) < 0) continue

				var/vector/destDir = vec2(destination.x - C.pX, destination.y - C.pY)



				//I found some colliders...
				avoidDestination = vec2(myShip.pX, myShip.pY)
				avoidDestination = avoidDestination.add(avoidVec.scaleToMagnitude(-myShip.bigRadius))
				avoidDestination = avoidDestination.add(destDir.scaleToMagnitude(myShip.bigRadius * 2))

				if(rand() > 0.5)
					avoidDestination = avoidDestination.add(avoidVec.cross(vec3(0,0,1)).scaleToMagnitude(myShip.bigRadius))
				else
					avoidDestination = avoidDestination.add(avoidVec.cross(vec3(0,0,1)).scaleToMagnitude(myShip.bigRadius))

				avoidTimer = gameTime + 1

			if(avoidDestination)
				destination = avoidDestination
				difVec = vec2(destination.x - myShip.pX, destination.y - myShip.pY)

			//I should set my ship speed depending on if I'm pointing towards the destination
			var/dist = difVec.magnitude()
			var/vector/difVecUnit = difVec.unit()

			var/speedMode = 0

			if(forward.dot(difVecUnit) < -0.7)
				speedMode = -1
			if(forward.dot(difVecUnit) > 0.3 && dist > myShip.bigRadius / 2)
				speedMode = 1
			if(forward.dot(difVecUnit) > 0.7 && dist > myShip.bigRadius)
				speedMode = 2
			if(forward.dot(difVecUnit) > 0.9 && dist > myShip.bigRadius * 2)
				speedMode = 3

			if(speedMode > maxSpeedMode) speedMode = maxSpeedMode

			myShip.SetSpeedMode(speedMode)

			//I should set my rotation towards the destination
			var/destAngle = difVec.toYaw()
			var/diffAngle = destAngle - myShip.angle

			if(diffAngle > 180) diffAngle -= 360
			if(diffAngle < -180) diffAngle += 360

			diffAngle *= 0.75

			if(diffAngle < -myShip.rotationSpeedLimit) diffAngle = -myShip.rotationSpeedLimit
			if(diffAngle > myShip.rotationSpeedLimit) diffAngle = myShip.rotationSpeedLimit

			myShip.rotationSpeed = diffAngle


		DepositCargoHome()
			for(var/i in myShip.cargo)
				for(var/client/C) //yep
					C.homebank[i] += myShip.cargo[i]
					myShip.cargo[i] = 0



	PlayerAI
		TickUpdate()
			if(myShip.isDead) del src

			UpdateFireTargets()

			.=..()

		proc
			UpdateFireTargets()
				myShip.fireTargets.Cut()

				if(!myShip.cannons.len) return

				for(var/Ship/S)
					if(!S.isHostile) continue
					if(S.isDocked) continue

					for(var/Cannon/C in myShip.cannons)
						if(C.CanFireAt(S))
							myShip.fireTargets += S
							break




	PirateAI
		var
			Ship/chaseTarget

		TickUpdate()
			if(myShip.isDead) del src

			//if I don't have anything to do, find the nearest player vessel...
			if(chaseTarget && chaseTarget.isDocked)
				chaseTarget = null

			if(!chaseTarget)
				myShip.fireTargets.Cut()
				longDestination = null

				FindNewTarget()

			if(chaseTarget)
				myShip.fireTargets = list(chaseTarget)

				if(longDestination)
					var/dx = longDestination.x - chaseTarget.pX
					var/dy = longDestination.y - chaseTarget.pY
					if(DIST(dx, dy) > 120)
						longDestination = null

				if(!longDestination)
					longDestination = GetEmptyLocation(vec2(chaseTarget.pX, chaseTarget.pY), myShip.bigRadius, 1, 2)

				if(longDestination)
					var/dx = chaseTarget.x - myShip.pX
					var/dy = chaseTarget.y - myShip.pY

					if(DIST(dx, dy) < 250)
						longDestination = null


			.=..()

		proc
			FindNewTarget()
				var/Ship/nearestTarget

				for(var/Ship/S)
					if(S.isDocked) continue
					if(S.isHostile) continue
					if(!nearestTarget) nearestTarget = S
					else
						var/dx = S.pX - myShip.pX
						var/dy = S.pY - myShip.pY

						var/tx = nearestTarget.pX - myShip.pX
						var/ty = nearestTarget.pY - myShip.pY

						if(dx*dx+dy*dy < tx*tx+ty*ty)
							nearestTarget = S

				chaseTarget = nearestTarget


proc
	SpawnPirates(vector/location, number)
		for(var/i = 0; i < number; i++)
			var/AI/PirateAI/AI = new()
			AI.myShip = new/Ship/PirateSchooner()

			location = AI.GetEmptyLocation(vec2(location.x, location.y), AI.myShip.bigRadius, 1, 2)

			AI.myShip.loc = locate(location.x / ICON_WIDTH,location.x / ICON_HEIGHT,1)
			AI.myShip.step_x = location.x % ICON_WIDTH
			AI.myShip.step_y = location.x % ICON_HEIGHT

			AI.myShip.PixelCoordsUpdate()
			AI.myShip.CollidersUpdate()

			gameActiveAtoms += AI
			gameActiveAtoms += AI.myShip