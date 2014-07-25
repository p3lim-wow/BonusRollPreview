local addonName, ns = ...

local buttons = {}
local temporary = {}

local defaults = {
	position = 'TOP',
}

local Panel = CreateFrame('Frame', nil, InterfaceOptionsFramePanelContainer)
Panel.name = addonName
Panel:Hide()

Panel:RegisterEvent('PLAYER_LOGIN')
Panel:SetScript('OnEvent', function()
	BonusRollPreviewDB = BonusRollPreviewDB or defaults

	for key, value in next, defaults do
		if(BonusRollPreviewDB[key] == nil) then
			BonusRollPreviewDB[key] = value
		end
	end

	BonusRollPreviewContainer:PLAYER_LOGIN()
end)

function Panel:okay()
	for key, value in next, temporary do
		BonusRollPreviewDB[key] = value
	end

	BonusRollPreviewContainer:HandleUpdate()
end

function Panel:default()
	BonusRollPreviewDB = defaults
	table.wipe(temporary)
end

function Panel:refresh()
	for key, button in next, buttons do
		if(button:IsObjectType('Button')) then
			UIDropDownMenu_SetSelectedValue(button, BonusRollPreviewDB[key])

			-- This is for some reason needed, gotta take a look into it later
			UIDropDownMenu_SetText(button, _G[BonusRollPreviewDB[key] .. '_KEY'])
		end
	end
end

local CreateDropdown
do
	local function OnClick(self)
		UIDropDownMenu_SetSelectedValue(self:GetParent().dropdown, self.value)
		temporary[self:GetParent().dropdown.key] = self.value
	end

	function CreateDropdown(parent, key, func)
		local Dropdown = CreateFrame('Button', addonName .. 'DropDown_' .. GetTime(), parent, 'UIDropDownMenuTemplate')
		Dropdown.OnClick = OnClick
		Dropdown.key = key

		UIDropDownMenu_SetWidth(Dropdown, 90)
		UIDropDownMenu_SetSelectedValue(Dropdown, BonusRollPreviewDB[key])
		UIDropDownMenu_Initialize(Dropdown, func)

		local Text = Dropdown:CreateFontString(nil, nil, 'GameFontHighlight')
		Text:SetPoint('LEFT', Dropdown, 'RIGHT', -1, 2)
		Dropdown.Text = Text

		buttons[key] = Dropdown

		return Dropdown
	end
end

Panel:SetScript('OnShow', function(self)
	local Title = self:CreateFontString(nil, nil, 'GameFontNormalLarge')
	Title:SetPoint('TOPLEFT', 16, -16)
	Title:SetText(addonName)

	local Description = self:CreateFontString(nil, nil, 'GameFontHighlightSmall')
	Description:SetPoint('TOPLEFT', Title, 'BOTTOMLEFT', 0, -8)
	Description:SetPoint('RIGHT', -32, 0)
	Description:SetJustifyH('LEFT')
	Description:SetText('Quick access to your upcoming loot!')
	self.Description = Description

	local Position = CreateDropdown(self, 'position', function(self)
		local selected = UIDropDownMenu_GetSelectedValue(self)
		local info = UIDropDownMenu_CreateInfo()
		info.text = 'Bottom'
		info.value = 'BOTTOM'
		info.func = self.OnClick
		info.checked = selected == info.value
		UIDropDownMenu_AddButton(info)

		info.text = 'Top'
		info.value = 'TOP'
		info.checked = selected == info.value
		UIDropDownMenu_AddButton(info)
	end)
	Position:SetPoint('TOPLEFT', Description, 'BOTTOMLEFT', -13, -14)
	Position.Text:SetText('Position of the list')

	self:SetScript('OnShow', nil)
end)

InterfaceOptions_AddCategory(Panel)

SLASH_BonusRollPreview1 = '/brp'
SLASH_BonusRollPreview1 = '/bonusrollpreview'
SlashCmdList[addonName] = function()
	InterfaceOptionsFrame_OpenToCategory(addonName)
end
