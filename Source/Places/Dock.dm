
TradeOffer
	var
		inputProduct = ""
		inputAmount = 0
		outputProduct = ""
		outputAmount = 0

FakeDock
	parent_type = /obj

	East
		icon = 'NewDockEast.png'
	North
		icon = 'NewDockNorth.png'
	South
		icon = 'NewDockSouth.png'
	West
		icon = 'NewDockWest.png'

Dock
	parent_type = /obj
	icon = 'DockingArea.png'

	var
		list/offers = list()

	New()
		var/list/duplicates = list()
		for(var/Dock/d)
			duplicates.Add(d.name)

		name = pick(dockNames - duplicates)

		maptext_height = 200
		maptext_width = 100
		maptext_x = 0
		maptext_y = -30
		maptext = "<b>[name]"

		pixel_x -= 45
		pixel_y -= 45

	Click()
		DisplayTradingMenu(usr.client, src)

	proc
		GenerateOffers(amount=2)
			if (amount < 1 || amount > 2)
				throw EXCEPTION("amount must be 1 or 2")

			offers = list()

			var/list/spices = list(BLACK_SPICE, YELLOW_SPICE, RED_SPICE, MAGENTA_SPICE, BLUE_SPICE, CYAN_SPICE, GREEN_SPICE)
			var/list/ref = list(BLACK_SPICE, YELLOW_SPICE, RED_SPICE, MAGENTA_SPICE, BLUE_SPICE, CYAN_SPICE, GREEN_SPICE)

			for(var/i = 0, i < amount, i ++)
				var/TradeOffer/offer = new()
				offer.inputProduct = pick(spices)
				spices.Remove(offer.inputProduct)

				offer.outputProduct = pick(spices - offer.inputProduct)

				var/combo = rand(5, 10)

				if (ref.Find(offer.inputProduct) > ref.Find(offer.outputProduct))
					offer.inputAmount = combo
					offer.outputAmount = round((1 + (combo / 100)) * combo * tradingFunction(offer.inputProduct, offer.outputProduct))
				else
					offer.inputAmount = round((1 - (combo / 100)) * combo * tradingFunction(offer.inputProduct, offer.outputProduct))
					offer.outputAmount = combo

				if (offer.inputAmount == offer.outputAmount)
					i --
					continue;

				// Success
				offers.Add(offer)
				spices.Remove(offer.outputProduct)
				spices.Remove(offer.inputProduct)

var/list/dockNames = list(
	"Thunder Hideout",
	"Rapier Anchorage",
	"Seadog Cove",
	"Black Sand Cave",
	"Seaweed Isle",
	"Reef of Marauders",
	"Bay of Lost Treasure",
	"Isle of Dry Rum",
	"Lagoon of Keelhaul",
	"Island of Mutiny",
	"Sunken Port",
	"Red Water Retreat",
	"Corsair Hideout",
	"Occult Cave",
	"Sunken Hideout",
	"Island of Buccaneers",
	"Haven of Broken Teeth",
	"Reef of the Black Spot",
	"Lagoon of Thunder",
	"Haven of Peril",
	"Red Sand Retreat",
	"Timber Atoll",
	"Scourge Bay",
	"Sunken Haven",
	"Landlubber Cave",
	"Isle of the High Tide",
	"Hideout of No Return",
	"Cay of Shivers",
	"Bay of Grog",
	"Bay of Swashbucklers",
	"Shark Fin Island",
	"Red Sand Enclave",
	"Barnacle Cay",
	"Davy Jones' Cavern",
	"Occult Atoll",
	"Hideout of Seadogs",
	"Reef of Crosses",
	"Retreat of Whispers",
	"Haven of Hazard",
	"Cove of Monsters",
	"Big Horn Enclave",
	"Barnacle Bay",
	"Old Salt Cay",
	"Unnamed Cay",
	"Scuttle Sanctuary",
	"Retreat of the Occult",
	"Anchorage of Blackbeard",
	"Bay of Sharks",
	"Anchorage of Sunken Ships",
	"Isle of Barnacles",
	"Dead Men Refuge",
	"Danger Cave",
	"Booty Atoll",
	"Marauder Cay",
	"Gibbit Lagoon",
	"Port of Hornswaggle",
	"Lagoon of Wreckages",
	"Cay of Mystery",
	"Enclave of the Cyclone",
	"Anchorage of Debris",
	"Timber Cavern",
	"Landlubber Sanctuary",
	"Wreckage Anchorage",
	"Sea Monster Cay",
	"Blood Port",
	"Anchorage of Nemo",
	"Anchorage of the Moon",
	"Refuge of Corsairs",
	"Bay of Timber",
	"Lagoon of Crimson",
	"Crow's Nest Hideout",
	"Dead Kraken Reef",
	"Plunder Port",
	"Blackbeard's Hideout",
	"Scurvy Hideout",
	"Cay of Danger",
	"Cavern of Dubloons",
	"Hideout of Wreckages",
	"Atoll of the Blood Moon",
	"Lagoon of Killer Whales",
	"Gunpowder Cove",
	"Danger Isle",
	"Turtle Atoll",
	"Sunken Reef Sanctuary",
	"Keelhaul Cove",
	"Sanctuary of Dead Whales",
	"Cove of Timber",
	"Cave of the Tempest",
	"Refuge of Scuttlebutt",
	"Cay of the Red Sand",
	"Skeleton Anchorage",
	"Nemo Atoll",
	"Thunder Isle",
	"Davy Jones' Reef",
	"High Tide Cay",
	"Cove of the Sunken Fleet",
	"Enclave of Wreckages",
	"Cove of Grog",
	"Reef of Corsairs",
	"Retreat of Anchors")