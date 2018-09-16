

Ship
	StarterCaravel
		icon = 'PlayerCaravel.dmi'
		icon_state = "ship"

		revSpeedLimit = -15
		passiveSpeedLimit = 50
		windSpeedBonusMult = 20

		//rotation speeds are in units of "degrees per second"
		rotationSpeedLimit = 40

		colliders = list(new/Collider(new/vector(0,0,0), new/vector(0,0,0), 13, 1), \
							new/Collider(new/vector(20,0,0), new/vector(0,0,0), 8, 1), \
							new/Collider(new/vector(-24,0,0), new/vector(0,0,0), 8, 1) )

		cannons = list(new/Cannon/Basic(null, 90), new/Cannon/Basic(null, -90))

	PirateSchooner
		icon = 'PirateSchooner.dmi'
		icon_state = "ship"

		isHostile = 1

		revSpeedLimit = -15
		passiveSpeedLimit = 75
		windSpeedBonusMult = 40

		maxHealth = 40
		health = 40

		//rotation speeds are in units of "degrees per second"
		rotationSpeedLimit = 80

		colliders = list(new/Collider(new/vector(0,0,0), new/vector(0,0,0), 10, 1), \
							new/Collider(new/vector(11,0,0), new/vector(0,0,0), 9, 1), \
							new/Collider(new/vector(-14,0,0), new/vector(0,0,0), 9, 1) )

		cannons = list(new/Cannon/Pirate(null, 67.5), new/Cannon/Pirate(null, -67.5))