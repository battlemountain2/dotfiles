## User-Authored Plugins
The snapshot vendors these custom local plugins under `.config/omarchy/plugins/`:

- `bry.control-center`: Full-featured Mac-inspired Control Center with sliders (brightness, keyboard backlight, volume), quick toggles (Wi-Fi, Bluetooth, Night Light, Stay Awake, DND, Mic, 120Hz/60Hz, Top Bar), media card, screenshot tools, and iPhone wireless bridge card.
- `bry.bar`: Customized status bar with indicators and widget layout.

## Cloned / Third-Party Plugins
The snapshot records configuration for these plugins without vendoring their
Git repositories:

- [Omaland](https://github.com/bobby-nicholas/omaland.git)
- [Omarchy Plugin Manager](https://github.com/peterszarvas94/omarchy-plugin-manager.git)
- [Lock Explorer](https://github.com/SirJul1337/omarchy-lock-explorer.git)
- [Aether Wallpapers](https://github.com/smillunchick/omarchy-aether-wallpapers.git)
- [Clipboard Manager](https://github.com/huyhuyvu01/omarchy-clipboard.git)
- [Mirador](https://github.com/sanjyay/Mirador.git)
- [Omarchy Spotify](https://github.com/stappmus/Omarchy-Spotify)
- [Notification Center](https://github.com/Shavanced/omarchy-notification-center-plugin.git)
- [Omasing Lyrics](https://github.com/stappmus/Omasing.git)
- [Omarchy Calendar](https://github.com/tmn73/omarchy-calendar)

Additional installed theme repositories include AmeKoji, Apocalypse,
Brutalism, Frost, Gotham City, Manga, NYC, and Solitude. The active theme at
snapshot time was `kiara`. Theme assets are omitted because Omarchy can install
or clone them independently and binary wallpapers do not help the configuration
comparison.

The `shell.json` snapshot deliberately omits plugin `sessionState` fields.
