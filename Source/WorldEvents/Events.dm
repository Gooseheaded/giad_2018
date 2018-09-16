
var/randomEventLoop = FALSE

var/resourceGeneratorLoop = FALSE
proc
	BasicResourceGeneratorLoop()
		if (resourceGeneratorLoop) return
		resourceGeneratorLoop = TRUE

		spawn while(TRUE)
			var/client/c = null
			for(var/client/x)
				c = x
				break

			if (c != null)
				c.homebank[BLACK_SPICE] += 25
				c.UpdateResourcesHud()

				for(var/obj/o in c.screen)
					if (o.name == "Homebank [BLACK_SPICE]")
						o.maptext = MAPTEXT_COLOR + "x[c.homebank[BLACK_SPICE]]"

			sleep(60 * 10)

	RandomWorldEventLoop()
		if (randomEventLoop) return
		randomEventLoop = TRUE

		spawn while(TRUE)
			var/option = rand(1,4)
			if (option == 1)
				RoyalTax()
			else if (option == 2)
				RefreshDockOffers()
			else if (option == 3)
				PirateAttack()
			else if (option == 4)
				BoomingEconomy()

			sleep(300 * 10)

	RoyalTax()
		var/list/spices = list(BLACK_SPICE, YELLOW_SPICE, RED_SPICE, MAGENTA_SPICE, BLUE_SPICE, CYAN_SPICE, GREEN_SPICE)
		var/spice = pick(spices)
		var/taxAmount = max(5, round(rand(1, 300) / spices.Find(spice)))

		displayText("The Royal family demands tribute. Have at least [taxAmount] <font color=[spice]>O</font> deposited at home soon, or suffer the consequences!")
		spawn(60 * 10)
			var/client/c = null
			for(var/client/x)
				c = x
				break
			if (c != null)
				if (c.homebank[spice] >= taxAmount)
					displayText("The Royal guard collects taxes you fairly, troubling you no more.")
					c.homebank[spice] -= taxAmount
				else
					displayText("The Royal guard does not hear your excuses. All your spices are taxed.")
					for(var/x in spices)
						c.homebank[x] = round(c.homebank[x] * (2 / 3))

				for(var/x in spices)
					for(var/obj/o in c.screen)
						if (o.name == "Homebank [x]")
							o.maptext = MAPTEXT_COLOR + "x[c.homebank[x]]"

	RefreshDockOffers()
		for(var/Dock/d)
			d.GenerateOffers()
		displayText("The market has radically changed! All docks have refreshed their offers!")

	PirateAttack()
		var/offScreenDistance = 32 * world.icon_size // 32 tiles, 30 px in size

		var/client/c = null
		for(var/client/x)
			c = x
			break

		var/vector/start = vec2(c.myShip.x * world.icon_size, c.myShip.y * world.icon_size)
		var/vector/target = vec2(world.maxx / 2 * world.icon_size, world.maxy / 2 * world.icon_size)
		var/vector/delta = vec2(target.x - start.x, target.y - start.y).unit().multiply(offScreenDistance)

		var/vector/result = vec2(start.x + delta.x, start.y + delta.y)

		var/pirateName = pick(pirateNames)

		displayText("Beware! [pirateName] and their crew are after your head! ([result.toString()])")
		SpawnPirates(result, rand(1,3))

	BoomingEconomy()
		var/list/spices = list(BLACK_SPICE, YELLOW_SPICE, RED_SPICE, MAGENTA_SPICE, BLUE_SPICE, CYAN_SPICE, GREEN_SPICE)
		var/spice = pick(spices)

		displayText("The economy booms! For a short time, all <font color=[spice]>O</font> can be sold for twice their normal price!")
		boomingEconomy = spice

		for(var/x in spices)
			for(var/client/c)
				for(var/obj/o in c.screen)
					if (o.name == "Price [spice]")
						o.maptext = MAPTEXT_COLOR + "[sellingFunction(spice)] each"

		spawn(60 * 10)
			displayText("The economy stabilizies once again, and <font color=[spice]>O</font> returns to their normal price.")
			boomingEconomy = null

			for(var/x in spices)
				for(var/client/c)
					for(var/obj/o in c.screen)
						if (o.name == "Price [spice]")
							o.maptext = MAPTEXT_COLOR + "[sellingFunction(spice)] each"

var/list/pirateNames = list("Goodman 'Black Eyes' Stanton",
	"Clive 'Subtle' Chalice",
	"Stockton 'Fishy' Yao",
	"Denham 'Treason' Sydney",
	"Twyford 'Defiance' Xander",
	"Arundel 'Softy' Sweat",
	"Hobbes 'The Slug' Damien",
	"Wyman 'Crabby' Rischer",
	"Fraser 'Weird'o' Vesh",
	"Wingate 'Crew Member' Zeddicus",
	"Garland 'Deceiver' Seth",
	"Swaine 'Swashbuckler' Chaos",
	"Belden 'Gloomy' Hallewell",
	"Fulke 'Frenzied' Tristan",
	"Orford 'Treasure' Barclay",
	"Clayborne 'The Sparrow' Ragnor",
	"Faxon 'Chipper' Roscoe",
	"Kelsey 'The Parrot' Bradley",
	"Clayland 'Bird Eye' Zen",
	"Randolph 'Insanity' Pickering",
	"Lee 'Rum Lover' Middleton",
	"Marguerite 'Corsair' Swien",
	"Rossie 'White Hair' Oxworth",
	"Rosalia 'Seafarer' Reyson",
	"Mozelle 'Braveheart' Rivers",
	"Maybell 'Shady' Auron",
	"Hassie 'Whale' Sydney",
	"Opal 'Cruel' Vail",
	"Freddie 'Haunted' Vossler",
	"Mona 'Foul' Ragnor",
	"Blackburn 'Gnarling' Nutlea",
	"Braddock 'Silver Hair' Hartford",
	"Farren 'Twisting' Heinrik",
	"Elton 'Parley' Rischer",
	"Longfellow 'Slick' Bourne",
	"Freed 'Grommet' Dudley",
	"Wheelwright 'The Coward' Alden",
	"Tupper 'Cutthroat' Asheton",
	"Derwin 'Relentless' Thorpe",
	"Hutton 'Executioner' Altham",
	"Harry 'Swashbuckler' Drace",
	"Ocie 'The Mad' Auron",
	"Angie 'Jolly' Lux",
	"Lucile 'Swindler' Smoky",
	"Dolly 'Hunter' Drace",
	"Maxie 'The Sour' Belzebob",
	"Maitane 'One Legged' Drake",
	"Rowena 'Weird'o' Perry",
	"Vassie 'Calmness' Springfield",
	"Mildred 'Riot' Bryce",
	"Currier 'Iron Fists' Snowdon",
	"Styles 'Smiling' Holton",
	"Johnson 'The Wild' Keic",
	"Darwin 'Ruthless' Zulu",
	"Hunter 'Rum Lover' Whitewall",
	"Rishley 'Golden-Eye' Allen",
	"Dick 'Splinter' Langley",
	"Studs 'Killer' Zeus",
	"Denman 'Dawg' Zeus",
	"Brent 'Braveheart' Whiteley",
	"Denman 'Fierce' Talon",
	"Chesney 'Con Artist' Clare",
	"Aldrich 'The Fierce' Beverly",
	"Burbank 'Whale-Eye' Hastings",
	"Tucker 'The Confident' Darby",
	"Faine 'Traitor' Camden",
	"Langston 'The Bull' Notleigh",
	"Stockwell 'Golden Tooth' Vexacion",
	"Waverley 'Swashbuckler' Vayne",
	"Elton 'One-Eared' Soames",
	"Ulrich 'Deceiver' Prysm",
	"Aylward 'Weasel' Hammett",
	"Trent 'Immortal' Alden",
	"Garfield 'One-Eared' Eldon",
	"Morland 'Smelly' Camus",
	"Clayland 'Fuming' Melton",
	"Farnham 'Handsome' Morren",
	"Ludlow 'Imposter' Zayn",
	"Merrill 'Ruthless' Pickering",
	"Morland 'Timbers' Zaine",
	"Hugh 'Ugly Mug' Prysm",
	"Crook 'Boatswain' Swet",
	"Langdon 'Furious' Holton",
	"Haslett 'Tormenting' Drace",
	"Swaine 'No Cash' Braxton",
	"Denton 'Grim Reaper' Virion",
	"Cleveland 'Cunning' Stanley",
	"Pendleton 'The Boar' Withers",
	"Borden 'Blunder' Fark",
	"Erland 'Mad Eye' Karayan",
	"Elbert 'Gloomy' Bartholomew",
	"Studs 'Pleasant' Tyde",
	"Forbes 'First Mate' Garthside",
	"Somerton 'Treason' Scias",
	"Blackstone 'Swindler' Lynk",
	"Dearborn 'The Journey' Swailes",
	"Kenelm 'The Coward' Ashley",
	"Chesney 'Subtle' Savant",
	"Lyndon 'Merciless' Berkeley",
	"Sadler 'Balding' Shayde")