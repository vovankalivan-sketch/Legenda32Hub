-- ====================================================================
-- LEGENDA32HUB V50 | АВТОНОМНЫЙ НЕЙРО-АГЕНТ И ВСТРОЕННЫЙ ИИ-ЧАТ
-- ====================================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local PathfindingService = game:GetService("PathfindingService")

-- Принудительное удаление старых GUI при перезапуске
if LocalPlayer.PlayerGui:FindFirstChild("LegendaHubNeuroDrive") then 
    LocalPlayer.PlayerGui.LegendaHubNeuroDrive:Destroy() 
end

-- Инициализация глобального ИИ-окружения
getgenv().NeuroAI_Active = false
getgenv().RGB_Enabled = false
getgenv().TargetZoneID = "38"

-- Матрица вывода ошибок (1-не работает, 2-ошибка патча, 3-функция недоступна)
local function reportHubError(funcName, errorCode)
    pcall(function()
        local desc = { [1] = "Сбой нейромодуля", [2] = "Изменение геометрии мира", [3] = "Движок заблокировал ввод" }
        game:GetService("StarterGui"):SetCore("ChatMakeSystemMessage", {
            Text = string.format("[Legenda32Hub ERROR] %s -> Код %d: %s", funcName, errorCode, desc[errorCode]),
            Color = Color3.fromRGB(255, 75, 75), Font = Enum.Font.GothamBold, TextSize = 13
        })
    end)
end

-- ==========================================
-- ИИ-ЯДРО КРОСС-ПЛАТФОРМЕННОЙ НАВИГАЦИИ (RAYCAST)
-- ==========================================
local function AI_NeuroWalkTo(targetPosition, statusLabel)
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return end
    
    local path = PathfindingService:CreatePath({AgentRadius = 2.5, AgentHeight = 5.5, AgentCanJump = true})
    local success, _ = pcall(function() path:ComputeAsync(root.Position, targetPosition) end)
    
    if success and path.Status == Enum.PathStatus.Success then
        local waypoints = path:GetWaypoints()
        for _, waypoint in ipairs(waypoints) do
            if not getgenv().NeuroAI_Active then break end
            
            -- Сканирование пространства лазерными лучами на 8 метров вперед
            local rayDirection = (waypoint.Position - root.Position).Unit * 8
            local params = RaycastParams.new()
            params.FilterDescendantsInstances = {char, Workspace:FindFirstChild("Network")}
            params.FilterType = Enum.RaycastFilterType.Exclude
            
            local hit = Workspace:Raycast(root.Position, rayDirection, params)
            if hit and hit.Instance and hit.Instance.CanCollide then
                statusLabel.Text = "Агент: Вижу препятствие! Корректирую шаги..."
                hum.Jump = true
                local escapeVector = Vector3.new(-rayDirection.Z, 0, rayDirection.X).Unit * 4
                hum:MoveTo(root.Position + escapeVector)
                task.wait(0.15)
            end
            
            if waypoint.Action == Enum.WaypointAction.Jump then hum.Jump = true end
            hum:MoveTo(waypoint.Position)
            
            -- Контроль застревания
            local dist = (root.Position - waypoint.Position).Magnitude
            local t = 0
            while dist > 3.5 and getgenv().NeuroAI_Active and t < 10 do
                task.wait(0.05)
                dist = (root.Position - waypoint.Position).Magnitude
                t = t + 1
            end
            
            if t >= 10 then
                hum.Jump = true
                hum:MoveTo(root.Position + Vector3.new(math.random(-5,5), 0, math.random(-5,5)))
                task.wait(0.2)
            end
        end
    else
        reportHubError("NeuroWalk", 1)
    end
end

-- ДИНАМИЧЕСКИЙ СКАНЕР ЛОКАЦИЙ ИГРЫ
local function AI_LocateMapZone(zoneID)
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

-- ==========================================
-- ИНИЦИАЛИЗАЦИЯ ИНТЕРФЕЙСА СИСТЕМЫ
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LegendaHubNeuroDrive"
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

-- Безлаговый drag кнопки L пальцем
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
Title.Text = "  Legenda32Hub | NeuroDrive v50"
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

local tabs = {"Автопилот", "ИИ-Чат", "Опции"}
local tabFrames = {}
local tabButtons = {}

for i, tabName in ipairs(tabs) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.32, 0, 1, 0)
    btn.Position = UDim2.new((i-1)*0.33, 0, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
    btn.Text = tabName
    btn.TextColor3 = Color3.fromRGB(140, 140, 140)
    btn.Font = Enum.Font.GothamBold; btn.TextSize = 10; btn.Parent = TabNavFrame
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
-- ВКЛАДКА 1: НЕЙРО-АВТОПИЛОТ
-- ==========================================
local AiToggle = Instance.new("TextButton")
AiToggle.Size = UDim2.new(1, 0, 0, 40)
AiToggle.BackgroundColor3 = Color3.fromRGB(45, 30, 30)
AiToggle.Text = "ВКЛЮЧИТЬ НЕЙРО-АГЕНТА: ВЫКЛ"
AiToggle.TextColor3 = Color3.fromRGB(255, 75, 75)
AiToggle.Font = Enum.Font.GothamBold; AiToggle.TextSize = 11; AiToggle.Parent = tabFrames["Автопилот"]
Instance.new("UICorner", AiToggle).CornerRadius = UDim.new(0, 6)

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Position = UDim2.new(0, 0, 0, 45); StatusLabel.Size = UDim2.new(1, 0, 0, 60)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Агент: Спит.\nОценка 3D мира: Готов к анализу.\nБаза лингвистики чата: Загружена."
StatusLabel.TextColor3 = Color3.fromRGB(160, 160, 160); StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 11; StatusLabel.TextXAlignment = Enum.TextXAlignment.Left; StatusLabel.Parent = tabFrames["Автопилот"]

AiToggle.MouseButton1Click:Connect(function()
    getgenv().NeuroAI_Active = not getgenv().NeuroAI_Active
    if getgenv().NeuroAI_Active then
        AiToggle.Text = "ВКЛЮЧИТЬ НЕЙРО-АГЕНТА: ВКЛ"
        AiToggle.TextColor3 = Color3.fromRGB(75, 255, 75); AiToggle.BackgroundColor3 = Color3.fromRGB(30, 45, 30)
        
        task.spawn(function()
            local vu = game:GetService("VirtualUser")
            local afkLoop = LocalPlayer.Idled:Connect(function() vu:CaptureController(); vu:ClickButton2(Vector2.new(0,0)) end)
            
            while getgenv().NeuroAI_Active do
                pcall(function()
                    local net = ReplicatedStorage:FindFirstChild("Network")
                    
                    -- Сбор подарков
                    local claimGift = net and (net:FindFirstChild("Rewards_ClaimGifts") or net:FindFirstChild("FreeRewards_Claim"))
                    if claimGift then for i = 1, 12 do claimGift:FireServer(i) end end
                    
                    -- RNG ролл
                    local roll = net and (net:FindFirstChild("RNG_Roll") or net:FindFirstChild("RNG_Event_Roll") or net:FindFirstChild("VoidRNG_Roll"))
                    if roll then roll:InvokeServer() end
                    
                    -- Анализ позиции и легитный бег
                    local zoneObj = AI_LocateMapZone(getgenv().TargetZoneID)
                    if zoneObj then
                        local dest = zoneObj:GetPivot().Position
                        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if root then
                            if (root.Position - dest).Magnitude > 50 then
                                StatusLabel.Text = "Агент [Действие]: Позиция нарушена. Бегу в Зону 38..."
                                AI_NeuroWalkTo(dest, StatusLabel)
                            else
                                StatusLabel.Text = "Агент [Действие]: Стою в Зоне 38. Анализирую монеты."
                            end
                        end
                    end
                    
                    -- Легитные физические клики
                    vu:Button1Down(Vector2.new(200, 200), workspace.CurrentCamera.CFrame)
                    
                    -- Сбор сфер в радиусе шага
                    for _, obj in ipairs(Workspace:GetChildren()) do
                        if (obj.Name == "Orb" or obj.Name == "Lootbag") and obj:IsA("BasePart") then
                            local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                            if root and (obj.Position - root.Position).Magnitude < 45 then
                                obj.CFrame = root.CFrame
                            end
                        end
                    end
                end)
                task.wait(0.2)
            end
            if afkLoop then afkLoop:Disconnect() end
        end)
    else
        AiToggle.Text = "ВКЛЮЧИТЬ НЕЙРО-АГЕНТА: ВЫКЛ"
        AiToggle.TextColor3 = Color3.fromRGB(255, 75, 75); AiToggle.BackgroundColor3 = Color3.fromRGB(45, 30, 30)
        StatusLabel.Text = "Агент: Спит.\nОценка 3D мира: Готов к анализу."
    end
end)

-- ==========================================
-- ВКЛАДКА 2: ВСТРОЕННЫЙ ИИ-ЧАТ (ИНТЕГРАЦИЯ С АГЕНТОМ)
-- ==========================================
local ChatFrame = tabFrames["ИИ-Чат"]

local ChatLog = Instance.new("TextLabel")
ChatLog.Size = UDim2.new(1, 0, 0, 75)
ChatLog.Position = UDim2.new(0, 0, 0, 0)
ChatLog.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
ChatLog.Text = "ИИ: Привет! Я твой ассистент Legenda32Hub. Задай мне вопрос или отправь команду (фарм, статус, зона, привет)."
ChatLog.TextColor3 = Color3.fromRGB(200, 200, 200)
ChatLog.TextSize = 10
ChatLog.Font = Enum.Font.Gotham
ChatLog.TextWrapped = true
ChatLog.TextXAlignment = Enum.TextXAlignment.Left
ChatLog.TextYAlignment = Enum.TextYAlignment.Top
ChatLog.Parent = ChatFrame
Instance.new("UICorner", ChatLog).CornerRadius = UDim.new(0, 6)

local ChatInput = Instance.new("TextBox")
ChatInput.Size = UDim2.new(1, 0, 0, 32)
ChatInput.Position = UDim2.new(0, 0, 0, 80)
ChatInput.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
ChatInput.PlaceholderText = "Напишите сообщение ИИ агенту..."
ChatInput.Text = ""
ChatInput.TextColor3 = Color3.fromRGB(255, 255, 255)
ChatInput.Font = Enum.Font.GothamBold
ChatInput.TextSize = 11
ChatInput.Parent = ChatFrame
Instance.new("UICorner", ChatInput).CornerRadius = UDim.new(0, 5)

-- База локальных лингвистических правил для ИИ-чата (NLP Core)
ChatInput.FocusLost:Connect(function(enterPressed)
    if enterPressed and ChatInput.Text ~= "" then
        local userText = ChatInput.Text:lower()
        ChatInput.Text = "" -- Очищаем поле ввода
        
        local botResponse = "ИИ: Извини, я не понял эту фразу. Попробуй ключевые слова: статус, фарм, зона, привет."
        
        -- Логические триггеры лингвистического процессора
        if userText:find("привет") or userText:find("ку") or userText:find("hello") then
            botResponse = "ИИ: Приветствую! Готов к выполнению задач. Я полностью автономен."
        elseif userText:find("статус") or userText:find("как дела") or userText:find("работа") then
            if getgenv().NeuroAI_Active then
                botResponse = "ИИ: Текущий статус: АКТИВЕН. Сканирую пространство, собираю ресурсы в зоне " .. getgenv().TargetZoneID .. ", полет нормальный!"
            else
                botResponse = "ИИ: Текущий статус: СПИТ. Нажмите кнопку на первой вкладке, чтобы активировать мои алгоритмы."
            end
        elseif userText:find("фарм") or userText:find("включи") or userText:find("запуск") then
            getgenv().NeuroAI_Active = true
            AiToggle.Text = "ВКЛЮЧИТЬ НЕЙРО-АГЕНТА: ВКЛ"
            AiToggle.TextColor3 = Color3.fromRGB(75, 255, 75); AiToggle.BackgroundColor3 = Color3.fromRGB(30, 45, 30)
            botResponse = "ИИ: Понял вас! Команда принята. Запускаю ИИ-Автопилот и перехожу в режим фарма."
        elseif userText:find("зона") or userText:find("где ты") or userText:find("локация") then
            local currentPos = "неизвестно"
            pcall(function()
                local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if root then currentPos = tostring(math.floor(root.Position.X)) .. ", " .. tostring(math.floor(root.Position.Z)) end
            end)
            botResponse = "ИИ: Моя целевая точка — Зона " .. getgenv().TargetZoneID .. " (Icy Peaks). Мои физические координаты в 3D мире: " .. currentPos
        elseif userText:find("выключи") or userText:find("стоп") then
            getgenv().NeuroAI_Active = false
            AiToggle.Text = "ВКЛЮЧИТЬ НЕЙРО-АГЕНТА: ВЫКЛ"
            AiToggle.TextColor3 = Color3.fromRGB(255, 75, 75); AiToggle.BackgroundColor3 = Color3.fromRGB(45, 30, 30)
            botResponse = "ИИ: Понял. Останавливаю фоновые процессы и перевожу нейромодули в режим ожидания."
        end
        
        ChatLog.Text = "Вы: " .. userText .. "\n" .. botResponse
    end
end)

-- ==========================================
-- ВКЛАДКА 3: ОПЦИИ И ЗАКРЫТИЕ
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
    getgenv().NeuroAI_Active = false; getgenv().RGB_Enabled = false; ScreenGui:Destroy()
end)

-- Системное уведомление
game:GetService("StarterGui"):SetCore("ChatMakeSystemMessage", {
    Text = "[Legenda32Hub]: Сборка v50 с локальным NLP ИИ-чатом успешно запущена в Delta Executor!",
    Color = Color3.fromRGB(75, 255, 75), Font = Enum.Font.GothamBold, TextSize = 14
})
