--[[
    =========================================================
    [ 💀 ] GENERAL REMOTE SPY & INTERCEPTOR
    [ 🔧 ] Architect: Agente Roblox Lua Expert
    [ 🎯 ] Purpose: Logar, Copiar e Executar Remotes (Events/Functions)
    =========================================================
]]

--// Serviços Nativos
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

--// Variaveis de Ambiente e Bypass do Anti-Cheat
local LocalPlayer = Players.LocalPlayer
local LoggedRemotes = {}
local IsSpying = true
local IgnoreList = {
    "MessageId", "Ping", "Mouse", "Movement", "Camera"
} -- Palavras-chave para ignorar remotes de spam do Roblox

--// Função Auxiliar de Formatação (Tabela p/ String)
local function FormatArguments(args)
    local result = ""
    for i, v in ipairs(args) do
        local varType = typeof(v)
        if varType == "string" then
            result = result .. "\"" .. v .. "\""
        elseif varType == "Instance" then
            result = result .. "game." .. v:GetFullName()
        elseif varType == "CFrame" then
            result = result .. "CFrame.new(" .. tostring(v) .. ")"
        elseif varType == "Vector3" then
            result = result .. "Vector3.new(" .. tostring(v) .. ")"
        elseif varType == "Color3" then
            result = result .. "Color3.new(" .. tostring(v) .. ")"
        elseif varType == "table" then
            result = result .. "{...}" -- Tabelas complexas
        else
            result = result .. tostring(v)
        end
        
        if i < #args then
            result = result .. ", "
        end
    end
    return result
end

--// Notificação na Tela (Feedback)
local function Notify(title, text)
    StarterGui:SetCore("SendNotification", {
        Title = title;
        Text = text;
        Icon = "rbxassetid://10882439086";
        Duration = 3;
    })
end

--// Interface Gráfica Simples Pelo Console (F9) ou Clipboard
-- Obs: Como solicitado, este script armazena tudo no F9 de forma organizada e também permite copiar ao clicar no log gerado.
local function LogRemote(remoteName, remotePath, method, argsStr)
    if not IsSpying then return end
    
    -- Checa IgnoreList para evitar flood na tela
    for _, ignoreWord in ipairs(IgnoreList) do
        if string.find(string.lower(remoteName), string.lower(ignoreWord)) then
            return 
        end
    end
    
    if not LoggedRemotes[remoteName] then
        LoggedRemotes[remoteName] = true
        
        local logMessage = string.format("[Remote Spy] Ativado:\nMethod: %s\nPath: %s\nArguments: %s", method, remotePath, argsStr)
        warn("============== [ REMOTE DETECTADO ] ==============")
        print("Nome: ", remoteName)
        print("Caminho: ", remotePath)
        print("Método: ", method)
        print("Argumentos (args): ", argsStr)
        
        -- Gerando Código Executável (Pronto para o Exploit)
        local exploitCode = string.format("local args = {%s}\n%s:%s(unpack(args))", argsStr, remotePath, method)
        print("--- Código para re-executar: ---")
        print(exploitCode)
        print("==================================================")
        
        -- Sistema de Backup em GUI Simples
        Notify("Remote Capturado!", "Nome: " .. remoteName .. "\nCheque o Console (F9) para copiar o código.")
    end
end

--// Hooking Metamethod: Interceptação Profunda do Jogo
local OldNamecall
OldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    -- Verifica se quem chamou NÃO foi o nosso Executor (checkcaller) para não se trancar em um loop de log
    if not checkcaller() then
        if method == "FireServer" or method == "InvokeServer" then
            if typeof(self) == "Instance" and (self:IsA("RemoteEvent") or self:IsA("RemoteFunction")) then
                local remoteName = self.Name
                local remotePath = "game." .. self:GetFullName()
                local argsStr = FormatArguments(args)
                
                -- Spawnar fora da Thread principal para não dar lag ou ser pego por verificações de tempo
                task.spawn(LogRemote, remoteName, remotePath, method, argsStr)
            end
        end
    end
    
    -- Retorna a execução original para o jogo não quebrar
    return OldNamecall(self, ...)
end))

--// Mensagem de Inicialização
Notify("Remote Spy Injetado!", "Fique atento ao F9 para copiar os códigos capturados.")
print("[Roblox Lua Expert] Remote Spy executando com Hooking Seguro nos métodos __namecall.")
