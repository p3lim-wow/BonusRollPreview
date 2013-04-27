local _, ns = ...

local items = {}
local specializations = {}
local collapsed = true
local currentEncounterID

local Frame = CreateFrame('Frame', nil, BonusRollFrame)
local Handle = CreateFrame('Button', nil, BonusRollFrame)

local backdrop = {
	bgFile = [[Interface\ChatFrame\ChatFrameBackground]], tile = true, tileSize = 16,
	edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]], edgeSize = 16,
	insets = {left = 4, right = 4, top = 4, bottom = 4}
}

local function OnUpdate(self, elapsed)
	if(IsModifiedClick('COMPAREITEMS')) then
		GameTooltip_ShowCompareItem()
	else
		ShoppingTooltip1:Hide()
		ShoppingTooltip2:Hide()
		ShoppingTooltip3:Hide()
	end

	if(IsModifiedClick('DRESSUP')) then
		ShowInspectCursor()
	else
		ResetCursor()
	end
end

local function OnEnter(self)
	GameTooltip:SetOwner(self, 'ANCHOR_TOPLEFT')
	GameTooltip:SetItemByID(self.itemID)

	self:SetScript('OnUpdate', OnUpdate)
end

local function OnLeave(self)
	GameTooltip:Hide()

	self:SetScript('OnUpdate', nil)
end

local function OnClick(self)
	HandleModifiedItemClick(self.itemLink)
end

local function GetItemLine(index)
	local Item = items[index]
	if(not Item) then
		Item = CreateFrame('Button', nil, Frame)
		Item:SetPoint('BOTTOM', 0, 6 + ((index - 1) * 48))
		Item:SetSize(321, 45)

		local Icon = Item:CreateTexture(nil, 'BACKGROUND')
		Icon:SetPoint('TOPLEFT', 2, -2)
		Icon:SetSize(42, 42)
		Item.Icon = Icon

		local Background = Item:CreateTexture(nil, 'BORDER')
		Background:SetAllPoints()
		Background:SetTexture([[Interface\EncounterJournal\UI-EncounterJournalTextures]])
		Background:SetTexCoord(0.00195313, 0.62890625, 0.61816406, 0.66210938)
		Background:SetDesaturated(true)

		local Name = Item:CreateFontString(nil, 'ARTWORK', 'GameFontNormalMed3')
		Name:SetPoint('TOPLEFT', Icon, 'TOPRIGHT', 7, -7)
		Name:SetSize(250, 12)
		Name:SetJustifyH('LEFT')
		Item.Name = Name

		local Class = Item:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
		Class:SetPoint('BOTTOMRIGHT', Name, 'TOPLEFT', 264, -30)
		Class:SetSize(0, 12)
		Class:SetJustifyH('RIGHT')
		Item.Class = Class

		local Slot = Item:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
		Slot:SetPoint('BOTTOMLEFT', Icon, 'BOTTOMRIGHT', 7, 5)
		Slot:SetPoint('BOTTOMRIGHT', Class, 'BOTTOMLEFT', -15, 0)
		Slot:SetSize(0, 12)
		Slot:SetJustifyH('LEFT')
		Item.Slot = Slot

		Item:SetScript('OnClick', OnClick)
		Item:SetScript('OnEnter', OnEnter)
		Item:SetScript('OnLeave', OnLeave)

		items[index] = Item
	end

	return Item
end

local function PopulateList()
	local numItems = 0
	for index = 1, EJ_GetNumLoot() do
		local name, texture, slot, itemClass, itemID, itemLink, encounterID = EJ_GetLootInfoByIndex(index)
		if(encounterID == currentEncounterID) then
			numItems = numItems + 1

			local Item = GetItemLine(numItems)
			Item.Icon:SetTexture(texture)
			Item.Name:SetText(name)
			Item.Slot:SetText(slot)
			Item.Class:SetText(itemClass)

			Item.itemID = itemID
			Item.itemLink = itemLink

			Item:Show()
		end
	end

	Frame:SetHeight(math.max(76, 8 + (numItems * 48)))

	if(numItems > 0) then
		Frame.Empty:Hide()
	else
		Frame.Empty:Show()
	end
end

local function InitializeList(specific)
	for index, button in pairs(items) do
		button:Hide()
	end

	if(not specific) then
		collapsed = false
		Handle:GetScript('OnClick')(Handle)
	end

	local currentInstance = EJ_GetCurrentInstance()
	EJ_SelectInstance(currentInstance > 0 and currentInstance or 322)

	local _, _, difficulty = GetInstanceInfo()
	EJ_SetDifficulty(difficulty > 2 and (difficulty - 2) or 1)

	local _, _, classID = UnitClass('player')
	local specialization = GetSpecialization()
	if(specific or specialization) then
		EJ_SetLootFilter(classID, GetSpecializationInfo(specific or specialization))
	else
		EJ_SetLootFilter(classID, 0)
	end

	PopulateList()
end

local function UpdateSpecializations(currentIndex)
	for index, button in pairs(specializations) do
		if(currentIndex == index) then
			button.LeftBorder:SetVertexColor(1, 0, 0)
			button.RightBorder:SetVertexColor(1, 0, 0)
		else
			button.LeftBorder:SetVertexColor(1, 1, 1)
			button.RightBorder:SetVertexColor(1, 1, 1)
		end
	end
end

local function SpecializationClick(self)
	UpdateSpecializations(self.index)
	InitializeList(self.index)
end

local function SpecializationEnter(self)
	GameTooltip:SetOwner(self, 'ANCHOR_TOPRIGHT')
	GameTooltip:AddLine(self.name, 1, 1, 1)
	GameTooltip:Show()
end

local function CreateSpecializationTabs(self)
	for index = 1, GetNumSpecializations() do
		local SpecButton = CreateFrame('Button', nil, self)
		SpecButton:SetSize(24, 16)
		SpecButton:SetScript('OnClick', SpecializationClick)
		SpecButton:SetScript('OnEnter', SpecializationEnter)
		SpecButton:SetScript('OnLeave', GameTooltip_Hide)
		SpecButton:SetFrameLevel(6)

		local _, name, _, texture = GetSpecializationInfo(index)
		SpecButton.index = index
		SpecButton.name = name

		local SpecBackground = SpecButton:CreateTexture(nil, 'BACKGROUND')
		SpecBackground:SetAllPoints()
		SpecBackground:SetTexture(texture)
		SpecBackground:SetTexCoord(0, 1, 0.2, 0.8)

		local SpecLeft = SpecButton:CreateTexture(nil, 'BORDER')
		SpecLeft:SetPoint('BOTTOMLEFT', -6, -7)
		SpecLeft:SetSize(18, 24)
		SpecLeft:SetTexture([[Interface\RaidFrame\RaidPanel-BottomLeft]])
		SpecLeft:SetTexCoord(0, 0.8, 0, 1)
		SpecButton.LeftBorder = SpecLeft

		local SpecRight = SpecButton:CreateTexture(nil, 'BORDER')
		SpecRight:SetPoint('BOTTOMRIGHT', 6, -7)
		SpecRight:SetSize(18, 24)
		SpecRight:SetTexture([[Interface\RaidFrame\RaidPanel-BottomRight]])
		SpecRight:SetTexCoord(0.2, 1, 0, 1)
		SpecButton.RightBorder = SpecRight

		if(index == 1) then
			SpecButton:SetPoint('TOPLEFT', self, 'BOTTOMLEFT', 20, 2)
		else
			SpecButton:SetPoint('LEFT', specializations[index - 1], 'RIGHT', 15, 0)
		end

		specializations[index] = SpecButton
	end

	UpdateSpecializations(GetSpecialization())
end

Frame:RegisterEvent('PLAYER_LOGIN')
Frame:SetScript('OnEvent', function(self, event, ...)
	if(event == 'SPELL_CONFIRMATION_PROMPT') then
		local spellID, confirmType = ...
		if(confirmType == CONFIRMATION_PROMPT_BONUS_ROLL) then
			currentEncounterID = ns.GetEncounterID(spellID)
			if(currentEncounterID) then
				if(#specializations == 0) then
					CreateSpecializationTabs(self)
				end

				InitializeList()
			else
				print('|cffff8080HabeebIt:|r Found an unused spell [' .. spellID .. ']. Please report this!')
			end
		end
	elseif(event == 'EJ_LOOT_DATA_RECEIVED' and BonusRollFrame:IsShown()) then
		PopulateList()
	elseif(event == 'PLAYER_LOGIN') then
		self:RegisterEvent('SPELL_CONFIRMATION_PROMPT')
		self:RegisterEvent('EJ_LOOT_DATA_RECEIVED')

		self:SetPoint('BOTTOMLEFT', BonusRollFrame, 'BOTTOMRIGHT')
		self:SetSize(338, 76)
		self:SetFrameLevel(10)
		self:Hide()

		self:SetBackdrop(backdrop)
		self:SetBackdropColor(0, 0, 0, 0.8)
		self:SetBackdropBorderColor(0.6, 0.6, 0.6)

		local Empty = self:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
		Empty:SetPoint('CENTER')
		Empty:SetText('This encounter has no possible items for\nyour current class and/or specialization')
		self.Empty = Empty

		Handle:SetPoint('BOTTOMRIGHT', 16, 4)
		Handle:SetSize(16, 64)
		Handle:SetNormalTexture([[Interface\RaidFrame\RaidPanel-Toggle]])
		Handle:GetNormalTexture():SetTexCoord(0, 1/2, 0, 1)
		Handle:SetFrameLevel(6)

		local HandleBackground = Handle:CreateTexture(nil, 'BACKGROUND')
		HandleBackground:SetPoint('BOTTOMLEFT', -2, 0)
		HandleBackground:SetPoint('TOPRIGHT')
		HandleBackground:SetTexture(0, 0, 0, 0.8)

		local BorderBottom = Handle:CreateTexture(nil, 'BORDER')
		BorderBottom:SetPoint('BOTTOMRIGHT', 6, -3)
		BorderBottom:SetSize(24, 24)
		BorderBottom:SetTexture([[Interface\RaidFrame\RaidPanel-BottomRight]])

		local BorderRight = Handle:CreateTexture(nil, 'BORDER')
		BorderRight:SetPoint('RIGHT', 7.5, 0)
		BorderRight:SetSize(12, 24)
		BorderRight:SetTexture([[Interface\RaidFrame\RaidPanel-Right]])

		local BorderTop = Handle:CreateTexture(nil, 'BORDER')
		BorderTop:SetPoint('TOPRIGHT', 6, 3)
		BorderTop:SetSize(24, 24)
		BorderTop:SetTexture([[Interface\RaidFrame\RaidPanel-UpperRight]])
	end
end)

Handle:SetScript('OnClick', function(self)
	self:ClearAllPoints()

	if(collapsed) then
		self:SetPoint('BOTTOMRIGHT', Frame, 16, 4)
		self:GetNormalTexture():SetTexCoord(1/2, 1, 0, 1)
		Frame:Show()
	else
		self:SetPoint('BOTTOMRIGHT', BonusRollFrame, 16, 4)
		self:GetNormalTexture():SetTexCoord(0, 1/2, 0, 1)
		Frame:Hide()
	end

	collapsed = not collapsed
end)
