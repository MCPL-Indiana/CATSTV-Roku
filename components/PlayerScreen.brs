' PlayerScreen.brs - Video playback logic (live HLS streams + on-demand M4V)
'
' Mirrors tvOS LiveStreamPlayerView / CityMeetingPlayerView: loads a URL into a
' Roku Video node, shows a loading state while buffering, then reveals the title overlay.
' Stream format is auto-detected: .m3u8 → HLS (live), everything else → MP4 (VOD).
' Coordinate space: HD 1280x720 (ui_resolution=HD).
' BACK key stops the video and signals MainScene to return to HomeScreen.

sub init()
    m.video            = m.top.findNode("video")
    m.loadingLabel     = m.top.findNode("loadingLabel")
    m.overlayBg        = m.top.findNode("overlayBg")
    m.channelNameLabel = m.top.findNode("channelNameLabel")

    m.video.observeField("state", "onVideoStateChange")
end sub

sub onChannelDataChange()
    channelData = m.top.channelData
    if channelData = invalid then return

    ' Update overlay label
    m.channelNameLabel.text = channelData.name

    ' Show loading state, hide overlay
    m.loadingLabel.text    = "Loading " + channelData.name + "..."
    m.loadingLabel.visible = true
    showOverlay(false)

    ' Build the ContentNode — detect stream format from URL
    content = CreateObject("roSGNode", "ContentNode")
    content.url   = channelData.streamUrl
    content.title = channelData.name

    ' HLS for live .m3u8 streams; MP4 for on-demand .m4v / .mp4 files
    if channelData.streamUrl.inStr(".m3u8") >= 0
        content.streamformat = "hls"
    else
        content.streamformat = "mp4"
    end if

    m.video.content = content
    m.video.control = "play"
    m.video.setFocus(true)
end sub

sub onVideoStateChange()
    state = m.video.state

    if state = "playing"
        m.loadingLabel.visible = false
        showOverlay(true)

    else if state = "buffering"
        m.loadingLabel.text    = "Buffering..."
        m.loadingLabel.visible = true
        showOverlay(false)

    else if state = "error"
        m.loadingLabel.text    = "Error loading stream."
        m.loadingLabel.visible = true
        showOverlay(false)
    end if
end sub

' Toggle the channel name overlay
sub showOverlay(visible as Boolean)
    m.overlayBg.visible        = visible
    m.channelNameLabel.visible = visible
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return false

    if key = "back"
        m.video.control  = "stop"
        m.video.content  = invalid
        m.top.playerClosed = true
        return true
    end if

    return false
end function
