
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
