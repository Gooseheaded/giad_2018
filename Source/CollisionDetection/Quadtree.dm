

var
	quadtreeRoots[0] //one root quadtree per Z depth


quadtree
	var
		z

		min_x
		min_y

		max_x
		max_y

		center_x
		center_y

		width
		height

		quadtree/children[0]
		quadtree/parent
		quadtree/root

		maxContents = 20
		contents[0]

	proc
		AddCollider(Collider/O)
			if(O.z != z) return

			var/ax = O.pX
			var/ay = O.pY
			var/ar = O.radius

			var/dx = ax - center_x
			var/dy = ay - center_y

			if(abs(dx) <= ar/2 + width/2 && abs(dy) <= ar/2 + height/2)
				if(children.len)
					/*
					I have children, so I'll let them deal with adding this.
					*/
					for(var/quadtree/child in children)
						child.AddCollider(O)

				else
					if(contents.len + 1 >= maxContents)
						Split()
						//now find the child that this belongs in and add it to them
						for(var/quadtree/child in children)
							child.AddCollider(O)

					else
						//shape intersects this. add it!
						contents |= O

		RemoveCollider(Collider/O, shouldPrune = 1)
			contents -= O

			if(children.len)
				for(var/quadtree/child in children)
					child.RemoveCollider(O, 0)

			if(shouldPrune)
				PruneChildren()

		Split() //create 4 child nodes
			children.Cut()

			var/quadtree/child

			var/w = max_x - min_x
			var/h = max_y - min_y

			child = new()
			child.z = src.z
			child.min_x = src.min_x
			child.min_y = src.min_y
			child.max_x = src.min_x + w/2
			child.max_y = src.min_y + h/2
			child.ComputeDims()
			child.parent = src
			child.root = src.root
			children += child

			child = new()
			child.z = src.z
			child.min_x = src.min_x + w/2
			child.min_y = src.min_y
			child.max_x = src.min_x + w
			child.max_y = src.min_y + h/2
			child.ComputeDims()
			child.parent = src
			child.root = src.root
			children += child

			child = new()
			child.z = src.z
			child.min_x = src.min_x
			child.min_y = src.min_y + h/2
			child.max_x = src.min_x + w/2
			child.max_y = src.min_y + h
			child.ComputeDims()
			child.parent = src
			child.root = src.root
			children += child

			child = new()
			child.z = src.z
			child.min_x = src.min_x + w/2
			child.min_y = src.min_y + h/2
			child.max_x = src.min_x + w
			child.max_y = src.min_y + h
			child.ComputeDims()
			child.parent = src
			child.root = src.root
			children += child

			for(var/Collider/O in contents)
				AddCollider(O)

			contents.Cut()

		ComputeDims()
			center_x = (min_x + max_x)/2
			center_y = (min_y + max_y)/2

			width = abs(max_x - min_x)
			height = abs(max_y - min_y)

		PruneChildren()
			var/emptyChildren = 0
			for(var/quadtree/child in children)
				if(child.children.len > 0)
					child.PruneChildren()
				else
					emptyChildren ++

			if(emptyChildren == 4)
				for(var/quadtree/child in children)
					del child

				children.Cut()

		GetRectContents(ax, ay, aw, ah)
			//ax, ay are x and y coordinates
			//aw and ah are width and height of rect

			var/outContents[0]

			if(children.len)
				/*
				go through all children and do this function for them
				*/

				for(var/quadtree/Q in children)
					//if the child intersects AABB bounds
					var
						dx = abs(ax - center_x)
						dy = abs(ay - center_y)

						w = width
						h = height

					if(dx <= aw/2 + w/2 && dy <= ah/2 + h/2)
						var/childContents[] = Q.GetRectContents(ax, ay, aw, ah)
						outContents |= childContents
			else
				outContents |= contents

			return outContents

		GetCircleContents(ax, ay, ar) //just treat the circle as a square
			return GetRectContents(ax, ay, ar, ar)