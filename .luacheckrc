std = 'lua51'

quiet = 1 -- suppress report output for files without warnings

-- see https://luacheck.readthedocs.io/en/stable/warnings.html#list-of-warnings
-- and https://luacheck.readthedocs.io/en/stable/cli.html#patterns
ignore = {
	'212/self', -- unused argument self
	'212/event', -- unused argument event
	'212/unit', -- unused argument unit
	'212/element', -- unused argument element
	'211/L', -- unused variable L
	'312/event', -- unused value of argument event
	'312/unit', -- unused value of argument unit
	'431', -- shadowing an upvalue
	'542', -- empty if branch
	'614', -- trailing whitespace in a comment
	'631', -- line is too long

	'122/BonusRollFrame', -- we mutate this object
}

globals = {
	-- exposed
	'BonusRollPreview',
	'BonusRollPreviewMixin',
	'BonusRollPreviewAnchor',
	'BonusRollPreviewHandle',

	-- savedvariables
	'BonusRollPreviewDB',
}

read_globals = {
	table = {fields = {'wipe'}},

	-- FrameXML objects
	'BackdropTemplateMixin',
	'BonusRollFrame',
	'DifficultyUtil',
	'EncounterJournal',
	'GameTooltip',
	'GenerateClosure',
	'Item',
	'LE_SPELL_CONFIRMATION_PROMPT_TYPE_BONUS_ROLL', -- enum const
	'QUESTION_MARK_ICON', -- const
	'SOUNDKIT', -- enum

	-- FrameXML functions
	'Clamp',
	'CopyTable',
	'CountTable',
	'CreateUnsecuredFramePool',
	'GameTooltip_Hide',

	-- GlobalStrings
	'RETRIEVING_ITEM_INFO',
	'SELECT_LOOT_SPECIALIZATION',

	-- namespaces
	'C_CurrencyInfo',
	'C_EncounterJournal',
	'C_SpecializationInfo',
	'C_Timer',
	'Enum',

	-- API
	'CreateFrame',
	'EJ_GetEncounterInfoByIndex',
	'EJ_GetNumLoot',
	'EJ_IsLootListOutOfDate',
	'EJ_SelectEncounter',
	'EJ_SelectInstance',
	'EJ_SetDifficulty',
	'EJ_SetLootFilter',
	'GetInstanceInfo',
	'GetItemInfoInstant',
	'GetJournalInfoForSpellConfirmation',
	'GetLootSpecialization',
	'GetNumSpecializations',
	'GetSpecialization', -- deprecated
	'GetSpecializationInfo', -- deprecated
	'GetSpellConfirmationPromptsInfo',
	'IsInInstance',
	'Mixin',
	'PlaySound',
	'SetLootSpecialization',
	'UnitClassBase',
	'hooksecurefunc',

	-- addons
	'AtlasLoot',
	'BastionLoot',
	'LOIHLOOT_GLOBAL_PRIVATE',
	'LootAlarm',
	'LootReserve',
}
