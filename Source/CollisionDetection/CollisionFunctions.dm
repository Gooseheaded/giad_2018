






Ship
	proc
		GlobalCollision()
			//returns null if no collisions!
			//world<<"GLOBAL COLLISION CALL"
			if(z < 0 || z > world.maxz) return

			for(var/Collider/C in colliders)
				var/otherColliders[] = quadtreeRoots[z].GetCircleContents(C.pX, C.pY, C.radius)

				for(var/Collider/D in otherColliders)
					if(C.parent == D.parent) continue
					if(C.densityFlags &= 1)
						if(C.Intersects(D))
							return D.parent


		ShipShipCollision(Ship/B)
			for(var/Collider/C in colliders)
				for(var/Collider/D in B.colliders)
					if(C.densityFlags &= 1)
						if(C.Intersects(D))
							return B