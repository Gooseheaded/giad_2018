
proc
	Play_Sound(F, atom/source, randFreq = 0, volume=100, range=1200, falloff=64) //This is for playing one-off 3d sounds
		if(!F) return
		if(!source) return


		var/foreConstant = 32

		var/sound/S = sound(F)
		S.environment = 0
		S.volume = volume
		S.falloff=falloff + foreConstant

		source.PixelCoordsUpdate()


		if(randFreq)
			S.frequency = 1 + rand(-randFreq, randFreq) / 100

		for(var/client/C)
			var/mob/M = C.eye
			if(!M) continue

			if(M.z != source.z) continue
			M.PixelCoordsUpdate()

			var/vector/difVec = vec2(source.pX, source.pY).subtract(vec2(M.pX,M.pY))

			if(difVec.magnitudeSquared() > range*range) continue

			S.x = difVec.x
			S.y = difVec.y * sin(45)
			S.z = foreConstant

			C << S
