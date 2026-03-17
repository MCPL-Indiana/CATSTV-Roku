' HomeScreen.brs - Channel selection + Recent Videos browsing
'
' Focus sections: "channels" | "gov" | "community" | "catsweek"
'
' Vertical scroll (contentGroup.translation.y):
'   0    → live channels visible; banner at top
'   -528 → "MOST RECENT VIDEOS" heading lands at y=10;
'           all three video rows fill y=52–692
'
' All key events are handled here — child components are purely visual.
' Video focus state is communicated via VideoRow.focusedIndex (integer field).

sub init()
    m.channels = [
        {
            id: "city",
            name: "CITY CHANNEL",
            subtitle: "Bloomington City Government",
            iconImage: "pkg:/images/icon_city.png",
            streamUrl: "https://cdn-us-east-prod-ingest-infra-dacast-com.akamaized.net/f8f183aa686dea8fded26ffa5475d3f5/source/index.m3u8"
        },
        {
            id: "county",
            name: "COUNTY CHANNEL",
            subtitle: "Monroe County Government",
            iconImage: "pkg:/images/icon_county.png",
            streamUrl: "https://cdn-us-east-prod-ingest-infra-dacast-com.akamaized.net/717441a0f28e627c7d64f28827fd262f/source/index.m3u8"
        },
        {
            id: "library",
            name: "LIBRARY CHANNEL",
            subtitle: "Monroe County Public Library",
            iconImage: "pkg:/images/icon_library.png",
            streamUrl: "https://cdn-us-east-prod-ingest-infra-dacast-com.akamaized.net/cfa6d8a759fc6aedf7e8a04c4ad003e6/source/index.m3u8"
        },
        {
            id: "special2",
            name: "SPECIAL 2",
            subtitle: "Special Programming",
            iconImage: "pkg:/images/icon_special.png",
            streamUrl: "https://cdn-us-east-prod-ingest-infra-dacast-com.akamaized.net/86d196fc-7e71-42df-c6f5-d1eafa67f0c1/index.m3u8"
        }
    ]

    m.channelFocusIndex   = 0
    m.govFocusIndex       = 0
    m.communityFocusIndex = 0
    m.catsweekFocusIndex  = 0
    m.focusSection        = "channels"

    ' ── Channel card references ──────────────────────────────────────────────
    m.cards = []
    for i = 0 to 3
        card = m.top.findNode("card" + i.toStr())
        card.channelName     = m.channels[i].name
        card.channelSubtitle = m.channels[i].subtitle
        card.iconImage       = m.channels[i].iconImage
        m.cards.push(card)
    end for

    ' ── Scrollable content group ─────────────────────────────────────────────
    m.contentGroup = m.top.findNode("contentGroup")

    ' ── Video row references ─────────────────────────────────────────────────
    m.govRow       = m.top.findNode("govRow")
    m.communityRow = m.top.findNode("communityRow")
    m.catsweekRow  = m.top.findNode("catsweekRow")

    m.govRow.sectionTitle       = "GOVERNMENT MEETINGS"
    m.govRow.iconImage          = "pkg:/images/icon_city.png"
    m.communityRow.sectionTitle = "COMMUNITY VIDEOS"
    m.communityRow.iconImage    = "pkg:/images/icon_community.png"
    m.catsweekRow.sectionTitle  = "CATSWEEK"
    m.catsweekRow.iconImage     = "pkg:/images/icon_catsweek.png"

    ' ── Banner image ─────────────────────────────────────────────────────────
    bannerImage = m.top.findNode("bannerImage")
    if bannerImage <> invalid
        bannerImage.uri = "pkg:/images/channels_banner.jpg"
    end if

    ' ── Scroll animation ─────────────────────────────────────────────────────
    m.scrollAnim   = m.top.findNode("scrollAnim")
    m.scrollInterp = m.top.findNode("scrollInterp")

    ' ── Initialize UI ────────────────────────────────────────────────────────
    updateChannelFocus()
    centerHeading()

    ' ── Kick off parallel JSON fetches ───────────────────────────────────────
    startVideoFetches()
end sub

' Center "WATCH CATS LIVE" by computing auto-width of each label
sub centerHeading()
    watchLabel = m.top.findNode("watchCatsLabel")
    liveLabel  = m.top.findNode("liveHeadingLabel")

    watchWidth = watchLabel.boundingRect().width
    liveWidth  = liveLabel.boundingRect().width

    startX = int((1280 - watchWidth - liveWidth) / 2)
    watchLabel.translation = [startX, 222]
    liveLabel.translation  = [startX + watchWidth, 222]
end sub

' Launch three background Task nodes in parallel (one per JSON feed)
sub startVideoFetches()
    m.govTask = CreateObject("roSGNode", "FetchVideosTask")
    m.govTask.observeField("result", "onGovResult")
    m.govTask.url       = "https://3w.mcpl.info/catsjson/city.json"
    m.govTask.sectionId = "gov"
    m.govTask.control   = "RUN"

    m.communityTask = CreateObject("roSGNode", "FetchVideosTask")
    m.communityTask.observeField("result", "onCommunityResult")
    m.communityTask.url       = "https://3w.mcpl.info/catsjson/community.json"
    m.communityTask.sectionId = "community"
    m.communityTask.control   = "RUN"

    m.catsweekTask = CreateObject("roSGNode", "FetchVideosTask")
    m.catsweekTask.observeField("result", "onCatsweekResult")
    m.catsweekTask.url       = "https://3w.mcpl.info/catsjson/catsweek.json"
    m.catsweekTask.sectionId = "catsweek"
    m.catsweekTask.control   = "RUN"
end sub

' ── Task result callbacks (called on render thread via observeField) ─────────

sub onGovResult(event as Object)
    result = event.getData()
    if result <> invalid and result.videos <> invalid
        m.govRow.videos = result.videos
    else
        m.govRow.videos = []
    end if
end sub

sub onCommunityResult(event as Object)
    result = event.getData()
    if result <> invalid and result.videos <> invalid
        m.communityRow.videos = result.videos
    else
        m.communityRow.videos = []
    end if
end sub

sub onCatsweekResult(event as Object)
    result = event.getData()
    if result <> invalid and result.videos <> invalid
        m.catsweekRow.videos = result.videos
    else
        m.catsweekRow.videos = []
    end if
end sub

' ── Scroll animation helper ──────────────────────────────────────────────────

sub scrollTo(targetY as Float)
    from = m.contentGroup.translation
    m.scrollInterp.keyValue = [from, [0.0, targetY]]
    m.scrollAnim.control = "start"
end sub

' ── Channel card focus ───────────────────────────────────────────────────────

sub updateChannelFocus()
    for i = 0 to m.cards.count() - 1
        m.cards[i].isFocused = (i = m.channelFocusIndex)
    end for
end sub

' ── Section switching ────────────────────────────────────────────────────────
' Scrolls the content group and updates focus indicators across all rows.

sub setFocusSection(section as String)
    m.focusSection = section

    if section = "channels"
        scrollTo(0.0)
        updateChannelFocus()
        m.govRow.focusedIndex       = -1
        m.communityRow.focusedIndex = -1
        m.catsweekRow.focusedIndex  = -1
    else
        scrollTo(-528.0)

        ' Defocus all channel cards
        for i = 0 to m.cards.count() - 1
            m.cards[i].isFocused = false
        end for

        ' Apply focused card index to the active row; deselect the others
        if section = "gov"
            m.govRow.focusedIndex       = m.govFocusIndex
            m.communityRow.focusedIndex = -1
            m.catsweekRow.focusedIndex  = -1
        else if section = "community"
            m.govRow.focusedIndex       = -1
            m.communityRow.focusedIndex = m.communityFocusIndex
            m.catsweekRow.focusedIndex  = -1
        else if section = "catsweek"
            m.govRow.focusedIndex       = -1
            m.communityRow.focusedIndex = -1
            m.catsweekRow.focusedIndex  = m.catsweekFocusIndex
        end if
    end if
end sub

' ── Key event handler ────────────────────────────────────────────────────────

function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return false

    if m.focusSection = "channels"
        if key = "left"
            if m.channelFocusIndex > 0
                m.channelFocusIndex -= 1
                updateChannelFocus()
            end if
            return true

        else if key = "right"
            if m.channelFocusIndex < m.channels.count() - 1
                m.channelFocusIndex += 1
                updateChannelFocus()
            end if
            return true

        else if key = "down"
            setFocusSection("gov")
            return true

        else if key = "OK" or key = "play"
            m.top.channelSelected = m.channels[m.channelFocusIndex]
            return true
        end if

    else if m.focusSection = "gov"
        videos = m.govRow.videos
        videoCount = 0
        if videos <> invalid then videoCount = videos.count()

        if key = "left"
            if m.govFocusIndex > 0
                m.govFocusIndex -= 1
                m.govRow.focusedIndex = m.govFocusIndex
            end if
            return true

        else if key = "right"
            if m.govFocusIndex < videoCount - 1
                m.govFocusIndex += 1
                m.govRow.focusedIndex = m.govFocusIndex
            end if
            return true

        else if key = "up"
            setFocusSection("channels")
            return true

        else if key = "down"
            setFocusSection("community")
            return true

        else if key = "OK" or key = "play"
            if videoCount > 0
                m.top.videoSelected = videos[m.govFocusIndex]
            end if
            return true
        end if

    else if m.focusSection = "community"
        videos = m.communityRow.videos
        videoCount = 0
        if videos <> invalid then videoCount = videos.count()

        if key = "left"
            if m.communityFocusIndex > 0
                m.communityFocusIndex -= 1
                m.communityRow.focusedIndex = m.communityFocusIndex
            end if
            return true

        else if key = "right"
            if m.communityFocusIndex < videoCount - 1
                m.communityFocusIndex += 1
                m.communityRow.focusedIndex = m.communityFocusIndex
            end if
            return true

        else if key = "up"
            setFocusSection("gov")
            return true

        else if key = "down"
            setFocusSection("catsweek")
            return true

        else if key = "OK" or key = "play"
            if videoCount > 0
                m.top.videoSelected = videos[m.communityFocusIndex]
            end if
            return true
        end if

    else if m.focusSection = "catsweek"
        videos = m.catsweekRow.videos
        videoCount = 0
        if videos <> invalid then videoCount = videos.count()

        if key = "left"
            if m.catsweekFocusIndex > 0
                m.catsweekFocusIndex -= 1
                m.catsweekRow.focusedIndex = m.catsweekFocusIndex
            end if
            return true

        else if key = "right"
            if m.catsweekFocusIndex < videoCount - 1
                m.catsweekFocusIndex += 1
                m.catsweekRow.focusedIndex = m.catsweekFocusIndex
            end if
            return true

        else if key = "up"
            setFocusSection("community")
            return true

        ' No "down" from catsweek — bottom of content

        else if key = "OK" or key = "play"
            if videoCount > 0
                m.top.videoSelected = videos[m.catsweekFocusIndex]
            end if
            return true
        end if
    end if

    return false
end function
