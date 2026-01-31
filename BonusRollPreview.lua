local _, addon = ...

-- sourced from _G
local LE_SPELL_CONFIRMATION_PROMPT_TYPE_BONUS_ROLL = LE_SPELL_CONFIRMATION_PROMPT_TYPE_BONUS_ROLL or 1

local GetSpecialization = GetSpecialization or C_SpecializationInfo.GetSpecialization -- deprecated in 12.x
local GetSpecializationInfo = GetSpecializationInfo or C_SpecializationInfo.GetSpecializationInfo -- deprecated in 12.x

local ignoredSpells = {
	-- 7.0
	[232109] = true, -- Return to Karazhan: Nighbane (no EJ entry)
	[240042] = true, -- Arena 2v2 Weekly Quest
	[240048] = true, -- Arena 3v3 Weekly Quest
	[240052] = true, -- Battlegrounds 10v10 Weekly Quest
}

local specialItems = { -- non-equippable items confirmed available from bonus rolls
	-- https://twitter.com/olandgren/status/428229005221691392
	[89783] = true, -- Mount: Son of Galleon's Saddle
	[94228] = true, -- Mount: Reins of the Cobalt Primordial Direhorn
	[87771] = true, -- Mount: Reins of the Heavenly Onyx Cloud Serpent
	[95057] = true, -- Mount: Reins of the Thundering Cobalt Cloud Serpent
}

local nop = function() end
local function resetButton(_, button)
	button:Hide()
	button:ClearAllPoints()

	button.Icon:SetTexture(QUESTION_MARK_ICON)
	button.Name:SetText(RETRIEVING_ITEM_INFO)
	button.Slot:SetText('')
	button.Class:SetText('')
	button.Fav:SetText('')

	button.itemID = nil
	button.itemLink = nil
	button.favoriteTag = nil
end

BonusRollPreviewMixin = {}
function BonusRollPreviewMixin:OnLoad()
	if(BackdropTemplateMixin) then
		Mixin(self, BackdropTemplateMixin)
	end

	self:SetBackdrop({
		bgFile = [[Interface\ChatFrame\ChatFrameBackground]],
		edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]],
		tile = true,
		edgeSize = 16,
		tileSize = 16,
		insets = {left=4, right=4, top=4, bottom=4},
	})

	self:RegisterEvent('SPELL_CONFIRMATION_PROMPT')
	self:RegisterEvent('SPELL_CONFIRMATION_TIMEOUT')
	self:RegisterEvent('PLAYER_ENTERING_WORLD')
	self:RegisterEvent('PLAYER_LOGIN')
	self:SetBackdropColor(0, 0, 0, 0.8)
	self:SetFrameLevel(self:GetParent():GetFrameLevel() - 2)

	-- TODO: consider parenting this frame to GroupLootContainer, but I'm afraid of taints
	BonusRollFrame:ClearAllPoints()
	BonusRollFrame:SetPoint('CENTER', BonusRollPreviewAnchor)
	BonusRollFrame.ClearAllPoints = nop
	BonusRollFrame.SetPoint = nop

	self.buttons = CreateUnsecuredFramePool('Button', self.ScrollFrame.ScrollChild, 'BonusRollPreviewButtonTemplate', resetButton)
	self.itemButtons = addon:T()
end

function BonusRollPreviewMixin:OnEvent(event, ...)
	if(event == 'EJ_DIFFICULTY_UPDATE') then
		-- difficulty to track has updated, update filter and item list
		self:UnregisterSafeEvent(event)
		self:UpdateItemFilter()
		self:UpdateItems()
	elseif(event == 'PLAYER_LOOT_SPEC_UPDATED') then
		-- we need to restart the entire encounter logic just in case the user
		-- has used the EncounterJournal before changing loot specializations.
		self:StartEncounter()
	elseif(event == 'SPELL_CONFIRMATION_PROMPT') then
		local spellID, confirmType, _, _, currencyID, currencyCost, difficultyID = ...
		if(confirmType ~= LE_SPELL_CONFIRMATION_PROMPT_TYPE_BONUS_ROLL) then
			return
		end

		if(not ignoredSpells[spellID]) then -- ignore blacklisted encounters
			local instanceID, encounterID = addon:GetJournalInfoForSpellConfirmation(spellID)
			if(encounterID) then
				local currency = C_CurrencyInfo.GetCurrencyInfo(currencyID)
				if(currency.quantity >= currencyCost) then
					self.difficultyID = difficultyID
					self.encounterID = encounterID
					self.instanceID = instanceID

					self:RegisterEvent('PLAYER_LOOT_SPEC_UPDATED')
					self:StartEncounter()

					-- show/hide list and handle
					self:SetShown(BonusRollPreviewDB.alwaysShow)
					self:UpdatePosition()
					BonusRollPreviewHandle:Show()
				end
			end
		end
	elseif(event == 'SPELL_CONFIRMATION_TIMEOUT') then
		self:UnregisterEvent('PLAYER_LOOT_SPEC_UPDATED')
		self:Hide()
		BonusRollPreviewHandle:Hide()
		self.buttons:ReleaseAll()
	elseif(event == 'PLAYER_ENTERING_WORLD') then
		-- check for any outstanding bonus rolls
		for _, info in next, GetSpellConfirmationPromptsInfo() do
			if(info and info.spellID) then
				local difficultyID = info.difficultyID
				if not difficultyID then
					local inInstance, instanceType, _ = IsInInstance()
					if inInstance and instanceType == 'raid' then
						_, _, difficultyID = GetInstanceInfo()
					end
				end

				self:OnEvent('SPELL_CONFIRMATION_PROMPT', info.spellID, info.confirmType, nil, nil, info.currencyID, info.currencyCost, difficultyID or DifficultyUtil.ID.Raid25Normal)
			end
		end
	elseif(event == 'PLAYER_LOGIN') then
		-- update anchor position and frame positions
		C_Timer.After(3, function() -- wait for db
			BonusRollPreviewAnchor:ClearAllPoints()
			BonusRollPreviewAnchor:SetPoint(unpack(BonusRollPreviewDB.anchor))
		end)
	end
end

function addon:ZONE_CHANGED_NEW_AREA()
	-- warm up cache
	local mapID = C_Map.GetBestMapForUnit('player')
	if not mapID or mapID < 1 then
		return
	end

	local _, _, classID = UnitClass('player')
	EJ_SetLootFilter(classID, 0) -- all specs for wide cache

	if IsInInstance() then
		local _, _, difficultyID = GetInstanceInfo()
		local instanceID = EJ_GetInstanceForMap(mapID)
		if instanceID and pcall(EJ_SelectInstance, instanceID) then
			EJ_SetDifficulty(difficultyID or DifficultyUtil.ID.Raid25Normal)

			local journalIndex = 1
			while journalIndex do
				local _, _, encounterID = EJ_GetEncounterInfoByIndex(journalIndex)
				if encounterID and encounterID > 0 then
					EJ_SelectEncounter(encounterID)

					for index = 1, EJ_GetNumLoot() do
						C_EncounterJournal.GetLootInfoByIndex(index)
					end

					journalIndex = journalIndex + 1
				else
					break
				end
			end
		end
	else
		for _, info in next, C_EncounterJournal.GetEncountersOnMap(mapID) do
			local _, _, _, _, _, instanceID = EJ_GetEncounterInfo(info.encounterID)
			if pcall(EJ_SelectInstance, instanceID) then
				EJ_SelectEncounter(info.encounterID)

				for index = 1, EJ_GetNumLoot() do
					C_EncounterJournal.GetLootInfoByIndex(index)
				end
			end
		end
	end
end

function BonusRollPreviewMixin:StartEncounter()
	-- start the encounter by selecting the encounter
	self:RegisterSafeEvent('EJ_DIFFICULTY_UPDATE')
	EJ_SelectInstance(self.instanceID)
	EJ_SetDifficulty(self.difficultyID) -- this will trigger EJ_DIFFICULTY_UPDATE
	EJ_SelectEncounter(self.encounterID) -- must be called last, otherwise breaks loot spec logic
end

local function shouldShowItem(itemID)
	if specialItems[itemID] then
		return true
	end

	local favoriteTag = addon.GetFavoriteTag and addon:GetFavoriteTag(itemID)
	if BonusRollPreviewDB.favoritesOnly then
		return favoriteTag ~= nil, favoriteTag
	end

	local _, _, _, _, _, itemClass, itemSubClass = GetItemInfoInstant(itemID)
	if itemClass == Enum.ItemClass.Weapon then
		return true, favoriteTag
	elseif itemClass == Enum.ItemClass.Armor then
		return true, favoriteTag
	elseif itemClass == Enum.ItemClass.Gem and itemSubClass == Enum.ItemArmorSubclass.Relic then
		-- azerite
		return true, favoriteTag
	elseif itemClass == Enum.ItemClass.Miscellaneous and itemSubClass == Enum.ItemMiscellaneousSubclass.Junk then
		-- armor tokens
		return true, favoriteTag
	end
end

function BonusRollPreviewMixin:PrepareButton(index)
	local button = self.buttons:Acquire()
	button:Show()

	-- set journal index
	button.index = index

	return button
end

function BonusRollPreviewMixin:ProcessItem(button, itemInfo)
	if not itemInfo then
		-- cache is still cold for some reason, this shouldn't happen
		return
	end

	if itemInfo.encounterID ~= self.encounterID then
		-- sometimes the API returns all loot for an entire instance, so we'll need to ignore
		-- items from other encounters
		return
	end

	local shouldShow, favoriteTag = shouldShowItem(itemInfo.itemID)
	if not shouldShow then
		return
	end

	if favoriteTag then
		PlaySound(SOUNDKIT.LFG_REWARDS, 'SFX')

		-- sort favorites first
		button.index = 0
	end

	-- update button data
	button.itemLink = itemInfo.link
	button.itemID = itemInfo.itemID

	-- update button widgets
	button.Icon:SetTexture(itemInfo.icon)
	button.Name:SetText(itemInfo.name)
	button.Slot:SetText(itemInfo.slot)
	button.Class:SetText(itemInfo.armorType)
	button.Fav:SetText(BonusRollPreviewDB.favoriteAlert and favoriteTag and favoriteTag or '')

	return true
end

local function sortByIndex(a, b)
	return a.index < b.index
end

function BonusRollPreviewMixin:UpdateButtonPositions()
	-- TODO: look into using a ScrollUtil instead of managing this ourselves
	table.sort(self.itemButtons, sortByIndex)

	for index, button in next, self.itemButtons do
		button:SetPoint('TOPLEFT', 0, (index - 1) * -40)
		button:SetPoint('TOPRIGHT', 0, (index - 1) * -40)
	end
end

function BonusRollPreviewMixin:UpdateItems()
	self.buttons:ReleaseAll() -- reset and hide all buttons in the pool
	self.numShownItems = 0
	self.itemButtons:wipe()

	for index = 1, EJ_GetNumLoot() do
		local itemInfo = C_EncounterJournal.GetLootInfoByIndex(index)
		if itemInfo and itemInfo.encounterID == self.encounterID then
			local button = self:PrepareButton(index, itemInfo.itemID)

			if itemInfo and itemInfo.link and itemInfo.link ~= "" then
				if self:ProcessItem(button, itemInfo) then
					self.itemButtons:insert(button)
				end
			end
		end
	end

	-- update box
	self:SetHeight(Clamp(10 + (#self.itemButtons * 40), 50, 330))
	self:UpdateButtonPositions()
	self:UpdateScrolling()
end

function BonusRollPreviewMixin:UpdateItemFilter()
	local _, classID = UnitClassBase('player')
	local lootSpecialization = GetLootSpecialization() or 0
	if(lootSpecialization == 0) then
		lootSpecialization = (GetSpecializationInfo(GetSpecialization() or 0)) or 0
	end

	EJ_SetLootFilter(classID, lootSpecialization)
end

function BonusRollPreviewMixin:RegisterSafeEvent(event)
	self:RegisterEvent(event)

	if(EncounterJournal) then
		-- if the EncounterJournal is loaded, prevent it from getting data and
		-- prevent our events from being triggered when we don't want to
		EncounterJournal:UnregisterEvent(event)
	end
end

function BonusRollPreviewMixin:UnregisterSafeEvent(event)
	self:UnregisterEvent(event)

	if(EncounterJournal) then
		-- if the EncounterJournal is loaded, let it have its events back
		EncounterJournal:RegisterEvent(event)
	end
end

function BonusRollPreviewMixin:UpdateHandlePosition(collapsed)
	local Handle = BonusRollPreviewHandle
	Handle:ClearAllPoints()

	local downwards = BonusRollPreviewDB.fillDirection == 'DOWN'
	if(collapsed) then
		if(downwards) then
			Handle:SetPoint('TOP', BonusRollFrame, 'BOTTOM', 0, 2)
			Handle.Arrow:SetTexCoord(0, 0, 1/2, 0, 0, 1, 1/2, 1)
		else
			Handle:SetPoint('BOTTOM', BonusRollFrame, 'TOP', 0, -2)
			Handle.Arrow:SetTexCoord(1/2, 1, 0, 1, 1/2, 0, 0, 0)
		end
	else
		if(downwards) then
			Handle:SetPoint('BOTTOM', self, 0, -14)
			Handle.Arrow:SetTexCoord(1/2, 1, 1, 1, 1/2, 0, 1, 0)
		else
			Handle:SetPoint('TOP', self, 0, 14)
			Handle.Arrow:SetTexCoord(1, 0, 1/2, 0, 1, 1, 1/2, 1)
		end
	end

	Handle.TopLeft:SetShown(not downwards)
	Handle.TopCenter:SetShown(not downwards)
	Handle.TopRight:SetShown(not downwards)
	Handle.BottomLeft:SetShown(downwards)
	Handle.BottomCenter:SetShown(downwards)
	Handle.BottomRight:SetShown(downwards)
end

function BonusRollPreviewMixin:UpdatePosition()
	self:ClearAllPoints()
	if(BonusRollPreviewDB.fillDirection == 'DOWN') then
		self:SetPoint('TOP', self:GetParent(), 'BOTTOM')
	else
		self:SetPoint('BOTTOM', self:GetParent(), 'TOP')
	end

	self:UpdateHandlePosition(not self:IsShown())
end

function BonusRollPreviewMixin:ToggleLock()
	local Anchor = BonusRollPreviewAnchor
	Anchor:SetShown(not Anchor:IsShown())
end

function BonusRollPreviewMixin:UpdateScrolling()
	local ScrollFrame = self.ScrollFrame
	local numButtons = #self.itemButtons
	if numButtons > 8 then
		ScrollFrame:EnableMouseWheel(true)
		ScrollFrame.ScrollChild:SetWidth(274 - ScrollFrame.Slider:GetWidth())
		ScrollFrame.Slider:Show()
		ScrollFrame.Slider:SetValue(0) -- reset scroll to top

		-- update scroll values
		local height = (10 + (numButtons * 40)) - self:GetHeight()
		ScrollFrame.Slider:SetMinMaxValues(0, height)
	else
		ScrollFrame:EnableMouseWheel(false)
		ScrollFrame.ScrollChild:SetWidth(274)
		ScrollFrame.Slider:Hide()
	end
end

function BonusRollPreviewMixin:Toggle()
	self:SetShown(not self:IsShown())
	self:UpdateHandlePosition(not self:IsShown())
end
