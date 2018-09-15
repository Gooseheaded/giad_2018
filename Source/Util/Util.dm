
proc
	childsOf(path)
		return typesof(path) - path

	substringTo(string,char)
		//Returns a substring of "string" from the beginning of the string to the first instance of "char"
		var/i = findtext(string,char)
		if(!i) return string
		else return copytext(string,1,i)//+length(char))

	substringPast(string,char)
		//Returns a substring of "string" from the end of the first instance of "char" to the end of the string
		var/i = findtext(string,char)
		if(!i) return null
		else return copytext(string,i+length(char),0)

	screenLocToPixelCoords(screenLoc)
		var/tx = substringTo(screenLoc,",")
		var/ty = substringPast(screenLoc,",")

		var/px = substringPast(tx, ":")
		var/py = substringPast(ty, ":")
		tx = substringTo(tx, ":")
		ty = substringTo(ty, ":")

		tx = text2num(tx)-1
		ty = text2num(ty)-1
		px = text2num(px)
		py = text2num(py)
		return list(tx * ICON_WIDTH + px, ty * ICON_HEIGHT + py)

	signChar(num)
		if(num >= 0) return "+"
		//if(num < 0) return "-"

atom/movable
	proc
		pixelCenter() //This returns the center of this movable atom relative to step_x and step_y
			//returns a list(2) with the coordinates
			return list(bound_x + bound_width/2, bound_y + bound_height/2)

		pixelCenterVector() //This returns the center of this movable atom relative to step_x and step_y
			//returns a list(2) with the coordinates
			return vec2(bound_x + bound_width/2, bound_y + bound_height/2)

		iconCenter() //This returns the center of this movable atom's icon, relative to his own step_x and step_y
			//returns a list(2) with the coordinates
			var/icon/I = icon(src.icon)
			var/px = I.Width()/2 - pixel_x
			var/py = I.Height()/2 - pixel_y
			return list(px, py)

		pixelCoordsVector() //This returns this movable atom's pixel coordinates relative ot the bottom left corner of the map
			return vec2((x-1)*ICON_WIDTH + step_x + 1, (y-1)*ICON_HEIGHT + step_y + 1)
