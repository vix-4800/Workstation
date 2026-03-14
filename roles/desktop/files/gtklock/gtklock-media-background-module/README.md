# GTKLock Media Background Module

Custom gtklock module that sets the current media album art as the lock screen background.

## Features

- **CSS-based background** - Sets background via CSS with high priority, doesn't block UI elements
- **Automatic updates** - Background changes when track changes
- **Multiple sources** - Supports local files and HTTP/HTTPS URLs (Spotify, etc.)
- **Style.css integration** - Uses default background from style.css when no media is playing
- **Smart caching** - Saves album art to `~/.cache/gtklock/media-bg.jpg`
- **Hides duplicate art** - Optionally hides playerctl module's album art via CSS
- **Multi-monitor support** - Works across all displays

## Configuration Options

| Option                | Type   | Default  | Description                               |
| --------------------- | ------ | -------- | ----------------------------------------- |
| `opacity`             | string | `1.0`    | Album art opacity (0.0-1.0)               |
| `darken`              | bool   | `false`  | Apply dark overlay for better readability |
| `darken-amount`       | string | `0.5`    | Darkness level of overlay (0.0-1.0)       |
| `hide-playerctl-art`  | bool   | `true`   | Hide album art in playerctl module        |
| `show-playerctl-art`  | flag   | -        | Show album art in playerctl module        |
| `background-size`     | string | `cover`  | CSS background-size property              |
| `background-position` | string | `center` | CSS background-position property          |

> [!NOTE]
> When no media is playing, the module doesn't set any window background, allowing your style.css to control the
> default background image/color.

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
opacity=0.45
darken=true
darken-amount=0.5
```

Set your default background in style.css:

```css
window {
    background-image: url('../../Pictures/Wallpapers/your-wallpaper.jpg');
    background-size: cover;
    background-position: center;
    background-color: #1e1e2e;
}
```

### Configuration Examples

**Minimal setup:**

```ini
[media-background]
# That's it! Default background comes from style.css
```

**Dark overlay for readability:**

```ini
[media-background]
darken=true
darken-amount=0.5
```

**Semi-transparent album art:**

```ini
[media-background]
opacity=0.8
darken=true
darken-amount=0.3
```

**Custom background sizing:**

```ini
[media-background]
background-size=contain
background-position=top center
```

## How It Works

The module uses CSS with `GTK_STYLE_PROVIDER_PRIORITY_USER` (highest priority) to override the default background:

- **No music playing** → Module doesn't set window CSS → Your style.css background shows
- **Music playing** → Module sets album art as background → Overrides style.css background
- **Music stopped** → Module clears CSS → Back to style.css background

The module automatically detects when tracks change or playback stops and updates accordingly.

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
