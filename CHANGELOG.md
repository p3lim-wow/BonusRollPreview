### Changes in 70300.44-Release:

- Fixed: Scrollbar not showing for >8 items
- Fixed: Random errors (temporary)

### Changes in 70300.43-Release:

- Changed: Update Interface version
- Changed: Update embeds for regression fix

### Changes in 70200.42-Release:

- Added: Option to move the BonusRollFrame
- Added: Option to control the direction the item list appears
- Added: Option to always show the item list
- Removed: Encounter database, there's an API for it now

### Changes in 70200.41-Release:

- Fixed: Missing fallback difficulties for Tome of Sargeras raid

### Changes in 70200.40-Release:

- Added: Support for Tomb of Sargeras raid
- Changed: PvP bonus loot rolls now ignored (we have no loot data)

### Changes in 70200.39-Release:

- Added: Support for Broken Shore world bosses

### Changes in 70200.38-Release:

- Added: Support for Cathedral of Night
- Changed: Update Interface version

### Changes in 70100.37-Release:

- Added: Fallback difficulty for bonus loots during login/reload
- Changed: Now hiding the box on blacklisted encounters (Nightbane)
- Fixed: Grand Magistix Elisande inconsistencies
- Fixed: General logic, some things were broken during boss death detection
- Fixed: Some of the interference with the Adventure Journal

### Changes in 70100.36-Release:

- Fixed: Nightbane showing up as an unknown ID (no loot table available)

### Changes in 70100.35-Release: 

- Fixed: Return to Karazhan IDs

### Changes in 70100.34-Release:

- Removed: Most of the Karazhan data, it was incorrect (please contribute!)
- Changed: Spell detection message gives more info

### Changes in 70100.33-Release:

- Changed: Update Interface version
- Changed: Don't poll tooltip updates on OnUpdate
- Fixed: Loot not propagating during reloads or zoning
- Fixed: Incorrect loot tables for the last two bosses of Violet Hold
- Fixed: Incorrect spell ID for Drugon

### Changes in 70000.32-Release:

- Added: Support for The Nighthold raid
- Added: Support for Trial of Valor raid
- Added: Support for Return to Karazhan dungeon
- Fixed: Incorrect loot tables for Elerethe and Il'gynoth in Emerald Nightmare

### Changes in 70000.31-Release:

- Changed: Hardcoded all the encounter and instance data, less prone to errors

### Changes in 70000.30-Release:

- Fixed: Syntax error

### Changes in 70000.29-Release:

- Fixed: Loot not showing up due to changes in Legion
- Fixed: Backround texture of handle not applying correctly
- Fixed: Loot not updating correctly when changing loot specs
- Fixed: Supreme Lord Kazzak loot not displaying correctly

### Changes in 70000.28-Release:

- Added: Support for (most of) Legion's raid encounters
- Added: Support for Legion's dungeon encounters
- Added: Support for Legion's world encounters
- Changed: Update Interface version

### Changes in 60200.27-Release:

- Fixed: Items sometimes not showing correctly
- Removed: Old addon detection

### Changes in 60200.26-Release:

- Added: Support for 6.2 raid encounters
- Added: Support for 6.2 world encounters
- Added: Support for mythic dungeons
- Changed: Update Interface version
- Fixed: World bosses sometimes not working correctly

### Changes in 60100.25-Release:

- Fixed: Item "Solar Spirehawk" should no longer show up in the list
- Fixed: Rare error when using the spec buttons

### Changes in 60100.24-Release:

- Added: Global name references to every frame
- Changed: Update Interface version
- Fixed: Slider showing when there are no items
- Fixed: Properly wrap multiline strings

### Changes in 60000.23-Release:

- Fixed: Incorrect difficulties for pre-Siege of Orgrimmar content
- Fixed: Item list sometimes not containing full amount of items
- Fixed: Tooltips not showing correct item for Heroic and Mythic items

### Changes in 60000.22-Release:

- Added: Support for "Warlords of Draenor" world encounters

### Changes in 60000.21-Release:

- Added: Support for "Warlords of Draenor" raid encounters
- Removed: Compatability code for "Mists of Pandaria"

### Changes in 50400.20-Release:

- Fixed: The arithmetic errors, hopefully

### Changes in 50400.19-Release:

- Added: Prelimiary work on "Warlords of Draenor" raid bosses
- Added: Changelog file
- Fixed: Arithmatic errors when the player doesn't have the currency to initiate a bonus roll

### Changes in 50400.18-Release:

- Added: Blacklist for raid mounts and Garrosh heirlooms as they cannot be rewarded by a bonus roll
- Added: Highlight texture to the loot specialization buttons
- Fixed: ShoppingTooltip3 is gone in the "Warlords of Draenor" expansion
- Fixed: Container not showing on second roll
- Fixed: Loot specialization buttons not showing on first use

### Changes in 50400.17-Release:

- Fixed: Delay the populate direction logic until the bonus roll frame has been positioned

### Changes in 50400.16-Release:

- Added: License
- Added: Custom dropdown to avoid tainting default UI
- Changed: Use fancy logic to populate the item list upwards or downwards
- Removed: Options

### Changes in 50400.14-Release:

- Changed: Rename the addon to "BonusRollPreview"
- Fixed: Options not being selected/shown when using chat command

### Changes in 50400.13-Release:

- Added: Scrolling item list to avoid the list going off the screen on some bosses
- Changed: Prepare for the "Warlords of Draenor" expansion by rewriting the database
- Changed: The Celestial bosses share the same spellID, only register one
- Fixed: Delay the Galakras encounterID check until player login

### Changes in 50400.12-Release:

- Fixed: Apparently Galakras have different encounterIDs from client to client

### Changes in 50400.11-Release:

- Fixed: Incorrect encounterID for Galakras

### Changes in 50400.10-Release:

- Added: Support for the "alwaysCompareItems" cvar
- Changed: Update encounters database
- Changed: Update Interface version
- Fixed: Instance difficulty

### Changes in 50300.8-Beta:

- Added: Options
- Added: Support for loot specialization
- Changed: Update Interface version

### Changes in 50300.7-Beta:

- Added: Support for 5.3's API changes

### Changes in 50200.6-Beta:

- Fixed: Incorrect spellID for Galleon

### Changes in 50200.5-Beta:

- Changed: Disable the journal when we're changing it's variables
- Fixed: Positioning of the different elements

### Changes in 50200.4-Beta:

- Added: Logic to support populating the list downwards
- Added: Error reporting to the chat
- Changed: Create the specialization buttons on demand
- Changed: Create the handle on demand
- Changed: Set the encounterID to the journal to force correct loot
- Fixed: Proper difficulty index based on default UI
- Fixed: Item list items storing
- Fixed: Item list height
- Fixed: Item tooltip position
- Fixed: Issues with item population due to misspelled event "EJ_LOOT_DATA_RECIEVED"

### Changes in 50200.3-Beta:

- Added: Specialization buttons
- Added: Notice if there are no items
- Fixed: Item list populating and clearing
- Fixed: Framelevel issues with the textures and frames

### Changes in 50200.2-Beta:

- Fixed: Difficulty index

### Changes in 50200.1-Beta:

- First public release
