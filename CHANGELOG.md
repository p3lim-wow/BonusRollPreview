## Changes in 60000.23-Release:

- Fixed: Incorrect difficulties for pre-Siege of Orgrimmar content
- Fixed: Item list sometimes not containing full amount of items
- Fixed: Tooltips not showing correct item for Heroic and Mythic items

## Changes in 60000.22-Release:

- Added: Support for "Warlords of Draenor" world encounters

## Changes in 60000.21-Release:

- Added: Support for "Warlords of Draenor" raid encounters
- Removed: Compatability code for "Mists of Pandaria"

## Changes in 50400.20-Release:

- Fixed: The arithmetic errors, hopefully

## Changes in 50400.19-Release:

- Added: Prelimiary work on "Warlords of Draenor" raid bosses
- Added: Changelog file
- Fixed: Arithmatic errors when the player doesn't have the currency to initiate a bonus roll

## Changes in 50400.18-Release:

- Added: Blacklist for raid mounts and Garrosh heirlooms as they cannot be rewarded by a bonus roll
- Added: Highlight texture to the loot specialization buttons
- Fixed: ShoppingTooltip3 is gone in the "Warlords of Draenor" expansion
- Fixed: Container not showing on second roll
- Fixed: Loot specialization buttons not showing on first use

## Changes in 50400.17-Release:

- Fixed: Delay the populate direction logic until the bonus roll frame has been positioned

## Changes in 50400.16-Release:

- Added: License
- Added: Custom dropdown to avoid tainting default UI
- Changed: Use fancy logic to populate the item list upwards or downwards
- Removed: Options

## Changes in 50400.14-Release:

- Changed: Rename the addon to "BonusRollPreview"
- Fixed: Options not being selected/shown when using chat command

## Changes in 50400.13-Release:

- Added: Scrolling item list to avoid the list going off the screen on some bosses
- Changed: Prepare for the "Warlords of Draenor" expansion by rewriting the database
- Changed: The Celestial bosses share the same spellID, only register one
- Fixed: Delay the Galakras encounterID check until player login

## Changes in 50400.12-Release:

- Fixed: Apparently Galakras have different encounterIDs from client to client

## Changes in 50400.11-Release:

- Fixed: Incorrect encounterID for Galakras

## Changes in 50400.10-Release:

- Added: Support for the "alwaysCompareItems" cvar
- Changed: Update encounters database
- Changed: Update Interface version
- Fixed: Instance difficulty

## Changes in 50300.8-Beta:

- Added: Options
- Added: Support for loot specialization
- Changed: Update Interface version

## Changes in 50300.7-Beta:

- Added: Support for 5.3's API changes

## Changes in 50200.6-Beta:

- Fixed: Incorrect spellID for Galleon

## Changes in 50200.5-Beta:

- Changed: Disable the journal when we're changing it's variables
- Fixed: Positioning of the different elements

## Changes in 50200.4-Beta:

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

## Changes in 50200.3-Beta:

- Added: Specialization buttons
- Added: Notice if there are no items
- Fixed: Item list populating and clearing
- Fixed: Framelevel issues with the textures and frames

## Changes in 50200.2-Beta:

- Fixed: Difficulty index

## Changes in 50200.1-Beta:

- First public release
