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
    m.focusBorder.visible = m.top.isFocused
    if m.top.isFocused
        m.cardBg.color  = "#4A5459FF"
        m.titleBg.color = "#4A5459FF"
    else
        m.cardBg.color  = "#636D72FF"
        m.titleBg.color = "#636D72FF"
    end if
end sub
