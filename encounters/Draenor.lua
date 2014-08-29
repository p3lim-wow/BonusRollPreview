local _, ns = ...
ns.encounterIDs = ns.encounterIDs or {}
ns.continents = ns.continents or {}

if(ns.WoD) then
	-- http://www.wowhead.com/spells=0?filter=na=Bonus;cr=84:109:16;crs=1:6:6
	for spellID, encounterID in next, {
		-- World - 557
		[-1] = 1291, -- Drov the Ruiner
		[-1] = 1211, -- Tarina the Ageless
		[-1] = 1262, -- Rukhmar

		-- Highmaul - 477
		[-1] = 1128, -- Kargath Bladefist
		[-1] = 971, -- The Butcher
		[-1] = 1195, -- Tectus
		[-1] = 1196, -- Brackenspore
		[-1] = 1148, -- Twin Ogron
		[-1] = 1153, -- Ko'ragh
		[-1] = 1197, -- Imperator Mar'gok

		-- Blackrock Foundry - 457
		[-1] = 1161, -- Gruul
		[-1] = 1202, -- Oregorger
		[-1] = 1122, -- Beastlord Darmac
		[-1] = 1123, -- Flamebender Ka'graz
		[-1] = 1155, -- Hans'gar and Franzok
		[-1] = 1147, -- Operator Thogar
		[-1] = 1154, -- The Blast Furnace
		[-1] = 1162, -- Kromog
		[-1] = 1203, -- The Iron Maidens
		[-1] = 959   -- Blackhand
	} do
		ns.encounterIDs[spellID] = encounterID
	end

	ns.continents[7] = 557
end
