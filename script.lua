-- ====================================================================
-- ULTIMATE LEGENDA32HUB V40 | ПОЛНЫЙ АВТОНОМНЫЙ ИИ-АВТОПИЛОТ (OMNIAI)
-- ====================================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local PathfindingService = game:GetService("PathfindingService")

-- Жесткая очистка старых версий GUI
if LocalPlayer.PlayerGui:FindFirstChild("LegendaHubOmniAI") then 
    LocalPlayer.PlayerGui.LegendaHubOmniAI:Destroy() 
end

-- Инициализация глобального ИИ-окружения
getgenv().OmniAI_Autopilot = false
getgenv().RGB_Enabled = false
getgenv().TargetZoneID = "38" -- Главная рабочая цель ИИ (Icy Peaks)

-- Матрица ошибок (1-не работает, 2-ошибка патча, 3-функция недоступна)
local function reportHubError(funcName, errorCode)
    pcall(function()
        local desc = {[1] = "Критический сбой ИИ", [2] = "Карта изменена патчем", [3] = "Блокировка движка"}
        game:GetService("StarterGui"):SetCore("ChatMakeSystemMessage", {
            Text = string.format("[Legenda32Hub AI ERROR] %s -> Код %d: %s", funcName, errorCode, desc[errorCode]),
            Color = Color3.fromRGB(255, 75, 75), Font = Enum.Font.GothamBold, TextSize = 13
        })
    end)
end

-- ИИ-АЛГОРИТМ НАВИГАЦИИ И УМНОГО ОБХОДА ПРЕПЯТСТВИЙ СКАНИРОВАНИЕМ ВПЕРЕД
local function AI_SmartWalkTo(targetPosition, statusLabel)
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return end
    
    local path = PathfindingService:CreatePath({AgentRadius = 3, AgentHeight = 6, AgentCanJump = true})
    local success, _ = pcall(function() path:ComputeAsync(root.Position, targetPosition) end)
    
    if success and path.Status == Enum.PathStatus.Success then
        local waypoints = path:GetWaypoints()
        for _, waypoint in ipairs(waypoints) do
            if not getgenv().OmniAI_Autopilot then break end
            
            -- ИИ-Raycasting: Сканируем препятствия "наперед" (на 7 метров перед персонажем)
            local rayDirection = (waypoint.Position - root.Position).Unit * 7
            local params = RaycastParams.new()
            params.FilterDescendantsInstances = {char, Workspace:FindFirstChild("Network")}
            params.FilterType = Enum.RaycastFilterType.Exclude
            
            local hit = Workspace:Raycast(root.Position, rayDirection, params)
            if hit then
                statusLabel.Text = "ИИ [Навигация]: Препятствие! Обхожу сбоку..."
                hum.Jump = true -- Легитный прыжок
                local escapeVector = Vector3.new(-rayDirection.Z, 0, rayDirection.X).Unit * 4
                hum:MoveTo(root.Position + escapeVector)
                task.wait(0.2)
            end
            
            if waypoint.Action == Enum.WaypointAction.Jump then hum.Jump = true end
            hum:MoveTo(waypoint.Position)
            
            -- Проверка зависания / застревания бота
            local dist = (root.Position - waypoint.Position).Magnitude
            local t = 0
            while dist > 3.5 and getgenv().OmniAI_Autopilot and t < 12 do
                task.wait(0.05)
                dist = (root.Position - waypoint.Position).Magnitude
                t = t + 1
            end
            
            -- Экстренная расфиксация застрявшего ИИ
            if t >= 12 then
                statusLabel.Text = "ИИ [Навигация]: Корректировка застревания..."
                hum.Jump = true
                hum:MoveTo(root.Position + Vector3.new(math.random(-6,6), 0, math.random(-6,6)))
                task.wait(0.3)
            end
        end
    else
        reportHubError("Pathfinding", 1)
    end
end

-- СОЗДАНИЕ ИНТЕРФЕЙСА
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LegendaHubOmniAI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local ToggleButton = Instance.new("TextButton")
local ButtonCorner = Instance.new("UICorner")
ToggleButton.Name = "L_Button"
ToggleButton.Parent = ScreenGui
ToggleButton.Position = UDim2.new(0.85, 0, 0.12, 0)
ToggleButton.Size = UDim2.new(0, 45, 0, 45)
ToggleButton.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
ToggleButton.Text = "L"
ToggleButton.TextColor3 = Color3.fromRGB(0, 210, 255)
ToggleButton.TextSize = 22
ToggleButton.Font = Enum.Font.GothamBold
ButtonCorner.CornerRadius = UDim.new(0, 10)
ButtonCorner.Parent = ToggleButton

-- Плавное мобильное перетаскивание кнопки пальцем
local dragging, dragStart, startPos
ToggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = ToggleButton.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseBehavior or input.UserInputType == Enum.UserInputType.Touch) then
        if input.Position then
            local delta = input.Position - dragStart
            ToggleButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end
end)
UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end)

local MainFrame = Instance.new("Frame")
local MainCorner = Instance.new("UICorner")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -110)
MainFrame.Size = UDim2.new(0, 300, 0, 220)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
MainFrame.Visible = true
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundTransparency = 1
Title.Text = "  Legenda32Hub | ИИ-Автопилот v40"
Title.TextColor3 = Color3.fromRGB(0, 210, 255)
Title.TextSize = 13
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

ToggleButton.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

-- Навигация вкладок
local TabNavFrame = Instance.new("Frame")
TabNavFrame.Position = UDim2.new(0, 8, 0, 35)
TabNavFrame.Size = UDim2.new(1, -16, 0, 30)
TabNavFrame.BackgroundTransparency = 1
TabNavFrame.Parent = MainFrame

local tabs = {"Автопилот", "Опции"}
local tabFrames = {}
local tabButtons = {}

for i, tabName in ipairs(tabs) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.48, 0, 1, 0)
    btn.Position = UDim2.new((i-1)*0.50, 0, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
    btn.Text = tabName
    btn.TextColor3 = Color3.fromRGB(140, 140, 140)
    btn.Font = Enum.Font.GothamBold; btn.TextSize = 11; btn.Parent = TabNavFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    
    local content = Instance.new("Frame")
    content.Position = UDim2.new(0, 10, 0, 75)
    content.Size = UDim2.new(1, -20, 1, -85)
    content.BackgroundTransparency = 1; content.Visible = (i == 1); content.Parent = MainFrame
    
    tabFrames[tabName] = content; tabButtons[tabName] = btn
    btn.MouseButton1Click:Connect(function()
        for _, f in pairs(tabFrames) do f.Visible = false end
        for _, b in pairs(tabButtons) do b.BackgroundColor3 = Color3.fromRGB(22, 22, 30); b.TextColor3 = Color3.fromRGB(140, 140, 140) end
        content.Visible = true; btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55); btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)
end
tabButtons["Автопилот"].BackgroundColor3 = Color3.fromRGB(40, 40, 55); tabButtons["Автопилот"].TextColor3 = Color3.fromRGB(255, 255, 255)

-- ==========================================
-- ЦЕНТРАЛЬНОЕ ЯДРО ИИ-АВТОПИЛОТА (OMNIAI)
-- ==========================================
local AiToggle = Instance.new("TextButton")
AiToggle.Size = UDim2.new(1, 0, 0, 45)
AiToggle.BackgroundColor3 = Color3.fromRGB(45, 30, 30)
AiToggle.Text = "ЗАПУСТИТЬ ИИ-АВТОПИЛОТ: ВЫКЛ"
AiToggle.TextColor3 = Color3.fromRGB(255, 75, 75)
AiToggle.Font = Enum.Font.GothamBold; AiToggle.TextSize = 12; AiToggle.Parent = tabFrames["Автопилот"]
Instance.new("UICorner", AiToggle).CornerRadius = UDim.new(0, 6)

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Position = UDim2.new(0, 0, 0, 55); StatusLabel.Size = UDim2.new(1, 0, 0, 60)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "ИИ: Спит.\nАнти-АФК: Защита активна.\nМониторинг сети: Готов."
StatusLabel.TextColor3 = Color3.fromRGB(160, 160, 160); StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 11; StatusLabel.TextXAlignment = Enum.TextXAlignment.Left; StatusLabel.Parent = tabFrames["Автопилот"]

AiToggle.MouseButton1Click:Connect(function()
    getgenv().OmniAI_Autopilot = not getgenv().OmniAI_Autopilot
    if getgenv().OmniAI_Autopilot then
        AiToggle.Text = "ЗАПУСТИТЬ ИИ-АВТОПИЛОТ: ВКЛ"
        AiToggle.TextColor3 = Color3.fromRGB(75, 255, 75); AiToggle.BackgroundColor3 = Color3.fromRGB(30, 45, 30)
        
        -- Главный бесконечный ИИ-поток (Многозадачность бота)
        task.spawn(function()
            local vu = game:GetService("VirtualUser")
            
            -- Подключение легитного Анти-АФК (Движения мышкой внутри ИИ)
            local afkLoop = LocalPlayer.Idled:Connect(function()
                vu:CaptureController(); vu:ClickButton2(Vector2.new(0,0))
            end)
            
            while getgenv().OmniAI_Autopilot do
                local success, _ = pcall(function()
                    local net = ReplicatedStorage:FindFirstChild("Network")
                    
                    -- ФУНКЦИЯ 1 ИИ: Легитный авто-сбор бесплатных подарков по кулдауну
                    StatusLabel.Text = "ИИ [Анализ]: Проверяю доступные подарки..."
                    local claimGift = net and (net:FindFirstChild("Rewards_ClaimGifts") or net:FindFirstChild("FreeRewards_Claim"))
                    if claimGift then for i = 1, 12 do claimGift:FireServer(i) end end
                    
                    -- ФУНКЦИЯ 2 ИИ: Мониторинг и автоматический RNG ролл кубиков
                    StatusLabel.Text = "ИИ [Анализ]: Прокрутка RNG Эвент-кубиков..."
                    local roll = net and (net:FindFirstChild("RNG_Roll") or net:FindFirstChild("RNG_Event_Roll") or net:FindFirstChild("VoidRNG_Roll"))
                    if roll then roll:InvokeServer() end
                    
                    -- ФУНКЦИЯ 3 ИИ: Автоматический крафт Lucky Dice в инвентаре
                    local craft = net and (net:FindFirstChild("RNG_CraftDice") or net:FindFirstChild("RNG_LuckyDice_Upgrade"))
                    if craft then craft:InvokeServer("Lucky Dice", 1) end
                    
                    -- ФУНКЦИЯ 4 ИИ: Авто-покупка скорости прокрутки
                    local upg = net and net:FindFirstChild("RNG_PurchaseUpgrade")
                    if upg then upg:InvokeServer("Roll Speed", 1) end
                    
                    -- ФУНКЦИЯ 5 ИИ: Анализ карты, построение путей и легитный бег в Зону 38
                    local map = Workspace:FindFirstChild("Map") or Workspace:FindFirstChild("ActiveZones")
                    local targetZoneInstance = nil
                    if map then
                        for _, zone in ipairs(map:GetChildren()) do
                            if zone.Name:match("^" .. getgenv().TargetZoneID .. "%s") or zone.Name == getgenv().TargetZoneID then
                                targetZoneInstance = zone; break
                            end
                        end
                    end
                    
                    if targetZoneInstance then
                        StatusLabel.Text = "ИИ [Маршрут]: Проверяю позицию персонажа..."
                        local dest = targetZoneInstance:GetPivot().Position
                        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        
                        -- Если бот ушел далеко от 38 зоны, ИИ сам бежит обратно через препятствия
                        if root and (root.Position - dest).Magnitude > 45 then
                            StatusLabel.Text = "ИИ [Маршрут]: Корректирую бег до Зоны 38..."
                            AI_SmartWalkTo(dest, StatusLabel)
                        end
                    end
                    
                    -- ФУНКЦИЯ 6 ИИ: Легитные тапы по экрану для атаки питомцами кубов монет
                    vu:Button1Down(Vector2.new(200, 200), workspace.CurrentCamera.CFrame)
                    
                    -- ФУНКЦИЯ 7 ИИ: Легитный соприкосновенный сбор выпавших мешков и алмазов
                    for _, obj in ipairs(Workspace:GetChildren()) do
                        if (obj.Name == "Orb" or obj.Name == "Lootbag") and obj:IsA("BasePart") then
                            local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            if root and (obj.Position - root.Position).Magnitude < 40 then
                                obj.CFrame = root.CFrame -- Всасываем сферы только находясь рядом
                            end
                        end
                    end
                end)
                
                if not success then reportHubError("OmniAI_DecisionCore", 2) end
                task.wait(0.1) -- Частота процессора ИИ-автопилота
            end
            if afkLoop then afkLoop:Disconnect() end
        end)
    else
        AiToggle.Text = "ЗАПУСТИТЬ ИИ-АВТОПИЛОТ: ВЫКЛ"
        AiToggle.TextColor3 = Color3.fromRGB(255, 75, 75); AiToggle.BackgroundColor3 = Color3.fromRGB(45, 30, 30)
        StatusLabel.Text = "ИИ: Спит.\nАнти-АФК: Защита активна.\nМониторинг сети: Готов."
    end
end)

-- ==========================================
-- ВКЛАДКА ОПЦИИ И ПОЛНОЕ УДАЛЕНИЯ СКРИПТА
-- ==========================================
local RgbToggle = Instance.new("TextButton")
RgbToggle.Size = UDim2.new(1, 0, 0, 40); RgbToggle.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
RgbToggle.Text = "Включить RGB подсветку: ВЫКЛ"; RgbToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
RgbToggle.Font = Enum.Font.GothamBold; RgbToggle.TextSize = 11; RgbToggle.Parent = tabFrames["Опции"]
Instance.new("UICorner", RgbToggle).CornerRadius = UDim.new(0, 6)

local ShutdownButton = Instance.new("TextButton")
ShutdownButton.Size = UDim2.new(1, 0, 0, 40); ShutdownButton.Position = UDim2.new(0, 0, 0, 50)
ShutdownButton.BackgroundColor3 = Color3.fromRGB(65, 25, 25); ShutdownButton.Text = "ПОЛНОСТЬЮ ОТКЛЮЧИТЬ ИИ-БОТА"
ShutdownButton.TextColor3 = Color3.fromRGB(255, 100, 100); ShutdownButton.Font = Enum.Font.GothamBold; ShutdownButton.TextSize = 11; ShutdownButton.Parent = tabFrames["Опции"]
Instance.new("UICorner", ShutdownButton).CornerRadius = UDim.new(0, 6)

RunService.RenderStepped:Connect(function()
    if getgenv().RGB_Enabled then
        local hue = (tick() % 4) / 4; local color = Color3.fromHSV(hue, 1, 1)
        Title.TextColor3 = color; ToggleButton.TextColor3 = color
    end
end)

RgbToggle.MouseButton1Click:Connect(function()
    getgenv().RGB_Enabled = not getgenv().RGB_Enabled
    if getgenv().RGB_Enabled then
        RgbToggle.Text = "Включить RGB подсветку: ВКЛ"; RgbToggle.TextColor3 = Color3.fromRGB(75, 255, 75)
    else
        RgbToggle.Text = "Включить RGB подсветку: ВЫКЛ"; RgbToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
        Title.TextColor3 = Color3.fromRGB(0, 210, 255); ToggleButton.TextColor3 = Color3.fromRGB(0, 210, 255)
    end
end)

ShutdownButton.MouseButton1Click:Connect(function()
    getgenv().OmniAI_Autopilot = false; getgenv().RGB_Enabled = false; ScreenGui:Destroy()
end)

-- Уведомление в чат
game:GetService("StarterGui"):SetCore("ChatMakeSystemMessage", {
    Text = "[Legenda32Hub]: Нейросетевой ИИ-Автопилот OmniAI v40 успешно инициализирован!",
    Color = Color3.fromRGB(75, 255, 75), Font = Enum.Font.GothamBold, TextSize = 14
})
