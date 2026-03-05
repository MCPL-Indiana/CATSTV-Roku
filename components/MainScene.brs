' MainScene.brs - Handles navigation between HomeScreen and PlayerScreen

sub init()
    m.homeScreen  = m.top.findNode("homeScreen")
    m.playerScreen = m.top.findNode("playerScreen")

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
            m.playerScreen.scale = [uiScale, uiScale]
        end if
    end if
    ' ─────────────────────────────────────────────────────────────────────────

    m.homeScreen.observeField("channelSelected", "onChannelSelected")
    m.homeScreen.observeField("videoSelected",   "onVideoSelected")
    m.playerScreen.observeField("playerClosed",  "onPlayerClosed")

    m.homeScreen.setFocus(true)
end sub

' Live stream selected — pass channelData directly to PlayerScreen
sub onChannelSelected(event as Object)
    channelData = event.getData()
    if channelData = invalid then return

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
        name:      videoData.title,
        streamUrl: videoData.streamUrl
    }

    m.playerScreen.channelData = channelData
    m.playerScreen.visible = true
    m.homeScreen.visible = false
    m.playerScreen.setFocus(true)
end sub

sub onPlayerClosed(event as Object)
    m.playerScreen.visible = false
    m.homeScreen.visible = true
    m.homeScreen.setFocus(true)
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    return false
end function
