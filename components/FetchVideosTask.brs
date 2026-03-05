' FetchVideosTask.brs - Downloads and parses a video JSON feed
'
' Runs on a separate Task thread so it never blocks the render thread.
' The JSON format mirrors the CATS library feeds used by the tvOS app:
'   [ { "title": "...", "data-m4v": "file.m4v", "thumbnail": "file-thumbnail.jpg" }, ... ]
' All video/thumbnail files live under the Azure Blob Storage base URL.

sub init()
    m.top.functionName = "fetchVideos"
end sub

sub fetchVideos()
    url = m.top.url
    if url = "" or url = invalid then return

    http = CreateObject("roUrlTransfer")
    http.SetUrl(url)
    http.AddHeader("User-Agent", "Roku/CatsTV")
    http.EnableFreshConnection(true)

    response = http.GetToString()

    if response = "" or response = invalid
        m.top.result = { sectionId: m.top.sectionId, videos: invalid, error: "Network error" }
        return
    end if

    jsonObj = ParseJson(response)
    if jsonObj = invalid
        m.top.result = { sectionId: m.top.sectionId, videos: invalid, error: "Parse error" }
        return
    end if

    baseUrl = "https://catstv.blob.core.windows.net/videoarchive/"
    videos = []

    for each item in jsonObj
        if item <> invalid and item.title <> invalid and item["data-m4v"] <> invalid
            thumb = item["thumbnail"]
            if thumb = invalid then thumb = ""

            video = {
                title:        item.title,
                streamUrl:    baseUrl + item["data-m4v"],
                thumbnailUrl: baseUrl + thumb
            }
            videos.push(video)
        end if
    end for

    m.top.result = { sectionId: m.top.sectionId, videos: videos }
end sub
