# GTKLock Media Background Module

Custom gtklock module that sets the current media album art as the lock screen background.

## Features

- **CSS-based background** - Sets background via CSS, doesn't block UI elements
- **Automatic updates** - Background changes when track changes
- **Multiple sources** - Supports local files and HTTP/HTTPS URLs (Spotify, etc.)
- **Fallback image** - Configurable fallback when no media is playing
- **Smart caching** - Saves album art to `~/.cache/gtklock/media-bg.jpg`
- **Hides duplicate art** - Automatically hides playerctl module's album art via CSS
- **Multi-monitor support** - Works across all displays

## Build & Install

```bash
cd config/gtklock/gtklock-media-background-module

meson setup build
meson compile -C build
sudo meson install -C build

# Create symlink for gtklock
sudo ln -sf /usr/local/lib/gtklock/modules/libmedia-background.so \
            /usr/lib/gtklock/media-background-module.so
```

## Configuration

Add to your `gtklock` config.ini:

```ini
[main]
modules=media-background-module;userinfo-module;playerctl-module

[playerctl]
art-size=0  # Hide album art in playerctl (shown as background)

[media-background]
fallback-image=/path/to/fallback.jpg
```

### Options

- `fallback-image` - Path to image used when no media is playing

## Usage

The module works automatically - just lock your screen while media is playing!

## Update

```bash
cd ~/.config/gtklock/gtklock-media-background-module
meson compile -C build
sudo meson install -C build
```

## Uninstall

```bash
sudo rm /usr/lib/gtklock/media-background-module.so
sudo rm /usr/local/lib/gtklock/modules/libmedia-background.so
```
