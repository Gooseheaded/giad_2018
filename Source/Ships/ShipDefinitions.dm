

Ship
	StarterCaravel
		icon = 'PlayerCaravel.dmi'
		icon_state = "ship"

		revSpeedLimit = -10
		passiveSpeedLimit = 50
		windSpeedBonusMult = 20

		//rotation speeds are in units of "degrees per second"
		rotationSpeedLimit = 40

		colliders = list(new/Collider(new/vector(0,0,0), new/vector(0,0,0), 13, 1), \
							new/Collider(new/vector(20,0,0), new/vector(0,0,0), 8, 1), \
							new/Collider(new/vector(-24,0,0), new/vector(0,0,0), 8, 1) )