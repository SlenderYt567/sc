--[[
    SlenderHub Skill: Remote Security & Stealth
    Version: 1.0
    Description: Functions to safely call remotes and bypass basic checks.
]]

local SecuritySkill = {}

-- Safe InvokeServer with pcall and timeout
function SecuritySkill.SafeInvoke(remote, ...)
    if not remote or not remote:IsA("RemoteFunction") then return end
    
    local success, result = pcall(function(...)
        return remote:InvokeServer(...)
    end, ...)
    
    if not success then
        warn("[SlenderHub Security] Remote invocation failed: " .. tostring(result))
    end
    
    return success, result
end

-- Stealth Metatable Hooking (Template)
-- Usage: SecuritySkill.HookProperty(game.Players.LocalPlayer.Character.Humanoid, "WalkSpeed", 16)
function SecuritySkill.HookProperty(instance, property, fakeValue)
    local mt = getrawmetatable(game)
    local oldIndex = mt.__index
    setreadonly(mt, false)

    mt.__index = newcclosure(function(t, k)
        if not checkcaller() and t == instance and k == property then
            return fakeValue
        end
        return oldIndex(t, k)
    end)

    setreadonly(mt, true)
    print("[SlenderHub Security] Property hook applied to: " .. tostring(instance))
end

-- Simple Remote Spam Protection
local lastCall = 0
function SecuritySkill.Throttle(interval, func, ...)
    local now = tick()
    if now - lastCall >= interval then
        lastCall = now
        return func(...)
    end
end

return SecuritySkill
