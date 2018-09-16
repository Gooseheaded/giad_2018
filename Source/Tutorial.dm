
Tutorial
	parent_type = /obj

	A
		icon = 'Tutorial1.png'
		screen_loc = "8,5"
		Click()
			usr.client.screen += new /Tutorial/B()
			del src
	B
		icon = 'Tutorial2.png'
		screen_loc = "8,5"
		Click()
			usr.client.screen += new /Tutorial/C()
			del src
	C
		icon = 'Tutorial3.png'
		screen_loc = "8,5"
		Click()
			usr.client.screen += new /Tutorial/D()
			del src
	D
		icon = 'Tutorial4.png'
		screen_loc = "8,5"
		Click()
			del src