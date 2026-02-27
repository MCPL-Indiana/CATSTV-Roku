' MainScene.brs - Handles navigation between HomeScreen and PlayerScreen

sub init()
    m.homeScreen = m.top.findNode("homeScreen")
    m.playerScreen = m.top.findNode("playerScreen")

    m.homeScreen.observeField("channelSelected", "onChannelSelected")
    m.playerScreen.observeField("playerClosed", "onPlayerClosed")

    m.homeScreen.setFocus(true)
end sub

sub onChannelSelected(event as Object)
    channelData = event.getData()
    if channelData = invalid then return

    m.playerScreen.channelData = channelData
    m.playerScreen.visible = true
    m.homeScreen.visible = false
    m.playerScreen.setFocus(true)
end sub

sub onPlayerClosed(event as Object)
    m.playerScreen.visible = false
    m.homeScreen.visible = true
    m.homeScreen.setFocus(true)
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    return false
end function
