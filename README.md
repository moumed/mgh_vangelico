# MGH Vangelico Robbery - Setup Guide
originl code from lsc_vangelico_robbery

Join our discord: [Here](https://discord.gg/TksepNQBU4) 
## Installation

1. Place the `mgh_vangelico` folder in your `resources` folder
2. Add `ensure mgh_vangelico` to your `server.cfg`
3. Execute the SQL file to add items to your database
4. Add the items to your inventory system

## Database Setup

Execute the `items.sql` file on your ESX database to add the robbery items.

## Inventory Setup

### For ox_inventory:
Add the items from `ox_inventory_items.lua` to your `ox_inventory/data/items.lua` file.

### For other inventory systems:
Adapt the items according to your inventory system format.

## Configuration

Edit the `config.lua` file to customize:
- Locale (fr/en)
- Police jobs
- Required cops count
- Loot items and their chances
- Cooldown times
- Dispatch system

## Items Added

- `diamond` - Diamond (Weight: 50, Rare, 20% chance)
- `gold_watch` - Gold Watch (Weight: 200, 30% chance)
- `ruby` - Ruby (Weight: 30, 25% chance)
- `emerald` - Emerald (Weight: 30, 25% chance)
- `sapphire` - Sapphire (Weight: 30, 15% chance)
- `pearl_necklace` - Pearl Necklace (Weight: 100, 10% chance)

## Features

- Configurable loot system
- Multi-language support (FR/EN)
- No selling functionality (robbery only)
- Proper cop verification at robbery start
- Skill check system
- Multiple dispatch system support
- Ox_lib integration

## Dependencies

- ESX Framework
- ox_lib
- ox_inventory (recommended)

## Support

For support, please contact MGH Development.