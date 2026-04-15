--[[
    SlenderHub | Royal Hatchers Module
    Architect: SlenderHub Roblox Lua Expert
    Description: Modularized version for Universal Loader.
]]

local Module = {}

function Module.Init(Window)
    --// 1. Services & Data
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Players = game:GetService("Players")
    local Workspace = game:GetService("Workspace")
    local LocalPlayer = Players.LocalPlayer
    local Remotes = ReplicatedStorage:WaitForChild("Remotes")
    local Functions = Remotes:WaitForChild("Functions")

    local EggsList = {
        "Common Egg", "Spotted Egg", "Rocky Egg", "Mushroom Egg", "Leaf Egg",
        "Arctic Egg", "Icy Egg", "Release Egg", "Lovely Egg", "Valentines Egg",
        "100K Egg", "Desert Egg", "Fiery Egg", "Magma Egg", "500K Egg",
        "Crystal Egg", "Floral Egg", "Mystical Egg", "Celebration Egg", "1M Egg", 
        "Season 1 Egg", "Light Egg", "Bounty Pets", "Exclusive Pets"
    }

    local Flags = {
        AutoClick = false,
        AutoEgg = false,
        SelectedEgg = "Common Egg",
        EggAmount = 100
    }

    --// 2. Tabs
    local TabFarming = Window:Tab("Royal Farming")
    local TabEggs = Window:Tab("Royal Eggs")

    --// 3. Farming Logic
    TabFarming:Toggle("Auto Click", false, "AutoClick", "Automatically clicks", function(Value)
        Flags.AutoClick = Value
        task.spawn(function()
            while Flags.AutoClick do
                pcall(function() Functions.Click:InvokeServer() end)
                task.wait(0.05)
            end
        end)
    end)

    --// 4. Egg Logic
    TabEggs:Dropdown("Select Egg", EggsList, "Common Egg", "SelectedEgg", "Egg to hatch", function(val)
        Flags.SelectedEgg = val
    end)

    TabEggs:Toggle("Auto Hatch", false, "AutoEgg", "Spam buys selected egg", function(Value)
        Flags.AutoEgg = Value
        task.spawn(function()
            while Flags.AutoEgg do
                pcall(function()
                    local eggFolder = Workspace:FindFirstChild("_") and Workspace._:FindFirstChild("Eggs")
                    if eggFolder and eggFolder:FindFirstChild(Flags.SelectedEgg) then
                        Functions.BuyEgg:InvokeServer(eggFolder[Flags.SelectedEgg], Flags.EggAmount)
                    end
                end)
                task.wait(0.1)
            end
        end)
    end)

    print("[SlenderHub] Royal Hatchers Module Loaded.")
end

return Module
