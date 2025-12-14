# Waybar Notes

This is a custom theme I made for a kartoza aesthetic

To test changes to waybar and related widget without doing a long painful nixos rebuild cycle each time, you can run this command e.g:

```markdown
cd /home/timlinux/dev/nix/nix-config/dotfiles/waybar
waybar -c config -s style.css --log-level debug 2>&1 | head -30
```

It will load up a second instance of the bar that you can preview your changes in.

## Modular Configuration System

This waybar config uses a modular system where the configuration is split into atomic JSON files for easier editing.

### Structure

```bash
waybar/
├── config.d/           # Individual JSON module files
│   ├── 00-base.json    # Base config (layer, position, module lists)
│   ├── 10-*.json       # Custom/improved modules
│   └── 90-*.json       # Auto-extracted modules
├── build-config.sh     # Merges JSON files into final config
├── config              # Generated merged config
└── style.css           # Styling
```

### Making Changes

Edit specific module files in `config.d/` then rebuild:

```bash
cd /home/timlinux/dev/nix/nix-config/dotfiles/waybar
./build-config.sh
waybar -c config -s style.css  # Test it
```

The config is automatically rebuilt by home-manager on `nixos-rebuild switch`.

### Benefits

- **Safe editing**: Changes are isolated to individual files
- **No corruption**: JSON tool bugs can't destroy the entire config
- **Easy diffs**: See exactly what changed in version control
- **Modular**: Enable/disable features by renaming files

## Credits

Tim Sutton, Nov 2025
