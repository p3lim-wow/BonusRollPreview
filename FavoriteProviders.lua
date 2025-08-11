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
  AtlasLootClassic = function()
    if AtlasLoot and AtlasLoot.Addons and AtlasLoot.Addons.GetAddon then
      local Favourites = AtlasLoot.Addons:GetAddon("Favourites")
      if Favourites and Favourites:IsEnabled() and Favourites.IsFavouriteItemID then
        return function(itemID) -- checker
          if Favourites:IsFavouriteItemID(itemID) then
            local icon = Favourites:GetIconForActiveItemID(itemID)
            return "|cff00ff00AL|r"..(icon and format("|T%s:0|t",icon)) or ''
          end
        end
      end
    end
  end,
  BastionLoot = function()
    if BastionLoot and BastionLoot.GetFavorite then
      return function(itemID) -- checker
        return BastionLoot:GetFavorite(itemID)
      end
    end
  end,
  LOIHLoot = function()
    if LOIHLOOT_GLOBAL_PRIVATE then
      return function(itemID) -- checker
        for subTable, tableData in pairs(LOIHLootCharDB) do
          if tableData[itemID] then
            return format("|cffF5F5DC%s|r:%s","LOIH",subTable)
          end
        end
      end
    end
  end,
  LootAlarm = function()
    if type(LootAlarmLocalDB) == "table" then
      return function(itemID) -- checker
        local activeProfile = LootAlarmLocalDB.Settings and LootAlarmLocalDB.Settings.LoadedProfile
        if activeProfile and activeProfile ~= '' then
          local profiles = LootAlarmLocalDB.Profiles
          if profiles then
            local Items = profiles[activeProfile].Items
            if Items then
              for ItemName,ItemInfo in pairs(Items) do
                if ItemInfo.ID == itemID then
                  return format("|cff2E8B57%s|r:%s","LA",activeProfile)
                end
              end
            end
          end
        end
      end
    end
  end,
  LootReserve = function()
    if LootReserve and LootReserve.Client and LootReserve.Client.IsFavorite then
      return function(itemID) -- checker
        return LootReserve.Client:IsFavorite(itemID) and "|cffDDA0DDLR|r"
      end
    end
  end,
}

local cachedProviderCheckers = {}
function addon:GetProviderChecker(provider)
  if not cachedProviderCheckers[provider] then
    local func = providerChecker[provider]()
    if type(func) == "function" then
      cachedProviderCheckers[provider] = func
    end
  end
  return cachedProviderCheckers[provider]
end

function addon:IsFavoritedItem(itemID)
  if BonusRollPreviewDB.favoriteProvider == 'ANY' then
    -- query all available checkers, return first hit
    local haveProviders, availableProviders = self:GetAvailableFavoriteProviders()
    local isFav
    if haveProviders then
      for _,provider in ipairs(availableProviders) do
        local checker = self:GetProviderChecker(provider)
        if type(checker) == "function" then
          local isFav = checker(itemID)
          if isFav then
            return isFav
          end
        end
      end
    end
  else
    -- query just the configured checker
    local func = self:GetProviderChecker(BonusRollPreviewDB.favoriteProvider)
    if type(func) == "function" then
      return func(itemID)
    end
  end
  return ''
end