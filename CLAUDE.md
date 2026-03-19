# CLAUDE.md - CatsTV Roku Channel

## Project Overview

CatsTV Roku is a Roku TV channel for CATS (Community Access Television Services) in Bloomington, IN. It streams four live public access TV channels via HLS and lets users browse recent archived videos by category. This is a Roku port of the companion tvOS app located at `../CatsTV`.

## Tech Stack

- **Language:** BrightScript
- **UI Framework:** Roku SceneGraph (XML component definitions + BrightScript logic)
- **Media Playback:** Roku `Video` node (native HLS + MP4)
- **Streaming:** HLS via Dacast/Akamai CDN (`.m3u8`) and MP4 VOD archives
- **Platform:** Roku OS, HD resolution (`ui_resolution=HD`, 1280×720 coordinate space)
- **No external dependencies** — pure BrightScript/SceneGraph

## Project Structure

```
├── manifest                          # Channel metadata (title, version, resolution, splash)
├── source/
│   └── main.brs                      # Entry point: roSGScreen + roMessagePort event loop
├── images/                           # All PNG/JPG assets
│   ├── channel_card_*.png            # Live channel button images (270×220, from Apple TV screenshot)
│   ├── section_*.png                 # Category heading icons (80×80 RGBA transparent, from Apple TV screenshot)
│   ├── icon_focus_hd.png             # Roku home screen icon (336×210)
│   ├── icon_side_hd.png              # Roku side panel icon (108×69)
│   └── splash_screen_hd.png          # Launch splash (1280×720)
└── components/
    ├── MainScene.xml / .brs          # Root scene — swaps HomeScreen/PlayerScreen
    ├── HomeScreen.xml / .brs         # Live channels + scrollable recent videos
    ├── ChannelCard.xml / .brs        # Live channel card: full PNG image + coral focus border
    ├── VideoRow.xml / .brs           # Horizontal scrollable row with section header
    ├── VideoCard.xml / .brs          # Video thumbnail card (270×170, 2-line title)
    ├── FetchVideosTask.xml / .brs    # Async Task node: fetches JSON video feed off render thread
    └── PlayerScreen.xml / .brs       # Full-screen Video node (HLS live + MP4 VOD)
```

## Architecture

Lightweight component-based pattern mirroring the tvOS app's Model-View structure:

- **`MainScene`** — navigation controller: swaps `HomeScreen`/`PlayerScreen` visibility and focus based on observed field events (`channelSelected`, `videoSelected`, `playerClosed`).
- **`HomeScreen`** — owns all navigation. Live channel data is inline in `HomeScreen.brs`. Video feeds are fetched via `FetchVideosTask` at launch. `onKeyEvent` handles all D-pad input; focus section tracked via `m.focusSection` ("channels" | "city" | "county" | "community" | "catsweek"). `contentGroup` scrolls vertically to reveal video rows.
- **`ChannelCard`** — stateless presentation component. Full 270×220 PNG image as background; coral border rectangles shown/hidden via `isFocused` field.
- **`VideoRow`** — horizontal strip: section icon + title header, then a clipped scrolling group of `VideoCard` nodes. Cards scroll to keep the focused card visible. Focus driven externally by `HomeScreen` via `focusedIndex` field.
- **`VideoCard`** — 270×170 card: 120px thumbnail + 50px title area (2-line wrap, `SmallestSystemFont`). Coral focus border via oversized background rectangle (7px overhang, clipping rect extended to match).
- **`FetchVideosTask`** — `Task` node that runs an HTTP fetch off the render thread and writes results to its `result` field. `HomeScreen` observes this field to populate each `VideoRow`.
- **`PlayerScreen`** — wraps a `Video` node. Auto-detects `.m3u8` (HLS) vs MP4. Loads VTT captions via `content.SubtitleTracks`. `BACK` key stops playback and sets `playerClosed = true`.

## HomeScreen Layout (1280×720)

```
y=0–60    Header bar (fixed, always on top, not in contentGroup)
          ↕ contentGroup scrolls vertically
y=0       Banner image (1280×212)
y=222     "WATCH CATS LIVE" heading
y=300     4 channel cards (270×220) at x=60, 357, 654, 951
y=530     Separator line
y=538     "MOST RECENT VIDEOS" label
y=580     City Meetings VideoRow
y=880     County Meetings VideoRow
y=1180    Community Videos VideoRow
y=1480    CATSWeek VideoRow
```

Scroll positions (contentGroup.translation.y) to bring each section to y≈70:
- channels → 0
- city → -528
- county → -810
- community → -1110
- catsweek → -1410

## Focus Architecture

- `HomeScreen` always holds Roku focus (`setFocus(true)`)
- All D-pad events handled in `HomeScreen.onKeyEvent`
- `m.focusSection`: `"channels"` | `"city"` | `"county"` | `"community"` | `"catsweek"`
- Video rows are purely visual — `VideoRow.focusedIndex` drives card highlighting
- Up/Down switches sections; Left/Right navigates within a row

## Video Feed

- JSON endpoint: `https://3w.mcpl.info/catsjson/{city,county,community,catsweek}.json`
- Video files: `https://catstv.blob.core.windows.net/videoarchive/`
- Each video entry includes `title`, `thumbnailUrl`, `streamUrl`, and optionally `subtitleUrl` (VTT)
- Fetched in parallel at launch via four `FetchVideosTask` instances

## PlayerScreen

- Accepts `channelData = { name, streamUrl }` for live channels
- Accepts `videoSelected = { title, streamUrl, subtitleUrl }` for VOD
- Auto-detects format: `.m3u8` → HLS, anything else → MP4
- Captions: `content.SubtitleTracks = { TrackName: url, Language: "en", Description: "English" }`

## Theme / Colors

All colors mirror `CATSTheme.swift` from the tvOS app:

| Token | Hex | Usage |
|---|---|---|
| `accentCoral` | `#FF5F62` | LIVE badges, focus borders, section headings |
| `backgroundDark` | `#4A5459` | Focused card bg, thumbnail placeholder |
| `backgroundMedium` | `#636D72` | Unfocused card bg |
| `appBackground` | `#282C2F` | Full-screen background |
| `headerBg` | `#1E2224` | Header bar |
| `textPrimary` | `#FFFFFF` | Channel names, titles |
| `textSecondary` | `#999999` | Subtitles, loading text |

## Image Assets

All images cropped or derived from Apple TV app screenshots:

| File | Size | Source |
|---|---|---|
| `channel_card_*.png` | 270×220 | Cropped from `screenshots/Apple2.png` |
| `section_city.png` | 80×80 | Cropped from Apple TV simulator screenshot |
| `section_county.png` | 80×80 | Cropped from `screenshots/county.png` |
| `section_community.png` | 80×80 | Cropped from Apple TV simulator screenshot |
| `section_catsweek.png` | 80×80 | Cropped from Apple TV simulator screenshot |
| `icon_focus_hd.png` | 336×210 | CATS circular logo on blue background + "CatsTV" text |
| `icon_side_hd.png` | 108×69 | Same as above, smaller |
| `splash_screen_hd.png` | 1280×720 | Scaled from `screenshots/splash.jpg` |

## Sideloading (Development)

```bash
# 1. Package the channel (from repo root)
zip -r ~/Desktop/CatsTV-Roku.zip manifest source components images --exclude "*.DS_Store"

# 2. Enable developer mode on Roku:
#    Home x3 → Up → Right → Left → Right → Left → Left

# 3. Upload to http://<roku-ip> → Development Application Installer
```

## Channel Data

Stream URLs defined in `HomeScreen.brs` (`m.channels` array):

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
