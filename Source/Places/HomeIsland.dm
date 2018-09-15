
HomeIsland
	parent_type = /obj

	icon = 'Placeholders.dmi'
	icon_state = "Home"

	New()
		icon = 'HomeDock.png'
		pixel_x -= 62
		pixel_y -= 53

	Click()
		DisplayHomebankingMenu(usr.client, src)