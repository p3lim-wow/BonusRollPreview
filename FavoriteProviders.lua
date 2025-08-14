local addonName,addon = ...

addon.favoriteProviders = {
  AtlasLootClassic = false,
  BastionLoot = false,
  LOIHLoot = false,
  LootAlarm = false,
  LootReserve = false,
}

local availableFavProviders = { }
local haveFavoriteProviders
function addon:GetAvailableFavoriteProviders()
  for name,status in pairs(addon.favoriteProviders) do
    local _, _, _, loadable, reason, security, updateAvailable = C_AddOns.GetAddOnInfo(name)
    local enabled = AddOnUtil.IsAddOnEnabledForCurrentCharacter(name)
    if (not reason or reason == '') and loadable and enabled then
      table.insert(availableFavProviders,name)
    end
  end
  haveFavoriteProviders = CountTable(availableFavProviders) > 0
  if haveFavoriteProviders then
    table.sort(availableFavProviders)
  else
    BonusRollPreviewDB.favoritesOnly = false
  end
  return haveFavoriteProviders, availableFavProviders
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
    if LOIHLOOT_GLOBAL_PRIVATE then
      for subTable, tableData in pairs(LOIHLootCharDB) do
        if tableData[itemID] then
          return format("|cffF5F5DC%s|r:%s","LOIH",subTable)
        end
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
  if BonusRollPreviewDB.favoriteProvider == 'ANY' then
    -- query all available checkers, return first hit
    local haveProviders, availableProviders = self:GetAvailableFavoriteProviders()
    local isFav
    if haveProviders then
      for _,provider in ipairs(availableProviders) do
        local isFav = providerChecker[provider](itemID)
        if isFav then
          return isFav
        end
      end
    end
  else
    -- query just the configured checker
    if providerChecker[BonusRollPreviewDB.favoriteProvider] then -- check we haven't ended up with a dangling reference
      return providerChecker[BonusRollPreviewDB.favoriteProvider](itemID)
    end
  end
  return ''
end