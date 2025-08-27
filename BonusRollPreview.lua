local addonName, addon = ...

-- sourced from _G
local LE_SPELL_CONFIRMATION_PROMPT_TYPE_BONUS_ROLL = LE_SPELL_CONFIRMATION_PROMPT_TYPE_BONUS_ROLL or 1

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

local query = {}

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

	self.buttons = CreateFramePool('Button', self.ScrollFrame.ScrollChild, 'BonusRollPreviewButtonTemplate')
end

function BonusRollPreviewMixin:OnEvent(event, ...)
	if(event == 'EJ_DIFFICULTY_UPDATE') then
		-- difficulty to track has updated, update filter and item list
		self:UnregisterSafeEvent(event)
		self:UpdateItemFilter()
		self:UpdateItems()
	elseif(event == 'EJ_LOOT_DATA_RECIEVED') then
		if(self:GetParent():IsShown()) then
			if(CountTable(query) == 0) then
				-- query is empty, bail out
				return self:UnregisterSafeEvent(event)
			end

			local itemID = ...
			if(EJ_IsLootListOutOfDate()) then
				-- entire list is considered out of date, wipe the query and start over
				table.wipe(query)
				self:UpdateItems()
			elseif(query[itemID]) then
				-- this sucks, but we have to restart the entire encounter to get accurate data
				-- by the data returns to the client the client might have changed parameters
				table.wipe(query)
				self:StartEncounter()
				-- self:UpdateItem(itemID)
			end
		end
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
		self:UnregisterEvent('EJ_LOOT_DATA_RECIEVED')
		self:UnregisterEvent('PLAYER_LOOT_SPEC_UPDATED')
		self:Hide()
		BonusRollPreviewHandle:Hide()
	elseif(event == 'PLAYER_ENTERING_WORLD') then
		-- check for any outstanding bonus rolls
		for _, info in next, GetSpellConfirmationPromptsInfo() do
			if(info and info.spellID) then
				local inInstance, instanceType = IsInInstance()
				local difficultyID, _
				if inInstance and instanceType == "raid" then
					_,_,difficultyID = GetInstanceInfo()
				end
				self:OnEvent('SPELL_CONFIRMATION_PROMPT', info.spellID, info.confirmType, nil, nil, info.currencyID, info.currencyCost, (info.difficultyID or difficultyID or DifficultyUtil.ID.Raid25Normal))
			end
		end
	elseif(event == 'PLAYER_LOGIN') then
		-- update anchor position and frame positions
		BonusRollPreviewAnchor:ClearAllPoints()
		BonusRollPreviewAnchor:SetPoint(unpack(BonusRollPreviewDB.anchor))

	end
end

function BonusRollPreviewMixin:StartEncounter()
	-- start the encounter by selecting the encounter
	self:RegisterSafeEvent('EJ_DIFFICULTY_UPDATE')
	EJ_SelectInstance(self.instanceID)
	EJ_SetDifficulty(self.difficultyID) -- this will trigger EJ_DIFFICULTY_UPDATE
	EJ_SelectEncounter(self.encounterID)
end

function BonusRollPreviewMixin:UpdateItems()
	self:RegisterSafeEvent('EJ_LOOT_DATA_RECIEVED')
	self.buttons:ReleaseAll() -- reset and hide all buttons in the pool

	local numItems = 0
	local soundAlert -- only do it once at the end of the loop, if we had any wishlisted items show up

	for index = 1, EJ_GetNumLoot() do
		local itemInfo = C_EncounterJournal.GetLootInfoByIndex(index)
		-- for some reason the API returns all loot for the entire instance
		-- so we need to make sure we only list the ones for the selected encounter
		if(itemInfo.encounterID == self.encounterID) then
			local _, _, _, _, _, itemClass, itemSubClass = GetItemInfoInstant(itemInfo.itemID)

			local Favorite = addon:IsFavoritedItem(itemInfo.itemID)
			if Favorite then
				soundAlert = BonusRollPreviewDB.favoriteAlert
			end
			-- only show equippable and special whitelisted items
			-- by filtering them by item class/subclass
			if(
					(BonusRollPreviewDB.favoritesOnly == false or (BonusRollPreviewDB.favoritesOnly and Favorite))
					and
					(
					itemClass == Enum.ItemClass.Weapon or itemClass == Enum.ItemClass.Armor or
					(itemClass == Enum.ItemClass.Gem and itemSubClass == Enum.ItemArmorSubclass.Relic) or -- azerite (retail)
					(itemClass == Enum.ItemClass.Miscellaneous and itemSubClass == Enum.ItemMiscellaneousSubclass.Junk) -- tokens (mists)
					)
				)	or specialItems[itemInfo.itemID] then
				-- add item to item count
				numItems = numItems + 1

				-- grab a button from the pool and position it
				local Button = self.buttons:Acquire()
				Button:SetPoint('TOPLEFT', 0, (numItems - 1) * -40)
				Button:SetPoint('TOPRIGHT', 0, (numItems - 1) * -40)
				Button:Show()

				-- update its data
				Button.itemLink = itemInfo.link
				Button.itemID = itemInfo.itemID
				Button.Fav:SetText(BonusRollPreviewDB.favoriteAlert and (Favorite or '') or '')

				if(itemInfo.link) then
					Button.Icon:SetTexture(itemInfo.icon)
					Button.Name:SetText(itemInfo.name)
					Button.Slot:SetText(itemInfo.slot)
					Button.Class:SetText(itemInfo.armorType)
				else
					-- item is not cached, show temporary information
					Button.Icon:SetTexture(QUESTION_MARK_ICON)
					Button.Name:SetText(RETRIEVING_ITEM_INFO)
					Button.Slot:SetText('')
					Button.Class:SetText('')

					-- add the item to our query list
					query[itemInfo.itemID] = index
				end
				self.buttons.numActiveObjects = numItems
			end
		end
	end

	if(numItems == 0) then
		self:OnEvent('SPELL_CONFIRMATION_TIMEOUT')
		return
	else
		if soundAlert then
			PlaySound(SOUNDKIT.LFG_REWARDS,"SFX")
		end
	end
	-- set height based on number of items, min 1, max 8
	local height = 10 + (numItems * 40)
	self:SetHeight(Clamp(height, 50, 330))

	-- update scrolling based on number of shown items
	if(numItems > 8) then
		self:EnableScrolling()
	else
		self:DisableScrolling()
	end
end

function BonusRollPreviewMixin:UpdateItemFilter()
	local _, classID = UnitClassBase('player')
	local lootSpecialization = GetLootSpecialization() or 0
	if(lootSpecialization == 0) then
		lootSpecialization = (addon:GetSpecializationInfo(addon:GetSpecialization() or 0)) or 0
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

function BonusRollPreviewMixin:EnableScrolling()
	local ScrollFrame = self.ScrollFrame
	ScrollFrame:EnableMouseWheel(true)
	ScrollFrame.ScrollChild:SetWidth(274 - ScrollFrame.Slider:GetWidth())

	-- set new scroll values
	local height = (10 + (self.buttons.numActiveObjects * 40)) - self:GetHeight()
	ScrollFrame.Slider:SetMinMaxValues(0, height)

	-- reset scroll to top
	ScrollFrame.Slider:SetValue(0)
	ScrollFrame.Slider:Show()
end

function BonusRollPreviewMixin:DisableScrolling()
	local ScrollFrame = self.ScrollFrame
	ScrollFrame:EnableMouseWheel(false)
	ScrollFrame.ScrollChild:SetWidth(274)
	ScrollFrame.Slider:Hide()
end

function BonusRollPreviewMixin:Toggle()
	self:SetShown(not self:IsShown())
	self:UpdateHandlePosition(not self:IsShown())
end
_G[addonName.."Ext"] = addon -- for debugging, comment out for release
