## GPU Recorder Compression

Three companion scripts for post-processing GPU-Recorder captures.

### Scripts

- **compress** — compresses video to just under 10MB
- **compress-latest** — compresses the most recent recording automatically
- **compress-share** — compresses and copies to clipboard for instant sharing

### Desktop Shortcuts

KDE `.desktop` files for drag-and-drop processing:

- **compress** — compresses video to just under 10MB
- **compress-mix** — same but merges mic and game audio tracks
- **compress-share** — compresses and copies to clipboard for instant sharing via KDE shortcuts

### Limitations

- `.desktop` files may break if used outside `$HOME/Videos/`
- Hardcoded 10MB target

### Planned

- Installation script to dynamically add scripts to PATH
- Allow shortcuts to work from any directory
- Customizable compression parameters
