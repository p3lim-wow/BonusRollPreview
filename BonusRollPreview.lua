local _, ns = ...
local currentEncounterInfo
local itemButtons = {}

local BACKDROP = {
	bgFile = [[Interface\ChatFrame\ChatFrameBackground]], tile = true, tileSize = 16,
	edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]], edgeSize = 16,
	insets = {left = 4, right = 4, top = 4, bottom = 4}
}

local Container = CreateFrame('Frame', 'BonusRollPreviewContainer', BonusRollFrame)
local Handle = CreateFrame('Button', 'BonusRollPreviewHandle', BonusRollFrame)

local Hotspot = CreateFrame('Frame', nil, BonusRollFrame)
local Buttons = CreateFrame('Frame', 'BonusRollPreviewSpecButtons', Hotspot)
Buttons:Hide()

local function SpecButtonClick(self)
	SetLootSpecialization(self.specID)
	Buttons:Hide()
	BonusRollFrame.SpecIcon:SetDesaturated(false)
end

local function SpecButtonEnter(self)
	GameTooltip:SetOwner(self, 'ANCHOR_TOPRIGHT')
	GameTooltip:AddLine(self.name, 1, 1, 1)
	GameTooltip:Show()
end

local specButtons
local function HotspotEnter()
	if(not Buttons:IsShown()) then
		if(not specButtons) then
			local numSpecs = GetNumSpecializations()
			for index = 1, numSpecs do
				local specID, name, _, texture = GetSpecializationInfo(index)

				local SpecButton = CreateFrame('Button', '$parentSpecButton' .. index, Buttons)
				SpecButton:SetPoint('LEFT', index * 28, 0)
				SpecButton:SetSize(22, 22)
				SpecButton:SetScript('OnClick', SpecButtonClick)
				SpecButton:SetScript('OnEnter', SpecButtonEnter)
				SpecButton:SetScript('OnLeave', GameTooltip_Hide)
				SpecButton:SetHighlightTexture([[Interface\Minimap\UI-Minimap-ZoomButton-Highlight]])

				SpecButton.specID = specID
				SpecButton.name = name

				local Icon = SpecButton:CreateTexture('$parentIcon', 'OVERLAY', nil, 1)
				Icon:SetAllPoints()
				Icon:SetTexture(texture)

				local Ring = SpecButton:CreateTexture('$parentRing', 'OVERLAY', nil, 2)
				Ring:SetPoint('TOPLEFT', -6, 6)
				Ring:SetSize(58, 58)
				Ring:SetTexture([[Interface\Minimap\Minimap-TrackingBorder]])
			end

			Buttons:SetSize(numSpecs * 28 + 34, 38)

			specButtons = true
		end

		BonusRollFrame.SpecIcon:SetDesaturated(true)
		Buttons:Show()
	end
end

local function HotspotLeave()
	if(not Buttons:IsMouseOver()) then
		BonusRollFrame.SpecIcon:SetDesaturated(false)
		Buttons:Hide()
	end
end

local function ButtonsLeave(self)
	if(not Hotspot:IsMouseOver()) then
		HotspotLeave()
	end
end

local function HookStartRoll(self, frame)
	local specID = GetLootSpecialization()
	if(not specID or specID == 0) then
		SetLootSpecialization(GetSpecializationInfo(GetSpecialization()))
	end
end

local function PositionDownwards()
	return (GetScreenHeight() - (BonusRollFrame:GetTop() or 200)) < 345
end

local collapsed
local function HandleClick(self)
	if(self) then
		collapsed = not collapsed
	else
		collapsed = true
	end

	Handle:ClearAllPoints()
	if(collapsed) then
		if(PositionDownwards()) then
			Handle.Arrow:SetTexCoord(0, 0, 1/2, 0, 0, 1, 1/2, 1)
			Handle:SetPoint('TOP', BonusRollFrame, 'BOTTOM', 0, 2)
		else
			Handle.Arrow:SetTexCoord(1/2, 1, 0, 1, 1/2, 0, 0, 0)
			Handle:SetPoint('BOTTOM', BonusRollFrame, 'TOP', 0, -2)
		end

		Container:Hide()
	else
		if(PositionDownwards()) then
			Handle.Arrow:SetTexCoord(1/2, 1, 1, 1, 1/2, 0, 1, 0)
			Handle:SetPoint('BOTTOM', Container, 0, -14)
		else
			Handle.Arrow:SetTexCoord(1, 0, 1/2, 0, 1, 1, 1/2, 1)
			Handle:SetPoint('TOP', Container, 0, 14)
		end

		Container:Show()
	end
end

local function HandlePosition()
	Container:ClearAllPoints()
	if(PositionDownwards()) then
		Container:SetPoint('TOP', BonusRollFrame, 'BOTTOM')

		Handle.Arrow:SetTexCoord(0, 0, 1/2, 0, 0, 1, 1/2, 1)
		Handle.TopCenter:Hide()
		Handle.TopRight:Hide()
		Handle.TopLeft:Hide()
		Handle.BottomCenter:Show()
		Handle.BottomRight:Show()
		Handle.BottomLeft:Show()
	else
		Container:SetPoint('BOTTOM', BonusRollFrame, 'TOP')

		Handle.Arrow:SetTexCoord(1/2, 1, 0, 1, 1/2, 0, 0, 0)
		Handle.TopCenter:Show()
		Handle.TopRight:Show()
		Handle.TopLeft:Show()
		Handle.BottomCenter:Hide()
		Handle.BottomRight:Hide()
		Handle.BottomLeft:Hide()
	end

	HandleClick()
end

local function ItemButtonUpdate(self, elapsed)
	if(IsModifiedClick('COMPAREITEMS') or (GetCVarBool('alwaysCompareItems') and not IsEquippedItem(self.itemLink))) then
		GameTooltip_ShowCompareItem()
	else
		ShoppingTooltip1:Hide()
		ShoppingTooltip2:Hide()
	end

	if(IsModifiedClick('DRESSUP')) then
		ShowInspectCursor()
	else
		ResetCursor()
	end
end

local function ItemButtonClick(self)
	HandleModifiedItemClick(self.itemLink)
end

local function ItemButtonEnter(self)
	GameTooltip:SetOwner(self, 'ANCHOR_TOPLEFT')
	GameTooltip:SetHyperlink(self.itemLink)

	self:SetScript('OnUpdate', ItemButtonUpdate)
end

local function ItemButtonLeave(self)
	GameTooltip:Hide()

	self:SetScript('OnUpdate', nil)
end

local function GetItemLine(index)
	local ItemButton = itemButtons[index]
	if(not ItemButton) then
		ItemButton = CreateFrame('Button', '$parentItemButton' .. index, Container.ScrollChild)
		ItemButton:SetPoint('TOPLEFT', 6, (index - 1) * -40)
		ItemButton:SetPoint('TOPRIGHT', -22, (index - 1) * -40)
		ItemButton:SetHeight(38)

		local Icon = ItemButton:CreateTexture('$parentIcon', 'BACKGROUND')
		Icon:SetPoint('TOPLEFT', 1, -1)
		Icon:SetSize(36, 36)
		ItemButton.Icon = Icon

		local Background = ItemButton:CreateTexture('$parentBackground', 'BORDER')
		Background:SetAllPoints()
		Background:SetTexture([[Interface\EncounterJournal\UI-EncounterJournalTextures]])
		Background:SetTexCoord(0.00195313, 0.62890625, 0.61816406, 0.66210938)
		Background:SetDesaturated(true)

		local Name = ItemButton:CreateFontString('$parentName', 'ARTWORK', 'GameFontNormalMed3')
		Name:SetPoint('TOPLEFT', Icon, 'TOPRIGHT', 7, -4)
		Name:SetPoint('TOPRIGHT', -6, -4)
		Name:SetHeight(12)
		Name:SetJustifyH('LEFT')
		ItemButton.Name = Name

		local Class = ItemButton:CreateFontString('$parentClass', 'ARTWORK', 'GameFontHighlight')
		Class:SetPoint('BOTTOMRIGHT', -6, 5)
		Class:SetSize(0, 12)
		Class:SetJustifyH('RIGHT')
		ItemButton.Class = Class

		local Slot = ItemButton:CreateFontString('$parentSlot', 'ARTWORK', 'GameFontHighlight')
		Slot:SetPoint('BOTTOMLEFT', Icon, 'BOTTOMRIGHT', 7, 4)
		Slot:SetPoint('BOTTOMRIGHT', Class, 'BOTTOMLEFT', -15, 0)
		Slot:SetSize(0, 12)
		Slot:SetJustifyH('LEFT')
		ItemButton.Slot = Slot

		ItemButton:SetScript('OnClick', ItemButtonClick)
		ItemButton:SetScript('OnEnter', ItemButtonEnter)
		ItemButton:SetScript('OnLeave', ItemButtonLeave)

		itemButtons[index] = ItemButton
	end

	return ItemButton
end

local resetTimer
local function ResetEvents()
	Container:UnregisterEvent('EJ_LOOT_DATA_RECIEVED')
	Container:UnregisterEvent('EJ_DIFFICULTY_UPDATE')

	if(EncounterJournal) then
		EncounterJournal:RegisterEvent('EJ_LOOT_DATA_RECIEVED')
		EncounterJournal:RegisterEvent('EJ_DIFFICULTY_UPDATE')
	end

	resetTimer = nil
end

function Container:Populate()
	local numItems = 0
	for index = 1, EJ_GetNumLoot() do
		local itemID, encounterID, name, texture, slot, armorType, itemLink = EJ_GetLootInfoByIndex(index)
		if(not itemLink) then
			-- Let the client receive the data
			return
		end

		if(encounterID == currentEncounterInfo[1] and not ns.itemBlacklist[itemID]) then
			numItems = numItems + 1

			local ItemButton = GetItemLine(numItems)
			ItemButton.Icon:SetTexture(texture)
			ItemButton.Name:SetText(name)
			ItemButton.Slot:SetText(slot)
			ItemButton.Class:SetText(armorType)

			ItemButton.itemLink = itemLink

			ItemButton:Show()
		end
	end

	self:Hide()
	self:SetHeight(math.min(330, math.max(50, 10 + (numItems * 40))))

	if(numItems > 0) then
		local height = (10 + (numItems * 40)) - self:GetHeight()
		self.Slider:SetMinMaxValues(0, height > 0 and height or 0)
		self.Slider:SetValue(0)

		if(numItems > 8) then
			self:EnableMouseWheel(true)
			self.Slider:Show()
			self.ScrollChild:SetWidth(286)
		else
			self:EnableMouseWheel(false)
			self.Slider:Hide()
			self.ScrollChild:SetWidth(302)
		end

		self.Empty:Hide()
	else
		self.Empty:Show()
		self.Slider:Hide()
	end

	if(resetTimer) then
		resetTimer:Cancel()
		resetTimer = nil
	end

	resetTimer = C_Timer.NewTimer(2, ResetEvents)
end

function Container:Update()
	if(EncounterJournal) then
		EncounterJournal:UnregisterEvent('EJ_LOOT_DATA_RECIEVED')
		EncounterJournal:UnregisterEvent('EJ_DIFFICULTY_UPDATE')
	end

	for index, button in next, itemButtons do
		button:Hide()
	end

	local encounterID, instanceID, difficulty = unpack(currentEncounterInfo)
	EJ_SelectInstance(instanceID)
	EJ_SelectEncounter(encounterID)

	if(not difficulty) then
		-- This should only ever happen in raids, everything else is hardcoded
		difficulty = select(3, GetInstanceInfo())
	end

	EJ_SetDifficulty(difficulty)
end

function Container:EJ_DIFFICULTY_UPDATE(event)
	local _, _, classID = UnitClass('player')
	EJ_SetLootFilter(classID, GetLootSpecialization() or GetSpecializationInfo(GetSpecialization() or 0) or 0)

	self:Populate()
end

function Container:EJ_LOOT_DATA_RECIEVED(event)
	if(BonusRollFrame:IsShown()) then
		self:Populate()
	end
end

function Container:PLAYER_LOOT_SPEC_UPDATED(event)
	self:RegisterEvent('EJ_LOOT_DATA_RECIEVED')
	self:RegisterEvent('EJ_DIFFICULTY_UPDATE')
	self:Update()
	HandlePosition()
end

function Container:SPELL_CONFIRMATION_PROMPT(event, spellID, confirmType, _, _, currencyID)
	if(confirmType == LE_SPELL_CONFIRMATION_PROMPT_TYPE_BONUS_ROLL) then
		currentEncounterInfo = ns.encounterInfo[spellID]
		if(currentEncounterInfo) then
			local _, count = GetCurrencyInfo(currencyID)
			if(count > 0) then
				self:RegisterEvent('PLAYER_LOOT_SPEC_UPDATED')
				self:RegisterEvent('EJ_LOOT_DATA_RECIEVED')
				self:RegisterEvent('EJ_DIFFICULTY_UPDATE')
				self:Update()
			end
		else
			print('|cffff8080BonusRollPreview:|r Found an unknown spell [' .. spellID .. ']. Please report this!')
		end
	end
end

function Container:SPELL_CONFIRMATION_TIMEOUT()
	currentEncounterInfo = nil

	self:UnregisterEvent('PLAYER_LOOT_SPEC_UPDATED')
end

function Container:PLAYER_LOGIN()
	local ScrollChild = CreateFrame('Frame', '$parentScrollChild', self)
	ScrollChild:SetHeight(1) -- Completely ignores this value, bug?
	self.ScrollChild = ScrollChild

	local Scroll = CreateFrame('ScrollFrame', '$parentScrollFrame', self)
	Scroll:SetPoint('TOPLEFT', 0, -6)
	Scroll:SetPoint('BOTTOMRIGHT', 0, 6)
	Scroll:SetScrollChild(ScrollChild)

	self:SetWidth(286)
	self:SetFrameLevel(self:GetParent():GetFrameLevel() - 2)
	self:SetBackdrop(BACKDROP)
	self:SetBackdropColor(0, 0, 0, 0.8)
	self:SetBackdropBorderColor(2/3, 2/3, 2/3)
	self:EnableMouseWheel(true)

	local Slider = CreateFrame('Slider', '$parentScrollBar', Scroll)
	Slider:SetPoint('TOPRIGHT', -5, -16)
	Slider:SetPoint('BOTTOMRIGHT', -5, 14)
	Slider:SetWidth(16)
	Slider:SetFrameLevel(self:GetFrameLevel() + 10)
	self.Slider = Slider

	local Thumb = Scroll:CreateTexture('$parentThumbTexture')
	Thumb:SetSize(16, 24)
	Thumb:SetTexture([[Interface\Buttons\UI-ScrollBar-Knob]])
	Thumb:SetTexCoord(1/4, 3/4, 1/8, 7/8)
	Slider:SetThumbTexture(Thumb)

	local Up = CreateFrame('Button', '$parentScrollUpButton', Slider)
	Up:SetPoint('BOTTOM', Slider, 'TOP')
	Up:SetSize(16, 16)
	Up:SetNormalTexture([[Interface\Buttons\UI-ScrollBar-ScrollUpButton-Up]])
	Up:SetDisabledTexture([[Interface\Buttons\UI-ScrollBar-ScrollUpButton-Disabled]])
	Up:SetHighlightTexture([[Interface\Buttons\UI-ScrollBar-ScrollUpButton-Highlight]])
	Up:GetNormalTexture():SetTexCoord(1/4, 3/4, 1/4, 3/4)
	Up:GetDisabledTexture():SetTexCoord(1/4, 3/4, 1/4, 3/4)
	Up:GetHighlightTexture():SetTexCoord(1/4, 3/4, 1/4, 3/4)
	Up:GetHighlightTexture():SetBlendMode('ADD')
	Up:SetScript('OnClick', function()
		Slider:SetValue(Slider:GetValue() - Slider:GetHeight() / 3)
	end)

	local Down = CreateFrame('Button', '$parentScrollDownButton', Slider)
	Down:SetPoint('TOP', Slider, 'BOTTOM')
	Down:SetSize(16, 16)
	Down:SetScript('OnClick', ScrollClick)
	Down:SetNormalTexture([[Interface\Buttons\UI-ScrollBar-ScrollDownButton-Up]])
	Down:SetDisabledTexture([[Interface\Buttons\UI-ScrollBar-ScrollDownButton-Disabled]])
	Down:SetHighlightTexture([[Interface\Buttons\UI-ScrollBar-ScrollDownButton-Highlight]])
	Down:GetNormalTexture():SetTexCoord(1/4, 3/4, 1/4, 3/4)
	Down:GetDisabledTexture():SetTexCoord(1/4, 3/4, 1/4, 3/4)
	Down:GetHighlightTexture():SetTexCoord(1/4, 3/4, 1/4, 3/4)
	Down:GetHighlightTexture():SetBlendMode('ADD')
	Down:SetScript('OnClick', function()
		Slider:SetValue(Slider:GetValue() + Slider:GetHeight() / 3)
	end)

	Slider:SetScript('OnValueChanged', function(self, value)
		local min, max = self:GetMinMaxValues()
		if(value == min) then
			Up:Disable()
		else
			Up:Enable()
		end

		if(value == max) then
			Down:Disable()
		else
			Down:Enable()
		end

		local Parent = self:GetParent()
		Parent:SetVerticalScroll(value)
		ScrollChild:SetPoint('TOP', 0, value)
	end)

	Scroll:SetScript('OnMouseWheel', function(self, alpha)
		if(alpha > 0) then
			Slider:SetValue(Slider:GetValue() - Slider:GetHeight() / 3)
		else
			Slider:SetValue(Slider:GetValue() + Slider:GetHeight() / 3)
		end
	end)

	local Empty = self:CreateFontString('$parentPlaceholder', 'ARTWORK', 'GameFontHighlight')
	Empty:SetPoint('TOPLEFT', 10, 0)
	Empty:SetPoint('BOTTOMRIGHT', -10, 0)
	Empty:SetText('This encounter has no possible items for your current class and/or specialization.')
	self.Empty = Empty

	Handle:SetSize(64, 16)
	Handle:SetNormalTexture([[Interface\RaidFrame\RaidPanel-Toggle]])
	Handle:SetScript('OnClick', HandleClick)
	Handle.Arrow = Handle:GetNormalTexture()

	local HandleBackground = Handle:CreateTexture('$parentBackground', 'BACKGROUND')
	HandleBackground:SetAllPoints()
	HandleBackground:SetColorTexture(0, 0, 0, 0.8)

	local TopCenter = Handle:CreateTexture('$parentTopCenter', 'BORDER')
	TopCenter:SetPoint('TOP', 0, 4.5)
	TopCenter:SetSize(24, 12)
	TopCenter:SetTexture([[Interface\RaidFrame\RaidPanel-UpperMiddle]])
	Handle.TopCenter = TopCenter

	local TopRight = Handle:CreateTexture('$parentTopRight', 'BORDER')
	TopRight:SetPoint('TOPRIGHT', 4, 4)
	TopRight:SetSize(24, 20)
	TopRight:SetTexture([[Interface\RaidFrame\RaidPanel-UpperRight]])
	TopRight:SetTexCoord(0, 1, 0, 0.8)
	Handle.TopRight = TopRight

	local TopLeft = Handle:CreateTexture('$parentTopLeft', 'BORDER')
	TopLeft:SetPoint('TOPLEFT', -4, 4)
	TopLeft:SetSize(24, 20)
	TopLeft:SetTexture([[Interface\RaidFrame\RaidPanel-UpperLeft]])
	TopLeft:SetTexCoord(0, 1, 0, 0.8)
	Handle.TopLeft = TopLeft

	local BottomCenter = Handle:CreateTexture('$parentBottomCenter', 'BORDER')
	BottomCenter:SetPoint('BOTTOM', 0, -9)
	BottomCenter:SetSize(24, 12)
	BottomCenter:SetTexture([[Interface\RaidFrame\RaidPanel-BottomMiddle]])
	Handle.BottomCenter = BottomCenter

	local BottomRight = Handle:CreateTexture('$parentBottomRight', 'BORDER')
	BottomRight:SetPoint('BOTTOMRIGHT', 4, -6)
	BottomRight:SetSize(24, 22)
	BottomRight:SetTexture([[Interface\RaidFrame\RaidPanel-BottomRight]])
	BottomRight:SetTexCoord(0, 1, 0.1, 1)
	Handle.BottomRight = BottomRight

	local BottomLeft = Handle:CreateTexture('$parentBottomLeft', 'BORDER')
	BottomLeft:SetPoint('BOTTOMLEFT', -4, -6)
	BottomLeft:SetSize(24, 22)
	BottomLeft:SetTexture([[Interface\RaidFrame\RaidPanel-BottomLeft]])
	BottomLeft:SetTexCoord(0, 1, 0.1, 1)
	Handle.BottomLeft = BottomLeft

	Hotspot:SetAllPoints(BonusRollFrame.SpecIcon)
	Hotspot:SetScript('OnEnter', HotspotEnter)
	Hotspot:SetScript('OnLeave', HotspotLeave)

	Buttons:SetPoint('LEFT', 4, 4)
	Buttons:SetScript('OnLeave', ButtonsLeave)

	self:RegisterEvent('SPELL_CONFIRMATION_PROMPT')
	self:RegisterEvent('SPELL_CONFIRMATION_TIMEOUT')

	hooksecurefunc('BonusRollFrame_StartBonusRoll', HookStartRoll)
	hooksecurefunc(BonusRollFrame, 'SetPoint', HandlePosition)
end

Container:SetScript('OnEvent', function(self, event, ...) self[event](self, event, ...) end)
Container:RegisterEvent('PLAYER_LOGIN')
