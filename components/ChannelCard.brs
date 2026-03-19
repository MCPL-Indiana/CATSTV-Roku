' ChannelCard.brs - Full-image channel card

sub init()
    m.cardPoster  = m.top.findNode("cardPoster")
    m.focusBorder = m.top.findNode("focusBorder")
end sub

sub onDataChange()
    if m.cardPoster <> invalid and m.top.iconImage <> invalid and m.top.iconImage <> ""
        m.cardPoster.uri = m.top.iconImage
    end if
end sub

sub onFocusChange()
    m.focusBorder.visible = m.top.isFocused
end sub
