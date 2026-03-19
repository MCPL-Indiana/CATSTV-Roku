# CatsTV — Roku Channel

A Roku TV channel for **CATS (Community Access Television Services)** in Bloomington, IN. Streams four live public access TV channels and browses recent archived videos by category.

This channel is a Roku port of the [CatsTV tvOS app](../CatsTV).

---

## Features

- **4 Live Channels** — City, County, Library, and Special 2 via HLS streaming
- **Recent Videos** — Four browsable rows of archived content:
  - City Meetings
  - County Meetings
  - Community Videos
  - CATSWeek
- **Closed Captions** — VTT sidecar captions for archived videos (when available)
- **Focused UI** — Coral focus border, section icons, and card thumbnails matching the Apple TV app

---

## Channels

| Channel | Description | Stream |
|---|---|---|
| City Channel | Bloomington City Government | HLS via Dacast/Akamai |
| County Channel | Monroe County Government | HLS via Dacast/Akamai |
| Library Channel | Monroe County Public Library | HLS via Dacast/Akamai |
| Special 2 | Special Programming | HLS via Dacast/Akamai |

Video data is fetched at launch from `https://3w.mcpl.info/catsjson/{city,county,community,catsweek}.json`.

---

## Tech Stack

- **Language:** BrightScript
- **UI Framework:** Roku SceneGraph (XML + BrightScript)
- **Media Playback:** Roku `Video` node (native HLS + MP4)
- **Streaming:** HLS via Dacast/Akamai CDN (`.m3u8`) and MP4 VOD archives
- **Platform:** Roku OS (HD 1280×720 `ui_resolution`)
- **IDE:** [Roku Extension for VS Code](https://marketplace.visualstudio.com/items?itemName=RokuCommunity.brightscript) (recommended)

---

## Project Structure

```
├── manifest                          # Channel metadata and configuration
├── source/
│   └── main.brs                      # Entry point — creates roSGScreen event loop
├── images/                           # All PNG/JPG assets
│   ├── channel_card_*.png            # Live channel button images (270×220)
│   ├── section_*.png                 # Category heading icons (80×80, transparent)
│   ├── icon_focus_hd.png             # Roku home screen icon (336×210)
│   ├── icon_side_hd.png              # Roku side panel icon (108×69)
│   └── splash_screen_hd.png          # Launch splash screen (1280×720)
├── components/
│   ├── MainScene.xml / .brs          # Root scene — manages screen navigation
│   ├── HomeScreen.xml / .brs         # Live channels + recent videos browser
│   ├── ChannelCard.xml / .brs        # Live channel card (full PNG image + coral focus border)
│   ├── VideoRow.xml / .brs           # Horizontal scrollable row of video cards
│   ├── VideoCard.xml / .brs          # Video thumbnail card with 2-line title
│   ├── FetchVideosTask.xml / .brs    # Async Task node for JSON video feed fetching
│   └── PlayerScreen.xml / .brs       # Full-screen HLS/MP4 video player
└── screenshots/                      # Reference screenshots from Apple TV app
```

---

## Sideloading to a Roku Device

### 1. Enable Developer Mode on your Roku

Enter this key sequence on your Roku remote:

```
Home × 3  →  Up  →  Right  →  Left  →  Right  →  Left  →  Left
```

Set a username and password when prompted and note your device's IP address.

### 2. Package the channel

From the repo root:

```bash
zip -r ~/Desktop/CatsTV-Roku.zip manifest source components images --exclude "*.DS_Store"
```

### 3. Upload via the Developer App Installer

1. Open `http://<roku-ip>` in your browser
2. Log in with the credentials you set in step 1
3. Go to **Development Application Installer**
4. Upload `CatsTV-Roku.zip`
5. The channel will launch automatically

---

## Contact

**Community Access Television Services**
303 E. Kirkwood Ave. • Bloomington, IN 47408 • (812) 349-3111
