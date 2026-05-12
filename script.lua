-- Безопасная инициализация интерфейса для Xeno
local Player = game:GetService("Players").LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Удаляем старую копию, если она была
if PlayerGui:FindFirstChild("SkeetMenu") then
    PlayerGui.SkeetMenu:Destroy()
end

local SkeetMenu = Instance.new("ScreenGui")
SkeetMenu.Name = "SkeetMenu"
SkeetMenu.ResetOnSpawn = false
SkeetMenu.Parent = PlayerGui

-- Главное окно
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = SkeetMenu
MainFrame.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
MainFrame.BorderColor3 = Color3.fromRGB(40, 40, 40)
MainFrame.BorderSizePixel = 1
MainFrame.Position = UDim2.new(0.3, 0, 0.25, 0)
MainFrame.Size = UDim2.new(0, 450, 0, 320)

-- Зеленая полоса Skeet сверху
local DecorationBar = Instance.new("Frame")
DecorationBar.Name = "DecorationBar"
DecorationBar.Parent = MainFrame
DecorationBar.BackgroundColor3 = Color3.fromRGB(163, 212, 47)
DecorationBar.BorderSizePixel = 0
DecorationBar.Size = UDim2.new(1, 0, 0, 3)

-- Панель вкладок (слева)
local LeftPanel = Instance.new("Frame")
LeftPanel.Name = "LeftPanel"
LeftPanel.Parent = MainFrame
LeftPanel.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
LeftPanel.BorderColor3 = Color3.fromRGB(30, 30, 30)
LeftPanel.Position = UDim2.new(0, 6, 0, 10)
LeftPanel.Size = UDim2.new(0, 100, 1, -16)

local TabContainer = Instance.new("UIListLayout")
TabContainer.Parent = LeftPanel
TabContainer.SortOrder = Enum.SortOrder.LayoutOrder

-- Панель контента (справа)
local ContentPanel = Instance.new("Frame")
ContentPanel.Name = "ContentPanel"
ContentPanel.Parent = MainFrame
ContentPanel.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
ContentPanel.BorderColor3 = Color3.fromRGB(30, 30, 30)
ContentPanel.Position = UDim2.new(0, 112, 0, 10)
ContentPanel.Size = UDim2.new(1, -118, 1, -16)

local ElementsList = Instance.new("UIListLayout")
ElementsList.Parent = ContentPanel
ElementsList.Padding = UDim.new(0, 6)

-- Скрипт плавного перетаскивания (Совместим с Xeno)
local UserInputService = game:GetService("UserInputService")
local dragging, dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- Конструктор вкладок
local function CreateTab(name, order)
    local Tab = Instance.new("TextButton")
    Tab.Name = name .. "Tab"
    Tab.Parent = LeftPanel
    Tab.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    Tab.BorderSizePixel = 0
    Tab.Size = UDim2.new(1, 0, 0, 30)
    Tab.Font = Enum.Font.Code
    Tab.Text = name:upper()
    Tab.TextColor3 = Color3.fromRGB(140, 140, 140)
    Tab.TextSize = 11
    Tab.LayoutOrder = order

    Tab.MouseButton1Click:Connect(function()
        for _, child in pairs(LeftPanel:GetChildren()) do
            if child:IsA("TextButton") then
                child.TextColor3 = Color3.fromRGB(140, 140, 140)
            end
        end
        Tab.TextColor3 = Color3.fromRGB(163, 212, 47)
    end)
end

-- Конструктор чекбоксов
local function CreateToggle(name, default, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Name = name .. "Frame"
    ToggleFrame.Parent = ContentPanel
    ToggleFrame.BackgroundTransparency = 1
    ToggleFrame.Size = UDim2.new(1, 0, 0, 20)
    
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Name = "Button"
    ToggleButton.Parent = ToggleFrame
    ToggleButton.Position = UDim2.new(0, 8, 0, 4)
    ToggleButton.Size = UDim2.new(0, 11, 0, 11)
    ToggleButton.BorderSizePixel = 1
    ToggleButton.BorderColor3 = Color3.fromRGB(40, 40, 40)
    ToggleButton.Text = ""
    
    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Parent = ToggleFrame
    ToggleLabel.Position = UDim2.new(0, 26, 0, 0)
    ToggleLabel.Size = UDim2.new(1, -26, 1, 0)
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Font = Enum.Font.Code
    ToggleLabel.Text = name
    ToggleLabel.TextColor3 = Color3.fromRGB(210, 210, 210)
    ToggleLabel.TextSize = 11
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local enabled = default
    local function updateView()
        if enabled then
            ToggleButton.BackgroundColor3 = Color3.fromRGB(163, 212, 47)
        else
            ToggleButton.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
        end
        callback(enabled)
    end
    
    ToggleButton.MouseButton1Click:Connect(function()
        enabled = not enabled
        updateView()
    end)
    updateView()
end

-- Создание интерфейса
CreateTab("Rage", 1)
CreateTab("Legit", 2)
CreateTab("Visuals", 3)
CreateTab("Misc", 4)

-- Интеграция тестовых функций
CreateToggle("Aimbot Enabled", false, function(val) end)
CreateToggle("Silent Aim", false, function(val) end)
CreateToggle("ESP Boxes", false, function(val) end)
