local MAJOR, MINOR = 'EJ_Ext', 1
assert(LibStub, MAJOR .. ' requires LibStub')

local lib, oldMinor = LibStub:NewLibrary(MAJOR, MINOR)
if(not lib) then
	return
end

local journalIDs = {
	-- 5.0 Pandaria
	[132205] = {322, 691}, -- Sha of Anger
	[132206] = {322, 725}, -- Salyis' Warband (Galleon)
	[136381] = {322, 814}, -- Nalak, The Storm God
	[137554] = {322, 826}, -- Oondasta
	[148317] = {322, 857}, -- Celestials (also encounterIDs 858, 859 and 860)
	[148316] = {322, 861}, -- Ordos, Fire-God of the Yaungol

	-- 5.0 Mogu'Shan Vaults
	[125144] = {317, 679}, -- The Stone Guard
	[132189] = {317, 689}, -- Feng the Accursed
	[132190] = {317, 682}, -- Gara'jal the Spiritbinder
	[132191] = {317, 687}, -- The Spirit Kings
	[132192] = {317, 726}, -- Elegon
	[132193] = {317, 677}, -- Will of the Emperor

	-- 5.0 Heart of Fear
	[132194] = {330, 745}, -- Imperial Vizier Zor'lok
	[132195] = {330, 744}, -- Blade Lord Tay'ak
	[132196] = {330, 713}, -- Garalon
	[132197] = {330, 741}, -- Wind Lord Mel'jarak
	[132198] = {330, 737}, -- Amber-Shaper Un'sok
	[132199] = {330, 743}, -- Grand Empress Shek'zeer

	-- 5.0 Terrace of Endless Spring
	[132200] = {320, 683}, -- Protectors of the Endless
	[132204] = {320, 683}, -- Protectors of the Endless (Elite)
	[132201] = {320, 742}, -- Tsulong
	[132202] = {320, 729}, -- Lei Shi
	[132203] = {320, 709}, -- Sha of Fear

	-- 5.0 Throne of Thunder
	[139674] = {362, 827}, -- Jin'rokh the Breaker
	[139677] = {362, 819}, -- Horridon
	[139679] = {362, 816}, -- Council of Elders
	[139680] = {362, 825}, -- Tortos
	[139682] = {362, 821}, -- Magaera
	[139684] = {362, 828}, -- Ji'kun, the Ancient Mother
	[139686] = {362, 818}, -- Durumu the Forgotten
	[139687] = {362, 820}, -- Primordious
	[139688] = {362, 824}, -- Dark Animus
	[139689] = {362, 817}, -- Iron Qon
	[139690] = {362, 829}, -- Twin Consorts (Empyreal Queens)
	[139691] = {362, 832}, -- Lei Shen, The Thunder King
	[139692] = {362, 831}, -- Ra-den

	-- 5.0 Siege of Orgrimmar
	[145909] = {369, 852}, -- Immerseus
	[145910] = {369, 849}, -- The Fallen Protectors
	[145911] = {369, 866}, -- Norushen
	[145912] = {369, 867}, -- Sha of Pride
	-- Galakras needs special handling
	[145914] = {369, 864}, -- Iron Juggernaut
	[145915] = {369, 856}, -- Kor'kron Dark Shaman
	[145916] = {369, 850}, -- General Nazgrim
	[145917] = {369, 846}, -- Malkorok
	[145919] = {369, 870}, -- Spoils of Pandaria
	[145920] = {369, 851}, -- Thok the Bloodthirsty
	[145918] = {369, 865}, -- Siegecrafter Blackfuse
	[145921] = {369, 853}, -- Paragons of the Klaxxi
	[145922] = {369, 869}, -- Garrosh Hellscream

	-- 6.0 Draenor
	[178847] = {557, 1291}, -- Drov the Ruiner
	[178849] = {557, 1211}, -- Tarina the Ageless
	[178851] = {557, 1262}, -- Rukhmar
	[188985] = {557, 1452}, -- Supreme Lord Kazzak

	-- 6.0 Highmaul
	[177521] = {477, 1128}, -- Kargath Bladefist
	[177522] = {477, 971}, -- The Butcher
	[177523] = {477, 1195}, -- Tectus
	[177524] = {477, 1196}, -- Brackenspore
	[177525] = {477, 1148}, -- Twin Ogron
	[177526] = {477, 1153}, -- Ko'ragh
	[177528] = {477, 1197}, -- Imperator Mar'gok

	-- 6.0 Blackrock Foundry
	[177529] = {457, 1161}, -- Gruul
	[177530] = {457, 1202}, -- Oregorger
	[177536] = {457, 1122}, -- Beastlord Darmac
	[177534] = {457, 1123}, -- Flamebender Ka'graz
	[177533] = {457, 1155}, -- Hans'gar and Franzok
	[177537] = {457, 1147}, -- Operator Thogar
	[177531] = {457, 1154}, -- The Blast Furnace
	[177535] = {457, 1162}, -- Kromog
	[177538] = {457, 1203}, -- The Iron Maidens
	[177539] = {457, 959},  -- Blackhand

	-- 6.0 Hellfire Citadel
	[188972] = {669, 1426}, -- Hellfire Assault
	[188973] = {669, 1425}, -- Iron Reaver
	[188974] = {669, 1392}, -- Kormrok
	[188975] = {669, 1432}, -- Hellfire High Council
	[188976] = {669, 1396}, -- Kilrogg Deadeye
	[188977] = {669, 1372}, -- Gorefiend
	[188978] = {669, 1433}, -- Shadow-Lord Iskar
	[188979] = {669, 1427}, -- Socrethar the Eternal
	[188980] = {669, 1391}, -- Fel Lord Zakuun
	[188981] = {669, 1447}, -- Xhul'horac
	[188982] = {669, 1394}, -- Tyrant Velhari
	[188983] = {669, 1395}, -- Mannoroth
	[188984] = {669, 1438}, -- Archimonde

	-- 6.0 Auchindoun
	[190154] = {547, 1185}, -- Vigilant Kaathar
	[190155] = {547, 1186}, -- Soulbinder Nyami
	[190156] = {547, 1216}, -- Azzakel
	[190157] = {547, 1225}, -- Teron'gor

	-- 6.0 Upper Blackrock Spire
	[190168] = {559, 1226}, -- Orebender Gor'ashan
	[190170] = {559, 1227}, -- Kyrak
	[190171] = {559, 1228}, -- Commander Tharbek
	[190172] = {559, 1229}, -- Ragewing the Untamed
	[190173] = {559, 1234}, -- Warlord Zaela

	-- 6.0 Shadowmoon Burial Grounds
	[190150] = {537, 1139}, -- Sadana Bloodfury
	[190151] = {537, 1168}, -- Nhallish
	[190152] = {537, 1140}, -- Bonemaw
	[190153] = {537, 1160}, -- Ner'zhul

	-- 6.0 The Everbloom
	[190158] = {556, 1214}, -- Witherbark
	[190159] = {556, 1207}, -- Ancient Protectors
	[190160] = {556, 1208}, -- Archmage Sol
	[190162] = {556, 1209}, -- Xeri'tac
	[190163] = {556, 1210}, -- Yalnu

	-- 6.0 Grimrail Depot
	[190147] = {536, 1138}, -- Rocketspark and Borka
	[190148] = {536, 1163}, -- Nitrogg Thundertower
	[190149] = {536, 1133}, -- Skylord Tovra

	-- 6.0 Iron Docks
	[190164] = {558, 1235}, -- Fleshrender Nok'gar
	[190165] = {558, 1236}, -- Grimrail Enforcers
	[190166] = {558, 1237}, -- Oshir
	[190167] = {558, 1238}, -- Skulloc

	-- 6.0 Skyreach
	[190142] = {476, 965}, -- Ranjit
	[190143] = {476, 966}, -- Araknath
	[190144] = {476, 967}, -- Rukhran
	[190146] = {476, 968}, -- High Sage Viryx

	-- 6.0 Bloodmaul Slag Mines
	[190138] = {385, 893}, -- Magmolatus
	[190139] = {385, 888}, -- Slave Watcher Crushto
	[190140] = {385, 887}, -- Roltall
	[190141] = {385, 889}, -- Gug'rokk

	-- 7.0 The Nighthold
	-- Grand Magistrix Elisande needs special handling
}

-- the following encounters present different IDs based on client randomness (not entirely sure)
local incorrectJournalEntries = {
	-- 5.0
	[145913] = {369, 5}, -- Galakras
	-- 7.0
	[232444] = {786, 9}, -- Grand Magistrix Elisande
}

local Handler = CreateFrame('Frame')
Handler:RegisterEvent('PLAYER_LOGIN')
Handler:SetScript('OnEvent', function(self, event)
	self:UnregisterEvent(event)

	for spellID, data in next, incorrectJournalEntries do
		EJ_SelectInstance(data[1])
		journalIDs[spellID] = {data[1], (select(3, EJ_GetEncounterInfoByIndex(data[2])))}
	end
end)

function lib:GetJournalInfoForSpellConfirmation(spellID)
	-- this extends the API to also work for earlier expansions
	-- it also fixes incorrect data for certain encounters (see above)
	local instanceID, encounterID
	if(journalIDs[spellID]) then
		instanceID, encounterID = unpack(journalIDs[spellID])
	else
		instanceID, encounterID = GetJournalInfoForSpellConfirmation(spellID)
	end

	return instanceID, encounterID
end

local difficulties = {
	-- 5.0
	[322] = 3, -- World: Pandaria
	[317] = 4, -- Raid: Mogu'Shan Vaults
	[330] = 4, -- Raid: Heart of Fear
	[320] = 4, -- Raid: Terrace of Endless Spring
	[362] = 4, -- Raid: Throne of Thunder
	[369] = 4, -- Raid: Siege of Orgrimmar

	-- 6.0
	[557] = 14, -- World: Draenor
	[477] = 14, -- Raid: Highmaul
	[457] = 14, -- Raid: Blackrock Foundry
	[669] = 14, -- Raid: Hellfire Citadel
	[547] = 23, -- Dungeon: Auchindoun
	[385] = 23, -- Dungeon: Bloodmaul Slag Mines
	[536] = 23, -- Dungeon: Grimrail Depot
	[558] = 23, -- Dungeon: Iron Docks
	[537] = 23, -- Dungeon: Shadowmoon Burial Grounds
	[476] = 23, -- Dungeon: Skyreach
	[556] = 23, -- Dungeon: The Everbloom
	[559] = 23, -- Dungeon: Upper Blackrock Spire

	-- 7.0
	[882] = 14, -- World: Broken Isles
	[959] = 14, -- World: Invasion Points
	[768] = 14, -- Raid: The Emerald Nightmare
	[861] = 14, -- Raid: Trial of Valor
	[786] = 14, -- Raid: The Nighthold
	[875] = 14, -- Raid: Tomb of Sargeras
	[946] = 14, -- Raid: Antorus, the Burning Throne
	[777] = 23, -- Dungeon: Assault on Violet Hold
	[740] = 23, -- Dungeon: Black Rook Hold
	[900] = 23, -- Dungeon: Cathedral of Eternal Night
	[800] = 23, -- Dungeon: Court of Stars
	[762] = 23, -- Dungeon: Darkheart Thicket
	[716] = 23, -- Dungeon: Eye of Azshara
	[721] = 23, -- Dungeon: Halls of Valor
	[727] = 23, -- Dungeon: Maw of Souls
	[767] = 23, -- Dungeon: Neltharion's Lair
	[860] = 23, -- Dungeon: Return to Karazhan
	[726] = 23, -- Dungeon: The Arcway
	[707] = 23, -- Dungeon: Vault of the Wardens
	[945] = 13, -- Dungeon: The Seat of the Triumvirate
}

function lib:GetBonusRollEncounterJournalLinkDifficulty(encounterID, instanceID)
	-- this extends the API to have correct fallback difficulty IDs
	local _, _, difficultyID = GetInstanceInfo()
	if(difficultyID ~= 0) then
		return difficultyID
	else
		if(encounterID == 1452) then
			-- Supreme Lord Kazzak thinks he's special
			return 15
		else
			return difficulties[instanceID] or 0
		end
	end
end
