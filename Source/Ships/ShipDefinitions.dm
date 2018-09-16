

Ship
	StarterCaravel
		icon = 'PlayerCaravel.dmi'
		icon_state = "ship"

		revSpeedLimit = -15
		passiveSpeedLimit = 50
		windSpeedBonusMult = 20

		//rotation speeds are in units of "degrees per second"
		rotationSpeedLimit = 40

		cargoCapacity = 10

		colliders = list(new/Collider(new/vector(0,0,0), new/vector(0,0,0), 13, 1), \
							new/Collider(new/vector(20,0,0), new/vector(0,0,0), 8, 1), \
							new/Collider(new/vector(-24,0,0), new/vector(0,0,0), 8, 1) )

		cannons = list(new/Cannon/Basic(null, 90), new/Cannon/Basic(null, -90))

	NPCCaravel
		icon = 'PlayerCaravel.dmi'
		icon_state = "ship"

		revSpeedLimit = -15
		passiveSpeedLimit = 50
		windSpeedBonusMult = 20

		cargoCapacity = 10

		//rotation speeds are in units of "degrees per second"
		rotationSpeedLimit = 40

		colliders = list(new/Collider(new/vector(0,0,0), new/vector(0,0,0), 13, 1), \
							new/Collider(new/vector(20,0,0), new/vector(0,0,0), 8, 1), \
							new/Collider(new/vector(-24,0,0), new/vector(0,0,0), 8, 1) )

		cannons = list(new/Cannon/Basic(null, 90), new/Cannon/Basic(null, -90), new/Cannon/Basic(null, 0))

	PirateSchooner
		icon = 'PirateSchooner.dmi'
		icon_state = "ship"

		isHostile = 1

		revSpeedLimit = -15
		passiveSpeedLimit = 60
		windSpeedBonusMult = 40

		maxHealth = 40
		health = 40

		cargoCapacity = 0

		//rotation speeds are in units of "degrees per second"
		rotationSpeedLimit = 80

		colliders = list(new/Collider(new/vector(0,0,0), new/vector(0,0,0), 10, 1), \
							new/Collider(new/vector(11,0,0), new/vector(0,0,0), 9, 1), \
							new/Collider(new/vector(-14,0,0), new/vector(0,0,0), 9, 1) )

		cannons = list(new/Cannon/Pirate(null, 67.5), new/Cannon/Pirate(null, -67.5))

	Trader
		icon = 'TradeVessel.dmi'
		icon_state = "ship"

		revSpeedLimit = -15
		passiveSpeedLimit = 60
		windSpeedBonusMult = 40

		maxHealth = 40
		health = 40

		cargoCapacity = 20

		//rotation speeds are in units of "degrees per second"
		rotationSpeedLimit = 80

		colliders = list(new/Collider(new/vector(0,0,0), new/vector(0,0,0), 10, 1), \
							new/Collider(new/vector(11,0,0), new/vector(0,0,0), 9, 1), \
							new/Collider(new/vector(-14,0,0), new/vector(0,0,0), 9, 1) )

	Escort
		icon = 'EscortVessel.dmi'
		icon_state = "ship"

		revSpeedLimit = -15
		passiveSpeedLimit = 60
		windSpeedBonusMult = 40

		maxHealth = 100
		health = 100

		cargoCapacity = 0

		//rotation speeds are in units of "degrees per second"
		rotationSpeedLimit = 80

		colliders = list(new/Collider(new/vector(0,0,0), new/vector(0,0,0), 10, 1), \
							new/Collider(new/vector(11,0,0), new/vector(0,0,0), 9, 1), \
							new/Collider(new/vector(-14,0,0), new/vector(0,0,0), 9, 1) )

		cannons = list(new/Cannon/Pirate(null, 67.5), new/Cannon/Pirate(null, -67.5), new/Cannon/Basic(null, 0))


Cannon
	Basic
		name = "Basic Cannon"
		fireDelay = 3
		fireInaccuracy = 2
		fireDamage = 10
		fireArc = 45
		range = 500

	Pirate
		name = "Pirate Cannon"

		fireDelay = 4
		fireInaccuracy = 5
		fireDamage = 5
		range = 250
		fireArc = 67.5