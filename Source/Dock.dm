
TradeOffer
	var
		inputProduct = ""
		inputAmount = 0
		outputProduct = ""
		outputAmount = 0

Dock
	var
		name = ""
		list/offers = list()

	proc
		GenerateOffers(amount=2)
			if (amount < 1 || amount > 2)
				throw EXCEPTION("amount must be 1 or 2")

			offers = list()

			var/list/inputOptions = list("Red","Yellow","Magenta","Blue","Cyan","Green")

			for(var/i = 0, i < amount, i ++)
				var/TradeOffer/offer = new()
				offer.inputAmount = rand(3,5)
				offer.inputProduct = pick(inputOptions)
				inputOptions.Remove(offer.inputProduct)
				offer.outputAmount = offer.inputAmount + rand(1,3)
				offer.outputProduct = offer.inputProduct
				while (offer.outputProduct == offer.inputProduct)
					offer.outputProduct = pick("Red","Yellow","Magenta","Blue","Cyan","Green")
				offers.Add(offer)