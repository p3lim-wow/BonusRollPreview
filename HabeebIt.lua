local _, ns = ...

local items = {}
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
	GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
	GameTooltip:SetItemByID(self.itemID)

	self.showingTooltip = true
	self:SetScript('OnUpdate', OnUpdate)
end

local function OnLeave(self)
	GameTooltip:Hide()

	self.showingTooltip = false
	self:SetScript('OnUpdate', nil)
end

local function OnClick(self)
	HandleModifiedItemClick(self.itemLink)
end

local function GetItemLine(name, texture, slot, itemClass, itemID, itemLink)
	local Item
	for button, used in pairs(items) do
		if(not used) then
			Item = button
		end
	end

	if(not Item) then
		Item = CreateFrame('Button', nil, Frame)
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
	end

	Item.Icon:SetTexture(texture)
	Item.Name:SetText(name)
	Item.Slot:SetText(slot)
	Item.Class:SetText(itemClass)

	Item.itemID = itemID
	Item.itemLink = itemLink

	items[Item] = true

	return Item
end

local function PopulateList()
	local numItems = 0
	for index = 1, EJ_GetNumLoot() do
		local name, texture, slot, itemClass, itemID, itemLink, encounterID = EJ_GetLootInfoByIndex(index)
		if(encounterID == currentEncounterID) then
			local Item = GetItemLine(name, texture, slot, itemClass, itemID, itemLink)
			Item:SetPoint('BOTTOM', 0, 6 + ((numItems) * 48))
			Item:Show()

			numItems = numItems + 1
		end
	end

	Frame:SetHeight(math.max(76, 12 + (numItems * 48)))

	if(numItems > 0) then
		Frame.Empty:Hide()
	else
		Frame.Empty:Show()
	end
end

local function InitializeList()
	for button in pairs(items) do
		items[button] = false
		button:Hide()
	end

	collapsed = false
	Handle:GetScript('OnClick')(Handle)

	EJ_SelectInstance(EJ_GetCurrentInstance() or 322)
	EJ_SetDifficulty(GetRaidDifficultyID() - 2 or 1)

	local _, _, classID = UnitClass('player')
	EJ_SetLootFilter(classID, GetSpecializationInfo(GetSpecialization() or 1) or 0)

	PopulateList()
end

Frame:RegisterEvent('PLAYER_LOGIN')
Frame:SetScript('OnEvent', function(self, event, ...)
	if(event == 'SPELL_CONFIRMATION_PROMPT') then
		local spellID, confirmType = ...
		if(confirmType == CONFIRMATION_PROMPT_BONUS_ROLL) then
			currentEncounterID = ns.GetEncounterID(spellID)
			if(currentEncounterID) then
				InitializeList()
			end
		end
	elseif(event == 'SPELL_CONFIRMATION_TIMEOUT') then
		local _, confirmType = ...
		if(confirmType == CONFIRMATION_PROMPT_BONUS_ROLL) then
			currentEncounterID = nil
		end
	elseif(event == 'EJ_LOOT_DATA_RECEIVED' and currentEncounterID) then
		PopulateList()
	elseif(event == 'PLAYER_LOGIN') then
		self:RegisterEvent('SPELL_CONFIRMATION_PROMPT')
		self:RegisterEvent('SPELL_CONFIRMATION_TIMEOUT')
		self:RegisterEvent('EJ_LOOT_DATA_RECEIVED')

		self:SetPoint('BOTTOMLEFT', BonusRollFrame, 'BOTTOMRIGHT')
		self:SetWidth(338)
		self:SetHeight(76)
		self:Hide()

		self:SetBackdrop(backdrop)
		self:SetBackdropColor(0, 0, 0, 0.8)
		self:SetBackdropBorderColor(0.6, 0.6, 0.6)

		local Empty = self:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
		Empty:SetPoint('CENTER')
		Empty:SetText('This encounter has no possible items for\nyour current class and/or specialization')
		self.Empty = Empty
	end
end)

Handle:SetScript('OnClick', function(self)
	self:ClearAllPoints()

	if(collapsed) then
		self:SetPoint('BOTTOMRIGHT', Frame, 14, 4)
		self:GetNormalTexture():SetTexCoord(1/2, 1, 0, 1)
		Frame:Show()
	else
		self:SetPoint('BOTTOMRIGHT', BonusRollFrame, 14, 4)
		self:GetNormalTexture():SetTexCoord(0, 1/2, 0, 1)
		Frame:Hide()
	end

	collapsed = not collapsed
end)

Handle:SetPoint('BOTTOMRIGHT', 14, 4)
Handle:SetSize(16, 64)
Handle:SetNormalTexture([[Interface\RaidFrame\RaidPanel-Toggle]])
Handle:GetNormalTexture():SetTexCoord(0, 1/2, 0, 1)
Handle:SetFrameStrata('BACKGROUND')

local HandleBackground = Handle:CreateTexture(nil, 'BACKGROUND')
HandleBackground:SetAllPoints()
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
