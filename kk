-- Slender Hub | Premium Completo (Sem Key)
if game.PlaceId ~= 14236123211 then return end

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Window = Rayfield:CreateWindow({
    Name = "Slender Hub | Premium",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "SlenderPremium",
        FileName = "PremiumConfig"
    }
})

local Toggles = {}
local Settings = {
    Craft = "ShortSwords",
    Egg = "1",
    Well = "Small"
}

-- Lista de itens de craft
local craftItems = {
    "ShortSwords", "Dagger", "HeavyHammer", "DualHammers", "QuadHammers",
    "Clover", "LuckyTooth", "HorseShoe", "GoldenClover",
    "HealthKit", "Heart", "HealthGem", "GoldenHealthGem",
    "BootsofSwiftness", "JetFuel", "RocketJet",
    "LuckyDie", "Magnet", "LuckyGem", "GemStack", "HandfulOfCoins"
}

-- Função de execução contínua
local function spawnLoop(flag, func, delay)
    spawn(function()
        while Toggles[flag] do
            pcall(func)
            task.wait(delay or 1)
        end
    end)
end

-- 🛠️ Aba Auto
local autoTab = Window:CreateTab("⚙️ Auto", 4483362458)

autoTab:CreateToggle({
    Name = "⚔️ Auto Click",
    CurrentValue = false,
    Flag = "AutoClick",
    Callback = function(v)
        Toggles.AutoClick = v
        if v then
            spawnLoop("AutoClick", function()
                game.ReplicatedStorage.Events.DamageIncreaseOnClickEvent:FireServer()
            end, 0.3)
        end
    end
})

autoTab:CreateToggle({
    Name = "🏆 Auto Win",
    CurrentValue = false,
    Flag = "AutoWin",
    Callback = function(v)
        Toggles.AutoWin = v
        if v then
            spawnLoop("AutoWin", function()
                game.ReplicatedStorage.Events.PushEvent:FireServer(true)
            end, 0.2)
        end
    end
})

autoTab:CreateDropdown({
    Name = "🛠️ Selecionar Craft",
    CurrentValue = Settings.Craft,
    Options = craftItems,
    Callback = function(v) Settings.Craft = v end
})

autoTab:CreateToggle({
    Name = "🧪 Auto Craft",
    CurrentValue = false,
    Flag = "AutoCraft",
    Callback = function(v)
        Toggles.AutoCraft = v
        if v then
            spawnLoop("AutoCraft", function()
                game.ReplicatedStorage.Events.CraftingEvent:FireServer(Settings.Craft)
            end, 1)
        end
    end
})

-- 🥚 Aba Egg
local eggTab = Window:CreateTab("🥚 Eggs")

eggTab:CreateDropdown({
    Name = "Selecionar Egg",
    CurrentValue = Settings.Egg,
    Options = (function()
        local t = {}
        for i = 1, 30 do table.insert(t, tostring(i)) end
        return t
    end)(),
    Callback = function(v) Settings.Egg = v end
})

-- Auto Hatch Premium (Delay 0s)
eggTab:CreateToggle({
    Name = "🐣 Auto Hatch (Premium - Rápido)",
    CurrentValue = false,
    Flag = "AutoHatch",
    Callback = function(v)
        Toggles.AutoHatch = v
        if v then
            spawnLoop("AutoHatch", function()
                game.ReplicatedStorage.Events.PlayerPressedKeyOnEgg:FireServer(Settings.Egg, 1)
            end, 0)
        end
    end
})

-- 💎 Aba Premium
local premiumTab = Window:CreateTab("💎 Premium")

-- Auto Damage Premium (Delay 0s)
premiumTab:CreateToggle({
    Name = "⚡ Auto Damage (Premium - Rápido)",
    CurrentValue = false,
    Flag = "AutoDamage",
    Callback = function(v)
        Toggles.AutoDamage = v
        if v then
            spawnLoop("AutoDamage", function()
                game.ReplicatedStorage.Events.DamageIncreaseOnClickEvent:FireServer()
            end, 0)
        end
    end
})

-- 🌀 Aba Misc
local miscTab = Window:CreateTab("🎲 Misc")

miscTab:CreateDropdown({
    Name = "Selecionar Poço dos Desejos",
    CurrentValue = Settings.Well,
    Options = {"Small", "Medium", "Mega"},
    Callback = function(v) Settings.Well = v end
})

miscTab:CreateToggle({
    Name = "💧 Auto Wishing Well",
    CurrentValue = false,
    Flag = "AutoWishingWell",
    Callback = function(v)
        Toggles.AutoWishingWell = v
        if v then
            spawnLoop("AutoWishingWell", function()
                game.ReplicatedStorage.Events.WishingWell:FireServer(Settings.Well)
            end, 1)
        end
    end
})

miscTab:CreateToggle({
    Name = "🎡 Auto Spin",
    CurrentValue = false,
    Flag = "AutoSpin",
    Callback = function(v)
        Toggles.AutoSpin = v
        if v then
            spawnLoop("AutoSpin", function()
                game.ReplicatedStorage.Events.SpinWheelEvent:FireServer(true)
            end, 1)
        end
    end
})

miscTab:CreateToggle({
    Name = "🔋 Auto PowerCore 1",
    CurrentValue = false,
    Flag = "AutoPower1",
    Callback = function(v)
        Toggles.AutoPower1 = v
        if v then
            spawnLoop("AutoPower1", function()
                game.ReplicatedStorage.Events.PowerCore:InvokeServer()
            end, 1)
        end
    end
})

miscTab:CreateToggle({
    Name = "🔌 Auto PowerCore 2",
    CurrentValue = false,
    Flag = "AutoPower2",
    Callback = function(v)
        Toggles.AutoPower2 = v
        if v then
            spawnLoop("AutoPower2", function()
                game.ReplicatedStorage.Events.PowerCoreV2:InvokeServer()
            end, 2)
        end
    end
})

miscTab:CreateToggle({
    Name = "💻 Auto Hack",
    CurrentValue = false,
    Flag = "AutoHack",
    Callback = function(v)
        Toggles.AutoHack = v
        if v then
            spawnLoop("AutoHack", function()
                game.ReplicatedStorage.Events.HackEvent:InvokeServer()
            end, 1)
        end
    end
})

miscTab:CreateButton({
    Name = "❌ Fechar GUI",
    Callback = function()
        Rayfield:Destroy()
    end
})

-- 🏰 Aba Dungeon
local dungeonTab = Window:CreateTab("🏯 Dungeon")

dungeonTab:CreateToggle({
    Name = "⚔️ Auto Dungeon",
    CurrentValue = false,
    Flag = "AutoDungeon",
    Callback = function(v)
        Toggles.AutoDungeon = v
        if v then
            spawnLoop("AutoDungeon", function()
                game.ReplicatedStorage.Events.DungeonTeleport:FireServer()
                task.wait(3)
                game.ReplicatedStorage.Events.StartDungeon:FireServer()
                task.wait(10)
                for _, mob in pairs(workspace.DungeonMobs:GetChildren()) do
                    if mob:FindFirstChild("HumanoidRootPart") then
                        game.ReplicatedStorage.Events.DamageEvent:FireServer(mob)
                    end
                end
            end, 5)
        end
    end
})
