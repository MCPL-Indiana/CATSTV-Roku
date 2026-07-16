' MainScene.brs - Handles navigation between HomeScreen and PlayerScreen

sub init()
    m.homeScreen   = m.top.findNode("homeScreen")
    m.searchScreen = m.top.findNode("searchScreen")
    m.playerScreen = m.top.findNode("playerScreen")
    m.playerLaunchedFrom = "home"

    ' ── Dynamic resolution scaling ────────────────────────────────────────────
    ' The UI is designed at HD (1280x720). At runtime we detect the TV's actual
    ' output resolution and apply a uniform scale factor to both screens so that
    ' every element renders natively crisp — no blurry Roku upscaling.
    '
    '   720p  TV  → scale 1.0  (no change, renders at design size)
    '   1080p TV  → scale 1.5  (1920/1280 = 1.5)
    '   4K    TV  → scale 3.0  (3840/1280 = 3.0, or 2.0 if Roku outputs 1080p to 4K)
    ' ─────────────────────────────────────────────────────────────────────────
    deviceInfo  = CreateObject("roDeviceInfo")
    displaySize = deviceInfo.GetDisplaySize()

    if displaySize.w > 0 and displaySize.h > 0
        scaleX = displaySize.w / 1280.0
        scaleY = displaySize.h / 720.0

        ' Use the smaller axis to preserve aspect ratio on any display
        if scaleX <= scaleY
            uiScale = scaleX
        else
            uiScale = scaleY
        end if

        if uiScale <> 1.0
            m.homeScreen.scale   = [uiScale, uiScale]
            m.searchScreen.scale = [uiScale, uiScale]
            m.playerScreen.scale = [uiScale, uiScale]
        end if
    end if
    ' ─────────────────────────────────────────────────────────────────────────

    m.homeScreen.observeField("channelSelected", "onChannelSelected")
    m.homeScreen.observeField("videoSelected",   "onVideoSelected")
    m.homeScreen.observeField("searchOpened",    "onSearchOpened")
    m.searchScreen.observeField("videoSelected", "onSearchVideoSelected")
    m.searchScreen.observeField("closed",        "onSearchClosed")
    m.playerScreen.observeField("playerClosed",  "onPlayerClosed")

    m.homeScreen.setFocus(true)
    m.top.signalBeacon("AppLaunchComplete")
end sub

sub onLaunchArgs(event as Object)
    args = event.getData()
    if args = invalid then return

    contentId = args.contentId
    mediaType = args.mediaType
    if contentId = invalid or contentId = "" then return

    ' Direct to Play (req 5.2): map contentId to live stream and launch player
    streamUrls = {
        city:     "https://cdn-us-east-prod-ingest-infra-dacast-com.akamaized.net/f8f183aa686dea8fded26ffa5475d3f5/source/index.m3u8",
        county:   "https://cdn-us-east-prod-ingest-infra-dacast-com.akamaized.net/717441a0f28e627c7d64f28827fd262f/source/index.m3u8",
        library:  "https://cdn-us-east-prod-ingest-infra-dacast-com.akamaized.net/cfa6d8a759fc6aedf7e8a04c4ad003e6/source/index.m3u8",
        special2: "https://cdn-us-east-prod-ingest-infra-dacast-com.akamaized.net/86d196fc-7e71-42df-c6f5-d1eafa67f0c1/index.m3u8"
    }
    streamUrl = streamUrls[contentId]
    if streamUrl = invalid then return

    channelData = { name: contentId, streamUrl: streamUrl }
    m.playerScreen.channelData = channelData
    m.playerScreen.visible = true
    m.homeScreen.visible = false
    m.playerScreen.setFocus(true)
end sub

' Live stream selected — pass channelData directly to PlayerScreen
sub onChannelSelected(event as Object)
    channelData = event.getData()
    if channelData = invalid then return

    m.playerLaunchedFrom = "home"
    m.playerScreen.channelData = channelData
    m.playerScreen.visible = true
    m.homeScreen.visible = false
    m.playerScreen.setFocus(true)
end sub

' VOD video selected — adapt video data to the channelData format PlayerScreen expects
sub onVideoSelected(event as Object)
    videoData = event.getData()
    if videoData = invalid then return

    channelData = {
        name:        videoData.title,
        streamUrl:   videoData.streamUrl,
        subtitleUrl: videoData.subtitleUrl
    }

    m.playerLaunchedFrom = "home"
    m.playerScreen.channelData = channelData
    m.playerScreen.visible = true
    m.homeScreen.visible = false
    m.playerScreen.setFocus(true)
end sub

' Search entry point tapped on HomeScreen — open SearchScreen
sub onSearchOpened(event as Object)
    opened = event.getData()
    if opened <> true then return

    m.homeScreen.visible = false
    m.searchScreen.visible = true
end sub

' VOD video selected from search results — same handoff as onVideoSelected
sub onSearchVideoSelected(event as Object)
    videoData = event.getData()
    if videoData = invalid then return

    channelData = {
        name:        videoData.title,
        streamUrl:   videoData.streamUrl,
        subtitleUrl: videoData.subtitleUrl
    }

    m.playerLaunchedFrom = "search"
    m.playerScreen.channelData = channelData
    m.playerScreen.visible = true
    m.searchScreen.visible = false
    m.playerScreen.setFocus(true)
end sub

' Back pressed on SearchScreen — return to HomeScreen
sub onSearchClosed(event as Object)
    closed = event.getData()
    if closed <> true then return

    m.searchScreen.visible = false
    m.homeScreen.visible = true
    m.homeScreen.setFocus(true)
end sub

sub onPlayerClosed(event as Object)
    m.playerScreen.visible = false
    if m.playerLaunchedFrom = "search"
        ' SearchScreen re-focuses its keyboard itself when it becomes visible
        ' again (see onVisibleChange) — don't overwrite that with a generic
        ' setFocus call here.
        m.searchScreen.visible = true
    else
        m.homeScreen.visible = true
        m.homeScreen.setFocus(true)
    end if
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    return false
end function
