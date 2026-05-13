' CatsTV - Community Access Television Services
' Roku Channel Entry Point

sub Main(args as Dynamic)
    screen = CreateObject("roSGScreen")
    m.port = CreateObject("roMessagePort")
    screen.setMessagePort(m.port)

    ' Create roInput and bind to port so deep link events are received while running
    input = CreateObject("roInput")
    input.setMessagePort(m.port)

    scene = screen.CreateScene("MainScene")
    screen.show()

    ' Pass launch-time deep link args for Direct to Play (req 5.2)
    if args <> invalid and args.DoesExist("contentId") then scene.launchArgs = args

    deviceInfo = CreateObject("roDeviceInfo")
    deviceInfo.EnableLowGeneralMemoryEvent(true)

    while true
        msg = wait(0, m.port)
        if type(msg) = "roSGScreenEvent"
            if msg.isScreenClosed() then return
        else if type(msg) = "roInputEvent"
            if msg.isInput()
                info = msg.getInfo()
                if info <> invalid then scene.launchArgs = info
            end if
        end if
    end while
end sub
