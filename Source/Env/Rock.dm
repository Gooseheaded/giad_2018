

obj/Terrain
	Rock
		//filters = filter(type="outline",size=1,color="#BBBBBB")
		icon = 'Rocks.dmi'
		pixel_x = -30
		pixel_y = -30

		var
			radius = 24
			Collider/collider

			shadowHeight = 5

		New()
			.=..()
			PixelCoordsUpdate()

			CreateShadow()
			CreateDeepShadow()

			var/matrix/M = new()
			M.Turn(rand(-180,180))
			transform = M

			spawn(1)
				collider = new()
				collider.parent = src
				collider.pX = pX
				collider.pY = pY
				collider.radius = src.radius
				collider.densityFlags = 3
				collider.z = src.z

				quadtreeRoots[z].AddCollider(collider)


		proc
			CreateShadow()
				world<<"CREATING SHADOW??"
				overlays.Cut()

				var/mutable_appearance/ma = new(src)
				ma.filters = null
				ma.layer -= 0.1
				ma.color = "#000000"
				ma.alpha = 160
				ma.pixel_x = shadowHeight
				ma.pixel_y = -shadowHeight
				ma.blend_mode = BLEND_MULTIPLY
				ma.filters += filter(type="blur", size = 2)

				overlays += ma


			CreateDeepShadow()
				var/obj/O = new()
				O.loc = src.loc
				O.mouse_opacity = 0
				O.step_x = src.step_x
				O.step_y = src.step_y

				var/mutable_appearance/ma = new(src)
				ma.filters = null
				ma.layer -= 1
				ma.color = "#000000"
				ma.alpha = 32
				ma.blend_mode = BLEND_MULTIPLY
				ma.filters += filter(type="blur", size = radius)

				var/matrix/M = new()
				M.Scale(2)
				M.Turn(rand(-180,180))
				ma.transform = M

				//O.appearance = ma
				O.WaterEffect(4)
				O.appearance = ma
				O.alpha = rand(24,48)