-- ====================================================================
-- LEGENDA32HUB V42 | АВТОНОМНЫЙ ИИ-ПОМОЩНИК С ВИЗУАЛЬНЫМ СКАНИРОВАНИЕМ
-- ====================================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local PathfindingService = game:GetService("PathfindingService")

-- Жесткая выгрузка старых копий хаба
if LocalPlayer.PlayerGui:FindFirstChild("LegendaHubAI_Helper") then 
    LocalPlayer.PlayerGui.LegendaHubAI_Helper:Destroy() 
end

-- Инициализация глобального ИИ-окружения
getgenv().AI_Helper_Active = false
getgenv().RGB_Enabled = false
getgenv().TargetZone = "38" -- Главный маркер назначения ИИ

-- Матрица вывода ошибок (1-не работает, 2-ошибка патча, 3-функция недоступна)
local function reportHubError(funcName, errorCode)
    pcall(function()
        local desc = { [1] = "Сбой нейромодуля", [2] = "Изменение геометрии мира", [3] = "Движок заблокировал ввод" }
        game:GetService("StarterGui"):SetCore("ChatMakeSystemMessage", {
            Text = string.format("[Legenda32Hub AI ERROR] %s -> Код %d: %s", funcName, errorCode, desc[errorCode]),
            Color = Color3.fromRGB(255, 75, 75), Font = Enum.Font.GothamBold, TextSize = 13
        })
    end)
end

-- НЕЙРОСЕТЕВАЯ ФУНКЦИЯ ОЦЕНКИ ПРОСТРАНСТВА И СКАНИРОВАНИЯ ОКРУЖЕНИЯ «ГЛАЗАМИ ИИ»
local function AI_AssessSpaceAndWalk(targetPos, statusLabel)
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return end

    -- Поиск пути по легитным точкам навигации
    local path = PathfindingService:CreatePath({AgentRadius = 2.5, AgentHeight = 5.5, AgentCanJump = true})
    local success, _ = pcall(function() path:ComputeAsync(root.Position, targetPos) end)

    if success and path.Status == Enum.PathStatus.Success then
        local waypoints = path:GetWaypoints()
        
        for i, waypoint in ipairs(waypoints) do
            if not getgenv().AI_Helper_Active then break end

            -- ВИЗУАЛЬНЫЙ АНАЛИЗАТОР ИИ (Прямой и угловой Raycast)
            local lookVector = (waypoint.Position - root.Position).Unit
            local leftVector = Vector3.new(-lookVector.Z, 0, lookVector.X).Unit
            
            local directionsToScan = {
                ["Вперед"] = lookVector * 8,
                ["Слева"] = (lookVector + leftVector).Unit * 5,
                ["Справа"] = (lookVector - leftVector).Unit * 5
            }

            local params = RaycastParams.new()
            params.FilterDescendantsInstances = {char, Workspace:FindFirstChild("Network")}
            params.FilterType = Enum.RaycastFilterType.Exclude

            -- ИИ сканирует пространство по трем осям видимости
            for side, dir in pairs(directionsToScan) do
                local hitResult = Workspace:Raycast(root.Position, dir, params)
                if hitResult and hitResult.Instance and hitResult.Instance.CanCollide then
                    statusLabel.Text = string.format("ИИ [Глаза]: Вижу преграду %s! Меняю траекторию...", side)
                    hum.Jump = true -- Симулируем интуитивный прыжок
                    
                    -- ИИ вычисляет вектор уклонения в противоположную от препятствия сторону
                    local dodgeDir = side == "Слева" and -leftVector or leftVector
                    hum:MoveTo(root.Position + (dodgeDir * 5))
                    task.wait(0.15)
                end
            end

            -- Легитное следование до точки
            if waypoint.Action == Enum.WaypointAction.Jump then hum.Jump = true end
            hum:MoveTo(waypoint.Position)

            -- Защита от «застревания» на месте
            local currentDist = (root.Position - waypoint.Position).Magnitude
            local timeoutCounter = 0
            while currentDist > 4 and getgenv().AI_Helper_Active and timeoutCounter < 10 do
                task.wait(0.05)
                currentDist = (root.Position - waypoint.Position).Magnitude
                timeoutCounter = timeoutCounter + 1
            end

            -- Микро-коррекция курса ИИ, если персонаж уперся в невидимый барьер
            if timeoutCounter >= 10 then
                statusLabel.Text = "ИИ [Анализ]: Завис на точке. Пересчитываю шаги..."
                hum.Jump = true
                hum:MoveTo(root.Position - (lookVector * 4)) -- Шаг назад для разгона
                task.wait(0.2)
            end
        end
    else
        reportHubError("PathfindingCore", 1)
    end
end

-- ДИНАМИЧЕСКИЙ ПОИСК ЗОНЫ НА КАРТЕ
local function AI_LocateZone(zoneID)
    local searchFolders = { Workspace:FindFirstChild("Map"), Workspace:FindFirstChild("ActiveZones"), Workspace:FindFirstChild("Zones") }
    for _, folder in ipairs(searchFolders) do
        if folder then
            for _, child in ipairs(folder:GetChildren()) do
                if child.Name:match("^" .. tostring(zoneID) .. "%s") or child.Name == tostring(zoneID) then
                    return child
                end
            end
        end
    end
    return nil
end

-- СОЗДАНИЕ ИНТЕРФЕЙСА
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LegendaHubAI_Helper"
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

-- Плавное мобильное перемещение кнопки пальцем по экрану
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
Title.Text = "  Legenda32Hub | ИИ-Помощник v42"
Title.TextColor3 = Color3.fromRGB(0, 210, 255)
Title.TextSize = 13
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

ToggleButton.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

-- Вкладки
local TabNavFrame = Instance.new("Frame")
TabNavFrame.Position = UDim2.new(0, 8, 0, 35)
TabNavFrame.Size = UDim2.new(1, -16, 0, 30)
TabNavFrame.BackgroundTransparency = 1
TabNavFrame.Parent = MainFrame

local tabs = {"ИИ Ассистент", "Опции"}
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
tabButtons["ИИ Ассистент"].BackgroundColor3 = Color3.fromRGB(40, 40, 55); tabButtons["ИИ Ассистент"].TextColor3 = Color3.fromRGB(255, 255, 255)

-- ==========================================
-- ИНТЕРФЕЙС УПРАВЛЕНИЯ ИИ-ПОМОЩНИКОМ
-- ==========================================
local AiToggle = Instance.new("TextButton")
AiToggle.Size = UDim2.new(1, 0, 0, 45)
AiToggle.BackgroundColor3 = Color3.fromRGB(45, 30, 30)
AiToggle.Text = "ВКЛЮЧИТЬ ИИ-ПОМОЩНИКА: ВЫКЛ"
AiToggle.TextColor3 = Color3.fromRGB(255, 75, 75)
AiToggle.Font = Enum.Font.GothamBold; AiToggle.TextSize = 12; AiToggle.Parent = tabFrames["ИИ Ассистент"]
Instance.new("UICorner", AiToggle).CornerRadius = UDim.new(0, 6)

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Position = UDim2.new(0, 0, 0, 55); StatusLabel.Size = UDim2.new(1, 0, 0, 60)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "ИИ: Ожидает запуска...\nАнализ пространства: Спит.\nАнти-кик система: Активна."
StatusLabel.TextColor3 = Color3.fromRGB(160, 160, 160); StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 11; StatusLabel.TextXAlignment = Enum.TextXAlignment.Left; StatusLabel.Parent = tabFrames["ИИ Ассистент"]

AiToggle.MouseButton1Click:Connect(function()
    getgenv().AI_Helper_Active = not getgenv().AI_Helper_Active
    if getgenv().AI_Helper_Active then
        AiToggle.Text = "ВКЛЮЧИТЬ ИИ-ПОМОЩНИКА: ВКЛ"
        AiToggle.TextColor3 = Color3.fromRGB(75, 255, 75); AiToggle.BackgroundColor3 = Color3.fromRGB(30, 45, 30)
        
        -- Фоновый ИИ-Поток принятия решений
        task.spawn(function()
            local vu = game:GetService("VirtualUser")
            
            -- Встроенный Анти-АФК
            local afkConnection = LocalPlayer.Idled:Connect(function()
                vu:CaptureController(); vu:ClickButton2(Vector2.new(0,0))
            end)
            
            while getgenv().AI_Helper_Active do
                pcall(function()
                    local net = ReplicatedStorage:FindFirstChild("Network")
                    
                    -- Сбор бесплатных подарков по кулдауну
                    local giftRemote = net and (net:FindFirstChild("Rewards_ClaimGifts") or net:FindFirstChild("FreeRewards_Claim"))
                    if giftRemote then for i = 1, 12 do giftRemote:FireServer(i) end end
                    
                    -- Участие в RNG событиях
                    local rollRemote = net and (net:FindFirstChild("RNG_Roll") or net:FindFirstChild("RNG_Event_Roll") or net:FindFirstChild("VoidRNG_Roll"))
                    if rollRemote then rollRemote:InvokeServer() end
                    
                    -- Автоматический крафт кубиков в инвентаре
                    local craftRemote = net and (net:FindFirstChild("RNG_CraftDice") or net:FindFirstChild("RNG_LuckyDice_Upgrade"))
                    if craftRemote then craftRemote:InvokeServer("Lucky Dice", 1) end
                    
                    -- Оценка позиции персонажа относительно Зоны 38
                    local zoneObj = AI_LocateZone(getgenv().TargetZone)
                    if zoneObj then
                        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        local targetWorldPos = zoneObj:GetPivot().Position
                        
                        if root then
                            local distanceToZone = (root.Position - targetWorldPos).Magnitude
                            
                            -- Если персонаж вылетел из зоны, ИИ оценивает пространство и плавно бежит обратно
                            if distanceToZone > 50 then
                                StatusLabel.Text = "ИИ [Глаза]: Оцениваю 3D-мир и строю легитный маршрут..."
                                AI_AssessSpaceAndWalk(targetWorldPos, StatusLabel)
                            else
                                StatusLabel.Text = "ИИ [Статус]: Позиция оптимальна. Ломаю кубы монет в Зоне 38!"
                            end
                        end
                    else
                        StatusLabel.Text = "ИИ [Анализ]: Локация не прогружена. Жду сервер..."
                    end
                    
                    -- Легитные клики для атаки питомцев
                    vu:Button1Down(Vector2.new(200, 200), workspace.CurrentCamera.CFrame)
                    
                    -- Безопасный сбор сфер на земле (только проходя вплотную рядом)
                    for _, obj in ipairs(Workspace:GetChildren()) do
                        if (obj.Name == "Orb" or obj.Name == "Lootbag") and obj:IsA("BasePart") then
                            local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            if root and (obj.Position - root.Position).Magnitude < 40 then
                                obj.CFrame = root.CFrame
                            end
                        end
                    end
                end)
                task.wait(0.2)
            end
            if afkConnection then afkConnection:Disconnect() end
        end)
    else
        AiToggle.Text = "ВКЛЮЧИТЬ ИИ-ПОМОЩНИКА: ВЫКЛ"
        AiToggle.TextColor3 = Color3.fromRGB(255, 75, 75); AiToggle.BackgroundColor3 = Color3.fromRGB(45, 30, 30)
        StatusLabel.Text = "ИИ: Ожидает запуска...\nАнализ пространства: Спит.\nАнти-кик система: Активна."
    end
end)

-- ==========================================
-- ВКЛАДКА ОПЦИИ И ВЫГРУЗКА СОФТА
-- ==========================================
local RgbToggle = Instance.new("TextButton")
RgbToggle.Size = UDim2.new(1, 0, 0, 40); RgbToggle.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
RgbToggle.Text = "Включить RGB подсветку: ВЫКЛ"; RgbToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
RgbToggle.Font = Enum.Font.GothamBold; RgbToggle.TextSize = 11; RgbToggle.Parent = tabFrames["Опции"]
Instance.new("UICorner", RgbToggle).CornerRadius = UDim.new(0, 6)

local ShutdownButton = Instance.new("TextButton")
ShutdownButton.Size = UDim2.new(1, 0, 0, 40); ShutdownButton.Position = UDim2.new(0, 0, 0, 50)
ShutdownButton.BackgroundColor3 = Color3.fromRGB(65, 25, 25); ShutdownButton.Text = "ПОЛНОСТЬЮ ВЫГРУЗИТЬ ИИ-СОФТ"
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
    getgenv().AI_Helper_Active = false; getgenv().RGB_Enabled = false; ScreenGui:Destroy()
end)

-- Системное сообщение в чат
game:GetService("StarterGui"):SetCore("ChatMakeSystemMessage", {
    Text = "[Legenda32Hub]: Автономный ИИ-Помощник v42 успешно интегрирован в геометрию 3D-мира!",
    Color = Color3.fromRGB(75, 255, 75), Font = Enum.Font.GothamBold, TextSize = 14
})
