-- Slender Hub - Punch Simulator PREMIUM (Updated with adjusted delays and Premium Egg Select)
if game.PlaceId ~= 14236123211 then return end

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Slender Hub Premium",
    LoadingTitle = "Slender Hub Premium",
    LoadingSubtitle = "by Slender",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = nil,
        FileName = "SlenderHubPremiumConfig"
    },
    Discord = {
        Enabled = true,
        Invite = "zFQMEvT6",
        RememberJoins = true
    }
})

-- Global Variables
_G.Autoclick = false
_G.autoHatch = false
_G.selectEgg = "1" -- Used by both Free and Premium Hatch
_G.autoCraft = false
_G.selectCraft = "ShortSwords"
_G.autoWishingWell = false
_G.selectWishingWell = "Small"
_G.autoWin = false
_G.autoSpin = false
_G.autoPower1 = false
_G.autoPower2 = false
_G.autoHack = false
_G.autoUGC = false
_G.autoDungeon = false
_G.autoEggBox = false
_G.eventEggCount = 1

-- NEW GLOBAL VARIABLES FOR PREMIUM
_G.AutoclickPremium = false
_G.autoHatchPremium = false

-- Core Functions (FREE - Maintained with original delays)
function Autoclick()
    while _G.Autoclick do
        game.ReplicatedStorage.Events.DamageIncreaseOnClickEvent:FireServer()
        task.wait(0.25) -- Free version delay
    end
end

function autoWin()
    while _G.autoWin do
        game.ReplicatedStorage.Events.PushEvent:FireServer(true)
        task.wait(0.1)
    end
end

function autoCraft()
    while _G.autoCraft do
        game:GetService("ReplicatedStorage").Events.CraftingEvent:FireServer(_G.selectCraft)
        task.wait(0.5)
    end
end

function autoWishingWell()
    while _G.autoWishingWell do
        game.ReplicatedStorage.Events.WishingWell:FireServer(_G.selectWishingWell)
        task.wait(1)
    end
end

function autoHatch()
    while _G.autoHatch do
        game.ReplicatedStorage.Events.PlayerPressedKeyOnEgg:FireServer(_G.selectEgg, 1)
        task.wait(1.2) -- Free version delay
    end
end

function autoPower1()
    while _G.autoPower1 do
        game.ReplicatedStorage.Events.PowerCoreEvent:FireServer("PowerCoreOne")
        task.wait(1)
    end
end

function autoPower2()
    while _G.autoPower2 do
        game.ReplicatedStorage.Events.PowerCoreEvent:FireServer("PowerCoreTwo")
        task.wait(1)
    end
end

function autoHack()
    while _G.autoHack do
        game.ReplicatedStorage.Events.HackEvent:FireServer()
        task.wait(0.7)
    end
end

function autoUGC()
    while _G.autoUGC do
        game.ReplicatedStorage.Events.NewUGCEvents.ClickedEventClaimButton:FireServer("NextBossEvent")
        task.wait(1)
    end
end

function autoSpin()
    while _G.autoSpin do
        game.ReplicatedStorage.Events.SpinWheelEvent:FireServer("Spin")
        task.wait(1)
    end
end

function autoDungeon()
    while _G.autoDungeon do
        game.ReplicatedStorage.Events.StartDungeon:FireServer()
        task.wait(2)
    end
end

function autoEventEggBox()
    while _G.autoEggBox do
        local args = {_G.eventEggCount}
        game:GetService("ReplicatedStorage").Events.RNGGame.EternalBloom.EternalBloomMysteryBoxEvents.PlayerWantsToRollMysteryBox:FireServer(unpack(args))
        task.wait(1)
    end
end

-- NEW PREMIUM FUNCTIONS (With adjusted delays)
function AutoclickPremium()
    while _G.AutoclickPremium do
        game.ReplicatedStorage.Events.DamageIncreaseOnClickEvent:FireServer()
        task.wait(0.05) -- Adjusted delay for Premium (faster than 0.25s)
    end
end

function autoHatchPremium()
    while _G.autoHatchPremium do
        game.ReplicatedStorage.Events.PlayerPressedKeyOnEgg:FireServer(_G.selectEgg, 1)
        task.wait(0.2) -- Adjusted delay for Premium (faster than 1.2s)
    end
end

-- Auto Tab (FREE - Corrected to interact with Premium)
local AutoTab = Window:CreateTab("Auto", 4483362458)
AutoTab:CreateToggle({
    Name = "Auto Damage",
    CurrentValue = false,
    Flag = "AutoDamage",
    Callback = function(v)
        _G.Autoclick = v
        if v then
            task.spawn(Autoclick)
            if _G.AutoclickPremium then
                _G.AutoclickPremium = false
                Rayfield:SetToggle("AutoDamagePremium", false)
            end
        end
    end
})

AutoTab:CreateToggle({
    Name = "Auto Win",
    CurrentValue = false,
    Flag = "AutoWin",
    Callback = function(v)
        _G.autoWin = v
        if v then task.spawn(autoWin) end
    end
})

AutoTab:CreateToggle({
    Name = "Auto Craft",
    CurrentValue = false,
    Flag = "AutoCraft",
    Callback = function(v)
        _G.autoCraft = v
        if v then task.spawn(autoCraft) end
    end
})

AutoTab:CreateDropdown({
    Name = "Select Craft",
    Options = {
        "ShortSwords", "Clover", "HealthKit", "BootsofSwiftness", "LuckyDie", "Magnet", "Dagger", "LuckyTooth",
        "JetFuel", "LuckyGem", "Heart", "HeavyHammer", "HorseShoe", "HandfulOfCoins", "HealthGem", "DualHammers",
        "GoldenClover", "GemStack", "GoldenHealthGem", "RocketJet", "QuadHammers"
    },
    CurrentOption = {"ShortSwords"},
    MultipleOptions = false,
    Flag = "DropdownCraft",
    Callback = function(Options)
        _G.selectCraft = Options[1]
    end
})

-- Eggs Tab (FREE - Corrected to interact with Premium)
local EggTab = Window:CreateTab("Eggs", 4483362458)
EggTab:CreateDropdown({
    Name = "Select Egg",
    Options = (function()
        local t = {}
        for i = 1, 30 do t[#t+1] = tostring(i) end
        return t
    end)(),
    CurrentOption = {"1"},
    MultipleOptions = false,
    Flag = "DropdownEgg",
    Callback = function(Options)
        _G.selectEgg = Options[1] -- Both dropdowns (Free and Premium) will modify this same variable.
    end
})

EggTab:CreateToggle({
    Name = "Auto Hatch",
    CurrentValue = false,
    Flag = "AutoHatch",
    Callback = function(v)
        _G.autoHatch = v
        if v then
            task.spawn(autoHatch)
            if _G.autoHatchPremium then
                _G.autoHatchPremium = false
                Rayfield:SetToggle("AutoHatchPremium", false)
            end
        end
    end
})

-- Misc Tab (FREE)
local MiscTab = Window:CreateTab("Misc", 4483362458)
MiscTab:CreateToggle({
    Name = "Auto PowerCore 1",
    CurrentValue = false,
    Flag = "AutoPower1",
    Callback = function(v)
        _G.autoPower1 = v
        if v then task.spawn(autoPower1) end
    end
})

MiscTab:CreateToggle({
    Name = "Auto PowerCore 2",
    CurrentValue = false,
    Flag = "AutoPower2",
    Callback = function(v)
        _G.autoPower2 = v
        if v then task.spawn(autoPower2) end
    end
})

MiscTab:CreateToggle({
    Name = "Auto Hack",
    CurrentValue = false,
    Flag = "AutoHack",
    Callback = function(v)
        _G.autoHack = v
        if v then task.spawn(autoHack) end
    end
})

MiscTab:CreateToggle({
    Name = "Auto UGC Claim",
    CurrentValue = false,
    Flag = "AutoUGC",
    Callback = function(v)
        _G.autoUGC = v
        if v then task.spawn(autoUGC) end
    end
})

MiscTab:CreateToggle({
    Name = "Auto Spin",
    CurrentValue = false,
    Flag = "AutoSpin",
    Callback = function(v)
        _G.autoSpin = v
        if v then task.spawn(autoSpin) end
    end
})

-- Dungeon Tab (FREE)
local DungeonTab = Window:CreateTab("Dungeon", 4483362458)
DungeonTab:CreateToggle({
    Name = "Auto Dungeon",
    CurrentValue = false,
    Flag = "AutoDungeon",
    Callback = function(v)
        _G.autoDungeon = v
        if v then task.spawn(autoDungeon) end
    end
})

-- Event Tab (FREE)
local EventTab = Window:CreateTab("Event", 4483362458)
EventTab:CreateDropdown({
    Name = "Egg Quantity", -- Translated
    Options = {"1", "10"},
    CurrentOption = {"1"},
    MultipleOptions = false,
    Flag = "EventEggCount",
    Callback = function(option)
        _G.eventEggCount = tonumber(option[1]) or 1
    end
})

EventTab:CreateToggle({
    Name = "Auto Egg Box",
    CurrentValue = false,
    Flag = "AutoEggBox",
    Callback = function(value)
        _G.autoEggBox = value
        if value then
            task.spawn(autoEventEggBox)
        end
    end
})

-- NEW PREMIUM TAB (With egg dropdown and adjusted delays)
local PremiumTab = Window:CreateTab("Premium", 4483362458)

PremiumTab:CreateDropdown({
    Name = "Select Egg Premium", -- New dropdown for Premium tab
    Options = (function()
        local t = {}
        for i = 1, 30 do t[#t+1] = tostring(i) end
        return t
    end)(),
    CurrentOption = {"1"},
    MultipleOptions = false,
    Flag = "DropdownEggPremium", -- Unique flag for config
    Callback = function(Options)
        _G.selectEgg = Options[1] -- Both dropdowns (Free and Premium) will modify this same variable.
    end
})

PremiumTab:CreateToggle({
    Name = "Auto Hatch PREMIUM (0.2s Delay)", -- Name updated to reflect delay
    CurrentValue = false,
    Flag = "AutoHatchPremium",
    Callback = function(v)
        _G.autoHatchPremium = v
        if v then
            task.spawn(autoHatchPremium)
            if _G.autoHatch then
                _G.autoHatch = false
                Rayfield:SetToggle("AutoHatch", false)
            end
        end
    end
})

PremiumTab:CreateToggle({
    Name = "Auto Damage PREMIUM (0.05s Delay)", -- Name updated to reflect delay
    CurrentValue = false,
    Flag = "AutoDamagePremium",
    Callback = function(v)
        _G.AutoclickPremium = v
        if v then
            task.spawn(AutoclickPremium)
            if _G.Autoclick then
                _G.Autoclick = false
                Rayfield:SetToggle("AutoDamage", false)
            end
        end
    end
})

-- Settings Tab (FREE)
local ConfigTab = Window:CreateTab("Settings", 4483362458) -- Translated tab name

ConfigTab:CreateButton({
    Name = "Enable Anti-AFK", -- Translated
    Callback = function()
        local vu = game:GetService("VirtualUser")
        game:GetService("Players").LocalPlayer.Idled:Connect(function()
            vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            task.wait(1)
            vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            print("[Anti-AFK] Simulated movement to prevent kick.") -- Translated print
        end)
    end
})

ConfigTab:CreateButton({
    Name = "Save Settings", -- Translated
    Callback = function()
        Window:SaveConfiguration()
        print("[Config] Settings saved successfully.") -- Translated print
    end
})

ConfigTab:CreateButton({
    Name = "Close Script", -- Translated
    Callback = function()
        -- Disable all automatic functions (including Premium ones)
        _G.Autoclick = false
        _G.autoHatch = false
        _G.autoCraft = false
        _G.autoWishingWell = false
        _G.autoWin = false
        _G.autoSpin = false
        _G.autoPower1 = false
        _G.autoPower2 = false
        _G.autoHack = false
        _G.autoUGC = false
        _G.autoDungeon = false
        _G.autoEggBox = false
        _G.AutoclickPremium = false
        _G.autoHatchPremium = false

        -- Close the Rayfield window
        Window:Destroy()
        print("[Script] Interface closed and scripts disabled.") -- Translated print
    end
})
