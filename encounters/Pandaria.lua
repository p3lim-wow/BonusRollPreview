
local _, ns = ...
ns.encounterInfo = ns.encounterInfo or {}
ns.itemBlacklist = ns.itemBlacklist or {}
ns.dynamicEncounters = ns.dynamicEncounters or {}

-- http://www.wowhead.com/spells=0?filter=na=Bonus;cr=84:109:16;crs=1:6:5
for spellID, encounterInfo in next, {
	--- World
	[132205] = {691, 322, 3}, -- Sha of Anger
	[132206] = {725, 322, 3}, -- Salyis' Warband (Galleon)
	[136381] = {814, 322, 3}, -- Nalak, The Storm God
	[137554] = {826, 322, 3}, -- Oondasta
	[148317] = {857, 322, 3}, -- Celestials (also encounterIDs 858, 859 and 860)
	[148316] = {861, 322, 3}, -- Ordos, Fire-God of the Yaungol

	--- Raids
	-- Mogu'Shan Vaults
	[125144] = {679, 317, nil, 4}, -- The Stone Guard
	[132189] = {689, 317, nil, 4}, -- Feng the Accursed
	[132190] = {682, 317, nil, 4}, -- Gara'jal the Spiritbinder
	[132191] = {687, 317, nil, 4}, -- The Spirit Kings
	[132192] = {726, 317, nil, 4}, -- Elegon
	[132193] = {677, 317, nil, 4}, -- Will of the Emperor

	-- Heart of Fear
	[132194] = {745, 330, nil, 4}, -- Imperial Vizier Zor'lok
	[132195] = {744, 330, nil, 4}, -- Blade Lord Tay'ak
	[132196] = {713, 330, nil, 4}, -- Garalon
	[132197] = {741, 330, nil, 4}, -- Wind Lord Mel'jarak
	[132198] = {737, 330, nil, 4}, -- Amber-Shaper Un'sok
	[132199] = {743, 330, nil, 4}, -- Grand Empress Shek'zeer

	-- Terrace of Endless Spring
	[132200] = {683, 320, nil, 4}, -- Protectors of the Endless
	[132204] = {683, 320, nil, 4}, -- Protectors of the Endless (Elite)
	[132201] = {742, 320, nil, 4}, -- Tsulong
	[132202] = {729, 320, nil, 4}, -- Lei Shi
	[132203] = {709, 320, nil, 4}, -- Sha of Fear

	-- Throne of Thunder
	[139674] = {827, 362, nil, 4}, -- Jin'rokh the Breaker
	[139677] = {819, 362, nil, 4}, -- Horridon
	[139679] = {816, 362, nil, 4}, -- Council of Elders
	[139680] = {825, 362, nil, 4}, -- Tortos
	[139682] = {821, 362, nil, 4}, -- Magaera
	[139684] = {828, 362, nil, 4}, -- Ji'kun, the Ancient Mother
	[139686] = {818, 362, nil, 4}, -- Durumu the Forgotten
	[139687] = {820, 362, nil, 4}, -- Primordious
	[139688] = {824, 362, nil, 4}, -- Dark Animus
	[139689] = {817, 362, nil, 4}, -- Iron Qon
	[139690] = {829, 362, nil, 4}, -- Twin Consorts (Empyreal Queens)
	[139691] = {832, 362, nil, 4}, -- Lei Shen, The Thunder King
	[139692] = {831, 362, nil, 4}, -- Ra-den

	-- Siege of Orgrimmar
	[145909] = {852, 369, nil, 4}, -- Immerseus
	[145910] = {849, 369, nil, 4}, -- The Fallen Protectors
	[145911] = {866, 369, nil, 4}, -- Norushen
	[145912] = {867, 369, nil, 4}, -- Sha of Pride
	-- Galakras needs special handling
	[145914] = {864, 369, nil, 4}, -- Iron Juggernaut
	[145915] = {856, 369, nil, 4}, -- Kor'kron Dark Shaman
	[145916] = {850, 369, nil, 4}, -- General Nazgrim
	[145917] = {846, 369, nil, 4}, -- Malkorok
	[145919] = {870, 369, nil, 4}, -- Spoils of Pandaria
	[145920] = {851, 369, nil, 4}, -- Thok the Bloodthirsty
	[145918] = {865, 369, nil, 4}, -- Siegecrafter Blackfuse
	[145921] = {853, 369, nil, 4}, -- Paragons of the Klaxxi
	[145922] = {869, 369, nil, 4}, -- Garrosh Hellscream
} do
	ns.encounterInfo[spellID] = encounterInfo
end

-- Galakras has two IDs (868, 881).
-- Pick whichever one the client wants to use at load.
ns.dynamicEncounters[145913] = {5, 369, nil, 4}

for _, itemID in next, {
	-- Mounts
	87777, -- Reins of the Astral Cloud Serpent
	93666, -- Spawn of Horridon
	95059, -- Cluth of Ji-Kun
	104253, -- Kor'kron Juggernaut
} do
	ns.itemBlacklist[itemID] = true
end
