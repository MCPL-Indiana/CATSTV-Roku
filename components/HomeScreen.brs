' HomeScreen.brs - Channel selection logic
'
' Channels mirror Channel.allChannels from the tvOS app.
' D-pad left/right moves focus; OK/Play selects and notifies MainScene.

sub init()
    nl = chr(10)
    m.channels = [
        {
            id: "city",
            name: "CITY CHANNEL",
            subtitle: "Bloomington City" + nl + "Government",
            iconText: "C",
            streamUrl: "https://cdn-us-east-prod-ingest-infra-dacast-com.akamaized.net/f8f183aa686dea8fded26ffa5475d3f5/source/index.m3u8"
        },
        {
            id: "county",
            name: "COUNTY CHANNEL",
            subtitle: "Monroe County" + nl + "Government",
            iconText: "M",
            streamUrl: "https://cdn-us-east-prod-ingest-infra-dacast-com.akamaized.net/717441a0f28e627c7d64f28827fd262f/source/index.m3u8"
        },
        {
            id: "library",
            name: "LIBRARY CHANNEL",
            subtitle: "Monroe County" + nl + "Public Library",
            iconText: "L",
            streamUrl: "https://cdn-us-east-prod-ingest-infra-dacast-com.akamaized.net/cfa6d8a759fc6aedf7e8a04c4ad003e6/source/index.m3u8"
        },
        {
            id: "special2",
            name: "SPECIAL 2",
            subtitle: "Special" + nl + "Programming",
            iconText: "S",
            streamUrl: "https://cdn-us-east-prod-ingest-infra-dacast-com.akamaized.net/86d196fc-7e71-42df-c6f5-d1eafa67f0c1/index.m3u8"
        }
    ]

    m.focusIndex = 0

    ' Cache card node references and populate data
    m.cards = []
    for i = 0 to 3
        card = m.top.findNode("card" + i.toStr())
        card.channelName = m.channels[i].name
        card.iconText = m.channels[i].iconText
        m.cards.push(card)
    end for

    updateFocus()
    centerHeading()
end sub

' Dynamically center "WATCH CATS LIVE" by measuring each auto-width label
' and computing a start x so the combined text sits at screen center (x=640).
sub centerHeading()
    watchLabel = m.top.findNode("watchCatsLabel")
    liveLabel  = m.top.findNode("liveHeadingLabel")

    watchWidth = watchLabel.boundingRect().width
    liveWidth  = liveLabel.boundingRect().width

    startX = int((1280 - watchWidth - liveWidth) / 2)
    watchLabel.translation = [startX, 153]
    liveLabel.translation  = [startX + watchWidth, 153]
end sub

' Highlight the focused card and dim the others
sub updateFocus()
    for i = 0 to m.cards.count() - 1
        m.cards[i].isFocused = (i = m.focusIndex)
    end for
    m.cards[m.focusIndex].setFocus(true)
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return false

    if key = "left"
        if m.focusIndex > 0
            m.focusIndex -= 1
            updateFocus()
        end if
        return true

    else if key = "right"
        if m.focusIndex < m.channels.count() - 1
            m.focusIndex += 1
            updateFocus()
        end if
        return true

    else if key = "OK" or key = "play"
        m.top.channelSelected = m.channels[m.focusIndex]
        return true
    end if

    return false
end function
