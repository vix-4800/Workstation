# Terminal companion scaffold

This directory contains the first-pass assets and conventions for the pixel companion.

## Expected sprite files

Put PNG sprites in `sprites/` using these names:

- `idle.png`
- `react.png`
- `thinking.png`
- `sweep.png`
- `success.png`
- `error.png`
- `sleep.png`
- `surprised.png`

The runtime script falls back to text labels until the PNG assets are added.

## Event flow

1. Fish hooks classify commands and write events into the FIFO.
2. `terminal-companion` reads the FIFO and maps events to states.
3. When Kitty graphics are available and a sprite exists, the script renders the PNG.
4. Otherwise it renders a text placeholder so the pipeline can be tested immediately.
