

TradeRoute
	var
		HomeIsland/homeDock

		ships[0]

		ais[0]

		vector/center
		TradeNode/homeNode

		nodes[0]
		nodeIndex = 0

		transTimer
		transDelay = 0.5 //amount of dock time per ship per transaction

		AI/activeTrader

		baseRadius = 200 //200 + 100 per ship

		stopFlag = 0

		startCargo[0]

	Del()
		gameActiveAtoms -= src
		..()

	proc
		GetHomeNode()
			homeDock = locate() in world

		AddShip(AI/AI)
			ships |= AI.myShip
			ais |= AI

			AI.tradeRoute = src

		RemoveShip(AI/AI)
			ships -= AI.myShip
			ais -= AI

		AddNode(TradeNode/n)
			nodes += n

		RemoveNode(TradeNode/n)
			nodes -= n
			if(nodeIndex > nodes.len)
				nodeIndex = 0

		Start()
			gameActiveAtoms |= src
			stopFlag = 0

		Stop()
			stopFlag = 1

		TickUpdate()
			//check all the ships to see if they're close enough ish.
			//trade ships should be trying to dock
			//Escort ships should be trying to stay close to the centroid
			//each trade ship must dock and perform
			if(nodes.len < 1) return

			if(!homeDock)
				GetHomeNode()


			RunTradeNode()

		GetCargo()
			var/convoyCargo[0]
			for(var/AI/AI in ais)
				for(var/i in AI.myShip.cargo)
					convoyCargo[i] += AI.myShip.cargo[i]
			return convoyCargo

		RunStartNode()
			nodeIndex = 0


			//formation keeping code
			var/formationRadius = baseRadius + 45 * ais.len

			//compute formation centroid
			center = vec2(0,0)
			for(var/AI/AI in ais)
				AI.maxSpeedMode = 3
				center.x += AI.myShip.pX
				center.y += AI.myShip.pY
			center *= 1/ais.len

			//now determine if formation is broken
			var/brokeFormation = 0
			for(var/AI/AI in ais)
				var/dx = center.x - AI.myShip.pX
				var/dy = center.y - AI.myShip.pY
				if(dx*dx+dy*dy > formationRadius*formationRadius)
					brokeFormation = 1
					break

			//if the formation is broken, then make the formation members slow down in order to allow stragglers to catch up
			if(brokeFormation)
				for(var/AI/AI in ais)
					var/dx = center.x - AI.myShip.pX
					var/dy = center.y - AI.myShip.pY
					if(dx*dx+dy*dy > formationRadius*formationRadius)
						AI.maxSpeedMode = 3
						AI.longDestination = AI.GetEmptyLocation(vec2(center.x, center.y), AI.myShip.bigRadius, 1, 1)
					else
						AI.maxSpeedMode = 1

			homeDock.PixelCoordsUpdate()

			var/numTraders = 0

			//set AI destinations to the dock or near the dock
			for(var/AI/AI in ais)
				var/hasTrade = 0

				for(var/i in AI.myShip.cargo)
					if(AI.myShip.cargo[i] > 0)
						hasTrade = 1
						numTraders++

				if(AI.longDestination != null) continue

				if(!activeTrader && hasTrade) activeTrader = AI

				if(activeTrader == AI)
					AI.SetDockDestination(homeDock)
				else
					AI.longDestination = AI.GetEmptyLocation(vec2(homeDock.pX, homeDock.pY), AI.myShip.bigRadius, 1, 2)

			var/convoyCargo[] = GetCargo()
			var/pickupCargo[] = startCargo.Copy()
			var/client/C = locate()
			if(C)
				for(var/i in startCargo)
					var/num = startCargo[i]
					if(C.homebank[i] < num) num = C.homebank[i]

					var/cnum = convoyCargo[i]

					num -= cnum
					if(num < 0) num = 0
					pickupCargo[i] = num


			//if this guy is the active trader, try to dock and make the trade transactions
			if(activeTrader)
				var/dx = homeDock.pX - activeTrader.myShip.pX
				var/dy = homeDock.pY - activeTrader.myShip.pY
				var/canTrade = 1
				var/speedLimit = 0.25
				if(activeTrader.myShip.currentSpeed > speedLimit)
					canTrade = 0

				if(dx*dx+dy*dy < 3 * 3 * ICON_WIDTH * ICON_HEIGHT)
					canTrade = 0


				var/hasTrade = 1

				var/cargoSpace = activeTrader.myShip.cargoCapacity - activeTrader.myShip.GetCurrentCargo()
				if(cargoSpace <= 0)
					hasTrade = 0

				if(!hasTrade)
					//I can't trade because I don't have the cargo to complete any transactions.
					activeTrader.longDestination = activeTrader.GetEmptyLocation(vec2(homeDock.pX, homeDock.pY), activeTrader.myShip.bigRadius, 1, 5)
					activeTrader = null

				if(canTrade && hasTrade)
					//I can trade and I am ready to trade. gogogogo
					if(gameTime > transTimer)
						transTimer = gameTime + transDelay

						for(var/i in pickupCargo)
							var/num = pickupCargo[i]


			var/finishedTrading = 1

			if(numTraders > 0) finishedTrading = 0
			else
				for(var/AI/AI in ais)
					if(AI.longDestination != null) finishedTrading = 0

			//if trading is done
			if(finishedTrading)

				if(stopFlag)
					gameActiveAtoms -= src
					return

				activeTrader = null
				nodeIndex++

				for(var/AI/AI in ais)
					AI.longDestination = null

				if(nodeIndex > 0 && nodeIndex <= nodes.len)
					var/TradeNode/node = nodes[nodeIndex]
					node.remainingTransactions = node.transactions.Copy()



		RunDropoffNode()
			nodeIndex = nodes.len + 1

			var/convoyCargo[0]
			for(var/AI/AI in ais)
				for(var/i in AI.myShip.cargo)
					convoyCargo[i] += AI.myShip.cargo[i]

			//formation keeping code
			var/formationRadius = baseRadius + 45 * ais.len

			//compute formation centroid
			center = vec2(0,0)
			for(var/AI/AI in ais)
				AI.maxSpeedMode = 3
				center.x += AI.myShip.pX
				center.y += AI.myShip.pY
			center *= 1/ais.len

			//now determine if formation is broken
			var/brokeFormation = 0
			for(var/AI/AI in ais)
				var/dx = center.x - AI.myShip.pX
				var/dy = center.y - AI.myShip.pY
				if(dx*dx+dy*dy > formationRadius*formationRadius)
					brokeFormation = 1
					break

			//if the formation is broken, then make the formation members slow down in order to allow stragglers to catch up
			if(brokeFormation)
				for(var/AI/AI in ais)
					var/dx = center.x - AI.myShip.pX
					var/dy = center.y - AI.myShip.pY
					if(dx*dx+dy*dy > formationRadius*formationRadius)
						AI.maxSpeedMode = 3
						AI.longDestination = AI.GetEmptyLocation(vec2(center.x, center.y), AI.myShip.bigRadius, 1, 1)
					else
						AI.maxSpeedMode = 1



			homeDock.PixelCoordsUpdate()

			var/numTraders = 0

			//set AI destinations to the dock or near the dock
			for(var/AI/AI in ais)
				var/hasTrade = 0

				for(var/i in AI.myShip.cargo)
					if(AI.myShip.cargo[i] > 0)
						hasTrade = 1
						numTraders++

				if(AI.longDestination != null) continue

				if(!activeTrader && hasTrade) activeTrader = AI

				if(activeTrader == AI)
					AI.SetDockDestination(homeDock)
				else
					AI.longDestination = AI.GetEmptyLocation(vec2(homeDock.pX, homeDock.pY), AI.myShip.bigRadius, 1, 2)

			//if this guy is the active trader, try to dock and make the trade transactions
			if(activeTrader)
				var/dx = homeDock.pX - activeTrader.myShip.pX
				var/dy = homeDock.pY - activeTrader.myShip.pY
				var/canTrade = 1
				var/speedLimit = 0.25
				if(activeTrader.myShip.currentSpeed > speedLimit)
					canTrade = 0

				if(dx*dx+dy*dy < 3 * 3 * ICON_WIDTH * ICON_HEIGHT)
					canTrade = 0

				var/hasTrade = 0

				for(var/i in activeTrader.myShip.cargo)
					if(activeTrader.myShip.cargo[i] > 0)
						hasTrade = 1
						break

				if(!hasTrade)
					//I can't trade because I don't have the cargo to complete any transactions.
					activeTrader.longDestination = activeTrader.GetEmptyLocation(vec2(homeDock.pX, homeDock.pY), activeTrader.myShip.bigRadius, 1, 5)
					activeTrader = null

				if(canTrade && hasTrade)
					//I can trade and I am ready to trade. gogogogo
					if(gameTime > transTimer)
						transTimer = gameTime + transDelay
						activeTrader.DepositCargoHome()

			var/finishedTrading = 1

			if(numTraders > 0) finishedTrading = 0
			else
				for(var/AI/AI in ais)
					if(AI.longDestination != null) finishedTrading = 0

			//if trading is done
			if(finishedTrading)

				if(stopFlag)
					gameActiveAtoms -= src
					return

				activeTrader = null
				nodeIndex = 0

				for(var/AI/AI in ais)
					AI.longDestination = null


		RunTradeNode()
			var/TradeNode/node

			if(nodeIndex < 1)
				return RunStartNode()
			if(nodeIndex > nodes.len)

				return RunDropoffNode()

			else
				node = nodes[nodeIndex]

			//formation keeping code
			var/formationRadius = baseRadius + 45 * ais.len

			//compute formation centroid
			center = vec2(0,0)
			for(var/AI/AI in ais)
				AI.maxSpeedMode = 3
				center.x += AI.myShip.pX
				center.y += AI.myShip.pY
			center *= 1/ais.len

			//now determine if formation is broken
			var/brokeFormation = 0
			for(var/AI/AI in ais)
				var/dx = center.x - AI.myShip.pX
				var/dy = center.y - AI.myShip.pY
				if(dx*dx+dy*dy > formationRadius*formationRadius)
					brokeFormation = 1
					break

			//if the formation is broken, then make the formation members slow down in order to allow stragglers to catch up
			if(brokeFormation)
				for(var/AI/AI in ais)
					var/dx = center.x - AI.myShip.pX
					var/dy = center.y - AI.myShip.pY
					if(dx*dx+dy*dy > formationRadius*formationRadius)
						AI.maxSpeedMode = 3
						AI.longDestination = AI.GetEmptyLocation(vec2(center.x, center.y), AI.myShip.bigRadius, 1, 1)
					else
						AI.maxSpeedMode = 1



			node.dock.PixelCoordsUpdate()

			var/numTraders = 0

			//set AI destinations to the dock or near the dock
			for(var/AI/AI in ais)
				var/hasTrade = 0

				for(var/TradeOffer/offer in node.transactions)
					if(AI.myShip.CanMakeTrade(offer))
						hasTrade = 1
						numTraders++

				if(AI.longDestination != null) continue

				if(!activeTrader && hasTrade) activeTrader = AI

				if(activeTrader == AI)
					AI.SetDockDestination(node.dock)
				else
					AI.longDestination = AI.GetEmptyLocation(vec2(node.dock.pX, node.dock.pY), AI.myShip.bigRadius, 1, 2)

			//if this guy is the active trader, try to dock and make the trade transactions
			if(activeTrader)
				var/dx = node.dock.pX - activeTrader.myShip.pX
				var/dy = node.dock.pY - activeTrader.myShip.pY
				var/canTrade = 1
				var/speedLimit = 0.25
				if(activeTrader.myShip.currentSpeed > speedLimit)
					canTrade = 0

				if(dx*dx+dy*dy < 3 * 3 * ICON_WIDTH * ICON_HEIGHT)
					canTrade = 0

				var/hasTrade = 0
				for(var/TradeOffer/offer in node.transactions)
					if(activeTrader.myShip.CanMakeTrade(offer))
						hasTrade = 1
						break

				if(!hasTrade)
					//I can't trade because I don't have the cargo to complete any transactions.
					activeTrader.longDestination = activeTrader.GetEmptyLocation(vec2(node.dock.pX, node.dock.pY), activeTrader.myShip.bigRadius, 1, 5)
					activeTrader = null

				if(canTrade && hasTrade)
					//I can trade and I am ready to trade. gogogogo
					if(gameTime > transTimer)
						transTimer = gameTime + transDelay

						for(var/TradeOffer/offer in node.transactions)
							if(activeTrader.myShip.CanMakeTrade(offer))
								activeTrader.myShip.cargo[offer.inputProduct] -= offer.inputAmount
								activeTrader.myShip.cargo[offer.outputProduct] += offer.outputAmount

			var/finishedTrading = 1

			if(numTraders > 0) finishedTrading = 0
			else
				for(var/AI/AI in ais)
					if(AI.longDestination != null) finishedTrading = 0

			//if trading is done
			if(finishedTrading)

				activeTrader = null
				nodeIndex++

				for(var/AI/AI in ais)
					AI.longDestination = null

				if(nodeIndex > 0 && nodeIndex <= nodes.len)
					node = nodes[nodeIndex]
					node.remainingTransactions = node.transactions.Copy()





TradeNode
	var
		Dock/dock

		transactions[0] //these are TradeOffer objects that belong to the dock
		//this format is:
		//offer = num

		remainingTransactions[0]
		//this is a copy of transactions, but this will decrement the num as transactions are being performed.