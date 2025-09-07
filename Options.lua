local _, addon = ...
local L = addon.L

local DEFAULT_POSITION = {'CENTER', 'UIParent', 'CENTER', 0, 0}

local settings = addon:T{
	{
		key = 'alwaysShow',
		type = 'toggle',
		title = L['Auto show'],
		tooltip = L['Always show the loot list'],
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
	local providers = addon:GetAvailableFavoriteProviders()
	if #providers > 0 then
		local providerOptions = {
			{value = 'ANY', label = L['Any']},
		}

		for _, name in next, providers do
			table.insert(providerOptions, {
				value = name,
				label = name,
			})
		end

		settings:insert({
			key = 'favoriteProvider',
			type = 'menu',
			title = L['Favorites from'],
			tooltip = L['Select a Favorite Items provider'],
			default = 'ANY',
			options = providerOptions,
		})

		settings:insert({
			key = 'favoriteAlert',
			type = 'toggle',
			title = L['Favorite alert'],
			tooltip = L['Visual and Audio cue for favorited Items'],
			default = true,
			parent = 'favoriteProvider',
		})

		settings:insert({
			key = 'favoritesOnly',
			type = 'toggle',
			title = L['Only favorites'],
			tooltip = L['Filter preview to favorited items only'],
			default = false,
			parent = 'favoriteProvider',
		})
	end

	function addon:PLAYER_LOGIN()
		if providers == 0 then
			BonusRollPreviewDB.favoritesOnly = false
		elseif not addon:HasFavoriteProvider(BonusRollPreviewDB.favoriteProvider) then
			BonusRollPreviewDB.favoriteProvider = 'ANY'
		end
	end
end

addon:RegisterSettings('BonusRollPreviewDB', settings)

function addon:PLAYER_LOGIN()
	if not BonusRollPreviewDB.anchor then
		BonusRollPreviewDB.anchor = CopyTable(DEFAULT_POSITION)
	end
end

addon:RegisterSlash('/bonusrollpreview', '/brp', function(msg)
	msg = msg:lower()

	if msg == 'unlock' or msg == 'lock' then
		BonusRollPreview:ToggleLock()
	elseif msg == 'reset' then
		BonusRollPreviewDB.anchor = CopyTable(DEFAULT_POSITION)
		BonusRollPreview:OnEvent('PLAYER_LOGIN')
	else
		addon:OpenSettings()
	end
end)
