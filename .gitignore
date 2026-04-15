--[[
    SlenderHub | Universal Loader (V11)
    Architect: SlenderHub Systems Expert
    Description: Dynamic game detection and modular script loading.
]]

--// 1. Loader Configuration
local LoaderConfig = {
    Version = "1.1.0",
    Debug = true,
    LocalMode = true, -- Tries to load from executor's 'workspace' folder first
    ModulesPath = "https://raw.githubusercontent.com/SlenderYt567/sc/refs/heads/main/"
}

--// 2. Game Mapping (PlaceId -> Module Name)
local GameModules = {
    [120405647949186] = "RoyalHatchers_Module.lua" -- Royal Hatchers
}

--// 3. UI Singleton
if getgenv().SlenderHubLoaded then 
    warn("[SlenderHub] Loader already active.")
    return 
end
getgenv().SlenderHubLoaded = true

--// 4. Load UI Library (SlenderWind V11)
local success, SlenderWind = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/SlenderYt567/sc/refs/heads/main/SlenderWind.lua"))()
end)

if not success or not SlenderWind then
    error("[SlenderHub] Failed to load UI Library!")
    return
end

--// 5. Initialize Window
local Window = SlenderWind.Window({
    Name = "SlenderHub | Universal Loader",
    KeySystem = false, -- Can be enabled later
    Theme = { 
        Accent = Color3.fromRGB(0, 255, 128),
        Background = Color3.fromRGB(15, 15, 20),
        Text = Color3.fromRGB(240, 240, 240)
    } 
})

--// 6. Universal Tab (Always visible)
local TabUniversal = Window:Tab("Universal")

TabUniversal:Label("--- Performance & AFK ---")
TabUniversal:Button("CPU Optimizer (Low Render)", "Disables 3D rendering", function()
    game:GetService("RunService"):Set3dRenderingEnabled(false)
end)

TabUniversal:Button("Restore Rendering", "Re-enables 3D rendering", function()
    game:GetService("RunService"):Set3dRenderingEnabled(true)
end)

--// 7. Dynamic Module Loading
local function LoadModule(moduleName)
    print("[SlenderHub] Tentando carregar módulo: " .. moduleName)
    
    local url = LoaderConfig.ModulesPath .. moduleName
    local moduleContent = nil
    local loadSource = ""
    
    -- Try local load first if enabled
    if LoaderConfig.LocalMode and readfile then
        local success, res = pcall(function() return readfile(moduleName) end)
        if success then
            moduleContent = res
            loadSource = "Local (Workspace)"
        end
    end
    
    -- Fallback to GitHub
    if not moduleContent then
        local fetchSuccess, result = pcall(function()
            return game:HttpGet(url)
        end)
        if fetchSuccess and result and not result:find("404") then
            moduleContent = result
            loadSource = "GitHub (Remote)"
        else
            return false, "Download falhou (404 ou sem internet)"
        end
    end
    
    -- Compile and Init
    if moduleContent then
        local moduleFunc, err = loadstring(moduleContent)
        if moduleFunc then
            local successInit, moduleTable = pcall(moduleFunc)
            if successInit and moduleTable and type(moduleTable.Init) == "function" then
                print("[SlenderHub] Inserindo módulo de: " .. loadSource)
                moduleTable.Init(Window)
                return true, loadSource
            else
                return false, "Módulo inválido ou formato incorreto"
            end
        else
            return false, "Erro de sintaxe Luau: " .. tostring(err)
        end
    end
    
    return false, "Falha desconhecida"
end

-- Detection Logic
local currentPlaceId = game.PlaceId
local targetModule = GameModules[currentPlaceId]

if targetModule then
    local TabLoading = Window:Tab("Loading...")
    TabLoading:Label("Detectando jogo...")
    TabLoading:Label("Buscando módulos: " .. targetModule)
    
    task.spawn(function()
        local success, source = LoadModule(targetModule)
        if success then
            TabLoading:Label("[SUCESSO] Carregado via: " .. source)
            task.wait(1.5)
            -- TabLoading:Destroy() -- Se a biblioteca tiver essa função
        else
            TabLoading:Label("[ERRO] " .. tostring(source))
            TabLoading:Label("Verifique se o arquivo está no GitHub ou na pasta Workspace.")
        end
    end)
else
    local TabNone = Window:Tab("Not Supported")
    TabNone:Label("Jogo não suportado pelo SlenderHub.")
    TabNone:Label("PlaceId: " .. currentPlaceId)
end

print("[SlenderHub] Universal Loader Process Finished.")
