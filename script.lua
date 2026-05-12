-- Либа для создания интерфейса (Упрощенный вариант Skeet Style)
local SkeetMenu = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local LeftPanel = Instance.new("Frame")
local TabContainer = Instance.new("UIListLayout")
local ContentPanel = Instance.new("Frame")
local DecorationBar = Instance.new("Frame")

-- Настройки основного окна
SkeetMenu.Name = "SkeetMenu"
SkeetMenu.Parent = game.CoreGui
SkeetMenu.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

MainFrame.Name = "MainFrame"
MainFrame.Parent = SkeetMenu
MainFrame.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
MainFrame.BorderColor3 = Color3.fromRGB(40, 40, 40)
MainFrame.BorderSizePixel = 1
MainFrame.Position = UDim2.new(0.3, 0, 0.25, 0)
MainFrame.Size = UDim2.new(0, 550, 0, 400)
MainFrame.Active = true
MainFrame.Draggable = true -- Позволяет двигать меню

-- Фирменная градиентная полоска Skeet сверху
DecorationBar.Name = "DecorationBar"
DecorationBar.Parent = MainFrame
DecorationBar.BackgroundColor3 = Color3.fromRGB(150, 200, 60) -- Зеленый цвет Gamesense
DecorationBar.BorderSizePixel = 0
DecorationBar.Size = UDim2.new(1, 0, 0, 3)

-- Левая панель для вкладок (Rage, Legit, Visuals, Misc)
LeftPanel.Name = "LeftPanel"
LeftPanel.Parent = MainFrame
LeftPanel.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
LeftPanel.BorderColor3 = Color3.fromRGB(30, 30, 30)
LeftPanel.Position = UDim2.new(0, 5, 0, 10)
LeftPanel.Size = UDim2.new(0, 110, 1, -15)

TabContainer.Parent = LeftPanel
TabContainer.SortOrder = Enum.SortOrder.LayoutOrder
TabContainer.Padding = UDim.new(0, 2)

-- Правая панель для контента
ContentPanel.Name = "ContentPanel"
ContentPanel.Parent = MainFrame
ContentPanel.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
ContentPanel.BorderColor3 = Color3.fromRGB(30, 30, 30)
ContentPanel.Position = UDim2.new(0, 120, 0, 10)
ContentPanel.Size = UDim2.new(1, -125, 1, -15)

-- Функция создания вкладки
local function CreateTab(name, order)
    local Tab = Instance.new("TextButton")
    Tab.Name = name .. "Tab"
    Tab.Parent = LeftPanel
    Tab.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    Tab.BorderSizePixel = 0
    Tab.Size = UDim2.new(1, 0, 0, 35)
    Tab.Font = Enum.Font.Code
    Tab.Text = name:upper()
    Tab.TextColor3 = Color3.fromRGB(150, 150, 150)
    Tab.TextSize = 13
    Tab.LayoutOrder = order

    Tab.MouseButton1Click:Connect(function()
        for _, child in pairs(LeftPanel:GetChildren()) do
            if child:IsA("TextButton") then
                child.TextColor3 = Color3.fromRGB(150, 150, 150)
            end
        end
        Tab.TextColor3 = Color3.fromRGB(150, 200, 60) -- Подсветка активной вкладки
    end)
end

-- Функция создания чекбокса (Включателя)
local function CreateToggle(name, parent, default, callback)
    local ToggleFrame = Instance.new("Frame")
    local ToggleButton = Instance.new("TextButton")
    local ToggleLabel = Instance.new("TextLabel")
    
    ToggleFrame.Name = name .. "Frame"
    ToggleFrame.Parent = parent
    ToggleFrame.BackgroundTransparency = 1
    ToggleFrame.Size = UDim2.new(1, 0, 0, 25)
    
    ToggleButton.Name = "Button"
    ToggleButton.Parent = ToggleFrame
    ToggleButton.Position = UDim2.new(0, 10, 0, 5)
    ToggleButton.Size = UDim2.new(0, 12, 0, 12)
    ToggleButton.BorderSizePixel = 1
    ToggleButton.BorderColor3 = Color3.fromRGB(40, 40, 40)
    
    ToggleLabel.Parent = ToggleFrame
    ToggleLabel.Position = UDim2.new(0, 30, 0, 0)
    ToggleLabel.Size = UDim2.new(1, -30, 1, 0)
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Font = Enum.Font.Code
    ToggleLabel.Text = name
    ToggleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    ToggleLabel.TextSize = 12
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local enabled = default
    local function update()
        if enabled then
            ToggleButton.BackgroundColor3 = Color3.fromRGB(150, 200, 60)
        else
            ToggleButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        }
        callback(enabled)
    end
    
    ToggleButton.MouseButton1Click:Connect(function()
        enabled = not enabled
        update()
    end)
    update()
end

-- Создаем вкладки как в оригинале
CreateTab("Rage", 1)
CreateTab("Legit", 2)
CreateTab("Visuals", 3)
CreateTab("Misc", 4)

-- Контейнер для элементов внутри правой панели
local ElementsList = Instance.new("UIListLayout")
ElementsList.Parent = ContentPanel
ElementsList.Padding = UDim.new(0, 5)

-- Пример добавления функций (Тестовые функции для Blox Strike)
CreateToggle("Aimbot Enabled", ContentPanel, false, function(state)
    print("Aimbot: ", state)
end)

CreateToggle("Wallhack (ESP)", ContentPanel, false, function(state)
    print("ESP: ", state)
end)

CreateToggle("BunnyHop", ContentPanel, false, function(state)
    print("Bhop: ", state)
end)
