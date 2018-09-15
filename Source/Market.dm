
/*
This file contains definitions for the Commodity class and Market class
Author: Anthony SuVasquez
*/

/*
Commodities are just one of 7 types of tradeable goods.
Black
Yellow
Red
Magenta
Blue
Cyan
Green
*/

var
	homeStoredCommodities[0] //This is just a list of how many of what commodity is stored at home.

Commodity
	parent_type = /obj

	var
		commodityType = ""


/*
The Market represents the market for the home island.
It simply stores a set of exchange rates between the various commodities and how much $ each one is worth.
*/
Market
	var
		exchangeRate[0]