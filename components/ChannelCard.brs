' ChannelCard.brs - Full-image channel card

sub init()
    m.cardPoster   = m.top.findNode("cardPoster")
    m.borderTop    = m.top.findNode("borderTop")
    m.borderBottom = m.top.findNode("borderBottom")
    m.borderLeft   = m.top.findNode("borderLeft")
    m.borderRight  = m.top.findNode("borderRight")
end sub

sub onDataChange()
    if m.cardPoster <> invalid and m.top.iconImage <> invalid and m.top.iconImage <> ""
        m.cardPoster.uri = m.top.iconImage
    end if
end sub

sub onFocusChange()
    if m.top.isFocused
        m.borderTop.color    = "#FF5F62FF"
        m.borderBottom.color = "#FF5F62FF"
        m.borderLeft.color   = "#FF5F62FF"
        m.borderRight.color  = "#FF5F62FF"
    else
        m.borderTop.color    = "#00000000"
        m.borderBottom.color = "#00000000"
        m.borderLeft.color   = "#00000000"
        m.borderRight.color  = "#00000000"
    end if
end sub
