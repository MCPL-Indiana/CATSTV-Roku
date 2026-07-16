' SearchScreen.brs - Full-archive video search logic (mirrors tvOS VideoSearchView)
'
' Layout: the keyboard sits at the top and the results grid below it, both inside
' contentGroup. Scrolling down through the grid translates contentGroup up, which
' carries the keyboard off the top of the screen. Nothing is clipped — content
' scrolled past y=0 simply leaves the screen — so cards can never draw over the
' keyboard the way they did when the grid scrolled inside a fixed clip region.
'
' The Keyboard node's rendered size isn't documented per resolution, so it's
' measured at runtime and everything below is placed relative to its real bottom
' edge (see layoutBelowKeyboard).
'
' m.focusArea: "keyboard" | "grid" — SceneGraph focus moves between m.keyboard
' and m.resultsGroup to match; resultsGroup has no onKeyEvent of its own, so
' events bubble up to this component's onKeyEvent, which drives the grid.

sub init()
    m.contentGroup = m.top.findNode("contentGroup")
    m.keyboard     = m.top.findNode("keyboard")
    m.statusLabel  = m.top.findNode("statusLabel")
    m.separator    = m.top.findNode("separator")
    m.resultsGroup = m.top.findNode("resultsGroup")
    m.scrollAnim   = m.top.findNode("scrollAnim")
    m.scrollInterp = m.top.findNode("scrollInterp")

    m.keyboardTop = 48

    ' Card grid: 4 across, matching the home screen rows.
    ' 60 + 3*294 + 270 = 1212, inside the 1220 right margin.
    m.columns    = 4
    m.cardWidth  = 270
    m.cardHeight = 170
    m.cardStepX  = 294
    m.cardStepY  = 200
    m.bottomPad  = 16
    m.topPad     = 16

    m.allVideos      = invalid
    m.lastFetchTime  = invalid
    m.cacheLifetime  = 15 * 60 ' seconds

    m.results        = []
    m.matchCount     = 0
    m.maxResults     = 60
    m.cards          = []
    m.gridFocusIndex = 0
    m.scrollOffset   = 0
    m.focusArea      = "keyboard"

    layoutBelowKeyboard()

    m.keyboard.observeField("text", "onSearchTextChange")
    m.top.observeField("visible", "onVisibleChange")

    updateStatusLabel()
end sub

' Centre the keyboard and stack the separator / status / grid underneath it,
' using the keyboard's measured size. Falls back to its typical HD footprint if
' the node hasn't been measured yet.
sub layoutBelowKeyboard()
    rect = m.keyboard.localBoundingRect()

    kbWidth = 0
    kbHeight = 0
    if rect <> invalid
        kbWidth  = rect.width
        kbHeight = rect.height
    end if
    if kbWidth <= 0 then kbWidth = 692
    if kbHeight <= 0 then kbHeight = 310

    kbX = int((1280 - kbWidth) / 2)
    if kbX < 0 then kbX = 0
    m.keyboard.translation = [kbX, m.keyboardTop]

    separatorY = m.keyboardTop + kbHeight + 14
    m.separator.translation = [60, separatorY]
    m.separator.visible     = true

    statusY = separatorY + 10
    m.statusLabel.translation = [60, statusY]

    m.gridTop = statusY + 32
    m.resultsGroup.translation = [60, m.gridTop]
end sub

sub onVisibleChange()
    if m.top.visible
        m.focusArea = "keyboard"
        resetScroll()
        m.keyboard.setFocus(true)
        ensureVideosLoaded()
    end if
end sub

' ── Video archive loading (cached 15 min) ────────────────────────────────────

sub ensureVideosLoaded()
    if m.allVideos <> invalid and m.lastFetchTime <> invalid
        now = CreateObject("roDateTime")
        elapsed = now.AsSeconds() - m.lastFetchTime.AsSeconds()
        if elapsed < m.cacheLifetime
            updateResults()
            return
        end if
    end if

    m.statusLabel.text = "Loading video archive..."
    task = CreateObject("roSGNode", "FetchAllVideosTask")
    task.observeField("result", "onAllVideosResult")
    task.control = "RUN"
    m.fetchTask = task
end sub

sub onAllVideosResult(event as Object)
    result = event.getData()
    if result <> invalid and result.videos <> invalid
        m.allVideos     = result.videos
        m.lastFetchTime = CreateObject("roDateTime")
    else
        m.allVideos = []
    end if
    updateResults()
end sub

' ── Search filtering ──────────────────────────────────────────────────────────

sub onSearchTextChange()
    updateResults()
end sub

sub updateResults()
    tokens = splitTokens(m.keyboard.text)

    if m.allVideos = invalid or tokens.count() = 0
        m.results    = []
        m.matchCount = 0
    else
        filtered = []
        matchCount = 0
        for each video in m.allVideos
            haystack = LCase(video.title)
            matchesAll = true
            for each token in tokens
                if Instr(1, haystack, token) = 0
                    matchesAll = false
                    exit for
                end if
            end for
            if matchesAll
                matchCount += 1
                ' Cap rendered cards — the archive holds thousands of videos and
                ' a short query can match hundreds. Building that many VideoCard
                ' nodes on every keystroke would stall the grid, so only the
                ' first m.maxResults are shown.
                if filtered.count() < m.maxResults then filtered.push(video)
            end if
        end for
        m.results    = filtered
        m.matchCount = matchCount
    end if

    rebuildGrid()
    updateStatusLabel()
end sub

function splitTokens(text as String) as Object
    tokens = []
    if text = invalid then return tokens
    parts = text.Split(" ")
    for each part in parts
        trimmed = LCase(part.Trim())
        if trimmed <> "" then tokens.push(trimmed)
    end for
    return tokens
end function

sub updateStatusLabel()
    text = m.keyboard.text
    if text = invalid then text = ""

    if m.allVideos = invalid
        m.statusLabel.text = "Loading video archive..."
    else if text.Trim() = ""
        m.statusLabel.text = "Search " + m.allVideos.count().toStr() + " videos"
    else if m.results.count() = 0
        quote = Chr(34)
        m.statusLabel.text = "No videos match " + quote + text + quote
    else if m.matchCount > m.results.count()
        m.statusLabel.text = "Showing " + m.results.count().toStr() + " of " + m.matchCount.toStr() + " results"
    else if m.results.count() = 1
        m.statusLabel.text = "1 result"
    else
        m.statusLabel.text = m.results.count().toStr() + " results"
    end if
end sub

' ── Results grid ───────────────────────────────────────────────────────────────

sub rebuildGrid()
    while m.resultsGroup.getChildCount() > 0
        m.resultsGroup.removeChildIndex(0)
    end while
    m.cards = []

    for i = 0 to m.results.count() - 1
        video = m.results[i]
        card = CreateObject("roSGNode", "VideoCard")
        card.videoTitle   = video.title
        card.thumbnailUrl = video.thumbnailUrl
        card.isFocused    = false

        col = i mod m.columns
        row = i \ m.columns
        card.translation = [col * m.cardStepX, row * m.cardStepY]

        m.resultsGroup.appendChild(card)
        m.cards.push(card)
    end for

    if m.gridFocusIndex >= m.results.count()
        m.gridFocusIndex = m.results.count() - 1
    end if
    if m.gridFocusIndex < 0 then m.gridFocusIndex = 0

    ' A fresh query re-flows the grid, so snap back to the keyboard's view
    ' rather than leaving the user scrolled into empty space.
    resetScroll()

    if m.focusArea = "grid"
        updateGridFocus()
    end if
end sub

sub updateGridFocus()
    if m.cards.count() = 0 then return
    for i = 0 to m.cards.count() - 1
        m.cards[i].isFocused = (i = m.gridFocusIndex)
    end for
    scrollToRow(m.gridFocusIndex \ m.columns)
end sub

sub clearGridFocus()
    for i = 0 to m.cards.count() - 1
        m.cards[i].isFocused = false
    end for
end sub

' ── Scrolling ─────────────────────────────────────────────────────────────────
' contentGroup holds the keyboard AND the grid, so these offsets slide the
' keyboard off the top as the user works down the results.

sub resetScroll()
    m.scrollOffset = 0
    m.contentGroup.translation = [0, 0]
end sub

sub scrollTo(targetY as Float)
    from = m.contentGroup.translation
    m.scrollInterp.keyValue = [from, [0.0, targetY]]
    m.scrollAnim.control = "start"
end sub

sub scrollToRow(row as Integer)
    ' Row 0 always parks at the top of the scroll, keeping the whole keyboard on
    ' screen — and bringing it back when the user walks up out of the results.
    if row <= 0
        offset = 0
    else
        offset = m.scrollOffset
        rowTop    = m.gridTop + row * m.cardStepY
        rowBottom = rowTop + m.cardHeight

        ' Pull up just far enough to reveal the row's bottom edge...
        if rowBottom + m.bottomPad - offset > 720
            offset = rowBottom + m.bottomPad - 720
        end if
        ' ...and back down if the row sits above the top of the screen, leaving a
        ' little headroom so it isn't flush against the edge when walking back up.
        if rowTop - offset < m.topPad
            offset = rowTop - m.topPad
        end if
        if offset < 0 then offset = 0
    end if

    if offset <> m.scrollOffset
        m.scrollOffset = offset
        scrollTo(-offset)
    end if
end sub

' ── Key event handler ─────────────────────────────────────────────────────────

function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return false

    if key = "back"
        m.top.closed = true
        return true
    end if

    if m.focusArea = "keyboard"
        if key = "down" and m.results.count() > 0
            m.focusArea = "grid"
            updateGridFocus()
            m.resultsGroup.setFocus(true)
            return true
        end if
        return false
    end if

    ' m.focusArea = "grid"
    if key = "up"
        if m.gridFocusIndex < m.columns
            m.focusArea = "keyboard"
            clearGridFocus()
            resetScroll()
            m.keyboard.setFocus(true)
        else
            m.gridFocusIndex -= m.columns
            updateGridFocus()
        end if
        return true
    else if key = "down"
        if m.gridFocusIndex + m.columns < m.results.count()
            m.gridFocusIndex += m.columns
            updateGridFocus()
        end if
        return true
    else if key = "left"
        if m.gridFocusIndex > 0
            m.gridFocusIndex -= 1
            updateGridFocus()
        end if
        return true
    else if key = "right"
        if m.gridFocusIndex < m.results.count() - 1
            m.gridFocusIndex += 1
            updateGridFocus()
        end if
        return true
    else if key = "OK" or key = "play"
        if m.results.count() > 0
            m.top.videoSelected = m.results[m.gridFocusIndex]
        end if
        return true
    end if

    return false
end function
