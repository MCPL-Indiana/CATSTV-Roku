' VideoRow.brs - Horizontal video card row logic
'
' Focus is driven externally: HomeScreen sets focusedIndex to highlight a card.
' The row handles its own horizontal scroll to keep the focused card visible.

sub init()
    m.iconLabel         = m.top.findNode("iconLabel")
    m.sectionTitleLabel = m.top.findNode("sectionTitleLabel")
    m.loadingLabel      = m.top.findNode("loadingLabel")
    m.errorLabel        = m.top.findNode("errorLabel")
    m.cardsGroup        = m.top.findNode("cardsGroup")

    m.cards        = []
    m.scrollOffset = 0

    ' Card step: 240px wide + 24px gap = 264px
    m.cardStep     = 264
    m.cardWidth    = 240
    m.visibleWidth = 1160
end sub

sub onMetaChange()
    if m.top.iconLetter <> invalid
        m.iconLabel.text = m.top.iconLetter
    end if
    if m.top.sectionTitle <> invalid
        m.sectionTitleLabel.text = m.top.sectionTitle
    end if
end sub

sub onVideosChange()
    videos = m.top.videos

    ' Clear existing cards
    while m.cardsGroup.getChildCount() > 0
        m.cardsGroup.removeChildIndex(0)
    end while
    m.cards        = []
    m.scrollOffset = 0
    m.cardsGroup.translation = [0, 0]

    if videos = invalid or videos.count() = 0
        m.loadingLabel.visible = false
        m.errorLabel.text      = "No videos available"
        m.errorLabel.visible   = true
        return
    end if

    m.loadingLabel.visible = false
    m.errorLabel.visible   = false

    for i = 0 to videos.count() - 1
        card = CreateObject("roSGNode", "VideoCard")
        card.videoTitle   = videos[i].title
        card.thumbnailUrl = videos[i].thumbnailUrl
        card.isFocused    = false
        card.translation  = [i * m.cardStep, 0]
        m.cardsGroup.appendChild(card)
        m.cards.push(card)
    end for

    ' Apply current focus state if the row is already focused when data arrives
    if m.top.focusedIndex >= 0
        onFocusedIndexChange()
    end if
end sub

sub onFocusedIndexChange()
    idx = m.top.focusedIndex
    if m.cards.count() = 0 then return

    for i = 0 to m.cards.count() - 1
        m.cards[i].isFocused = (i = idx)
    end for

    if idx >= 0
        scrollToCard(idx)
    end if
end sub

' Translate cardsGroup so that card at idx is fully within the visible area
sub scrollToCard(idx as Integer)
    cardX = idx * m.cardStep

    ' Scroll right: card right edge beyond visible right edge
    if cardX + m.cardWidth > m.scrollOffset + m.visibleWidth
        m.scrollOffset = cardX + m.cardWidth - m.visibleWidth
    end if

    ' Scroll left: card left edge before visible left edge
    if cardX < m.scrollOffset
        m.scrollOffset = cardX
    end if

    m.cardsGroup.translation = [-m.scrollOffset, 0]
end sub
