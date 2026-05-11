-- Базовый скрипт-эксперимент для сбора монет в зоне видимости
-- Поместите этот скрипт в StarterPlayer -> StarterPlayerScripts внутри Roblox Studio

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

-- Настройки эксперимента
local SEARCH_RADIUS = 50 -- Радиус поиска монет
local TICK_RATE = 1 -- Как часто искать монеты (в секундах)

-- Функция симуляции сбора монеты
local function collectCoin(coin)
    if coin:IsA("BasePart") then
        print("Эксперимент: Обнаружена монета: " + coin.Name)
        -- Здесь обычно вызывается FireServer() для отправки события на сервер игры
        -- Например: game:GetService("ReplicatedStorage").Network["Coins:Collect"]:FireServer(coin.Name)
    end
end

-- Основной цикл поиска предметов
while true do
    task.wait(TICK_RATE)
    
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        local playerPos = character.HumanoidRootPart.Position
        
        -- Поиск папки с монетами в Workspace (в реальной игре имя папки другое)
        -- Обычно в симуляторах монеты лежат в Workspace.Coins или Workspace.Debris
        local coinsFolder = Workspace:FindFirstChild("Coins") or Workspace:FindFirstChild("ActiveCoins")
        
        if coinsFolder then
            for _, coin in ipairs(coinsFolder:GetChildren()) do
                if coin:IsA("BasePart") and (coin.Position - playerPos).Magnitude <= SEARCH_RADIUS then
                    collectCoin(coin)
                end
            end
        else
            -- Альтернативный поиск по всему Workspace, если папка не найдена
            for _, object in ipairs(Workspace:GetChildren()) do
                if object.Name:lower():find("coin") or object.Name:lower():find("currency") then
                    collectCoin(object)
                end
            end
        end
    end
end
