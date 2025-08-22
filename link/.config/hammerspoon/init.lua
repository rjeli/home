print('init.lua')

-- hs.audiodevice.watcher.isRunning()
--
-- hs.notify.new({
--     title = "hamma",
--     informativeText = "spoon"
-- }):send()
--
-- print('hi')
--

-- function getAllDeviceUids()
--     local uids = {}
--     for _, dev in ipairs(hs.audiodevice.allDevices()) do
--         uids[dev:uid()] = true
--     end
--     return uids
-- end

-- local devs = {}

local prevOutDev = hs.audiodevice.defaultOutputDevice()

hs.audiodevice.watcher.setCallback(function(event)
    -- 'dIn ', 'dOut': default in/out changed
    -- 'sOut': system out (effects) changed
    -- 'dev#': audio device added/removed

    print('got event:', event)

    inDev = hs.audiodevice.defaultInputDevice()
    outDev = hs.audiodevice.defaultOutputDevice()

    print('  inDev:', inDev)
    print('  outDev:', outDev)

    if outDev:uid() ~= prevOutDev:uid() then
        if outDev:name() == "External Headphones" then
            prevOutDev:setDefaultOutputDevice()
            hs.alert(
                'switched audio output back to ' .. prevOutDev:name(),
                0.5
            )
        else
            print('audio switched to ' .. outDev:name() .. ' (' .. outDev:uid() .. ')')
            prevOutDev = outDev
        end
    end
end)

hs.audiodevice.watcher.start()
