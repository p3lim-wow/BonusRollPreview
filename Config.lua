local addonName, ns = ...

local objects = {}
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
	for key, object in next, objects do
		if(object:IsObjectType('Frame')) then
			object.Label:SetText(object.keys[BonusRollPreviewDB[key]])
		end
	end
end

local CreateDropdown
do
	local BACKDROP = {
		bgFile = [[Interface\DialogFrame\UI-DialogBox-Background-Dark]],
		edgeFile = [[Interface\DialogFrame\UI-DialogBox-Border]], edgeSize = 32,
		insets = {top = 12, bottom = 9, left = 11, right = 12}
	}

	local function OnHide(self)
		self.Menu:Hide()
	end

	local function MenuClick(self)
		local Menu = self:GetParent().Menu
		if(Menu:IsShown()) then
			Menu:Hide()
		else
			for key, Item in next, Menu.items do
				Item.Button:SetChecked(key == (temporary[Menu.key] or QuickQuestDB[Menu.key]))
			end

			Menu:Show()
		end

		PlaySound('igMainMenuOptionCheckBoxOn')
	end

	local function ItemClick(self)
		local Menu = self:GetParent()
		temporary[Menu.key] = self.value

		Menu:Hide()
		Menu:GetParent().Label:SetText(self:GetText())
	end

	function CreateDropdown(parent, key, items)
		local Dropdown = CreateFrame('Frame', nil, parent)
		Dropdown:SetSize(110, 32)
		Dropdown:SetScript('OnHide', OnHide)
		Dropdown.keys = items

		local LeftTexture = Dropdown:CreateTexture(nil, 'ARTWORK')
		LeftTexture:SetPoint('TOPLEFT', -14, 17)
		LeftTexture:SetSize(25, 64)
		LeftTexture:SetTexture([[Interface\Glues\CharacterCreate\CharacterCreate-LabelFrame]])
		LeftTexture:SetTexCoord(0, 0.1953125, 0, 1)

		local RightTexture = Dropdown:CreateTexture(nil, 'ARTWORK')
		RightTexture:SetPoint('TOPRIGHT', 14, 17)
		RightTexture:SetSize(25, 64)
		RightTexture:SetTexture([[Interface\Glues\CharacterCreate\CharacterCreate-LabelFrame]])
		RightTexture:SetTexCoord(0.8046875, 1, 0, 1)

		local MiddleTexture = Dropdown:CreateTexture(nil, 'ARTWORK')
		MiddleTexture:SetPoint('TOPLEFT', LeftTexture, 'TOPRIGHT')
		MiddleTexture:SetPoint('TOPRIGHT', RightTexture, 'TOPLEFT')
		MiddleTexture:SetTexture([[Interface\Glues\CharacterCreate\CharacterCreate-LabelFrame]])
		MiddleTexture:SetTexCoord(0.1953125, 0.8046875, 0, 1)

		local Button = CreateFrame('Button', nil, Dropdown)
		Button:SetPoint('TOPRIGHT', RightTexture, -16, -18)
		Button:SetSize(24, 24)
		Button:SetNormalTexture([[Interface\ChatFrame\UI-ChatIcon-ScrollDown-Up]])
		Button:SetPushedTexture([[Interface\ChatFrame\UI-ChatIcon-ScrollDown-Down]])
		Button:SetDisabledTexture([[Interface\ChatFrame\UI-ChatIcon-ScrollDown-Disabled]])
		Button:SetHighlightTexture([[Interface\Buttons\UI-Common-MouseHilight]])
		Button:GetHighlightTexture():SetBlendMode('ADD')
		Button:SetScript('OnClick', MenuClick)
		Dropdown.Button = Button

		local Label = Dropdown:CreateFontString(nil, nil, 'GameFontHighlightSmall')
		Label:SetPoint('RIGHT', Button, 'LEFT')
		Label:SetSize(0, 10)
		Dropdown.Label = Label

		local Menu = CreateFrame('Frame', nil, Dropdown)
		Menu:SetPoint('TOPLEFT', Dropdown, 'BOTTOMLEFT', 0, 4)
		Menu:SetBackdrop(BACKDROP)
		Menu:Hide()
		Menu.key = key
		Menu.items = {}
		Dropdown.Menu = Menu

		local index, maxWidth = 0, 0
		for value, name in next, items do
			local Item = CreateFrame('Button', nil, Menu)
			Item:SetPoint('TOPLEFT', 14, -(14 + (18 * index)))
			Item:SetHighlightTexture([[Interface\QuestFrame\UI-QuestTitleHighlight]])
			Item:GetHighlightTexture():SetBlendMode('ADD')
			Item:SetScript('OnClick', ItemClick)
			Item.value = value

			local ItemButton = CreateFrame('CheckButton', nil, Item)
			ItemButton:SetPoint('LEFT')
			ItemButton:SetSize(16, 16)
			ItemButton:SetNormalTexture([[Interface\Common\UI-DropDownRadioChecks]])
			ItemButton:GetNormalTexture():SetTexCoord(0.5, 1, 0.5, 1)
			ItemButton:SetCheckedTexture([[Interface\Common\UI-DropDownRadioChecks]])
			ItemButton:GetCheckedTexture():SetTexCoord(0, 0.5, 0.5, 1)
			ItemButton:EnableMouse(false)
			Item.Button = ItemButton

			local ItemLabel = Item:CreateFontString(nil, nil, 'GameFontHighlightSmall')
			ItemLabel:SetPoint('LEFT', ItemButton, 'RIGHT', 4, -1)
			ItemLabel:SetText(name)
			Item:SetFontString(ItemLabel)

			local width = ItemLabel:GetWidth()
			if(width > maxWidth) then
				maxWidth = width
			end

			Menu.items[value] = Item
			index = index + 1
		end

		for _, Item in next, Menu.items do
			Item:SetSize(32 + maxWidth, 18)
		end

		Menu:SetSize(60 + maxWidth, 28 + 18 * index)

		local Text = Dropdown:CreateFontString(nil, nil, 'GameFontHighlight')
		Text:SetPoint('LEFT', Dropdown, 'RIGHT', 3, 2)
		Dropdown.Text = Text

		objects[key] = Dropdown

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

	local Position = CreateDropdown(self, 'position', {
		BOTTOM = 'Bottom',
		TOP = 'Top'
	})
	Position:SetPoint('TOPLEFT', Description, 'BOTTOMLEFT', 0, -14)
	Position.Text:SetText('Position of the list')

	Panel:refresh()
	self:SetScript('OnShow', nil)
end)

InterfaceOptions_AddCategory(Panel)

SLASH_BonusRollPreview1 = '/brp'
SLASH_BonusRollPreview1 = '/bonusrollpreview'
SlashCmdList[addonName] = function()
	InterfaceOptionsFrame_OpenToCategory(addonName)
	InterfaceOptionsFrame_OpenToCategory(addonName)
end
