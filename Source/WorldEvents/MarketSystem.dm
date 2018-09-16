
var
	tradeUpTable[7][7]
	tradeDownTable[7][7]

proc
	BuildTradeUpTable()
		var/list/spices = list(BLACK_SPICE, YELLOW_SPICE, RED_SPICE, MAGENTA_SPICE, BLUE_SPICE, CYAN_SPICE, GREEN_SPICE)

		// Clear
		for (var/input in spices)
			for (var/output in spices)
				tradeUpTable[spices.Find(input)][spices.Find(output)] = 0

		// Set the diagonal
		for (var/input in spices)
			tradeUpTable[spices.Find(input)][spices.Find(input)] = 1

		var/factor = 2
		// Calculate greater values
		for (var/input in spices)
			for (var/index = spices.Find(input) + 1; index <= spices.len; index ++)
				tradeUpTable[spices.Find(input)][index] = tradeUpTable[spices.Find(input)][index-1] * factor

		for (var/input in spices)
			for (var/output in spices)
				if (input == output) continue
				if (tradeUpTable[spices.Find(input)][spices.Find(output)] == 0) continue
				//world << "[tradeUpTable[spices.Find(input)][spices.Find(output)]] [input] are required to get 1 [output]"

	BuildTradeDownTable()
		var/list/spices = list(BLACK_SPICE, YELLOW_SPICE, RED_SPICE, MAGENTA_SPICE, BLUE_SPICE, CYAN_SPICE, GREEN_SPICE)

		// Clear
		for (var/input in spices)
			for (var/output in spices)
				tradeDownTable[spices.Find(input)][spices.Find(output)] = 0

		// Set the diagonal
		for (var/input in spices)
			tradeDownTable[spices.Find(input)][spices.Find(input)] = 1

		var/factor = 2
		// Calculate greater values
		for (var/input in spices)
			for (var/index = spices.Find(input) - 1; index >= 1; index --)
				tradeDownTable[spices.Find(input)][index] = tradeDownTable[spices.Find(input)][index+1] * factor

		for (var/input in spices)
			for (var/output in spices)
				if (input == output) continue
				if (tradeUpTable[spices.Find(input)][spices.Find(output)] == 0) continue
				//world << "1 [output] yields [tradeUpTable[spices.Find(input)][spices.Find(output)]] [input]"

	tradingFunction(inputSpice, outputSpice)
		if (inputSpice == null)
			throw EXCEPTION("inputSpice cannot be null.")

		if (outputSpice == null)
			throw EXCEPTION("outputSpice cannot be null.")

		var/list/spices = list(BLACK_SPICE, YELLOW_SPICE, RED_SPICE, MAGENTA_SPICE, BLUE_SPICE, CYAN_SPICE, GREEN_SPICE)

		var/inIndex = spices.Find(inputSpice)
		if (inIndex == 0)
			throw EXCEPTION("inputSpice must be one of the 7 support spices.")

		var/outIndex = spices.Find(outputSpice)
		if (outIndex == 0)
			throw EXCEPTION("outputSpice must be one of the 7 support spices.")

		//var/distance = abs(inIndex - outIndex)
		var/profitOrDiscountMargin = 0.07

		if (inIndex == outIndex)
			return 1
		else if (inIndex > outIndex)
			return round(tradeDownTable[inIndex][outIndex] * (1 + profitOrDiscountMargin))
		else
			return round(tradeUpTable[inIndex][outIndex] * (1 - profitOrDiscountMargin))

	sellingFunction(inputSpice)
		if (inputSpice == null)
			throw EXCEPTION("inputSpice cannot be null.")
		var/list/spices = list(BLACK_SPICE, YELLOW_SPICE, RED_SPICE, MAGENTA_SPICE, BLUE_SPICE, CYAN_SPICE, GREEN_SPICE)

		var/inIndex = spices.Find(inputSpice)
		if (inIndex == 0)
			throw EXCEPTION("inputSpice must be one of the 7 support spices.")

		return round(3 ** inIndex)