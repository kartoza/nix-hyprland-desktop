# Waybar CSS Keywords and Properties Reference

Based on documentation and your existing configuration, here's a comprehensive list of CSS keywords, properties, and selectors supported by Waybar:

## CSS Selectors

### Main Window

- `window#waybar` - Main waybar window
- `window#waybar.hidden` - Hidden state
- `window#waybar.<name>` - Named waybar instances
- `window#waybar.<position>` - Position-based styling

### Layout Containers

- `.modules-left` - Left modules container
- `.modules-center` - Center modules container
- `.modules-right` - Right modules container

### Workspaces

- `#workspaces` - Workspace container
- `#workspaces button` - Individual workspace buttons
- `#workspaces button.focused` - Active workspace
- `#workspaces button.urgent` - Urgent workspace

### Taskbar

- `#taskbar` - Taskbar container
- `#taskbar button` - Individual app buttons
- `#taskbar button.active` - Active app
- `#taskbar button.minimized` - Minimized app
- `#taskbar button.urgent` - Urgent app

### Module Selectors

- `#battery`, `#cpu`, `#memory`, `#clock`, `#network`, `#pulseaudio`
- `#temperature`, `#backlight`, `#disk`, `#tray`, `#mode`, `#language`
- `#idle_inhibitor`, `#scratchpad`, `#window`
- `#custom-<name>` - Custom modules

### State Classes

- `.charging`, `.critical`, `.warning` (battery)
- `.muted`, `.medium`, `.high` (audio)
- `.activated`, `.deactivated` (idle inhibitor)
- `.disabled`, `.enabled` (various states)
- `.recording`, `.stopped`, `.idle` (recorder)
- `.perfect`, `.warning`, `.critical`, `.unknown` (monitoring)

### Pseudo-classes

- `:hover` - Hover states
- `:not()` - Negation selector

## CSS Properties

### Color Properties

- `color` - Text/foreground color
- `background-color` - Background color
- `background-image` - Background images
- `background-size` - Background sizing
- `background-position` - Background positioning
- `background-repeat` - Background repetition
- `opacity` - Transparency (0-1)

### Font Properties

- `font-family` - Font family
- `font-size` - Font size
- `font-weight` - Font weight (normal, bold, 100-900)
- `font-style` - Font style (normal, italic, oblique)

### Box Model

- `padding` - Internal spacing
- `margin` - External spacing
- `border` - Border shorthand
- `border-width`, `border-color`, `border-style` - Border components
- `border-radius` - Rounded corners
- `min-width`, `min-height` - Minimum dimensions

### Visual Effects

- `box-shadow` - Drop shadows
- `text-shadow` - Text shadows
- `text-decoration-line` - Text decoration
- `letter-spacing` - Character spacing

### Animation

- `transition-property` - Transition target
- `transition-duration` - Transition timing
- `animation-name`, `animation-duration` - Animations

## Color Value Formats

### Standard Formats

- Hex: `#569FC6`, `#RGB`, `#RRGGBB`
- RGB: `rgb(86, 159, 198)`
- RGBA: `rgba(86, 159, 198, 0.15)`
- Named colors: `red`, `blue`, `transparent`

### GTK Theme Variables

- `@theme_base_color` - Base theme color
- `@unfocused_borders` - Border colors
- `@theme_text_color` - Text colors

### GTK Color Functions

- `shade(color, factor)` - Lighten/darken
- `mix(color1, color2, factor)` - Color mixing
- `alpha(color, opacity)` - Transparency

## Special Features

### Hot Reloading

- Send `SIGUSR2` to waybar process to reload styles
- `pkill -SIGUSR2 waybar`

### Debugging

- `GTK_DEBUG=interactive waybar` - Interactive inspector
- `waybar -l debug` - Debug mode with CSS classes

### File Locations

- `~/.config/waybar/style.css` - Primary stylesheet
- `~/.config/waybar/style-light.css` - Light theme variant
- `~/.config/waybar/style-dark.css` - Dark theme variant
