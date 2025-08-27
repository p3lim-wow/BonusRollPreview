local addonName, addon = ...
local L = addon.L

local settings = {
  {
    key = 'alwaysShow',
    type = 'toggle',
    title = L['Auto unfold'],
    tooltip = L['Always unfold the loot list'],
    default = false
  },
  {
    key = 'fillDirection',
    type = 'menu',
    title = L['Direction'],
    tooltip = L['Direction the loot list should appear'],
    default = 'UP',
    options = {
      {value = 'UP', label = L['Up']},
      {value = 'DOWN', label = L['Down']},
    },
  },
}

if addon.GetAvailableFavoriteProviders then
  local haveFavoriteProviders, sortedFavProviders = addon:GetAvailableFavoriteProviders()
  do
    if haveFavoriteProviders then
      tinsert(settings, {
        key = 'favoriteProvider',
        type = 'menu',
        title = L['Favorites from'],
        tooltip = L['Select a Favorite Items provider'],
        default = 'ANY',
        options = {
          {value = 'ANY', label = L['Any']},
        },
      })
      tinsert(settings,{
        key = 'favoriteAlert',
        type = 'toggle',
        title = L['Favorite alert'],
        tooltip = L['Visual and Audio cue for favorited Items'],
        default = true,
        parent = 'favoriteProvider',
      })
      tinsert(settings,{
        key = 'favoritesOnly',
        type = 'toggle',
        title = L['Only favorites'],
        tooltip = L['Filter preview to favorited items only'],
        default = false,
        parent = 'favoriteProvider',
      })
      for index,setting in ipairs(settings) do
        if setting.key == 'favoriteProvider' then
          if setting.type == 'menu' and setting.options then
            for order,provider in ipairs(sortedFavProviders) do
              tinsert(setting.options, {value = provider, label = provider})
            end
          end
          break
        end
      end
    end
  end
end

addon:RegisterSettings('BonusRollPreviewDB', settings)

function addon:OnLogin()
  if not BonusRollPreviewDB.anchor then
    BonusRollPreviewDB.anchor = {'CENTER', 'UIParent', 'CENTER', 0, 0}
  end
  if addon.GetAvailableFavoriteProviders then
    if not haveFavoriteProviders then
      BonusRollPreviewDB.favoritesOnly = false
    elseif not addon.favoriteProviders[BonusRollPreviewDB.favoriteProvider] then
      BonusRollPreviewDB.favoriteProvider = 'ANY'
    end
  end
end

addon:RegisterSlash('/bonusrollpreview', '/brp', function(msg)
  msg = msg:lower()

  if(msg == 'unlock' or msg == 'lock') then
    BonusRollPreview:ToggleLock()
  elseif(msg == 'reset') then
    BonusRollPreviewDB.anchor = {'CENTER', 'UIParent', 'CENTER', 0, 0}
    BonusRollPreview:OnEvent('PLAYER_LOGIN')
  else
    addon:OpenSettings()
  end
end)