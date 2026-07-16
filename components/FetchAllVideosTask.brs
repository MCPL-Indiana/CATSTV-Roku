' FetchAllVideosTask.brs - Downloads the cumulative video archive index for search
'
' Mirrors tvOS VideoSearchService: tries the cumulative "all.json" index first
' (one request covering the whole archive). If that's unavailable or fails to
' parse, falls back to combining the four per-section feeds so search still
' works over whatever the app can see.

sub init()
    m.top.functionName = "fetchAllVideos"
end sub

sub fetchAllVideos()
    videos = fetchIndex("https://3w.mcpl.info/catsjson/all.json")

    if videos = invalid or videos.count() = 0
        videos = fetchCombinedFeeds()
    end if

    if videos = invalid
        m.top.result = { videos: invalid, error: "Network error" }
        return
    end if

    m.top.result = { videos: videos }
end sub

function fetchCombinedFeeds() as Object
    urls = [
        "https://3w.mcpl.info/catsjson/city.json",
        "https://3w.mcpl.info/catsjson/county.json",
        "https://3w.mcpl.info/catsjson/community.json",
        "https://3w.mcpl.info/catsjson/catsweek.json"
    ]

    combined = []
    seen = {}

    for each url in urls
        videos = fetchIndex(url)
        if videos <> invalid
            for each video in videos
                if seen[video.streamUrl] = invalid
                    seen[video.streamUrl] = true
                    combined.push(video)
                end if
            end for
        end if
    end for

    if combined.count() = 0 then return invalid
    return combined
end function

' Downloads and parses a single CATS JSON feed. Decodes leniently — a
' malformed record is skipped rather than discarding the whole feed.
function fetchIndex(url as String) as Object
    http = CreateObject("roUrlTransfer")
    http.SetUrl(url)
    http.AddHeader("User-Agent", "Roku/CatsTV")

    response = http.GetToString()
    if response = "" or response = invalid then return invalid

    ' Strip UTF-8 BOM (U+FEFF) if the server included one
    if Left(response, 1) = Chr(65279)
        response = Mid(response, 2)
    end if

    jsonObj = ParseJson(response)
    if jsonObj = invalid then return invalid

    baseUrl = "https://catstv.blob.core.windows.net/videoarchive/"
    videos = []
    seen = {}

    for each item in jsonObj
        if item <> invalid and item.title <> invalid and item["data-m4v"] <> invalid
            m4v = item["data-m4v"]
            if seen[m4v] = invalid
                seen[m4v] = true

                thumb = item["thumbnail"]
                if thumb = invalid then thumb = ""

                vtt = item["data-vtt"]
                subtitleUrl = ""
                if vtt <> invalid and vtt <> "" then subtitleUrl = baseUrl + vtt

                videos.push({
                    title:        item.title,
                    streamUrl:    baseUrl + m4v,
                    thumbnailUrl: baseUrl + thumb,
                    subtitleUrl:  subtitleUrl
                })
            end if
        end if
    end for

    if videos.count() = 0 then return invalid
    return videos
end function
