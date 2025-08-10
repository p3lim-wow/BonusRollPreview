local addonName, addon = ...

local settings = {
	{
		key = 'alwaysShow',
		type = 'toggle',
		title = addon.L['Always unfold the loot list'],
		-- tooltip = '',
		default = false
	},
	{
		key = 'fillDirection',
		type = 'menu',
		title = addon.L['Direction the loot list should appear'],
		-- tooltip = '',
		default = 'UP',
		options = {
			{value = 'UP', label = addon.L['Up']},
			{value = 'DOWN', label = addon.L['Down']},
		},
	}
}

addon:RegisterSettings('BonusRollPreviewDB', settings)
-- addon:RegisterSettingsSlash('/bonusrollpreview', '/brp')

function addon:OnLogin()
	if not BonusRollPreviewDB.anchor then
		BonusRollPreviewDB.anchor = {'CENTER', 'UIParent', 'CENTER', 0, 0}
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
