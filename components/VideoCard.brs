' VideoCard.brs - Video thumbnail card visual state management

sub init()
    m.focusBorder = m.top.findNode("focusBorder")
    m.cardBg      = m.top.findNode("cardBg")
    m.titleBg     = m.top.findNode("titleBg")
    m.titleLabel  = m.top.findNode("titleLabel")
    m.thumb       = m.top.findNode("thumb")
end sub

sub onTitleChange()
    m.titleLabel.text = m.top.videoTitle
end sub

sub onThumbChange()
    if m.top.thumbnailUrl <> ""
        m.thumb.uri = m.top.thumbnailUrl
    end if
end sub

sub onFocusChange()
    if m.top.isFocused
        ' Focused: coral border + darker background
        m.focusBorder.color = "#FF5F62FF"
        m.cardBg.color      = "#4A5459FF"
        m.titleBg.color     = "#4A5459FF"
    else
        ' Unfocused: no border + medium gray background
        m.focusBorder.color = "#00000000"
        m.cardBg.color      = "#636D72FF"
        m.titleBg.color     = "#636D72FF"
    end if
end sub
