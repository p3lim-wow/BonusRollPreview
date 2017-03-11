local addonName, ns = ...
local itemButtons = {}

local BACKDROP = {
	bgFile = [[Interface\ChatFrame\ChatFrameBackground]], tile = true, tileSize = 16,
	edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]], edgeSize = 16,
	insets = {left = 4, right = 4, top = 4, bottom = 4}
}

local Container = CreateFrame('Frame', addonName .. 'Container', BonusRollFrame)
local Handle = CreateFrame('Button', addonName .. 'Handle', BonusRollFrame)

local function ShouldFillDownwards()
	return (GetScreenHeight() - (BonusRollFrame:GetTop() or 200)) < 345
end

--- ItemButton
local function OnItemButtonClick(self)
	HandleModifiedItemClick(self.itemLink)
end

local function OnItemButtonEnter(self)
	GameTooltip:SetOwner(self, 'ANCHOR_TOPLEFT')
	GameTooltip:SetHyperlink(self.itemLink)
	Container:RegisterEvent('MODIFIER_STATE_CHANGED')
end

local function OnItemButtonLeave(self)
	GameTooltip:Hide()
	Container:UnregisterEvent('MODIFIER_STATE_CHANGED')
end

local function CreateItemButton(index)
	local Button = CreateFrame('Button', '$parentItemButton' .. index, Container.ScrollChild)
	Button:SetPoint('TOPLEFT', 6, (index - 1) * -40)
	Button:SetPoint('TOPRIGHT', -22, (index - 1) * -40)
	Button:SetHeight(38)

	local Icon = Button:CreateTexture('$parentIcon', 'BACKGROUND')
	Icon:SetPoint('TOPLEFT', 1, -1)
	Icon:SetSize(36, 36)
	Button.Icon = Icon

	local Background = Button:CreateTexture('$parentBackground', 'BORDER')
	Background:SetAllPoints()
	Background:SetTexture([[Interface\EncounterJournal\UI-EncounterJournalTextures]])
	Background:SetTexCoord(0.00195313, 0.62890625, 0.61816406, 0.66210938)
	Background:SetDesaturated(true)

	local Name = Button:CreateFontString('$parentName', 'ARTWORK', 'GameFontNormalMed3')
	Name:SetPoint('TOPLEFT', Icon, 'TOPRIGHT', 7, -4)
	Name:SetPoint('TOPRIGHT', -6, -4)
	Name:SetHeight(12)
	Name:SetJustifyH('LEFT')
	Button.Name = Name

	local Class = Button:CreateFontString('$parentClass', 'ARTWORK', 'GameFontHighlight')
	Class:SetPoint('BOTTOMRIGHT', -6, 5)
	Class:SetSize(0, 12)
	Class:SetJustifyH('RIGHT')
	Button.Class = Class

	local Slot = Button:CreateFontString('$parentSlot', 'ARTWORK', 'GameFontHighlight')
	Slot:SetPoint('BOTTOMLEFT', Icon, 'BOTTOMRIGHT', 7, 4)
	Slot:SetPoint('BOTTOMRIGHT', Class, 'BOTTOMLEFT', -15, 0)
	Slot:SetSize(0, 12)
	Slot:SetJustifyH('LEFT')
	Button.Slot = Slot

	Button:SetScript('OnClick', OnItemButtonClick)
	Button:SetScript('OnEnter', OnItemButtonEnter)
	Button:SetScript('OnLeave', OnItemButtonLeave)

	return Button
end

local function GetItemButton(index)
	local ItemButton = itemButtons[index]
	if(not ItemButton) then
		ItemButton = CreateItemButton(index)
		itemButtons[index] = ItemButton
	end

	return ItemButton
end

--- Handle
local function UpdateHandle(collapsed)
	Handle:ClearAllPoints()
	Handle.collapsed = collapsed

	if(collapsed) then
		if(ShouldFillDownwards()) then
			Handle.Arrow:SetTexCoord(0, 0, 1/2, 0, 0, 1, 1/2, 1)
			Handle:SetPoint('TOP', BonusRollFrame, 'BOTTOM', 0, 2)
		else
			Handle.Arrow:SetTexCoord(1/2, 1, 0, 1, 1/2, 0, 0, 0)
			Handle:SetPoint('BOTTOM', BonusRollFrame, 'TOP', 0, -2)
		end
	else
		if(ShouldFillDownwards()) then
			Handle.Arrow:SetTexCoord(1/2, 1, 1, 1, 1/2, 0, 1, 0)
			Handle:SetPoint('BOTTOM', Container, 0, -14)
		else
			Handle.Arrow:SetTexCoord(1, 0, 1/2, 0, 1, 1, 1/2, 1)
			Handle:SetPoint('TOP', Container, 0, 14)
		end
	end
end

local function OnHandleClick(self)
	UpdateHandle(not self.collapsed)
	Container:SetShown(not self.collapsed)
end

function Container:CreateHandle()
	Handle:SetSize(64, 16)
	Handle:SetNormalTexture([[Interface\RaidFrame\RaidPanel-Toggle]])
	Handle:SetScript('OnClick', OnHandleClick)
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
end

--- Container
local function OnScrollUpClick(self)
	local Slider = self:GetParent()
	Slider:SetValue(Slider:GetValue() - Slider:GetHeight() / 3)
end

local function OnScrollDownClick(self)
	local Slider = self:GetParent()
	Slider:SetValue(Slider:GetValue() + Slider:GetHeight() / 3)
end

local function OnSliderValueChanged(self, value)
	local min, max = self:GetMinMaxValues()
	if(value == min) then
		self.ScrollUp:Disable()
	else
		self.ScrollUp:Enable()
	end

	if(value == max) then
		self.ScrollDown:Disable()
	else
		self.ScrollDown:Enable()
	end

	local Scroll = self:GetParent()
	Scroll:SetVerticalScroll(value)
	Scroll:GetScrollChild():SetPoint('TOP', 0, value)
end

local function OnScrollMouseWheel(self, alpha)
	if(alpha > 0) then
		self.Slider:SetValue(self.Slider:GetValue() - self.Slider:GetHeight() / 3)
	else
		self.Slider:SetValue(self.Slider:GetValue() + self.Slider:GetHeight() / 3)
	end
end

function Container:CreateFrame()
	local ScrollChild = CreateFrame('Frame', '$parentScrollChild', self)
	ScrollChild:SetHeight(1) -- Completely ignores this value, bug?
	self.ScrollChild = ScrollChild

	local Scroll = CreateFrame('ScrollFrame', '$parentScrollFrame', self)
	Scroll:SetPoint('TOPLEFT', 0, -6)
	Scroll:SetPoint('BOTTOMRIGHT', 0, 6)
	Scroll:SetScrollChild(ScrollChild)
	Scroll:SetScript('OnMouseWheel', OnScrollMouseWheel)

	self:SetWidth(286)
	self:SetFrameLevel(self:GetParent():GetFrameLevel() - 2)
	self:SetBackdrop(BACKDROP)
	self:SetBackdropColor(0, 0, 0, 0.8)
	self:SetBackdropBorderColor(2/3, 2/3, 2/3)

	local Slider = CreateFrame('Slider', '$parentScrollBar', Scroll)
	Slider:SetPoint('TOPRIGHT', -5, -16)
	Slider:SetPoint('BOTTOMRIGHT', -5, 14)
	Slider:SetWidth(16)
	Slider:SetFrameLevel(self:GetFrameLevel() + 10)
	Slider:SetScript('OnValueChanged', OnSliderValueChanged)
	Scroll.Slider = Slider
	self.Slider = Slider

	local Thumb = Scroll:CreateTexture('$parentThumbTexture')
	Thumb:SetSize(16, 24)
	Thumb:SetTexture([[Interface\Buttons\UI-ScrollBar-Knob]])
	Thumb:SetTexCoord(1/4, 3/4, 1/8, 7/8)
	Slider:SetThumbTexture(Thumb)

	local ScrollUp = CreateFrame('Button', '$parentScrollUpButton', Slider)
	ScrollUp:SetPoint('BOTTOM', Slider, 'TOP')
	ScrollUp:SetSize(16, 16)
	ScrollUp:SetNormalTexture([[Interface\Buttons\UI-ScrollBar-ScrollUpButton-Up]])
	ScrollUp:SetDisabledTexture([[Interface\Buttons\UI-ScrollBar-ScrollUpButton-Disabled]])
	ScrollUp:SetHighlightTexture([[Interface\Buttons\UI-ScrollBar-ScrollUpButton-Highlight]])
	ScrollUp:GetNormalTexture():SetTexCoord(1/4, 3/4, 1/4, 3/4)
	ScrollUp:GetDisabledTexture():SetTexCoord(1/4, 3/4, 1/4, 3/4)
	ScrollUp:GetHighlightTexture():SetTexCoord(1/4, 3/4, 1/4, 3/4)
	ScrollUp:GetHighlightTexture():SetBlendMode('ADD')
	ScrollUp:SetScript('OnClick', OnScrollUpClick)
	Slider.ScrollUp = ScrollUp

	local ScrollDown = CreateFrame('Button', '$parentScrollDownButton', Slider)
	ScrollDown:SetPoint('TOP', Slider, 'BOTTOM')
	ScrollDown:SetSize(16, 16)
	ScrollDown:SetNormalTexture([[Interface\Buttons\UI-ScrollBar-ScrollDownButton-Up]])
	ScrollDown:SetDisabledTexture([[Interface\Buttons\UI-ScrollBar-ScrollDownButton-Disabled]])
	ScrollDown:SetHighlightTexture([[Interface\Buttons\UI-ScrollBar-ScrollDownButton-Highlight]])
	ScrollDown:GetNormalTexture():SetTexCoord(1/4, 3/4, 1/4, 3/4)
	ScrollDown:GetDisabledTexture():SetTexCoord(1/4, 3/4, 1/4, 3/4)
	ScrollDown:GetHighlightTexture():SetTexCoord(1/4, 3/4, 1/4, 3/4)
	ScrollDown:GetHighlightTexture():SetBlendMode('ADD')
	ScrollDown:SetScript('OnClick', OnScrollDownClick)
	Slider.ScrollDown = ScrollDown

	local Empty = self:CreateFontString('$parentPlaceholder', 'ARTWORK', 'GameFontHighlight')
	Empty:SetPoint('TOPLEFT', 10, 0)
	Empty:SetPoint('BOTTOMRIGHT', -10, 0)
	Empty:SetText('This encounter has no possible items for your current class and/or specialization.')
	self.Empty = Empty
end

--- Hooks
local function HookSetPoint()
	Container:ClearAllPoints()

	if(ShouldFillDownwards()) then
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

	UpdateHandle(true)
end

--- Logic
function Container:StartEncounter()
	for index, button in next, itemButtons do
		button:Hide()
	end

	EJ_SelectInstance(self.instanceID)
	EJ_SelectEncounter(self.encounterID)

	if(not self.difficulty) then
		-- This should only ever happen in raids, everything else is hardcoded
		self.difficulty = select(3, GetInstanceInfo())
	end

	if(not self.difficulty or self.difficulty == 0) then
		-- Fallback difficulty, for PEW
		self.difficulty = self.fallbackDifficulty
	end

	self:RegisterEvent('EJ_DIFFICULTY_UPDATE')
	if(EncounterJournal) then
		EncounterJournal:UnregisterEvent('EJ_DIFFICULTY_UPDATE')
	end

	EJ_SetDifficulty(self.difficulty)
end

function Container:UpdateItems()
	if(not self:IsEventRegistered('EJ_LOOT_DATA_RECIEVED')) then
		self:RegisterEvent('EJ_LOOT_DATA_RECIEVED')
	end

	if(EncounterJournal) then
		EncounterJournal:UnregisterEvent('EJ_LOOT_DATA_RECIEVED')
	end

	local numItems = 0
	for index = 1, EJ_GetNumLoot() do
		local itemID, encounterID, name, texture, slot, armorType, itemLink = EJ_GetLootInfoByIndex(index)
		if(not itemLink) then
			-- Let the client receive the data
			return
		end

		if(not ns.itemBlacklist[itemID]) then
			numItems = numItems + 1

			local ItemButton = GetItemButton(numItems)
			ItemButton.Icon:SetTexture(texture)
			ItemButton.Name:SetText(name)
			ItemButton.Slot:SetText(slot)
			ItemButton.Class:SetText(armorType)
			ItemButton.itemLink = itemLink
			ItemButton:Show()
		end
	end

	if(self:IsEventRegistered('EJ_LOOT_DATA_RECIEVED')) then
		self:UnregisterEvent('EJ_LOOT_DATA_RECIEVED')
	end

	if(EncounterJournal) then
		EncounterJournal:RegisterEvent('EJ_LOOT_DATA_RECIEVED')
	end

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
		self:EnableMouseWheel(false)
		self.Slider:Hide()
		self.ScrollChild:SetWidth(302)
	end
end

function Container:UpdateItemFilter()
	local _, _, classID = UnitClass('player')
	local lootSpecialization = GetLootSpecialization()
	if(not lootSpecialization or lootSpecialization == 0) then
		lootSpecialization = (GetSpecializationInfo(GetSpecialization() or 0)) or 0
	end

	EJ_SetLootFilter(classID, lootSpecialization)
end

--- Events
function Container:EJ_DIFFICULTY_UPDATE(event)
	if(EncounterJournal) then
		EncounterJournal:RegisterEvent(event)
	end

	self:UnregisterEvent(event)
	self:UpdateItemFilter()
	self:UpdateItems()
end

function Container:EJ_LOOT_DATA_RECIEVED(event)
	if(BonusRollFrame:IsShown()) then
		self:UpdateItems()
	end
end

function Container:PLAYER_LOOT_SPEC_UPDATED()
	-- We need to restart the entire encounter in case the user has
	-- used the Adventure Guide before changing loot specializations.
	self:StartEncounter()
end

function Container:SPELL_CONFIRMATION_PROMPT(event, spellID, confirmType, _, _, currencyID)
	if(confirmType == LE_SPELL_CONFIRMATION_PROMPT_TYPE_BONUS_ROLL) then
		self:Hide()
		Handle:Hide()

		local encounterInfo = ns.encounterInfo[spellID]
		if(encounterInfo) then
			local _, count = GetCurrencyInfo(currencyID)
			if(count > 0) then
				self:RegisterEvent('PLAYER_LOOT_SPEC_UPDATED')

				self.encounterID = encounterInfo[1]
				self.instanceID = encounterInfo[2]
				self.difficulty = encounterInfo[3]
				self.fallbackDifficulty = encounterInfo[4]
				self:StartEncounter()

				Handle:Show()
				UpdateHandle(true)
			end
		elseif(not ns.encounterBlacklist[spellID]) then
			print('|cffff8080' .. addonName .. ':|r Found an unknown spell [' .. spellID .. ']. Please report this, with boss name!')
		end
	end
end

function Container:PLAYER_ENTERING_WORLD(event)
	for _, info in next, GetSpellConfirmationPromptsInfo() do
		if(info) then
			self:SPELL_CONFIRMATION_PROMPT(event, info.spellID, info.confirmType, nil, nil, info.currencyID)
		end
	end
end

function Container:SPELL_CONFIRMATION_TIMEOUT()
	self:UnregisterEvent('PLAYER_LOOT_SPEC_UPDATED')
end

function Container:MODIFIER_STATE_CHANGED()
	if(IsModifiedClick('COMPAREITEMS') or GetCVarBool('alwaysCompareItems')) then
		GameTooltip_ShowCompareItem()
	else
		for _, shoppingTooltip in next, GameTooltip.shoppingTooltips do
			shoppingTooltip:Hide()
		end
	end

	if(IsModifiedClick('DRESSUP')) then
		ShowInspectCursor()
	else
		ResetCursor()
	end
end

function Container:PLAYER_LOGIN()
	self:CreateFrame()
	self:CreateHandle()

	self:RegisterEvent('SPELL_CONFIRMATION_PROMPT')
	self:RegisterEvent('SPELL_CONFIRMATION_TIMEOUT')

	hooksecurefunc(BonusRollFrame, 'SetPoint', HookSetPoint)

	-- Inject odd encounters
	for spellID, data in next, ns.dynamicEncounters do
		EJ_SelectInstance(data[2])
		ns.encounterInfo[spellID] = {
			(select(3, EJ_GetEncounterInfoByIndex(data[1]))),
			data[2],
			data[3],
			data[4],
		}
	end
end

Container:RegisterEvent('PLAYER_LOGIN')
Container:RegisterEvent('PLAYER_ENTERING_WORLD')
Container:SetScript('OnEvent', function(self, event, ...)
	self[event](self, event, ...)
end)
