local Buttons = CreateFrame('Frame', (...) .. 'SpecButtons', BonusRollFrame)
Buttons:SetPoint('LEFT', BonusRollFrame.SpecIcon, 4, 4)
Buttons:Hide()

local function HideButtons()
	BonusRollFrame.SpecIcon:SetDesaturated(false)
	Buttons:Hide()
end

local function ShowButtons()
	BonusRollFrame.SpecIcon:SetDesaturated(true)
	Buttons:Show()
end

local function OnButtonClick(self)
	SetLootSpecialization(self:GetID())
	HideButtons()
end

local function OnButtonEnter(self)
	GameTooltip:SetOwner(self, 'ANCHOR_TOPRIGHT')
	GameTooltip:AddLine(self.tooltip, 1, 1, 1)
	GameTooltip:Show()
end

local Zone = CreateFrame('Frame', nil, BonusRollFrame)
Zone:SetAllPoints(BonusRollFrame.SpecIcon)
Zone.tooltip = SELECT_LOOT_SPECIALIZATION

Zone:SetScript('OnLeave', function()
	GameTooltip_Hide()

	if(not Buttons:IsMouseOver()) then
		HideButtons()
	end
end)

Zone:SetScript('OnEnter', function(self)
	OnButtonEnter(self)

	if(not Buttons:IsShown()) then
		if(not self.initialized) then
			local numSpecs = GetNumSpecializations()
			for index = 1, numSpecs do
				local specID, name, _, texture = GetSpecializationInfo(index)

				local Button = CreateFrame('Button', '$parentButton' .. index, Buttons)
				Button:SetPoint('LEFT', index * 28, 0)
				Button:SetSize(22, 22)
				Button:SetScript('OnClick', OnButtonClick)
				Button:SetScript('OnEnter', OnButtonEnter)
				Button:SetScript('OnLeave', GameTooltip_Hide)
				Button:SetNormalTexture(texture)
				Button:SetHighlightTexture([[Interface\Minimap\UI-Minimap-ZoomButton-Highlight]])
				Button:SetID(specID)
				Button.tooltip = name

				-- BUG: mouse gets stuck on this border and won't hide the container
				local Border = Button:CreateTexture('$parentBorder', 'OVERLAY')
				Border:SetPoint('TOPLEFT', -6, 6)
				Border:SetSize(58, 58)
				Border:SetTexture([[Interface\Minimap\Minimap-TrackingBorder]])
			end

			local width, height = self:GetSize()
			Buttons:SetSize((numSpecs * 28) + width, height)

			self.initialized = true
		end

		ShowButtons()
	end
end)

Buttons:SetScript('OnLeave', function(self)
	if(not Zone:IsMouseOver() and not Buttons:IsMouseOver()) then
		HideButtons()
	end
end)


hooksecurefunc('BonusRollFrame_StartBonusRoll', function()
	-- Need to force show the SpecIcon when the player
	-- has no chosen loot specialization.
	local lootSpecialization = GetLootSpecialization()
	if(not lootSpecialization or lootSpecialization == 0) then
		local specID, _, _, texture = GetSpecializationInfo(GetSpecialization() or 0)
		if(specID) then
			BonusRollFrame.SpecIcon:SetTexture(texture)
			BonusRollFrame.SpecIcon:Show()
			BonusRollFrame.SpecRing:Show()
		end
	end
end)
