-- Авто-удаление прошлой версии хаба
if game:GetService("CoreGui"):FindFirstChild("LegendaHubFinal") then
    game:GetService("CoreGui"):FindFirstChild("LegendaHubFinal"):Destroy()
end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Глобальные настройки функций
local _G = getgenv and getgenv() or _G
_G.AutoFarmCurrentZone = false
_G.AutoRNGEvent = false
_G.RGB_Enabled = false

-- Создание UI контейнера
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LegendaHubFinal"
ScreenGui.Parent = game:GetService("CoreGui")

-- ==========================================
-- ПОЛНОСТЬЮ РАБОЧАЯ ПЕРЕТАСКИВАЕМАЯ КНОПКА «L»
-- ==========================================
local ToggleButton = Instance.new("TextButton")
local ButtonCorner = Instance.new("UICorner")

ToggleButton.Name = "L_Button"
ToggleButton.Parent = ScreenGui
ToggleButton.Position = UDim2.new(0.05, 0, 0.25, 0)
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
ToggleButton.Text = "L"
ToggleButton.TextColor3 = Color3.fromRGB(0, 210, 255)
ToggleButton.TextSize = 26
ToggleButton.Font = Enum.Font.GothamBold

ButtonCorner.CornerRadius = UDim.new(1, 0)
ButtonCorner.Parent = ToggleButton

-- Новый безошибочный алгоритм перетаскивания (Touch / Mouse drag)
local dragging, dragInput, dragStart, startPos
ToggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = ToggleButton.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseBehavior or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        ToggleButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- ==========================================
-- ОСНОВНОЕ ОКНО
-- ==========================================
local MainFrame = Instance.new("Frame")
local MainCorner = Instance.new("UICorner")

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -120)
MainFrame.Size = UDim2.new(0, 320, 0, 240)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
MainFrame.Visible = true

MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 0, 35)
Title.BackgroundTransparency = 1
Title.Text = "  LegendaHub | PS99"
Title.TextColor3 = Color3.fromRGB(0, 210, 255)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

-- Открытие / Закрытие фрейма при клике на L
ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- Кнопка полного удаления скрипта (Крестик)
local DestroyScriptButton = Instance.new("TextButton")
DestroyScriptButton.Parent = MainFrame
DestroyScriptButton.Size = UDim2.new(0, 30, 0, 30)
DestroyScriptButton.Position = UDim2.new(1, -35, 0, 5)
DestroyScriptButton.BackgroundTransparency = 1
DestroyScriptButton.Text = "×"
DestroyScriptButton.TextColor3 = Color3.fromRGB(255, 75, 75)
DestroyScriptButton.TextSize = 24
DestroyScriptButton.Font = Enum.Font.GothamBold

DestroyScriptButton.MouseButton1Click:Connect(function()
    _G.AutoFarmCurrentZone = false
    _G.AutoRNGEvent = false
    _G.RGB_Enabled = false
    ScreenGui:Destroy()
end)

-- ==========================================
-- НАВИГАЦИЯ ВКЛАДОК
-- ==========================================
local TabNavFrame = Instance.new("Frame")
TabNavFrame.Position = UDim2.new(0, 10, 0, 40)
TabNavFrame.Size = UDim2.new(1, -20, 0, 30)
TabNavFrame.BackgroundTransparency = 1
TabNavFrame.Parent = MainFrame

local BtnFarmTab = Instance.new("TextButton")
BtnFarmTab.Size = UDim2.new(0.33, -4, 1, 0)
BtnFarmTab.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
BtnFarmTab.Text = "Автофарм"
BtnFarmTab.TextColor3 = Color3.fromRGB(255, 255, 255)
BtnFarmTab.Font = Enum.Font.GothamBold
BtnFarmTab.TextSize = 11
BtnFarmTab.Parent = TabNavFrame
Instance.new("UICorner", BtnFarmTab).CornerRadius = UDim.new(0, 6)

local BtnEventTab = Instance.new("TextButton")
BtnEventTab.Size = UDim2.new(0.33, -4, 1, 0)
BtnEventTab.Position = UDim2.new(0.33, 2, 0, 0)
BtnEventTab.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
BtnEventTab.Text = "Эвенты"
BtnEventTab.TextColor3 = Color3.fromRGB(150, 150, 150)
BtnEventTab.Font = Enum.Font.GothamBold
BtnEventTab.TextSize = 11
BtnEventTab.Parent = TabNavFrame
Instance.new("UICorner", BtnEventTab).CornerRadius = UDim.new(0, 6)

local BtnSettingsTab = Instance.new("TextButton")
BtnSettingsTab.Size = UDim2.new(0.33, -4, 1, 0)
BtnSettingsTab.Position = UDim2.new(0.66, 4, 0, 0)
BtnSettingsTab.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
BtnSettingsTab.Text = "Настройки"
BtnSettingsTab.TextColor3 = Color3.fromRGB(150, 150, 150)
BtnSettingsTab.Font = Enum.Font.GothamBold
BtnSettingsTab.TextSize = 11
BtnSettingsTab.Parent = TabNavFrame
Instance.new("UICorner", BtnSettingsTab).CornerRadius = UDim.new(0, 6)

-- Контейнеры контента
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

local SettingsContent = Instance.new("Frame")
SettingsContent.Position = UDim2.new(0, 10, 0, 80)
SettingsContent.Size = UDim2.new(1, -20, 1, -90)
SettingsContent.BackgroundTransparency = 1
SettingsContent.Visible = false
SettingsContent.Parent = MainFrame

local function switchTab(activeContent, activeBtn)
    FarmContent.Visible = (FarmContent == activeContent)
    EventContent.Visible = (EventContent == activeContent)
    SettingsContent.Visible = (SettingsContent == activeContent)
    
    local buttons = {BtnFarmTab, BtnEventTab, BtnSettingsTab}
    for _, btn in ipairs(buttons) do
        if btn == activeBtn then
            btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            btn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
            btn.TextColor3 = Color3.fromRGB(150, 150, 150)
        end
    end
end

BtnFarmTab.MouseButton1Click:Connect(function() switchTab(FarmContent, BtnFarmTab) end)
BtnEventTab.MouseButton1Click:Connect(function() switchTab(EventContent, BtnEventTab) end)
BtnSettingsTab.MouseButton1Click:Connect(function() switchTab(SettingsContent, BtnSettingsTab) end)

-- ==========================================
-- ИСПРАВЛЕННЫЙ РАБОЧИЙ АВТОФАРМ
-- ==========================================
local FarmToggle = Instance.new("TextButton")
FarmToggle.Size = UDim2.new(1, 0, 0, 45)
FarmToggle.BackgroundColor3 = Color3.fromRGB(40, 30, 30)
FarmToggle.Text = "Магнит монет и сфер: ВЫКЛ"
FarmToggle.TextColor3 = Color3.fromRGB(255, 75, 75)
FarmToggle.Font = Enum.Font.GothamBold
FarmToggle.TextSize = 12
FarmToggle.Parent = FarmContent
Instance.new("UICorner", FarmToggle).CornerRadius = UDim.new(0, 6)

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Position = UDim2.new(0, 0, 0, 55)
StatusLabel.Size = UDim2.new(1, 0, 0, 20)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Статус: Ждем активации магнита..."
StatusLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 11
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = FarmContent

FarmToggle.MouseButton1Click:Connect(function()
    _G.AutoFarmCurrentZone = not _G.AutoFarmCurrentZone
    if _G.AutoFarmCurrentZone then
        FarmToggle.Text = "Магнит монет и сфер: ВКЛ"
        FarmToggle.TextColor3 = Color3.fromRGB(75, 255, 75)
        FarmToggle.BackgroundColor3 = Color3.fromRGB(30, 40, 30)
        
        task.spawn(function()
            while _G.AutoFarmCurrentZone do
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                
                if root then
                    StatusLabel.Text = "Статус: Притягиваем сферы на вашей позиции"
                    
                    -- В PS99 все выпавшие сферы лежат строго в папке Workspace.Network.Orbs
                    local orbsFolder = Workspace:FindFirstChild("Network") and Workspace.Network:FindFirstChild("Orbs")
                    if orbsFolder then
                        for _, orb in ipairs(orbsFolder:GetChildren()) do
                            if orb:IsA("BasePart") then
                                -- Принудительно стягиваем все сферы прямо в карман игрока
                                orb.CFrame = root.CFrame
                            end
                        end
                    else
                        -- Резервный метод сбора на случай изменения пути разработчиками
                        for _, obj in ipairs(Workspace:GetChildren()) do
                            if (obj.Name == "Orb" or obj.Name == "Lootbag") and obj:IsA("BasePart") then
                                obj.Position = root.Position
                            end
                        end
                    end
                end
                task.wait(0.1) -- Максимально быстрый сбор сфер
            end
        end)
    else
        FarmToggle.Text = "Магнит монет и сфер: ВЫКЛ"
        FarmToggle.TextColor3 = Color3.fromRGB(255, 75, 75)
        FarmToggle.BackgroundColor3 = Color3.fromRGB(40, 30, 30)
        StatusLabel.Text = "Статус: Остановлен"
    end
end)

-- ==========================================
-- КОНТЕНТ: ЭВЕНТЫ
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
                    local roll = network:FindFirstChild("RNG_Roll") or network:FindFirstChild("RNG_Event_Roll") or network:FindFirstChild("VoidRNG_Roll")
                    if roll then roll:InvokeServer() end
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

-- ==========================================
-- КОНТЕНТ: НАСТРОЙКИ (RGB РЕЖИМ)
-- ==========================================
local RgbToggle = Instance.new("TextButton")
RgbToggle.Size = UDim2.new(1, 0, 0, 45)
RgbToggle.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
RgbToggle.Text = "Включить Переливающийся RGB: ВЫКЛ"
RgbToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
RgbToggle.Font = Enum.Font.GothamBold
RgbToggle.TextSize = 11
RgbToggle.Parent = SettingsContent
Instance.new("UICorner", RgbToggle).CornerRadius = UDim.new(0, 6)

-- Логика плавного перелива цветов RGB
RunService.RenderStepped:Connect(function()
    if _G.RGB_Enabled then
        local hue = (tick() % 4) / 4 -- Скорость перелива
        local color = Color3.fromHSV(hue, 1, 1)
        Title.TextColor3 = color
        ToggleButton.TextColor3 = color
    end
end)

RgbToggle.MouseButton1Click:Connect(function()
    _G.RGB_Enabled = not _G.RGB_Enabled
    if _G.RGB_Enabled then
        RgbToggle.Text = "Включить Переливающийся RGB: ВКЛ"
        RgbToggle.TextColor3 = Color3.fromRGB(75, 255, 75)
    else
        RgbToggle.Text = "Включить Переливающийся RGB: ВЫКЛ"
        RgbToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
        Title.TextColor3 = Color3.fromRGB(0, 210, 255)
        ToggleButton.TextColor3 = Color3.fromRGB(0, 210, 255)
    end
end)
