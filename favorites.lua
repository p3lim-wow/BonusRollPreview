local _, addon = ...

local favoriteProviders = {
	AtlasLootClassic = false,
	BastionLoot = false,
	LOIHLoot = false,
	LootAlarm = false,
	LootReserve = false,
	LootHunter = false,
}

local availableProviders = addon:T() -- only used for options menu & login check
function addon:GetAvailableFavoriteProviders()
	availableProviders:wipe()

	for name in next, favoriteProviders do
		if addon:IsAddOnEnabled(name) then
			availableProviders:insert(name)

			favoriteProviders[name] = true -- use this as a registry
		else
			favoriteProviders[name] = false
		end
	end

	availableProviders:sort()

	return availableProviders
end

function addon:HasFavoriteProvider(name)
	return favoriteProviders[name]
end

local providerChecker = {
	AtlasLootClassic = function(itemID)
		if AtlasLoot and AtlasLoot.Addons and AtlasLoot.Addons.GetAddon then
			local favourites = AtlasLoot.Addons:GetAddon('Favourites')
			if favourites and favourites:IsEnabled() and favourites.IsFavouriteItemID then
				if favourites:IsFavouriteItemID(itemID) then
					local icon = favourites:GetIconForActiveItemID(itemID)
					return '|cff00ff00AL|r' .. (icon and string.format('|T%s:0|t', icon)) or ''
				end
			end
		end
	end,
	BastionLoot = function(itemID)
		if BastionLoot and BastionLoot.GetFavorite then
			return BastionLoot:GetFavorite(itemID)
		end
	end,
	LOIHLoot = function(itemID)
		if LOIHLOOT_GLOBAL_PRIVATE and LOIHLOOT_GLOBAL_PRIVATE.IsItemWishList then
			local isFavorite, list = LOIHLOOT_GLOBAL_PRIVATE:IsItemWishList(itemID)
			if isFavorite then
				return string.format('|cff006666%s|r', list)
			end
		end
	end,
	LootAlarm = function(itemID)
		if LootAlarm and LootAlarm.IsInitialized and LootAlarm.GetActiveProfileName and LootAlarm.HasItemInActiveProfile then
			if LootAlarm:IsInitialized() then
				local profile = LootAlarm:GetActiveProfileName()
				local isFavorite = LootAlarm:HasItemInActiveProfile(itemID)
				return isFavorite and string.format('|cff2E8B57%s|r:%s', 'LA', profile)
			end
		end
	end,
	LootReserve = function(itemID)
		if LootReserve and LootReserve.Client and LootReserve.Client.IsFavorite then
			return LootReserve.Client:IsFavorite(itemID) and '|cffDDA0DDLR|r'
		end
	end,
	LootHunter = function(itemID)
		if LootHunterAPI and LootHunterAPI.IsFavorite then
			return LootHunterAPI:IsFavorite(itemID)
		end
	end,
}

function addon:GetFavoriteTag(itemID)
	local provider = BonusRollPreviewDB.favoriteProvider
	if not provider then
		return
	end

	if provider == 'ANY' then
		-- just iterate our registry
		for name, status in next, favoriteProviders do
			if status and providerChecker[name] and providerChecker[name](itemID) then
				return providerChecker[name](itemID)
			end
		end
	end

	-- just the configured checker
	-- check we haven't ended up with a dangling reference
	return favoriteProviders[provider] and providerChecker[provider] and providerChecker[provider](itemID)
end
