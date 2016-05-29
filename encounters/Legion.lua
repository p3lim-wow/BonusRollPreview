local _, ns = ...
ns.encounterIDs = ns.encounterIDs or {}
ns.itemBlacklist = ns.itemBlacklist or {}
ns.continents = ns.continents or {}

-- http://www.wowhead.com/spells=0?filter=na=Bonus;cr=84:109:16;crs=1:6:6
for spellID, encounterID in next, {
	-- World - 822
	[227128] = 1790, -- Ana-Mouz
	[227129] = 1774, -- Calamir
	[228130] = 1789, -- Drugon the Frostblood
	[227131] = 1795, -- Flotsam
	[227132] = 1770, -- Humongris
	[227133] = 1769, -- Levantus
	[227134] = 1783, -- Na'zak the Fiend
	[227135] = 1749, -- Nithogg
	[227136] = 1763, -- Shar'thos
	[227137] = 1756, -- The Soultakers
	[227138] = 1796, -- Withered J'im

	-- The Emerald Nightmare - 768
	[221046] = 1703, -- Nythendra
	[221047] = 1744, -- Elerethe Renferal
	[221048] = 1738, -- Il'gynoth, Heart of Corruption
	[221049] = 1667, -- Ursoc
	[221050] = 1704, -- Dragons of Nightmare
	[221052] = 1750, -- Cenarius
	[221053] = 1726, -- Xavius

	-- The Nighthold - 786
	--- NYI

	-- Black Rook Hold - 740
	[226595] = 1518, -- The Amalgam of Souls
	[226599] = 1653, -- Illysanna Ravencrest
	[226600] = 1664, -- Smashspite the Hateful
	[226603] = 1672, -- Lord Kur'talos Ravencrest

	-- Court of Stars - 800
	[226605] = 1718, -- Patrol Captain Gerdo
	[226607] = 1719, -- Talixae Flamewreath
	[226608] = 1720, -- Advisor Melandrus

	-- Darkheart Thicket - 762
	[226610] = 1654, -- Archdruid Glaidalis
	[226611] = 1655, -- Oakheart
	[226613] = 1656, -- Dresaron
	[226615] = 1657, -- Shade of Xavius

	-- Eye of Azshara - 716
	[226618] = 1480, -- Warlord Parjesh
	[226619] = 1490, -- Lady Hatecoil
	[226621] = 1491, -- King Deepbeard
	[226622] = 1479, -- Serpentrix
	[226624] = 1492, -- Wrath of Azshara

	-- Halls of Valor - 721
	[226636] = 1485, -- Hymdall
	[226626] = 1486, -- Hyrja
	[226627] = 1487, -- Fenryr
	[226629] = 1488, -- God-King Skovald
	[226625] = 1489, -- Odyn

	-- Maw of Souls - 727
	[226637] = 1502, -- Ymiron, the Fallen King
	[226638] = 1512, -- Harbaron
	[226639] = 1663, -- Helya

	-- Neltharion's Lair - 767
	[226640] = 1662, -- Rokmora
	[226641] = 1665, -- Ularogg Cragshaper
	[226642] = 1673, -- Naraxas
	[226643] = 1687, -- Dargul the Underking

	-- The Arcway - 726
	[226644] = 1497, -- Ivanyr
	[226645] = 1498, -- Corstilax
	[226646] = 1499, -- General Xakal
	[226647] = 1500, -- Nal'tira
	[226648] = 1501, -- Advisor Vandros

	-- Vault of the Wardens - 707
	[226649] = 1467, -- Tirathon Saltheril
	[226652] = 1695, -- Inquisitor Tormentorum
	[226653] = 1468, -- Ash'golm
	[226654] = 1469, -- Glazer
	[226655] = 1470, -- Cordana Felsong

	-- Assault on Violet Hold - ???
	[226656] = 1693, -- Festerface
	[226657] = 1694, -- Shivermaw
	[226658] = 1702, -- Blood-Princess Thal'ena
	[226659] = 1686, -- Mindflayer Kaahrj
	[226660] = 1688, -- Millificent Manastorm
	[226661] = 1696, -- Anub'esset
	[226662] = 1697, -- Sael'orn
	[226663] = 1711, -- Fel Lord Betrug
} do
	ns.encounterIDs[spellID] = encounterID
end

for _, itemID in next, {
	-- Mounts
} do
	ns.itemBlacklist[itemID] = true
end

ns.continents[8] = 822
