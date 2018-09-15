

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

	proc
		TickUpdate()
			NavToDest()

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
			if(forward.dot(difVecUnit) > 0.5 && dist > myShip.bigRadius / 2)
				speedMode = 1
			if(forward.dot(difVecUnit) > 0.7 && dist > myShip.bigRadius)
				speedMode = 2
			if(forward.dot(difVecUnit) > 0.9 && dist > myShip.bigRadius * 2)
				speedMode = 3

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