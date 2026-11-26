# Realistic Shovel

**Version 0.2.4** · Noita addon

Realistic Shovel changes the ordinary shovel introduced by Varia Addons to make excavation more realistic. Instead of simply destroying terrain, the shovel loosens selected materials, collects loose matter and deposits it in nearby open space.

## Features

- Loosens selected compacted terrain, including soil, snow and coal.
- Displaces loose terrain, mud, liquids and other powders.
- Preserves the identity of collected materials during transport. Natural material reactions still occur after deposition.
- Leaves ordinary solid rock and metals intact. Selected softer rock variants can be loosened.
- Changes only the ordinary Varia Addons shovel, not other shovels or the original POWERDIGGER spell.

## Requirements

- Noita
- [Varia Addons](https://steamcommunity.com/sharedfiles/filedetails/?id=2194682888)

Realistic Shovel is an addon, not a standalone mod. No other mods are required.

## Installation

### Steam Workshop

Workshop publication is planned. Once available, subscribe to both Varia Addons and Realistic Shovel, enable them in Noita's Mods menu and place Realistic Shovel below Varia Addons in the load order.

### Manual installation from GitHub

1. Install Varia Addons.
2. Download this repository using **Code → Download ZIP** and extract it.
3. Copy the inner `realistic_shovel` folder into `Noita/mods/`.
4. Enable both mods in Noita, placing Realistic Shovel below Varia Addons in the load order.
5. Restart the game.

The mod supports existing ordinary shovels in saved games. A new run is not required.

## Configuration

Optional settings are available in `realistic_shovel/config.lua`:

| Setting | Default | Function |
| --- | --- | --- |
| `REALISTIC_SHOVEL_MOVE_LIQUIDS` | `true` | Enables displacement of liquids. |
| `REALISTIC_SHOVEL_MOVE_OTHER_POWDERS` | `true` | Enables displacement of additional powders. |
| `REALISTIC_SHOVEL_RESTORE` | `false` | Restores the original shovel action before uninstalling. |

## Safe uninstallation

The mod replaces the permanent action on ordinary shovels in saved games. Restore that action before disabling or removing the mod.

1. Back up the save and close Noita.
2. Set `REALISTIC_SHOVEL_RESTORE = true` in `config.lua`.
3. Start the game with both mods enabled and load the affected save. Keep the modified shovel in the inventory or nearby until its original action is restored.
4. Save and close the game, then disable or remove Realistic Shovel.

Any modified shovels in other areas must also be loaded and restored before removal. Alternatively, restore a backup from before installation.

## Feedback

Report bugs and compatibility issues through [GitHub Issues](https://github.com/PolvitoFeerico/Realistic-Shovel-Noita-mod/issues).

## License

See [LICENSE](LICENSE) for the license covering Realistic Shovel's own code.
