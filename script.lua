-- ====================================================================
-- LEGENDA32HUB | ПОЛНОСТЬЮ ЛЕГИТНАЯ СИСТЕМА АВТО-БЕГА И ФАРМА (БЕЗ ТП)
-- ====================================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local PathfindingService = game:GetService("PathfindingService")

-- Очистка старых GUI
if LocalPlayer.PlayerGui:FindFirstChild("LegendaHubLegit") then 
    LocalPlayer.PlayerGui.LegendaHubLegit:Destroy() 
end

-- Флаги управления
getgenv().AutoLegitWalk = false
getgenv().AutoLegitClick = false
getgenv().AutoRNGEvent = false
getgenv().RGB_Enabled = false
getgenv().SelectedLegitZone = "38" -- Ваша целевая зона для бега и фарма

-- Матрица ошибок (1-не работает, 2-ошибка патча, 3-функция недоступна)
local function reportHubError(funcName, errorCode, rawErr)
    pcall(function()
        local descriptions = {
            [1] = "Не работает (Сбой поиска пути)",
            [2] = "Ошибка патча (Изменена геометрия карты)",
            [3] = "Функция недоступна (Заблокировано движком)"
        }
        game:GetService("StarterGui"):SetCore("ChatMakeSystemMessage", {
            Text = string.format("[Legenda32Hub LEGIT ERROR] %s -> Код %d: %s", funcName, errorCode, descriptions[errorCode]),
            Color = Color3.fromRGB(255, 100, 100),
            Font = Enum.Font.GothamBold,
            TextSize = 13
        })
    end)
end

-- Функция легитного бега по точкам (Pathfinding)
local function LegitMoveTo(targetPosition)
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    
    if humanoid and rootPart then
        local path = PathfindingService:CreatePath({
            AgentRadius = 2,
            AgentHeight = 5,
            AgentCanJump = true
        })
        
        local success, err = pcall(function()
            path:ComputeAsync(rootPart.Position, targetPosition)
        end)
        
        if success and path.Status == Enum.PathStatus.Success then
            local waypoints = path:GetWaypoints()
            for _, waypoint in ipairs(waypoints) do
                if not getgenv().AutoLegitWalk then break end
                
                -- Если на пути стена, симулируем прыжок
                if waypoint.Action == Enum.WaypointAction.Jump then
                    humanoid.Jump = true
                end
                
                humanoid:MoveTo(waypoint.Position)
                -- Ждем пока персонаж дойдет до точки маршрута
                local distance = (rootPart.Position - waypoint.Position).Magnitude
                local timeout = 0
                while distance > 3 and getgenv().AutoLegitWalk and timeout < 20 do
                    task.wait(0.05)
                    distance = (rootPart.Position - waypoint.Position).Magnitude
                    timeout = timeout + 1
                end
            end
        else
            reportHubError("LegitMoveTo", 1, err)
        end
    end
end

-- Создание интерфейса в PlayerGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LegendaHubLegit"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Кнопка "L"
local ToggleButton = Instance.new("TextButton")
local ButtonCorner = Instance.new("UICorner")
ToggleButton.Name = "L_Button"
ToggleButton.Parent = ScreenGui
ToggleButton.Position = UDim2.new(0.85, 0, 0.12, 0)
ToggleButton.Size = UDim2.new(0, 45, 0, 45)
ToggleButton.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
ToggleButton.Text = "L"
ToggleButton.TextColor3 = Color3.fromRGB(0, 210, 255)
ToggleButton.TextSize = 22
ToggleButton.Font = Enum.Font.GothamBold
ButtonCorner.CornerRadius = UDim.new(0, 10)
ButtonCorner.Parent = ToggleButton

-- Touch-перетаскивание кнопки
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
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)

-- Главная панель
local MainFrame = Instance.new("Frame")
local MainCorner = Instance.new("UICorner")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -110)
MainFrame.Size = UDim2.new(0, 300, 0, 220)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
MainFrame.Visible = true
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundTransparency = 1
Title.Text = "  Legenda32Hub | Legit AI System"
Title.TextColor3 = Color3.fromRGB(0, 210, 255)
Title.TextSize = 14
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

ToggleButton.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

-- Вкладки
local TabNavFrame = Instance.new("Frame")
TabNavFrame.Position = UDim2.new(0, 8, 0, 35)
TabNavFrame.Size = UDim2.new(1, -16, 0, 30)
TabNavFrame.BackgroundTransparency = 1
TabNavFrame.Parent = MainFrame

local tabs = {"Авто-Бег", "Эвенты", "Опции"}
local tabFrames = {}
local tabButtons = {}

for i, tabName in ipairs(tabs) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.32, 0, 1, 0)
    btn.Position = UDim2.new((i-1)*0.33, 0, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    btn.Text = tabName
    btn.TextColor3 = Color3.fromRGB(140, 140, 140)
    btn.Font = Enum.Font.GothamBold; btn.TextSize = 11; btn.Parent = TabNavFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
    
    local content = Instance.new("ScrollingFrame")
    content.Position = UDim2.new(0, 10, 0, 75)
    content.Size = UDim2.new(1, -20, 1, -85)
    content.BackgroundTransparency = 1; content.CanvasSize = UDim2.new(0, 0, 2, 0)
    content.ScrollBarThickness = 2; content.Visible = (i == 1); content.Parent = MainFrame
    
    tabFrames[tabName] = content; tabButtons[tabName] = btn
    
    btn.MouseButton1Click:Connect(function()
        for _, f in pairs(tabFrames) do f.Visible = false end
        for _, b in pairs(tabButtons) do b.BackgroundColor3 = Color3.fromRGB(25, 25, 35); b.TextColor3 = Color3.fromRGB(140, 140, 140) end
        content.Visible = true; btn.BackgroundColor3 = Color3.fromRGB(40, 40, 55); btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)
end
tabButtons["Авто-Бег"].BackgroundColor3 = Color3.fromRGB(40, 40, 55); tabButtons["Авто-Бег"].TextColor3 = Color3.fromRGB(255, 255, 255)

-- ==========================================
-- КОНТЕНТ ВКЛАДКИ «АВТО-БЕГ» (УМНЫЙ ЛЕГИТНЫЙ АИ)
-- ==========================================
local WalkToggle = Instance.new("TextButton")
WalkToggle.Size = UDim2.new(1, 0, 0, 40)
WalkToggle.BackgroundColor3 = Color3.fromRGB(45, 30, 30)
WalkToggle.Text = "Умный Авто-Бег до Зоны 38: ВЫКЛ"
WalkToggle.TextColor3 = Color3.fromRGB(255, 75, 75)
WalkToggle.Font = Enum.Font.GothamBold; WalkToggle.TextSize = 11; WalkToggle.Parent = tabFrames["Авто-Бег"]
Instance.new("UICorner", WalkToggle).CornerRadius = UDim.new(0, 6)

local ClickToggle = Instance.new("TextButton")
ClickToggle.Size = UDim2.new(1, 0, 0, 40)
ClickToggle.Position = UDim2.new(0, 0, 0, 45)
ClickToggle.BackgroundColor3 = Color3.fromRGB(45, 30, 30)
ClickToggle.Text = "Легитный Кликер по монетам: ВЫКЛ"
ClickToggle.TextColor3 = Color3.fromRGB(255, 75, 75)
ClickToggle.Font = Enum.Font.GothamBold; ClickToggle.TextSize = 11; ClickToggle.Parent = tabFrames["Авто-Бег"]
Instance.new("UICorner", ClickToggle).CornerRadius = UDim.new(0, 6)

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Position = UDim2.new(0, 0, 0, 90); StatusLabel.Size = UDim2.new(1, 0, 0, 20)
StatusLabel.BackgroundTransparency = 1; StatusLabel.Text = "Статус АИ: Ожидание команд..."
StatusLabel.TextColor3 = Color3.fromRGB(160, 160, 160); StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 11; StatusLabel.TextXAlignment = Enum.TextXAlignment.Left; StatusLabel.Parent = tabFrames["Авто-Бег"]

-- Логика Авто-Бега
WalkToggle.MouseButton1Click:Connect(function()
    getgenv().AutoLegitWalk = not getgenv().AutoLegitWalk
    if getgenv().AutoLegitWalk then
        WalkToggle.Text = "Умный Авто-Бег до Зоны 38: ВКЛ"
        WalkToggle.TextColor3 = Color3.fromRGB(75, 255, 75); WalkToggle.BackgroundColor3 = Color3.fromRGB(30, 45, 30)
        
        task.spawn(function()
            while getgenv().AutoLegitWalk do
                StatusLabel.Text = "Статус АИ: Поиск Зоны " .. getgenv().SelectedLegitZone .. " на карте..."
                
                -- Ищем физический объект папки зоны в игре
                local map = Workspace:FindFirstChild("Map") or Workspace:FindFirstChild("ActiveZones")
                local targetZoneObj = nil
                if map then
                    for _, zone in ipairs(map:GetChildren()) do
                        if zone.Name:match("^" .. getgenv().SelectedLegitZone .. "%s") or zone.Name == getgenv().SelectedLegitZone then
                            targetZoneObj = zone; break
                        end
                    end
                end
                
                if targetZoneObj then
                    StatusLabel.Text = "Статус АИ: Маршрут построен. Бежим в зону..."
                    local targetPos = targetZoneObj:GetPivot().Position
                    LegitMoveTo(targetPos) -- Вызов функции физического бега по точкам
                    
                    if getgenv().AutoLegitWalk then
                        StatusLabel.Text = "Статус АИ: Успешно прибыли в целевую локацию!"
                    end
                    break
                else
                    reportHubError("AutoLegitWalk", 2, "Зона не найдена")
                    task.wait(2)
                end
            end
        end)
    else
        WalkToggle.Text = "Умный Авто-Бег до Зоны 38: ВЫКЛ"
        WalkToggle.TextColor3 = Color3.fromRGB(255, 75, 75); WalkToggle.BackgroundColor3 = Color3.fromRGB(45, 30, 30)
        StatusLabel.Text = "Статус АИ: Остановлен."
    end
end)

-- Логика легитного кликера
ClickToggle.MouseButton1Click:Connect(function()
    getgenv().AutoLegitClick = not getgenv().AutoLegitClick
    if getgenv().AutoLegitClick then
        ClickToggle.Text = "Легитный Кликер по монетам: ВКЛ"
        ClickToggle.TextColor3 = Color3.fromRGB(75, 255, 75); ClickToggle.BackgroundColor3 = Color3.fromRGB(30, 45, 30)
        
        task.spawn(function()
            local vu = game:GetService("VirtualUser")
            while getgenv().AutoLegitClick do
                pcall(function()
                    -- Симулируем естественные тапы по центру экрана пальцем
                    vu:Button1Down(Vector2.new(windowWidth or 200, windowHeight or 200), workspace.CurrentCamera.CFrame)
                end)
                task.wait(0.08) -- Безопасная скорость легитного клика
            end
        end)
    else
        ClickToggle.Text = "Легитный Кликер по монетам: ВЫКЛ"
        ClickToggle.TextColor3 = Color3.fromRGB(255, 75, 75); ClickToggle.BackgroundColor3 = Color3.fromRGB(45, 30, 30)
    end
end)

-- ==========================================
-- ОСТАЛЬНЫЕ ВКЛАДКИ (ЭВЕНТЫ И ОПЦИИ)
-- ==========================================
local RngToggle = Instance.new("TextButton")
RngToggle.Size = UDim2.new(1, 0, 0, 40); RngToggle.BackgroundColor3 = Color3.fromRGB(45, 30, 30)
RngToggle.Text = "Авто RNG Ролл: ВЫКЛ"; RngToggle.TextColor3 = Color3.fromRGB(255, 75, 75)
RngToggle.Font = Enum.Font.GothamBold; RngToggle.TextSize = 11; RngToggle.Parent = tabFrames["Эвенты"]
Instance.new("UICorner", RngToggle).CornerRadius = UDim.new(0, 6)

RngToggle.MouseButton1Click:Connect(function()
    getgenv().AutoRNGEvent = not getgenv().AutoRNGEvent
    if getgenv().AutoRNGEvent then
        RngToggle.Text = "Авто RNG Ролл: ВКЛ"; RngToggle.TextColor3 = Color3.fromRGB(75, 255, 75); RngToggle.BackgroundColor3 = Color3.fromRGB(30, 45, 30)
        task.spawn(function()
            while getgenv().AutoRNGEvent do
                pcall(function()
                    local net = ReplicatedStorage.Network
                    local remote = net:FindFirstChild("RNG_Roll") or net:FindFirstChild("RNG_Event_Roll") or net:FindFirstChild("VoidRNG_Roll")
                    if remote then remote:InvokeServer() end
                end)
                task.wait(0.1)
            end
        end)
    else
        RngToggle.Text = "Авто RNG Ролл: ВЫКЛ"; RngToggle.TextColor3 = Color3.fromRGB(255, 75, 75); RngToggle.BackgroundColor3 = Color3.fromRGB(45, 30, 30)
    end
end)

local RgbToggle = Instance.new("TextButton")
RgbToggle.Size = UDim2.new(1, 0, 0, 35); RgbToggle.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
RgbToggle.Text = "Переливающийся RGB режим: ВЫКЛ"; RgbToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
RgbToggle.Font = Enum.Font.GothamBold; RgbToggle.TextSize = 11; RgbToggle.Parent = tabFrames["Опции"]
Instance.new("UICorner", RgbToggle).CornerRadius = UDim.new(0, 6)

local ShutdownButton = Instance.new("TextButton")
ShutdownButton.Size = UDim2.new(1, 0, 0, 35); ShutdownButton.Position = UDim2.new(0, 0, 0, 45)
ShutdownButton.BackgroundColor3 = Color3.fromRGB(65, 25, 25); ShutdownButton.Text = "ПОЛНОСТЬЮ УДАЛИТЬ СКРИПТ"
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
        RgbToggle.Text = "Переливающийся RGB режим: ВКЛ"; RgbToggle.TextColor3 = Color3.fromRGB(75, 255, 75)
    else
        RgbToggle.Text = "Переливающийся RGB режим: ВЫКЛ"; RgbToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
        Title.TextColor3 = Color3.fromRGB(0, 210, 255); ToggleButton.TextColor3 = Color3.fromRGB(0, 210, 255)
    end
end)

ShutdownButton.MouseButton1Click:Connect(function()
    getgenv().AutoLegitWalk = false; getgenv().AutoLegitClick = false; getgenv().AutoRNGEvent = false; getgenv().RGB_Enabled = false; ScreenGui:Destroy()
end)

game:GetService("StarterGui"):SetCore("ChatMakeSystemMessage", {
    Text = "[Legenda32Hub]: Абсолютно легитная ИИ-система запущена. Обход через физику включен.",
    Color = Color3.fromRGB(75, 255, 75), Font = Enum.Font.GothamBold, TextSize = 14
})
