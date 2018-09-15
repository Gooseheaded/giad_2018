vector
	var
		x
		y
		z

	New()
		.=..()

		if(args.len == 3)
			x = args[1]
			y = args[2]
			z = args[3]

		else if(args.len == 2) //yaw pitch format
			var/yaw = args[1]
			var/pitch = args[2]

			x = cos(yaw) * cos(pitch)
			y = sin(yaw) * cos(pitch)
			z = sin(pitch)

	proc
		dot(vector/v)
			return x*v.x + y*v.y + z*v.z

		cross(vector/v)
			return new/vector(y * v.z - z * v.y, -x * v.z + z * v.x, x * v.y - y * v.x)

		magnitude()
			return sqrt(x*x + y*y + z*z)

		magnitudeSquared()
			return (x*x + y*y + z*z)

		unit()
			var/mag = magnitudeSquared()
			if(mag == 1) return src
			mag = 1/sqrt(mag)
			return new/vector(x*mag, y*mag, z*mag)

		projectOnto(vector/b) //src projected unto b
			var/ab = src.dot(b)
			var/bb = b.dot(b)
			return b.multiply(ab/bb)

		matrixMultiply(matrix/m)
			var/x1 = x * m.a + y * m.b + z * m.c
			var/y1 = x * m.d + y * m.e + z * m.f
			var/z1 = z
			return new/vector(x1, y1, z1)

		multiply(scalar)
			return new/vector(x * scalar, y * scalar, z * scalar)

		scaleToMagnitude(magnitude)
			return multiply(magnitude/magnitude())

		add(vector/v) //src + v
			return new/vector(x + v.x, y + v.y, z + v.z)

		subtract(vector/v) //src - v
			return new/vector(x - v.x, y - v.y, z - v.z)

		randomPerpendicular()
			var/vector/random = new(rand(), rand(), rand())
			var/ab = src.dot(random)
			var/bb = src.dot(src)

			return random.subtract(src.multiply(ab/bb))

		rotateAboutAxis(vector/u, angle)
			u = u.unit()

			var/dot = src.dot(u)
			if(dot*dot == src.magnitudeSquared()) return clone()

			var/cos = cos(angle)
			var/sin = sin(angle)
			var/nx = x * (cos + u.x * u.x * (1-cos)) \
				+ y * (u.x * u.y * (1-cos) - u.z * sin) \
				+ z * (u.x * u.z * (1-cos) + u.y * sin)

			var/ny = x * (u.y * u.x * (1-cos) + u.z * sin) \
				+ y * (cos + u.y * u.y * (1-cos))\
				+ z * (u.y * u.z * (1-cos) - u.x * sin)

			var/nz = x * (u.z * u.x * (1-cos) - u.y * sin) \
				+ y * (u.z * u.y * (1-cos) + u.x * sin) \
				+ z * (cos + u.z * u.z * (1-cos))

			return new/vector(nx, ny, nz)

		clone()
			return multiply(1)

		toYaw()
			return arctan2(x,y)

		toString()
			return "\<[x], [y], [z]>"

		toList()
			return list(x, y, z)

proc
	vec3(x=0, y=0, z=0)
		return new/vector(x,y,z)

	vec2(x=0, y=0)
		return new/vector(x,y,0)