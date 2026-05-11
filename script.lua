-- Очистка старого UI перед запуском
if game:GetService("CoreGui"):FindFirstChild("LegendaHubMobileFix") then
    game:GetService("CoreGui"):FindFirstChild("LegendaHubMobileFix"):Destroy()
end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Флаги функций
local _G = getgenv and getgenv() or _G
_G.AutoFarmLastZone = false
_G.AutoRNGEvent = false

-- Создание главного контейнера
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LegendaHubMobileFix"
ScreenGui.Parent = game:GetService("CoreGui")

-- ==========================================
-- КНОПКА «L» ДЛЯ ОТОБРАЖЕНИЯ МЕНЮ
-- ==========================================
local ToggleButton = Instance.new("TextButton")
local ButtonCorner = Instance.new("UICorner")

ToggleButton.Name = "L_Button"
ToggleButton.Parent = ScreenGui
ToggleButton.Position = UDim2.new(0.02, 0, 0.25, 0)
ToggleButton.Size = UDim2.new(0, 45, 0, 45)
ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
ToggleButton.Text = "L"
ToggleButton.TextColor3 = Color3.fromRGB(0, 210, 255)
ToggleButton.TextSize = 24
ToggleButton.Font = Enum.Font.GothamBold

ButtonCorner.CornerRadius = UDim.new(1, 0)
ButtonCorner.Parent = ToggleButton

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

-- Заголовок хаба
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundTransparency = 1
Title.Text = "  LegendaHub | PS99"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

-- Переключатель видимости по кнопке L
ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- ==========================================
-- КНОПКИ ПЕРЕКЛЮЧЕНИЯ ВКЛАДОК (НАВИГАЦИЯ)
-- ==========================================
local TabNavFrame = Instance.new("Frame")
TabNavFrame.Position = UDim2.new(0, 10, 0, 40)
TabNavFrame.Size = UDim2.new(1, -20, 0, 30)
TabNavFrame.BackgroundTransparency = 1
TabNavFrame.Parent = MainFrame

local BtnFarmTab = Instance.new("TextButton")
BtnFarmTab.Size = UDim2.new(0.5, -5, 1, 0)
BtnFarmTab.Position = UDim2.new(0, 0, 0, 0)
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

-- Контейнеры для содержимого вкладок
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

-- Логика переключения контейнеров
BtnFarmTab.MouseButton1Click:Connect(function()
    FarmContent.Visible = true
    EventContent.Visible = false
    BtnFarmTab.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    BtnFarmTab.TextColor3 = Color3.fromRGB(255, 255, 255)
    BtnEventTab.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    BtnEventTab.TextColor3 = Color3.fromRGB(150, 150, 150)
end)

BtnEventTab.MouseButton1Click:Connect(function()
    FarmContent.Visible = false
    EventContent.Visible = true
    BtnEventTab.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    BtnEventTab.TextColor3 = Color3.fromRGB(255, 255, 255)
    BtnFarmTab.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    BtnFarmTab.TextColor3 = Color3.fromRGB(150, 150, 150)
end)

-- ==========================================
-- СОДЕРЖИМОЕ ВКЛАДКИ «АВТОФАРМ»
-- ==========================================
local FarmToggle = Instance.new("TextButton")
FarmToggle.Size = UDim2.new(1, 0, 0, 45)
FarmToggle.BackgroundColor3 = Color3.fromRGB(40, 30, 30)
FarmToggle.Text = "Фарм последней открытой локи: ВЫКЛ"
FarmToggle.TextColor3 = Color3.fromRGB(255, 75, 75)
FarmToggle.Font = Enum.Font.GothamBold
FarmToggle.TextSize = 12
FarmToggle.Parent = FarmContent
Instance.new("UICorner", FarmToggle).CornerRadius = UDim.new(0, 6)

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Position = UDim2.new(0, 0, 0, 55)
StatusLabel.Size = UDim2.new(1, 0, 0, 20)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Статус ТП: Ожидание..."
StatusLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 11
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = FarmContent

-- Функция поиска последней зоны на карте
local function GetLastZone()
    local map = Workspace:FindFirstChild("Map") or Workspace:FindFirstChild("ActiveZones")
    local maxNum, bestZone = 0, nil
    if map then
        for _, z in ipairs(map:GetChildren()) do
            local num = tonumber(z.Name:match("^(%d+)"))
            if num and num > maxNum then
                maxNum = num
                bestZone = z
            end
        end
    end
    return bestZone, maxNum
end

FarmToggle.MouseButton1Click:Connect(function()
    _G.AutoFarmLastZone = not _G.AutoFarmLastZone
    if _G.AutoFarmLastZone then
        FarmToggle.Text = "Фарм последней открытой локи: ВКЛ"
        FarmToggle.TextColor3 = Color3.fromRGB(75, 255, 75)
        FarmToggle.BackgroundColor3 = Color3.fromRGB(30, 40, 30)
        
        task.spawn(function()
            while _G.AutoFarmLastZone do
                local zone, num = GetLastZone()
                if zone and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    StatusLabel.Text = "Статус ТП: Локация найдена (Зона " .. tostring(num) .. ")"
                    local cf = zone:GetPivot().Position
                    local root = LocalPlayer.Character.HumanoidRootPart
                    if (root.Position - cf).Magnitude > 60 then
                        root.CFrame = CFrame.new(cf + Vector3.new(0, 6, 0))
                        task.wait(1)
                    end
                    -- Автоматическое притягивание Orbs
                    for _, v in ipairs(Workspace:GetChildren()) do
                        if (v.Name == "Orb" or v.Name == "Lootbag") and v:IsA("BasePart") then
                            v.Position = root.Position
                        end
                    end
                else
                    StatusLabel.Text = "Статус ТП: Ошибка сканирования карты"
                end
                task.wait(0.3)
            end
        end)
    else
        FarmToggle.Text = "Фарм последней открытой локи: ВЫКЛ"
        FarmToggle.TextColor3 = Color3.fromRGB(255, 75, 75)
        FarmToggle.BackgroundColor3 = Color3.fromRGB(40, 30, 30)
        StatusLabel.Text = "Статус ТП: Остановлен"
    end
end)

-- ==========================================
-- СОДЕРЖИМОЕ ВКЛАДКИ «ЭВЕНТЫ» (АВТО-RNG)
-- ==========================================
local RngToggle = Instance.new("TextButton")
local RngCorner = Instance.new("UICorner")

RngToggle.Size = UDim2.new(1, 0, 0, 45)
RngToggle.BackgroundColor3 = Color3.fromRGB(40, 30, 30)
RngToggle.Text = "Авто RNG Ролл событие: ВЫКЛ"
RngToggle.TextColor3 = Color3.fromRGB(255, 75, 75)
RngToggle.Font = Enum.Font.GothamBold
RngToggle.TextSize = 12

RngCorner.CornerRadius = UDim.new(0, 6)
RngCorner.Parent = RngToggle
RngToggle.Parent = EventContent

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

-- Логика Авто RNG Ролла
RngToggle.MouseButton1Click:Connect(function()
    _G.AutoRNGEvent = not _G.AutoRNGEvent
    if _G.AutoRNGEvent then
        RngToggle.Text = "Авто RNG Ролл событие: ВКЛ"
        RngToggle.TextColor3 = Color3.fromRGB(75, 255, 75)
        RngToggle.BackgroundColor3 = Color3.fromRGB(30, 40, 30)
        
        task.spawn(function()
            while _G.AutoRNGEvent do
                RngStatus.Text = "Статус RNG: Крутим кубик (Roll)..."
                
                -- Эмуляция клика по удаленному событию RNG Ивента в PS99
                local network = ReplicatedStorage:FindFirstChild("Network")
                if network then
                    -- Посылаем сетевые сигналы ролла (работает как в обычной локации, так и в ивент-мире)
                    local rollEvent = network:FindFirstChild("RNG_Roll") or network:FindFirstChild("RNG_Event_Roll")
                    if rollEvent then
                        rollEvent:InvokeServer()
                    else
                        -- Резервный метод: нажатие кнопки через интерфейс, если ремот скрыт
                        pcall(function()
                            local gui = LocalPlayer.PlayerGui:FindFirstChild("RNGEvent") or LocalPlayer.PlayerGui:FindFirstChild("RNG")
                            if gui and gui:FindFirstChild("Main") and gui.Main:FindFirstChild("RollButton") then
                                    game:GetService("VirtualInputManager"):SendMouseButtonEvent(gui.Main.RollButton.AbsolutePosition.X + 10, gui.Main.RollButton.AbsolutePosition.Y + 10, 0, true, game, 1)
                                    game:GetService("VirtualInputManager"):SendMouseButtonEvent(gui.Main.RollButton.AbsolutePosition.X + 10, gui.Main.RollButton.AbsolutePosition.Y + 10, 0, false, game, 1)
                            end
                        end)
                    end
                end
                task.wait(0.2) -- Быстрый повтор ролла
            end
        end)
    else
        RngToggle.Text = "Авто RNG Ролл событие: ВЫКЛ"
        RngToggle.TextColor3 = Color3.fromRGB(255, 75, 75)
        RngToggle.BackgroundColor3 = Color3.fromRGB(40, 30, 30)
        RngStatus.Text = "Статус RNG: Остановлен"
    end
end)
