

Collider
	var
		atom/parent

		shapeType = 0 //0 for square, 1 for circle

		vector/offset
		vector/absoluteOffset

		z

		radius

		quadtree/quadtree

		pX
		pY

		densityFlags //density flags? :O These are bitflags
		//1 - collides with ships
		//2 - island avoidance collider. This is for near island warnings and AI pathfinding
		//

	Del()
		if(quadtree)
			quadtree.RemoveCollider(src)

		..()

	New(vector/nOffset = new(0,0,0), vector/nAbsoluteOffset = new(0,0,0), nRadius = 1, nDensity = 1)
		.=..()
		offset = nOffset
		absoluteOffset = nAbsoluteOffset
		radius = nRadius
		densityFlags = nDensity

	proc
		Intersects(Collider/C)
			var/dx = C.pX - pX - parent.cOffsetX
			var/dy = C.pY - pY - parent.cOffsetY
			var/r = C.radius + radius
			return r*r > dx*dx+dy*dy




/*
An IslandCollider is simply the obejct that we place on the map that represents collision primitives.
It will create the appropriate primitive and link it to the island.
*/


IslandCollider
	parent_type = /obj

	var
		radius
		islandID

	proc
		Init()
			PixelCoordsUpdate()

			var/Dock/dock //find the island

			//now create a collider

			var/Collider/collider = new()
			collider.radius = radius
			collider.parent = dock

			collider.pX = pX
			collider.pY = pY

			quadtreeRoots[z].AddCollider(collider)

			del src