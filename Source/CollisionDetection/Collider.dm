

Collider
	var
		atom/parent

		shapeType = 0 //0 for square, 1 for circle

		vector/offset = new(0,0)
		vector/absoluteOffset = new(0,0)

		z

		radius

		quadtree/quadtree

		pX
		pY