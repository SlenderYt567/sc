-- Slender Hub - Punch Simulator Free Version
if game.PlaceId ~= 14236123211 then return end

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Slender Hub - Free Version", -- Changed name for Free version
    LoadingTitle = "Slender Hub - Free Version", -- Changed loading title
    LoadingSubtitle = "by Slender",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = nil,
        FileName = "SlenderHubFreeConfig" -- Changed config file name for Free version
    },
    Discord = {
        Enabled = true,
        Invite = "zFQMEvT6",
        RememberJoins = true
    }
})

-- Global Variables (Combined from Free and Premium versions)
-- Note: Premium variables are kept to allow UI elements to exist, but will be gated.
_G.Autoclick = false -- Auto Damage for Free version
_G.AutoclickPremium = false -- Auto Damage for Premium version (will be gated)
_G.autoHatch = false -- Auto Hatch for Free version
_G.autoHatchPremium = false -- Auto Hatch for Premium version (will be gated)
_G.selectEgg = "1" -- Used by egg dropdowns (Free and Premium)
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
_G.autoEggBox = false
_G.eventEggCount = 1
_G.autoGolden = false 
_G.autoAscend = false 

-- NEW GLOBAL VARIABLES FOR AUTO QUEST (Now for Premium only)
_G.autoQuest = false
_G.selectQuest = "Damage" -- Default quest type
_G.questInitialDamage = 0 -- Stores initial damage when starting the quest (for Premium)
_G.questTotalDamageGoal = 15000 -- Damage goal for the quest (for Premium)
_G.questInitialLegendaries = 0 -- Stores initial legendary count (for Premium)
_G.questTotalLegendariesGoal = 25 -- Legendary goal for the quest (for Premium)

-- Helper Functions for Auto Quest (Still present but only for Premium to use if this base is shared)
function getLegendaryPetCount()
    local player = game.Players.LocalPlayer
    local petFolder = player:FindFirstChild("Pets") -- Common location for pets folder

    if not petFolder then
        -- Fallback: Try to find the pets folder if not named "Pets"
        for _, child in ipairs(player:GetChildren()) do
            if child:IsA("Folder") and (string.find(child.Name:lower(), "pet") or string.find(child.Name:lower(), "inventory")) then
                petFolder = child
                break
            end
        end
    end

    if not petFolder then
        warn("[getLegendaryPetCount] Player pets folder not found.")
        return 0
    end

    local legendaryCount = 0
    for _, petInstance in ipairs(petFolder:GetChildren()) do
        local isLegendary = false
        
        -- Prioritize detection by value (StringValue or NumberValue)
        local rarityValue = petInstance:FindFirstChild("Rarity") or petInstance:FindFirstChild("Rank") or petInstance:FindFirstChild("Tier")
        if rarityValue then
            if rarityValue:IsA("StringValue") then
                -- Check if it's a string like "Legendary", "Secret", etc.
                if string.find(rarityValue.Value:lower(), "legendary") or string.find(rarityValue.Value:lower(), "secret") or string.find(rarityValue.Value:lower(), "mythic") then
                    isLegendary = true
                end
            elseif (rarityValue:IsA("IntValue") or rarityValue:IsA("NumberValue")) then
                -- If it's a number, assume higher numbers are rarer
                -- This is a guess, might need adjustment if the game uses a specific rank system
                if rarityValue.Value >= 5 then -- Example: Rank 5 or higher is legendary/mythic
                    isLegendary = true
                end
            end
        end

        -- Fallback: Check if "Legendary" is in the pet instance name
        if not isLegendary and string.find(petInstance.Name:lower(), "legendary") then
            isLegendary = true
        end

        if isLegendary then
            legendaryCount = legendaryCount + 1
        end
    end
    return legendaryCount
end


-- Free Version Functions (with their original delays)
function AutoclickFree() 
    while _G.Autoclick do
        game.ReplicatedStorage.Events.DamageIncreaseOnClickEvent:FireServer()
        task.wait(0.4) -- Free version delay
    end
end

function autoHatchFree() 
    while _G.autoHatch do
        game.ReplicatedStorage.Events.PlayerPressedKeyOnEgg:FireServer(_G.selectEgg, 1)
        task.wait(1.6) -- Free version delay
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

function autoEventEggBox()
    while _G.autoEggBox do
        local args = {_G.eventEggCount}
        game:GetService("ReplicatedStorage").Events.RNGGame.EternalBloom.EternalBloomMysteryBoxEvents.PlayerWantsToRollMysteryBox:FireServer(unpack(args))
        task.wait(1)
    end
end

function autoAscend()
    while _G.autoAscend do
        local args = {
            [1] = true
        }
        game:GetService("ReplicatedStorage").Events.AscendEvent:FireServer(unpack(args))
        print("[Auto Ascend] Attempting to ascend.")
        task.wait(5.0) -- Wait time between Ascend attempts
    end
end

function autoGolden()
    while _G.autoGolden do
        local player = game.Players.LocalPlayer
        local petFolder = player:FindFirstChild("Pets") 
        
        if not petFolder then
            for _, child in ipairs(player:GetChildren()) do
                if child:IsA("Folder") and (string.find(child.Name:lower(), "pet") or string.find(child.Name:lower(), "inventory")) then 
                    petFolder = child
                    break
                end
            end
        end

        if petFolder then
            local petsByTypeName = {} 
            local petsFound = 0

            for _, petInstance in ipairs(petFolder:GetChildren()) do
                local petType = nil
                local isGolden = false

                -- Try to get the pet type name (e.g., "Cat", "Dog")
                local nameValue = petInstance:FindFirstChild("PetType") or petInstance:FindFirstChild("Name")
                if nameValue and nameValue:IsA("StringValue") then
                    petType = nameValue.Value
                else
                    petType = petInstance.Name:gsub("%d+", ""):gsub(" ", "") 
                end
                
                -- Try to identify if the pet is already Golden (either by a BoolValue or by name)
                local isGoldenValue = petInstance:FindFirstChild("IsGolden")
                if isGoldenValue and isGoldenValue:IsA("BoolValue") then
                    isGolden = isGoldenValue.Value
                else
                    isGolden = string.find(petInstance.Name:lower(), "golden") or (petType and string.find(petType:lower(), "golden")) 
                end

                if petType and not isGolden then
                    petsByTypeName[petType] = petsByTypeName[petType] or {}
                    table.insert(petsByTypeName[petType], petInstance)
                    petsFound = petsFound + 1
                end
            end

            local mergedAny = false
            for typeName, petsOfType in pairs(petsByTypeName) do
                if #petsOfType >= 6 then
                    local mergeArgsTable = {}
                    for i = 1, 6 do
                        local pet = petsOfType[i]
                        local petID = pet.Name 

                        local currentXP = pet:FindFirstChild("CurrentXP") and pet.CurrentXP.Value or 0
                        local level = pet:FindFirstChild("Level") and pet.Level.Value or 1
                        local equipped = pet:FindFirstChild("Equipped") and pet.Equipped.Value or false
                        
                        local existsValue = pet:FindFirstChild("Exists") and pet.Exists.Value or os.time() 

                        mergeArgsTable[tostring(petID)] = { 
                            ["exists"] = existsValue,
                            ["petType"] = "normal", 
                            ["currentXP"] = currentXP,
                            ["level"] = level,
                            ["equipped"] = equipped,
                            ["name"] = typeName 
                        }
                    end

                    game:GetService("ReplicatedStorage").Events.PlayerGoldenMerge:FireServer(mergeArgsTable)
                    print("[Auto Golden] Attempted to merge 6x '" .. typeName .. "' pets.")
                    mergedAny = true
                    task.wait(3.0) 
                    break 
                end
            end

            if not mergedAny then
                print("[Auto Golden] Not enough normal pets of any type found for merge (" .. petsFound .. " total normal pets). Waiting...")
                task.wait(5.0) 
            end
        else
            print("[Auto Golden] Could not find player pets folder. Waiting...")
            task.wait(10.0) 
        end
        task.wait(0.5) 
    end
end


-- Premium Version Functions (These functions will exist but not be activated by UI in Free version)
function AutoclickPremium()
    while _G.AutoclickPremium do
        game.ReplicatedStorage.Events.DamageIncreaseOnClickEvent:FireServer()
        task.wait(0.05) -- Premium delay (faster)
    end
end

function autoHatchPremium()
    while _G.autoHatchPremium do
        game.ReplicatedStorage.Events.PlayerPressedKeyOnEgg:FireServer(_G.selectEgg, 1)
        task.wait(0.2) -- Premium delay (faster)
    end
end

-- AUTO QUEST FUNCTION (This function is for Premium use, not directly called by Free UI)
function autoQuest()
    local player = game.Players.LocalPlayer
    local leaderstats = player:WaitForChild("leaderstats", 10)

    if not leaderstats then 
        warn("[Auto Quest] Leaderstats not found. Deactivating.") 
        _G.autoQuest = false; -- This will be handled by UI lock in Free
        return 
    end

    while _G.autoQuest do
        if _G.selectQuest == "Damage" then
            local damageStat = leaderstats:FindFirstChild("Damage")
            if not damageStat then 
                warn("[Auto Quest - Damage] 'Damage' leaderstat not found. Deactivating.") 
                _G.autoQuest = false; -- Handled by UI lock in Free
                break 
            end

            if _G.questInitialDamage == 0 then 
                _G.questInitialDamage = damageStat.Value
                print(string.format("[Auto Quest - Damage] Starting quest. Current damage: %d. Goal: %d.", _G.questInitialDamage, _G.questTotalDamageGoal))
            end

            local currentDamageProgress = damageStat.Value - _G.questInitialDamage
            
            if currentDamageProgress >= _G.questTotalDamageGoal then
                print("[Auto Quest - Damage] 15000 Damage Quest completed! Deactivating Auto Quest and Ultra Fast Damage.")
                _G.AutoclickPremium = false; Rayfield:SetToggle("AutoDamagePremium", false);
                _G.autoQuest = false; Rayfield:SetToggle("AutoQuest", false);
                _G.questInitialDamage = 0 -- Reset for the next quest
                break 
            else
                print(string.format("[Auto Quest - Damage] Progress: %d/%d Damage", currentDamageProgress, _G.questTotalDamageGoal))
                if not _G.AutoclickPremium then
                    print("[Auto Quest - Damage] Activating Ultra Fast Damage (Premium)...")
                    _G.AutoclickPremium = true; task.spawn(AutoclickPremium); Rayfield:SetToggle("AutoDamagePremium", true);
                    -- Ensure other click/hatch automations are deactivated
                    _G.Autoclick = false; Rayfield:SetToggle("AutoDamageFree", false);
                    _G.autoHatch = false; Rayfield:SetToggle("AutoHatchFree", false);
                    _G.autoHatchPremium = false; Rayfield:SetToggle("AutoHatchPremium", false); 
                    _G.autoEggBox = false; Rayfield:SetToggle("AutoEggBox", false);
                end
            end
        elseif _G.selectQuest == "Hatch" then
            local currentLegendaries = getLegendaryPetCount()
            if _G.questInitialLegendaries == 0 then
                _G.questInitialLegendaries = currentLegendaries
                print(string.format("[Auto Quest - Hatch] Starting quest. Current legendaries: %d. Goal: %d new legendaries.", _G.questInitialLegendaries, _G.questTotalLegendariesGoal))
            end

            local hatchedLegendaries = currentLegendaries - _G.questInitialLegendaries

            if hatchedLegendaries >= _G.questTotalLegendariesGoal then
                print(string.format("[Auto Quest - Hatch] %d Legendaries Quest completed! Deactivating Auto Quest and Hyper Hatching Premium.", _G.questTotalLegendariesGoal))
                _G.autoHatchPremium = false; Rayfield:SetToggle("AutoHatchPremium", false); 
                _G.autoQuest = false; Rayfield:SetToggle("AutoQuest", false);
                _G.questInitialLegendaries = 0 -- Reset for the next quest
                break
            else
                print(string.format("[Auto Quest - Hatch] Progresso: %d/%d Lendaries hatched.", hatchedLegendaries, _G.questTotalLegendariesGoal))
                if not _G.autoHatchPremium then 
                    print("[Auto Quest - Hatch] Activating Hyper Hatching Premium...")
                    _G.autoHatchPremium = true; task.spawn(autoHatchPremium); Rayfield:SetToggle("AutoHatchPremium", true);
                    -- Ensure other click/hatch automations are deactivated
                    _G.Autoclick = false; Rayfield:SetToggle("AutoDamageFree", false);
                    _G.AutoclickPremium = false; Rayfield:SetToggle("AutoDamagePremium", false); 
                    _G.autoHatch = false; Rayfield:SetToggle("AutoHatchFree", false);
                    _G.autoEggBox = false; Rayfield:SetToggle("AutoEggBox", false);
                end
            end
        end
        task.wait(2) -- Checks progress every 2 seconds
    end
    _G.questInitialDamage = 0 -- Reset initial damage when deactivating Auto Quest
    _G.questInitialLegendaries = 0 -- Reset initial legendaries
    print("[Auto Quest] Function deactivated.")
end


-- UI Construction

-- "Premium" Tab (GATED FOR FREE VERSION)
local PremiumTab = Window:CreateTab("Premium", 4483362458) 
PremiumTab:CreateLabel("⭐ Unlock exclusive features by getting Premium! ⭐")
-- Changed Discord label to a button that copies the invite
PremiumTab:CreateButton({
    Name = "Copy Discord Invite (For Premium)",
    Callback = function()
        local discordInvite = "https://discord.gg/9Q6Q33Q7"
        local success, err = pcall(function()
            -- Use the global 'setclipboard' function which is commonly supported by exploits
            setclipboard(discordInvite) 
        end)

        if success then
            Rayfield:Notify({
                Title = "Discord Invite Copied!",
                Content = "The Discord invite link has been copied to your clipboard.",
                Duration = 3 -- Default duration, can be adjusted
                -- Removed Image parameter to ensure notification appears
            })
            print("[Discord] Invite link copied: " .. discordInvite)
        else
            Rayfield:Notify({
                Title = "Clipboard Error",
                Content = "Failed to copy Discord invite. Your exploit may not support clipboard access. Link printed to console.",
                Duration = 5 -- Default duration, can be adjusted
                -- Removed Image parameter to ensure notification appears
            })
            warn("[Discord Error] Failed to copy invite to clipboard: " .. tostring(err))
            print("[Discord] Manual Copy: Please copy this link manually: " .. discordInvite)
        end
    end
})


-- Section for Premium Egg Selection
PremiumTab:CreateSection("Egg Management (Premium Locked)")
PremiumTab:CreateDropdown({
    Name = "Select Egg (Premium Locked)", 
    Options = (function()
        local t = {}
        for i = 1, 30 do t[#t+1] = tostring(i) end
        return t
    end)(),
    CurrentOption = {"1"},
    MultipleOptions = false,
    Flag = "DropdownEggPremium", 
    Callback = function(Options)
        _G.selectEgg = Options[1] -- Still allow selection in UI for display, but activation is locked
        Rayfield:Notify({
            Title = "Premium Locked",
            Content = "You need Premium to use this feature! Join Discord to purchase: https://discord.gg/9Q6Q33Q7",
            Duration = 5,
            -- Removed Image parameter
        })
    end
})

-- Section for Performance Automations
PremiumTab:CreateSection("High Performance Automation (Premium Locked)")
PremiumTab:CreateToggle({
    Name = "Hyper Hatching (PREMIUM LOCKED)", 
    CurrentValue = false,
    Flag = "AutoHatchPremium",
    Icon = "rbxassetid://6053303867", 
    Callback = function(v)
        _G.autoHatchPremium = false -- Ensure it's off
        Rayfield:SetToggle("AutoHatchPremium", false) -- Force UI toggle back off
        Rayfield:Notify({
            Title = "Premium Locked",
            Content = "You need Premium to use Hyper Hatching! Join Discord to purchase: https://discord.gg/9Q6Q33Q7",
            Duration = 5,
            -- Removed Image parameter
        })
    end
})

PremiumTab:CreateToggle({
    Name = "Ultra Fast Damage (PREMIUM LOCKED)", 
    CurrentValue = false,
    Flag = "AutoDamagePremium",
    Icon = "rbxassetid://4483362458", 
    Callback = function(v)
        _G.AutoclickPremium = false -- Ensure it's off
        Rayfield:SetToggle("AutoDamagePremium", false) -- Force UI toggle back off
        Rayfield:Notify({
            Title = "Premium Locked",
            Content = "You need Premium for Ultra Fast Damage! Join Discord to purchase: https://discord.gg/9Q6Q33Q7",
            Duration = 5,
            -- Removed Image parameter
        })
    end
})


-- "Auto" Tab (Free version features)
local AutoTab = Window:CreateTab("Auto", 4483362458)
AutoTab:CreateToggle({
    Name = "Auto Damage (Free)", -- REMOVED DELAY INDICATION
    CurrentValue = false,
    Flag = "AutoDamageFree", 
    Callback = function(v)
        _G.Autoclick = v
        if v then
            task.spawn(AutoclickFree)
            -- No explicit _G.autoQuest interaction here, as it's locked in Free version.
            -- Other automations (like Auto Egg Box / Auto Hatch) still need to manage their conflicts.
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

AutoTab:CreateToggle({
    Name = "Auto Golden",
    CurrentValue = false,
    Flag = "AutoGolden",
    Callback = function(v)
        _G.autoGolden = v
        if v then task.spawn(autoGolden) end
    end
})

AutoTab:CreateToggle({
    Name = "Auto Ascend",
    CurrentValue = false,
    Flag = "AutoAscend",
    Callback = function(v)
        _G.autoAscend = v
        if v then task.spawn(autoAscend) end
    end
})

-- "Eggs" Tab (Free version features)
local EggTab = Window:CreateTab("Eggs", 4483362458)
EggTab:CreateDropdown({
    Name = "Select Egg", -- This dropdown sets _G.selectEgg for free hatcher
    Options = (function()
        local t = {}
        for i = 1, 30 do t[#t+1] = tostring(i) end
        return t
    end)(),
    CurrentOption = {"1"},
    MultipleOptions = false,
    Flag = "DropdownEgg",
    Callback = function(Options)
        _G.selectEgg = Options[1]
    end
})

EggTab:CreateToggle({
    Name = "Auto Hatch (Free)", -- REMOVED DELAY INDICATION
    CurrentValue = false,
    Flag = "AutoHatchFree", 
    Callback = function(v)
        _G.autoHatch = v
        if v then
            task.spawn(autoHatchFree)
            if _G.autoEggBox then -- Deactivates Egg Box if Free Hatch is activated
                _G.autoEggBox = false
                Rayfield:SetToggle("AutoEggBox", false)
            end
        end
    end
})

-- "Misc" Tab (Free version features)
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

-- "Dungeon" Tab (Only the manual join button)
local DungeonTab = Window:CreateTab("Dungeon", 4483362458)
DungeonTab:CreateButton({ 
    Name = "Manually Join Dungeon",
    Callback = function()
        local args = {
            [1] = "StartDungeon"
        }
        game:GetService("ReplicatedStorage").Events.DungeonEvent:FireServer(unpack(args))
        print("[Dungeon] Attempting to manually join dungeon.")
    end
})

-- "Event" Tab (Free version features + Auto Quest - now locked)
local EventTab = Window:CreateTab("Event", 4483362458)

-- Auto Egg Box Section (Free)
EventTab:CreateSection("Auto Egg Box")
EventTab:CreateDropdown({
    Name = "Egg Quantity",
    Options = {"1", "10"},
    CurrentOption = {"1"},
    MultipleOptions = false,
    Flag = "EventEggCount",
    Callback = function(option)
        _G.eventEggCount = tonumber(option[1]) or 1
    end
})

EventTab:CreateToggle({
    Name = "Auto Egg Box (Event)", 
    CurrentValue = false,
    Flag = "AutoEggBox",
    Callback = function(value)
        _G.autoEggBox = value
        if value then
            task.spawn(autoEventEggBox)
            if _G.autoHatch then
                _G.autoHatch = false
                Rayfield:SetToggle("AutoHatchFree", false)
            end
        end
    end
})

-- Auto Quest Section (PREMIUM LOCKED in Free version)
EventTab:CreateSection("Auto Quest (Premium Locked)") -- Label indicating it's locked
EventTab:CreateDropdown({
    Name = "Select Quest (Premium Locked)",
    Options = {"Damage", "Hatch"},
    CurrentOption = {"Damage"},
    MultipleOptions = false,
    Flag = "DropdownQuest", -- Still use the flag for saving config
    Callback = function(Options)
        _G.selectQuest = Options[1] -- Still allow selection in UI for display
        Rayfield:Notify({
            Title = "Premium Locked",
            Content = "You need Premium to use Auto Quest! Join Discord to purchase: https://discord.gg/9Q6Q33Q7",
            Duration = 5,
            -- Removed Image parameter
        })
    end
})

EventTab:CreateToggle({
    Name = "Auto Quest (PREMIUM LOCKED)",
    CurrentValue = false,
    Flag = "AutoQuest",
    Callback = function(v)
        _G.autoQuest = false -- Ensure it's off
        Rayfield:SetToggle("AutoQuest", false) -- Force UI toggle back off
        Rayfield:Notify({
            Title = "Premium Locked",
            Content = "Auto Quest is a Premium feature! Join Discord to purchase: https://discord.gg/9Q6Q33Q7",
            Duration = 5,
            -- Removed Image parameter
        })
    end
})


-- "Settings" Tab
local ConfigTab = Window:CreateTab("Settings", 4483362458) 
ConfigTab:CreateButton({
    Name = "Enable Anti-AFK", 
    Callback = function()
        local vu = game:GetService("VirtualUser")
        game:GetService("Players").LocalPlayer.Idled:Connect(function()
            vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            task.wait(1)
            vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            print("[Anti-AFK] Simulated movement to prevent kick.")
        end)
    end
})

ConfigTab:CreateButton({
    Name = "Save Settings", 
    Callback = function()
        Window:SaveConfiguration()
        print("[Config] Settings saved successfully.") 
    end
})

ConfigTab:CreateButton({
    Name = "Close Script", 
    Callback = function()
        -- Deactivate all automatic functions (including Premium and Quest)
        _G.Autoclick = false
        _G.AutoclickPremium = false -- Gated
        _G.autoHatch = false
        _G.autoHatchPremium = false -- Gated
        _G.autoCraft = false
        _G.autoWishingWell = false
        _G.autoWin = false
        _G.autoSpin = false
        _G.autoPower1 = false
        _G.autoPower2 = false
        _G.autoHack = false
        _G.autoUGC = false
        _G.autoEggBox = false
        _G.autoGolden = false
        _G.autoAscend = false
        _G.autoQuest = false -- Gated

        -- Close the Rayfield window
        Window:Destroy()
        print("[Script] Interface closed and scripts deactivated.") 
    end
})
