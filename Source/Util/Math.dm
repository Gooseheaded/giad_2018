#define DIST(x, y) sqrt(x*x + y*y)


proc
	arctan(x)
		return arcsin(x/sqrt(1+x*x))

	arctan2(x,y)
		if(x > 0) return arctan(y/x)

		if(x < 0)
			if(y >= 0) return 180 + arctan(y/x)
			if(y < 0) return arctan(y/x) - 180

		if(y < 0) return -90
		if(y > 0) return 90
		return 0

	tan(angle)
		return sin(angle)/cos(angle)