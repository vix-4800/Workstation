# GTKLock Media Background Module

Custom gtklock module that sets the current media album art as the lock screen background.

## Features

- **CSS-based background** - Sets background via CSS, doesn't block UI elements
- **Automatic updates** - Background changes when track changes
- **Multiple sources** - Supports local files and HTTP/HTTPS URLs (Spotify, etc.)
- **Fallback image** - Configurable fallback when no media is playing
- **Smart caching** - Saves album art to `~/.cache/gtklock/media-bg.jpg`
- **Hides duplicate art** - Optionally hides playerctl module's album art via CSS
- **Multi-monitor support** - Works across all displays

## Configuration Options

| Option | Type | Default | Description |
| ------ | ---- | ------- | ----------- |
| `fallback-image` | string | none | Path to fallback image when no media playing |
| `background-color` | string | `@base` | Background color when no image (CSS color) |
| `opacity` | double | `1.0` | Background image opacity (0.0-1.0) |
| `blur-radius` | int | `0` | Background blur in pixels (0-50, GTK 3.24.38+) |
| `enable-background-image` | bool | `true` | Enable album art as background |
| `no-background-image` | flag | - | Disable album art, use solid color only |
| `darken` | bool | `false` | Apply dark overlay for better readability |
| `darken-amount` | double | `0.5` | Darkness level of overlay (0.0-1.0) |
| `hide-playerctl-art` | bool | `true` | Hide album art in playerctl module |
| `show-playerctl-art` | flag | - | Show album art in playerctl module |
| `background-size` | string | `cover` | CSS background-size property |
| `background-position` | string | `center` | CSS background-position property |

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
opacity=0.85
darken=true
darken-amount=0.4
background-color=#1e1e2e
```

### Configuration Examples

**Simple setup (album art as background):**

```ini
[media-background]
fallback-image=/home/user/wallpaper.jpg
```

**Dark overlay for readability:**

```ini
[media-background]
darken=true
darken-amount=0.5
```

**Semi-transparent background:**

```ini
[media-background]
opacity=0.8
```

**Solid color only (no album art):**

```ini
[media-background]
no-background-image=true
background-color=#1e1e2e
```

**Custom background sizing:**

```ini
[media-background]
background-size=contain
background-position=top center
```

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
