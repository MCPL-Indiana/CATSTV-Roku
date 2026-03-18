' ChannelCard.brs - Channel card visual state management

sub init()
    m.cardBg       = m.top.findNode("cardBg")
    m.iconPoster   = m.top.findNode("iconPoster")
    m.nameLabel    = m.top.findNode("nameLabel")
    m.subtitleLabel = m.top.findNode("subtitleLabel")

    m.borderTop    = m.top.findNode("borderTop")
    m.borderBottom = m.top.findNode("borderBottom")
    m.borderLeft   = m.top.findNode("borderLeft")
    m.borderRight  = m.top.findNode("borderRight")

    ' Ensure wrap and numLines are set programmatically (XML attrs unreliable on some firmware)
    if m.subtitleLabel <> invalid
        m.subtitleLabel.wrap     = true
        m.subtitleLabel.numLines = 2
    end if
end sub

sub onDataChange()
    if m.nameLabel    <> invalid then m.nameLabel.text    = m.top.channelName
    if m.subtitleLabel <> invalid then m.subtitleLabel.text = m.top.channelSubtitle
    if m.iconPoster <> invalid and m.top.iconImage <> invalid and m.top.iconImage <> ""
        m.iconPoster.uri = m.top.iconImage
    end if
end sub

sub onFocusChange()
    if m.top.isFocused
        ' Focused: darker background, coral name, coral border
        m.cardBg.color       = "#4A5459FF"
        m.nameLabel.color    = "#FF5F62FF"
        m.borderTop.color    = "#FF5F62FF"
        m.borderBottom.color = "#FF5F62FF"
        m.borderLeft.color   = "#FF5F62FF"
        m.borderRight.color  = "#FF5F62FF"
    else
        ' Unfocused: medium gray background, white name, no border
        m.cardBg.color       = "#636D72FF"
        m.nameLabel.color    = "#FFFFFFFF"
        m.borderTop.color    = "#00000000"
        m.borderBottom.color = "#00000000"
        m.borderLeft.color   = "#00000000"
        m.borderRight.color  = "#00000000"
    end if
end sub
