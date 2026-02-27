# CLAUDE.md - CatsTV Roku Channel

## Project Overview

CatsTV Roku is a Roku TV channel for CATS (Community Access Television Services) in Bloomington, IN. It provides a live stream viewer for four public access TV channels via HLS streaming. This is a Roku port of the companion tvOS app located at `../CatsTV`.

## Tech Stack

- **Language:** BrightScript
- **UI Framework:** Roku SceneGraph (XML component definitions + BrightScript logic)
- **Media Playback:** Roku `Video` node (native HLS)
- **Streaming:** HLS via Dacast/Akamai CDN (`.m3u8` manifests)
- **Platform:** Roku OS, FHD resolution (1920×1080)
- **No external dependencies** — pure BrightScript/SceneGraph

## Project Structure

```
Roku/
├── manifest                         # Channel metadata (title, version, resolution, splash)
├── source/
│   └── main.brs                     # Entry point: roSGScreen + roMessagePort event loop
└── components/
    ├── MainScene.xml / .brs         # Root scene — owns navigation between HomeScreen/PlayerScreen
    ├── HomeScreen.xml / .brs        # Channel selection (4-card horizontal grid)
    ├── ChannelCard.xml / .brs       # Focusable card: icon letter, LIVE badge, name, subtitle
    └── PlayerScreen.xml / .brs      # Full-screen Video node with loading/error states
```

## Architecture

Lightweight component-based pattern mirroring the tvOS app's Model-View structure:

- **`MainScene`** — navigation controller: swaps `HomeScreen`/`PlayerScreen` visibility and focus based on observed field events (`channelSelected`, `playerClosed`).
- **`HomeScreen`** — channel data is defined inline in `HomeScreen.brs` (mirrors `Channel.allChannels`). Focus is managed manually via `onKeyEvent` (left/right D-pad) since Roku SceneGraph requires explicit focus handling for custom layouts.
- **`ChannelCard`** — stateless presentation component driven by interface fields (`channelName`, `channelSubtitle`, `iconText`, `isFocused`). Focus state changes trigger `onFocusChange` to update colors and border visibility.
- **`PlayerScreen`** — wraps a `Video` node. Observes `video.state` to transition between loading, playing, and error UI states. `BACK` key sets `playerClosed = true` to notify `MainScene`.

## Theme / Colors

All colors mirror `CATSTheme.swift` from the tvOS app:

| Token | Hex | Usage |
|---|---|---|
| `accentCoral` | `#FF5F62` | LIVE badges, focused card border/name, heading accent |
| `backgroundDark` | `#4A5459` | Focused card bg, thumbnail area bg |
| `backgroundMedium` | `#636D72` | Unfocused card bg |
| `appBackground` | `#282C2F` | Full-screen background |
| `footerGray` | `#6E7377` | Footer text, back hint |
| `textPrimary` | `#FFFFFF` | Channel names, icon letters |
| `textSecondary` | `#999999` | Subtitles, footer org name |

## Sideloading (Development)

```bash
# 1. Package the channel
cd ~/Desktop/Roku
zip -r ../CatsTV-Roku.zip .

# 2. Enable developer mode on Roku:
#    Home x3 → Up → Right → Left → Right → Left → Left

# 3. Upload to http://<roku-ip> → Development Application Installer
```

## Channel Data

Channel stream URLs are defined in `HomeScreen.brs` in the `m.channels` array. They map 1-to-1 with `Channel.allChannels` in the tvOS app:

| ID | Name | Stream URL |
|---|---|---|
| `city` | City Channel | `...f8f183aa.../source/index.m3u8` |
| `county` | County Channel | `...717441a0.../source/index.m3u8` |
| `library` | Library Channel | `...cfa6d8a7.../source/index.m3u8` |
| `special2` | Special 2 | `...86d196fc.../index.m3u8` |

## Git Conventions

- **Remote:** Named `Github` (not `origin`)
- **Main branch:** `main`
- **Claude branches:** `claude/<adjective-name>` (e.g., `claude/sunny-pascal`)
- **Workflow:** Feature branches merged to `main` via GitHub PRs
