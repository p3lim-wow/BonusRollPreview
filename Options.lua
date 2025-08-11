local addonName, addon = ...
local L = addon.L

local defaults = {
	anchor = {'CENTER', 'UIParent', 'CENTER', 0, 0},
	alwaysShow = false,
	fillDirection = 'UP',
	favoriteAlert = true,
	favoritesOnly = false,
	favoriteProvider = 'ANY',
}

local Options = LibStub('Wasabi'):New(addonName, 'BonusRollPreviewDB', defaults)
Options:Initialize(function(self)
	local Title = self:CreateTitle()
	Title:SetPoint('TOPLEFT', 16, -16)
	Title:SetText(addonName)

	local Description = self:CreateDescription()
	Description:SetPoint('TOPLEFT', Title, 'BOTTOMLEFT', 0, -8)
	Description:SetText(L['Lock/unlock movement with /brp lock, and reset the position with /brp reset.']:gsub('/brp %w+', '|cff9999ff%1|r'))

	local AlwaysShow = self:CreateCheckButton('alwaysShow')
	AlwaysShow:SetPoint('TOPLEFT', Description, 'BOTTOMLEFT', 0, -20)
	AlwaysShow:SetText(L['Always unfold the loot list'])

	local FillDirection = self:CreateDropDown('fillDirection')
	FillDirection:SetPoint('TOPLEFT', AlwaysShow, 'BOTTOMLEFT', 0, -10)
	FillDirection:SetText(L['Direction the loot list should appear'])
	FillDirection:SetValues({
		UP = L['Up'],
		DOWN = L['Down'],
	})

	local haveFavoriteProviders, availableFavProviders = addon:GetAvailableFavoriteProviders()
	local FavoriteProviders = self:CreateDropDown('favoriteProvider')
	FavoriteProviders:SetPoint('TOPLEFT', FillDirection, 'BOTTOMLEFT', 0, -10)
	FavoriteProviders:SetText(L['Select a Favorite Items provider'])
	if haveFavoriteProviders then
		local values = {
			ANY = L['Any'],
		}
		for _,addonName in ipairs(availableFavProviders) do
			values[addonName] = addonName
		end
		FavoriteProviders:SetValues(values)
		FavoriteProviders:Enable()
	else
		FavoriteProviders:SetValues({[_G.NONE] = _G.NONE})
		FavoriteProviders:Disable()
	end

	if haveFavoriteProviders then
		local FavoriteShow = self:CreateCheckButton('favoriteAlert')
		FavoriteShow:SetPoint('TOPLEFT', FavoriteProviders, 'BOTTOMLEFT', 0, -10)
		FavoriteShow:SetText(L['Visual and Audio cue for favorited Items'])

		local OnlyFavorites = self:CreateCheckButton('favoritesOnly')
		OnlyFavorites:SetPoint('TOPLEFT', FavoriteShow, 'BOTTOMLEFT', 20, -10)
		OnlyFavorites:SetText(L['Filter preview to favorited items only'])
	end

end)

_G['SLASH_' .. addonName .. '1'] = '/brp'
SlashCmdList[addonName] = function(msg)
	msg = msg:lower()

	if(msg == 'unlock' or msg == 'lock') then
		BonusRollPreview:ToggleLock()
	elseif(msg == 'reset') then
		BonusRollPreviewDB.anchor = CopyTable(defaults.anchor)
		BonusRollPreview:OnEvent('PLAYER_LOGIN')
	else
		Options:ShowOptions()
	end
end