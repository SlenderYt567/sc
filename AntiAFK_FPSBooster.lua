-- ==========================================
-- Anti-AFK & FPS Booster (Otimização para Emulador/MuMu Player)
-- ==========================================

local VirtualUser = game:GetService("VirtualUser")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

print("Iniciando Anti-AFK e FPS Booster...")

-- ==========================================
-- 1. Anti-AFK (Prevenção de Desconexão)
-- ==========================================

-- Método 1: Evita o kick padrão do Roblox (20 minutos)
LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
    print("Anti-AFK: Prevenindo desconexão por inatividade do Roblox.")
end)

-- Método 2: Ação a cada 5 minutos (300 segundos) conforme solicitado
task.spawn(function()
    while true do
        task.wait(300)
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
        print("Anti-AFK: Clique simulado de 5 minutos executado.")
    end
end)

-- ==========================================
-- 2. FPS Booster (Otimização de Gráficos)
-- ==========================================

pcall(function()
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
end)

-- Limitar FPS para evitar sobrecarga no emulador (se o executor suportar)
pcall(function()
    if setfpscap then setfpscap(60) end
end)

-- Remover sombras e neblina
Lighting.GlobalShadows = false
Lighting.FogEnd = 9e9
Lighting.ShadowSoftness = 0

-- Remover efeitos de iluminação
for _, effect in pairs(Lighting:GetChildren()) do
    if effect:IsA("PostEffect") or effect:IsA("BlurEffect") or effect:IsA("SunRaysEffect") or effect:IsA("ColorCorrectionEffect") or effect:IsA("BloomEffect") or effect:IsA("DepthOfFieldEffect") then
        effect.Enabled = false
    end
end

-- Otimizar Água e Terreno
local Terrain = Workspace:FindFirstChildOfClass("Terrain")
if Terrain then
    Terrain.WaterWaveSize = 0
    Terrain.WaterWaveSpeed = 0
    Terrain.WaterReflectance = 0
    Terrain.WaterTransparency = 0
    pcall(function() Terrain.Decoration = false end)
end

-- Otimizar Peças do Mapa (Remove texturas, reduz material e desativa partículas)
-- Usamos task.spawn para não travar a execução caso o mapa seja muito grande
task.spawn(function()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.Material = Enum.Material.SmoothPlastic
            obj.Reflectance = 0
            obj.CastShadow = false
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            obj.Transparency = 1
        elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
            obj.Enabled = false
        end
        -- Pequena pausa para evitar travar o jogo enquanto otimiza muitos blocos
        if _ % 5000 == 0 then task.wait() end
    end
    print("FPS Booster: Otimização do mapa concluída!")
end)

print("Anti-AFK e FPS Booster carregados com sucesso!")
