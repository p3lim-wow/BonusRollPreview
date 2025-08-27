local addonName,addon = ...

addon.favoriteProviders = {
  AtlasLootClassic = false,
  BastionLoot = false,
  LOIHLoot = false,
  LootAlarm = false,
  LootReserve = false,
}

local sortedFavProviders = { } -- only used for options menu & login check
local haveFavoriteProviders
function addon:GetAvailableFavoriteProviders()
  sortedFavProviders = wipe(sortedFavProviders)
  for name,status in pairs(addon.favoriteProviders) do
    local _, _, _, loadable, reason, security, updateAvailable = C_AddOns.GetAddOnInfo(name)
    local enabled = AddOnUtil.IsAddOnEnabledForCurrentCharacter(name)
    if (not reason or reason == '') and loadable and enabled then
      table.insert(sortedFavProviders,name)
      addon.favoriteProviders[name] = true -- use this as a registry
    else
      addon.favoriteProviders[name] = false
    end
  end
  haveFavoriteProviders = CountTable(sortedFavProviders) > 0
  if haveFavoriteProviders then
    table.sort(sortedFavProviders)
  else
    BonusRollPreviewDB.favoritesOnly = false
  end
  return haveFavoriteProviders, sortedFavProviders
end

local providerChecker = {
  AtlasLootClassic = function(itemID)
    if AtlasLoot and AtlasLoot.Addons and AtlasLoot.Addons.GetAddon then
      local Favourites = AtlasLoot.Addons:GetAddon("Favourites")
      if Favourites and Favourites:IsEnabled() and Favourites.IsFavouriteItemID then
        if Favourites:IsFavouriteItemID(itemID) then
          local icon = Favourites:GetIconForActiveItemID(itemID)
          return "|cff00ff00AL|r"..(icon and format("|T%s:0|t",icon)) or ''
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
      local isFav, list = LOIHLOOT_GLOBAL_PRIVATE:IsItemWishList(itemID)
      if isFav then
        return format("|cff006666%s|r",list)
      end
    end
  end,
  LootAlarm = function(itemID)
    if LootAlarm and LootAlarm.IsInitialized and LootAlarm.GetActiveProfileName and LootAlarm.HasItemInActiveProfile then
      if LootAlarm:IsInitialized() then
        local profile = LootAlarm:GetActiveProfileName()
        local isFav = LootAlarm:HasItemInActiveProfile(itemID)
        return isFav and format("|cff2E8B57%s|r:%s","LA",profile)
      end
    end
  end,
  LootReserve = function(itemID)
    if LootReserve and LootReserve.Client and LootReserve.Client.IsFavorite then
      return LootReserve.Client:IsFavorite(itemID) and "|cffDDA0DDLR|r"
    end
  end,
}

function addon:IsFavoritedItem(itemID)
  local favoriteProvider = BonusRollPreviewDB.favoriteProvider
  if not favoriteProvider then return end
  if favoriteProvider == 'ANY' then
    -- just iterate our registry
    local isFav
    for provider, status in pairs(addon.favoriteProviders) do
      if status and providerChecker[provider] then
        isFav = providerChecker[provider](itemID)
        if isFav then
          return isFav
        end
      end
    end
  else
    -- just the configured checker
    -- check we haven't ended up with a dangling reference
    if providerChecker[favoriteProvider] and addon.favoriteProviders[favoriteProvider] then
      return providerChecker[favoriteProvider](itemID)
    end
  end
end