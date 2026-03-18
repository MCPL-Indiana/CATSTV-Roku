' HomeScreen.brs - Channel selection + Recent Videos browsing
'
' Focus sections: "channels" | "city" | "county" | "community" | "catsweek"
'
' Vertical scroll (contentGroup.translation.y):
'   0     → live channels visible; banner at top
'   -528  → "MOST RECENT VIDEOS" at y=10; City Meetings at y=52
'   -714  → County Meetings at y=70
'   -918  → Community Videos at y=70
'   -1122 → CATSWeek at y=70
'
' All key events are handled here — child components are purely visual.

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
    m.cityFocusIndex      = 0
    m.countyFocusIndex    = 0
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

    ' ── Banner image ─────────────────────────────────────────────────────────
    bannerImage = m.top.findNode("bannerImage")
    if bannerImage <> invalid
        bannerImage.uri = "pkg:/images/channels_banner.jpg"
    end if

    ' ── Scrollable content group ─────────────────────────────────────────────
    m.contentGroup = m.top.findNode("contentGroup")

    ' ── Video row references ─────────────────────────────────────────────────
    m.cityRow      = m.top.findNode("cityRow")
    m.countyRow    = m.top.findNode("countyRow")
    m.communityRow = m.top.findNode("communityRow")
    m.catsweekRow  = m.top.findNode("catsweekRow")

    m.cityRow.sectionTitle      = "CITY MEETINGS"
    m.cityRow.iconImage         = "pkg:/images/section_city.png"
    m.countyRow.sectionTitle    = "COUNTY MEETINGS"
    m.countyRow.iconImage       = "pkg:/images/section_county.png"
    m.communityRow.sectionTitle = "COMMUNITY VIDEOS"
    m.communityRow.iconImage    = "pkg:/images/section_community.png"
    m.catsweekRow.sectionTitle  = "CATSWEEK"
    m.catsweekRow.iconImage     = "pkg:/images/section_catsweek.png"

    ' ── Scroll animation ─────────────────────────────────────────────────────
    m.scrollAnim   = m.top.findNode("scrollAnim")
    m.scrollInterp = m.top.findNode("scrollInterp")

    ' ── Initialize UI ────────────────────────────────────────────────────────
    updateChannelFocus()
    centerHeading()

    ' ── Kick off parallel JSON fetches ───────────────────────────────────────
    startVideoFetches()
end sub

sub centerHeading()
    watchLabel = m.top.findNode("watchCatsLabel")
    liveLabel  = m.top.findNode("liveHeadingLabel")

    watchWidth = watchLabel.boundingRect().width
    liveWidth  = liveLabel.boundingRect().width

    startX = int((1280 - watchWidth - liveWidth) / 2)
    watchLabel.translation = [startX, 222]
    liveLabel.translation  = [startX + watchWidth, 222]
end sub

sub startVideoFetches()
    m.cityTask = CreateObject("roSGNode", "FetchVideosTask")
    m.cityTask.observeField("result", "onCityResult")
    m.cityTask.url       = "https://3w.mcpl.info/catsjson/city.json"
    m.cityTask.sectionId = "city"
    m.cityTask.control   = "RUN"

    m.countyTask = CreateObject("roSGNode", "FetchVideosTask")
    m.countyTask.observeField("result", "onCountyResult")
    m.countyTask.url       = "https://3w.mcpl.info/catsjson/county.json"
    m.countyTask.sectionId = "county"
    m.countyTask.control   = "RUN"

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

' ── Task result callbacks ─────────────────────────────────────────────────────

sub onCityResult(event as Object)
    result = event.getData()
    if result <> invalid and result.videos <> invalid
        m.cityRow.videos = result.videos
    else
        m.cityRow.videos = []
    end if
end sub

sub onCountyResult(event as Object)
    result = event.getData()
    if result <> invalid and result.videos <> invalid
        m.countyRow.videos = result.videos
    else
        m.countyRow.videos = []
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

' ── Scroll animation helper ───────────────────────────────────────────────────

sub scrollTo(targetY as Float)
    from = m.contentGroup.translation
    m.scrollInterp.keyValue = [from, [0.0, targetY]]
    m.scrollAnim.control = "start"
end sub

' ── Channel card focus ────────────────────────────────────────────────────────

sub updateChannelFocus()
    for i = 0 to m.cards.count() - 1
        m.cards[i].isFocused = (i = m.channelFocusIndex)
    end for
end sub

' ── Section switching ─────────────────────────────────────────────────────────
' Each video section scrolls to place itself near the top of the screen.

sub setFocusSection(section as String)
    m.focusSection = section

    ' Defocus all channel cards
    for i = 0 to m.cards.count() - 1
        m.cards[i].isFocused = false
    end for
    ' Clear all video row focus
    m.cityRow.focusedIndex      = -1
    m.countyRow.focusedIndex    = -1
    m.communityRow.focusedIndex = -1
    m.catsweekRow.focusedIndex  = -1

    if section = "channels"
        scrollTo(0.0)
        updateChannelFocus()
    else if section = "city"
        scrollTo(-528.0)   ' "MOST RECENT VIDEOS" at y=10; City at y=52
        m.cityRow.focusedIndex = m.cityFocusIndex
    else if section = "county"
        scrollTo(-714.0)   ' County at y=70
        m.countyRow.focusedIndex = m.countyFocusIndex
    else if section = "community"
        scrollTo(-918.0)   ' Community at y=70
        m.communityRow.focusedIndex = m.communityFocusIndex
    else if section = "catsweek"
        scrollTo(-1122.0)  ' CATSWeek at y=70
        m.catsweekRow.focusedIndex = m.catsweekFocusIndex
    end if
end sub

' ── Key event handler ─────────────────────────────────────────────────────────

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
            setFocusSection("city")
            return true
        else if key = "OK" or key = "play"
            m.top.channelSelected = m.channels[m.channelFocusIndex]
            return true
        end if

    else if m.focusSection = "city"
        videos = m.cityRow.videos
        videoCount = 0
        if videos <> invalid then videoCount = videos.count()
        if key = "left"
            if m.cityFocusIndex > 0
                m.cityFocusIndex -= 1
                m.cityRow.focusedIndex = m.cityFocusIndex
            end if
            return true
        else if key = "right"
            if m.cityFocusIndex < videoCount - 1
                m.cityFocusIndex += 1
                m.cityRow.focusedIndex = m.cityFocusIndex
            end if
            return true
        else if key = "up"
            setFocusSection("channels")
            return true
        else if key = "down"
            setFocusSection("county")
            return true
        else if key = "OK" or key = "play"
            if videoCount > 0
                m.top.videoSelected = videos[m.cityFocusIndex]
            end if
            return true
        end if

    else if m.focusSection = "county"
        videos = m.countyRow.videos
        videoCount = 0
        if videos <> invalid then videoCount = videos.count()
        if key = "left"
            if m.countyFocusIndex > 0
                m.countyFocusIndex -= 1
                m.countyRow.focusedIndex = m.countyFocusIndex
            end if
            return true
        else if key = "right"
            if m.countyFocusIndex < videoCount - 1
                m.countyFocusIndex += 1
                m.countyRow.focusedIndex = m.countyFocusIndex
            end if
            return true
        else if key = "up"
            setFocusSection("city")
            return true
        else if key = "down"
            setFocusSection("community")
            return true
        else if key = "OK" or key = "play"
            if videoCount > 0
                m.top.videoSelected = videos[m.countyFocusIndex]
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
            setFocusSection("county")
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
