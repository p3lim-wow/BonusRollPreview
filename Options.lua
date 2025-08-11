local addonName, addon = ...
local L = addon.L

local settings = {
  {
    key = 'alwaysShow',
    type = 'toggle',
    title = L['Always unfold the loot list'],
    -- tooltip = '',
    default = false
  },
  {
    key = 'fillDirection',
    type = 'menu',
    title = L['Direction the loot list should appear'],
    -- tooltip = '',
    default = 'UP',
    options = {
      {value = 'UP', label = L['Up']},
      {value = 'DOWN', label = L['Down']},
    },
  },
}

local haveFavoriteProviders, availableFavProviders = addon:GetAvailableFavoriteProviders()
do
  if haveFavoriteProviders then
    tinsert(settings, {
      key = 'favoriteProvider',
      type = 'menu',
      title = L['Select a Favorite Items provider'],
      default = 'ANY',
      options = {
        {value = 'ANY', label = L['Any']},
      },
    })
    tinsert(settings,{
      key = 'favoriteAlert',
      type = 'toggle',
      title = L['Visual and Audio cue for favorited Items'],
      default = true,
      parent = 'favoriteProvider',
    })
    tinsert(settings,{
      key = 'favoritesOnly',
      type = 'toggle',
      title = L['Filter preview to favorited items only'],
      default = false,
      parent = 'favoriteProvider',
    })
    for index,setting in ipairs(settings) do
      if setting.key == 'favoriteProvider' then
        if setting.type == 'menu' and setting.options then
          for order,provider in ipairs(availableFavProviders) do
            tinsert(setting.options, {value = provider, label = provider})
          end
        end
        break
      end
    end
  end
end

addon:RegisterSettings('BonusRollPreviewDB', settings)

function addon:OnLogin()
  if not BonusRollPreviewDB.anchor then
    BonusRollPreviewDB.anchor = {'CENTER', 'UIParent', 'CENTER', 0, 0}
  end
  if not haveFavoriteProviders then
    BonusRollPreviewDB.favoritesOnly = false
  else
    if not tContains(availableFavProviders,BonusRollPreviewDB.favoriteProvider) then
      BonusRollPreviewDB.favoriteProvider = 'ANY'
    end
  end
end

addon:RegisterSlash('/bonusrollpreview', '/brp', function(msg)
  msg = msg:lower()

  if(msg == 'unlock' or msg == 'lock') then
    BonusRollPreview:ToggleLock()
  elseif(msg == 'reset') then
    BonusRollPreviewDB.anchor = CopyTable(defaults.anchor)
    BonusRollPreview:OnEvent('PLAYER_LOGIN')
  else
    addon:OpenSettings()
  end
end)
