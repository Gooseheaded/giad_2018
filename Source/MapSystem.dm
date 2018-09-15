
// Progress halted

WorldNode
	var
		x = 0
		y = 0
		name = ""
		nodeType = ""
		obj/display = null
		isExplored = FALSE

WorldGraph
	var
		nodes[][]

proc/GenerateWorld(size)
	throw EXCEPTION("Not implemented yet.")

	/*
	if (size < 5 || size > 10)
		throw EXCEPTION("World size cannot be less than 5 or greater than 10.")

	var/WorldGraph/newWorld = new()
	*/