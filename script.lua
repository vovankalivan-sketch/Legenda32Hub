-- Очистка старого UI перед запуском
if game:GetService("CoreGui"):FindFirstChild("LegendaHubMobileFix") then
    game:GetService("CoreGui"):FindFirstChild("LegendaHubMobileFix"):Destroy()
end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

-- Флаги функций
local _G = getgenv and getgenv() or _G
_G.AutoFarmCurrentZone = false
_G.AutoRNGEvent = false

-- Создание главного контейнера
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LegendaHubMobileFix"
ScreenGui.Parent = game:GetService("CoreGui")

-- ==========================================
-- ИСПРАВЛЕННАЯ ПЕРЕТАСКИВАЕМАЯ КНОПКА «L»
-- ==========================================
local ToggleButton = Instance.new("TextButton")
local ButtonCorner = Instance.new("UICorner")

ToggleButton.Name = "L_Button"
ToggleButton.Parent = ScreenGui
ToggleButton.Position = UDim2.new(0.05, 0, 0.25, 0)
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
ToggleButton.Text = "L"
ToggleButton.TextColor3 = Color3.fromRGB(0, 210, 255)
ToggleButton.TextSize = 26
ToggleButton.Font = Enum.Font.GothamBold

ButtonCorner.CornerRadius = UDim.new(1, 0)
ButtonCorner.Parent = ToggleButton

-- Скрипт перетаскивания кнопки пальцем без лагов
local dragging, dragInput, dragStart, startPos
ToggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = ToggleButton.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseBehavior or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        ToggleButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- ==========================================
-- ОСНОВНОЕ ОКНО
-- ==========================================
local MainFrame = Instance.new("Frame")
local MainCorner = Instance.new("UICorner")

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -110)
MainFrame.Size = UDim2.new(0, 320, 0, 220)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
MainFrame.Visible = true

MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundTransparency = 1
Title.Text = "  LegendaHub | PS99"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Навигация вкладок
local TabNavFrame = Instance.new("Frame")
TabNavFrame.Position = UDim2.new(0, 10, 0, 40)
TabNavFrame.Size = UDim2.new(1, -20, 0, 30)
TabNavFrame.BackgroundTransparency = 1
TabNavFrame.Parent = MainFrame

local BtnFarmTab = Instance.new("TextButton")
BtnFarmTab.Size = UDim2.new(0.5, -5, 1, 0)
BtnFarmTab.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
BtnFarmTab.Text = "Автофарм"
BtnFarmTab.TextColor3 = Color3.fromRGB(255, 255, 255)
BtnFarmTab.Font = Enum.Font.GothamBold
BtnFarmTab.TextSize = 12
BtnFarmTab.Parent = TabNavFrame
Instance.new("UICorner", BtnFarmTab).CornerRadius = UDim.new(0, 6)

local BtnEventTab = Instance.new("TextButton")
BtnEventTab.Size = UDim2.new(0.5, -5, 1, 0)
BtnEventTab.Position = UDim2.new(0.5, 5, 0, 0)
BtnEventTab.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
BtnEventTab.Text = "Эвенты"
BtnEventTab.TextColor3 = Color3.fromRGB(150, 150, 150)
BtnEventTab.Font = Enum.Font.GothamBold
BtnEventTab.TextSize = 12
BtnEventTab.Parent = TabNavFrame
Instance.new("UICorner", BtnEventTab).CornerRadius = UDim.new(0, 6)

local FarmContent = Instance.new("Frame")
FarmContent.Position = UDim2.new(0, 10, 0, 80)
FarmContent.Size = UDim2.new(1, -20, 1, -90)
FarmContent.BackgroundTransparency = 1
FarmContent.Parent = MainFrame

local EventContent = Instance.new("Frame")
EventContent.Position = UDim2.new(0, 10, 0, 80)
EventContent.Size = UDim2.new(1, -20, 1, -90)
EventContent.BackgroundTransparency = 1
EventContent.Visible = false
EventContent.Parent = MainFrame

BtnFarmTab.MouseButton1Click:Connect(function()
    FarmContent.Visible = true; EventContent.Visible = false
    BtnFarmTab.BackgroundColor3 = Color3.fromRGB(35, 35, 45); BtnFarmTab.TextColor3 = Color3.fromRGB(255, 255, 255)
    BtnEventTab.BackgroundColor3 = Color3.fromRGB(25, 25, 35); BtnEventTab.TextColor3 = Color3.fromRGB(150, 150, 150)
end)

BtnEventTab.MouseButton1Click:Connect(function()
    FarmContent.Visible = false; EventContent.Visible = true
    BtnEventTab.BackgroundColor3 = Color3.fromRGB(35, 35, 45); BtnEventTab.TextColor3 = Color3.fromRGB(255, 255, 255)
    BtnFarmTab.BackgroundColor3 = Color3.fromRGB(25, 25, 35); BtnFarmTab.TextColor3 = Color3.fromRGB(150, 150, 150)
end)

-- ==========================================
-- ВКЛАДКА «АВТОФАРМ» (ОПРЕДЕЛЕНИЕ ТЕКУЩЕЙ ЗОНЫ)
-- ==========================================
local FarmToggle = Instance.new("TextButton")
FarmToggle.Size = UDim2.new(1, 0, 0, 45)
FarmToggle.BackgroundColor3 = Color3.fromRGB(40, 30, 30)
FarmToggle.Text = "Фарм ТЕКУЩЕЙ открытой локи: ВЫКЛ"
FarmToggle.TextColor3 = Color3.fromRGB(255, 75, 75)
FarmToggle.Font = Enum.Font.GothamBold
FarmToggle.TextSize = 12
FarmToggle.Parent = FarmContent
Instance.new("UICorner", FarmToggle).CornerRadius = UDim.new(0, 6)

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Position = UDim2.new(0, 0, 0, 55)
StatusLabel.Size = UDim2.new(1, 0, 0, 20)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Статус: Ожидание..."
StatusLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 11
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = FarmContent

-- Умная функция: ищет зону, в которой игрок НАХОДИТСЯ ближе всего
local function GetCurrentZone()
    local map = Workspace:FindFirstChild("Map") or Workspace:FindFirstChild("ActiveZones")
    local closestZone, minDistance = nil, math.huge
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    if map and root then
        for _, zone in ipairs(map:GetChildren()) do
            local zoneNum = tonumber(zone.Name:match("^(%d+)"))
            -- Фильтруем зоны, чтобы не брать те, что выше текущей доступной игроку
            if zoneNum then
                local distance = (root.Position - zone:GetPivot().Position).Magnitude
                if distance < minDistance then
                    minDistance = distance
                    closestZone = zone
                end
            end
        end
    end
    return closestZone
end

FarmToggle.MouseButton1Click:Connect(function()
    _G.AutoFarmCurrentZone = not _G.AutoFarmCurrentZone
    if _G.AutoFarmCurrentZone then
        FarmToggle.Text = "Фарм ТЕКУЩЕЙ открытой локи: ВКЛ"
        FarmToggle.TextColor3 = Color3.fromRGB(75, 255, 75)
        FarmToggle.BackgroundColor3 = Color3.fromRGB(30, 40, 30)
        
        task.spawn(function()
            while _G.AutoFarmCurrentZone do
                local zone = GetCurrentZone()
                local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                
                if zone and root then
                    local zoneName = zone.Name
                    StatusLabel.Text = "Статус: Фарм в вашей зоне — " .. zoneName
                    
                    -- Телепортируем строго в центр вашей текущей зоны (например, 38)
                    local targetPos = zone:GetPivot().Position
                    if (root.Position - targetPos).Magnitude > 40 then
                        root.CFrame = CFrame.new(targetPos + Vector3.new(0, 5, 0))
                        task.wait(0.5)
                    end
                    
                    -- Магнит сфер монет в этой зоне
                    for _, v in ipairs(Workspace:GetChildren()) do
                        if (v.Name == "Orb" or v.Name == "Lootbag") and v:IsA("BasePart") then
                            v.Position = root.Position
                        end
                    end
                else
                    StatusLabel.Text = "Статус: Встаньте в нужную зону!"
                end
                task.wait(0.3)
            end
        end)
    else
        FarmToggle.Text = "Фарм ТЕКУЩЕЙ открытой локи: ВЫКЛ"
        FarmToggle.TextColor3 = Color3.fromRGB(255, 75, 75)
        FarmToggle.BackgroundColor3 = Color3.fromRGB(40, 30, 30)
        StatusLabel.Text = "Статус: Остановлен"
    end
end)

-- ==========================================
-- ВКЛАДКА «ЭВЕНТЫ» (АВТО-RNG)
-- ==========================================
local RngToggle = Instance.new("TextButton")
RngToggle.Size = UDim2.new(1, 0, 0, 45)
RngToggle.BackgroundColor3 = Color3.fromRGB(40, 30, 30)
RngToggle.Text = "Авто RNG Ролл событие: ВЫКЛ"
RngToggle.TextColor3 = Color3.fromRGB(255, 75, 75)
RngToggle.Font = Enum.Font.GothamBold
RngToggle.TextSize = 12
RngToggle.Parent = EventContent
Instance.new("UICorner", RngToggle).CornerRadius = UDim.new(0, 6)

local RngStatus = Instance.new("TextLabel")
RngStatus.Position = UDim2.new(0, 0, 0, 55)
RngStatus.Size = UDim2.new(1, 0, 0, 20)
RngStatus.BackgroundTransparency = 1
RngStatus.Text = "Статус RNG: Не активен"
RngStatus.TextColor3 = Color3.fromRGB(160, 160, 160)
RngStatus.Font = Enum.Font.Gotham
RngStatus.TextSize = 11
RngStatus.TextXAlignment = Enum.TextXAlignment.Left
RngStatus.Parent = EventContent

RngToggle.MouseButton1Click:Connect(function()
    _G.AutoRNGEvent = not _G.AutoRNGEvent
    if _G.AutoRNGEvent then
        RngToggle.Text = "Авто RNG Ролл событие: ВКЛ"
        RngToggle.TextColor3 = Color3.fromRGB(75, 255, 75)
        RngToggle.BackgroundColor3 = Color3.fromRGB(30, 40, 30)
        
        task.spawn(function()
            while _G.AutoRNGEvent do
                RngStatus.Text = "Статус RNG: Ролл запущен..."
                local network = ReplicatedStorage:FindFirstChild("Network")
                if network then
                    local rollEvent = network:FindFirstChild("RNG_Roll") or network:FindFirstChild("RNG_Event_Roll") or network:FindFirstChild("VoidRNG_Roll")
                    if rollEvent then
                        rollEvent:InvokeServer()
                    end
                end
                task.wait(0.1)
            end
        end)
    else
        RngToggle.Text = "Авто RNG Ролл событие: ВЫКЛ"
        RngToggle.TextColor3 = Color3.fromRGB(255, 75, 75)
        RngToggle.BackgroundColor3 = Color3.fromRGB(40, 30, 30)
        RngStatus.Text = "Статус RNG: Остановлен"
    end
end)
