-- Автоматический выбор доступного контейнера (Обход ограничений Xeno)
local TargetGui;
local success, err = pcall(function()
    TargetGui = game:GetService("CoreGui")
end)

if not success or not TargetGui then
    -- Если CoreGui закрыт защитой, внедряемся в системный чат/интерфейс
    TargetGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
end

-- Полная очистка старых зависших элементов меню
for _, child in pairs(TargetGui:GetChildren()) do
    if child.Name == "SkeetMenu_BS" then
        child:Destroy()
    end
end

-- Создание корневого контейнера
local SkeetMenu = Instance.new("ScreenGui")
SkeetMenu.Name = "SkeetMenu_BS"
SkeetMenu.DisplayOrder = 9999 -- Поверх всех окон игры
SkeetMenu.ResetOnSpawn = false
SkeetMenu.Parent = TargetGui

-- Главный фрейм Skeet
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = SkeetMenu
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
MainFrame.BorderColor3 = Color3.fromRGB(40, 40, 40)
MainFrame.BorderSizePixel = 1
MainFrame.Position = UDim2.new(0.35, 0, 0.3, 0)
MainFrame.Size = UDim2.new(0, 420, 0, 300)
MainFrame.ZIndex = 5

-- Полоска Gamesense (Зеленый неон)
local Line = Instance.new("Frame")
Line.Parent = MainFrame
Line.BackgroundColor3 = Color3.fromRGB(163, 212, 47)
Line.BorderSizePixel = 0
Line.Size = UDim2.new(1, 0, 0, 2)
Line.ZIndex = 6

-- Левая панель вкладок
local TabsFrame = Instance.new("Frame")
TabsFrame.Parent = MainFrame
TabsFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
TabsFrame.BorderColor3 = Color3.fromRGB(25, 25, 25)
TabsFrame.Position = UDim2.new(0, 6, 0, 10)
TabsFrame.Size = UDim2.new(0, 90, 1, -16)
TabsFrame.ZIndex = 6

local UIList = Instance.new("UIListLayout")
UIList.Parent = TabsFrame
UIList.SortOrder = Enum.SortOrder.LayoutOrder

-- Правая панель под контент функций
local Content = Instance.new("Frame")
Content.Parent = MainFrame
Content.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
Content.BorderColor3 = Color3.fromRGB(25, 25, 25)
Content.Position = UDim2.new(0, 102, 0, 10)
Content.Size = UDim2.new(1, -108, 1, -16)
Content.ZIndex = 6

local ContentList = Instance.new("UIListLayout")
ContentList.Parent = Content
ContentList.Padding = UDim.new(0, 4)

-- Функция создания вкладки
local function AddTab(text, id)
    local Button = Instance.new("TextButton")
    Button.Parent = TabsFrame
    Button.Size = UDim2.new(1, 0, 0, 32)
    Button.BackgroundTransparency = 1
    Button.Font = Enum.Font.Code
    Button.Text = text:upper()
    Button.TextColor3 = (id == 1) and Color3.fromRGB(163, 212, 47) or Color3.fromRGB(130, 130, 130)
    Button.TextSize = 11
    Button.ZIndex = 7
    
    Button.MouseButton1Click:Connect(function()
        for _, v in pairs(TabsFrame:GetChildren()) do
            if v:IsA("TextButton") then v.TextColor3 = Color3.fromRGB(130, 130, 130) end
        end
        Button.TextColor3 = Color3.fromRGB(163, 212, 47)
    end)
end

-- Функция создания переключателя (Чекбокс)
local function AddToggle(name, callback)
    local Frame = Instance.new("Frame")
    Frame.Parent = Content
    Frame.BackgroundTransparency = 1
    Frame.Size = UDim2.new(1, 0, 0, 22)
    Frame.ZIndex = 7

    local Box = Instance.new("TextButton")
    Box.Parent = Frame
    Box.Position = UDim2.new(0, 8, 0, 5)
    Box.Size = UDim2.new(0, 10, 0, 10)
    Box.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Box.BorderColor3 = Color3.fromRGB(45, 45, 45)
    Box.Text = ""
    Box.ZIndex = 8

    local Label = Instance.new("TextLabel")
    Label.Parent = Frame
    Label.Position = UDim2.new(0, 24, 0, 0)
    Label.Size = UDim2.new(1, -24, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.Code
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(200, 200, 200)
    Label.TextSize = 11
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.ZIndex = 8

    local state = false
    Box.MouseButton1Click:Connect(function()
        state = not state
        Box.BackgroundColor3 = state and Color3.fromRGB(163, 212, 47) or Color3.fromRGB(20, 20, 20)
        pcall(callback, state)
    end)
end

-- Скрипт перетаскивания (Математический Drag без багов Xeno)
local UIS = game:GetService("UserInputService")
local dragToggle, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragToggle = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragToggle = false end
        end)
    end
end)
UIS.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and dragToggle then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Инициализация элементов
AddTab("Rage", 1)
AddTab("Legit", 2)
AddTab("Visuals", 3)
AddTab("Misc", 4)

AddToggle("Aimbot Master", function(t) print("Aimbot:", t) end)
AddToggle("Silent Bullet", function(t) print("Silent:", t) end)
AddToggle("Wallhack Boxes", function(t) print("ESP:", t) end)
