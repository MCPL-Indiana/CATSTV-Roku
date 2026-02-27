' PlayerScreen.brs - HLS video playback logic
'
' Mirrors tvOS LiveStreamPlayerView: loads the HLS .m3u8 URL into a Roku Video node,
' shows a loading state while buffering, then reveals the channel name / LIVE overlay.
' Coordinate space: HD 1280x720 (ui_resolution=HD).
' BACK key stops the video and signals MainScene to return to HomeScreen.

sub init()
    m.video            = m.top.findNode("video")
    m.loadingLabel     = m.top.findNode("loadingLabel")
    m.overlayBg        = m.top.findNode("overlayBg")
    m.channelNameLabel = m.top.findNode("channelNameLabel")
    m.liveDot          = m.top.findNode("liveDot")
    m.liveLabel        = m.top.findNode("liveLabel")

    m.video.observeField("state", "onVideoStateChange")
end sub

sub onChannelDataChange()
    channelData = m.top.channelData
    if channelData = invalid then return

    ' Update overlay label
    m.channelNameLabel.text = channelData.name

    ' Show loading state, hide overlay
    m.loadingLabel.text    = "Loading " + channelData.name + " Live Stream..."
    m.loadingLabel.visible = true
    showOverlay(false)

    ' Build the ContentNode for this HLS stream
    content = CreateObject("roSGNode", "ContentNode")
    content.url          = channelData.streamUrl
    content.streamformat = "hls"
    content.title        = channelData.name

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
        m.loadingLabel.text    = "Error loading stream. Press BACK to return."
        m.loadingLabel.visible = true
        showOverlay(false)
    end if
end sub

' Toggle the channel name / LIVE indicator overlay
sub showOverlay(visible as Boolean)
    m.overlayBg.visible        = visible
    m.channelNameLabel.visible = visible
    m.liveDot.visible          = visible
    m.liveLabel.visible        = visible
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
