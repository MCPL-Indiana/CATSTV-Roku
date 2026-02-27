# CatsTV — Roku Channel

A Roku TV channel for **CATS (Community Access Television Services)** in Bloomington, IN. Provides a live stream viewer for four public access TV channels via HLS streaming.

This channel is a Roku port of the [CatsTV tvOS app](../CatsTV).

---

## Channels

| Channel | Description | Stream |
|---|---|---|
| City Channel | Bloomington City Government | HLS via Dacast/Akamai |
| County Channel | Monroe County Government | HLS via Dacast/Akamai |
| Library Channel | Monroe County Public Library | HLS via Dacast/Akamai |
| Special 2 | Special Programming | HLS via Dacast/Akamai |

---

## Tech Stack

- **Language:** BrightScript
- **UI Framework:** Roku SceneGraph (XML + BrightScript)
- **Media Playback:** Roku `Video` node (native HLS support)
- **Streaming:** HLS via Dacast/Akamai CDN (`.m3u8` manifests)
- **Platform:** Roku OS (FHD 1920×1080)
- **IDE:** [Roku Extension for VS Code](https://marketplace.visualstudio.com/items?itemName=RokuCommunity.brightscript) (recommended)

---

## Project Structure

```
Roku/
├── manifest                         # Channel metadata and configuration
├── source/
│   └── main.brs                     # Entry point — creates roSGScreen event loop
└── components/
    ├── MainScene.xml / .brs         # Root scene — manages screen navigation
    ├── HomeScreen.xml / .brs        # Channel selection grid
    ├── ChannelCard.xml / .brs       # Focusable channel card component
    └── PlayerScreen.xml / .brs      # Full-screen HLS video player
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

```bash
cd ~/Desktop/Roku
zip -r ../CatsTV-Roku.zip .
```

### 3. Upload via the Developer App Installer

1. Open `http://<roku-ip>` in your browser
2. Log in with the credentials you set in step 1
3. Go to **Development Application Installer**
4. Upload `CatsTV-Roku.zip`
5. The channel will launch automatically

---

## Channel Store Submission

Before submitting to the Roku Channel Store, add the following image assets to `images/`:

| File | Size | Purpose |
|---|---|---|
| `images/icon_focus_hd.png` | 336 × 210 px | Channel grid focused icon |
| `images/icon_side_hd.png` | 108 × 69 px | Channel grid side icon |
| `images/splash_hd.png` | 1920 × 1080 px | Launch splash screen |

Then uncomment the icon/splash lines in `manifest`.

---

## Contact

**Community Access Television Services**
303 E. Kirkwood Ave. • Bloomington, IN 47408 • (812) 349-3111
