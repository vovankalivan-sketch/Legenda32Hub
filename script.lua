-- Сервисы Roblox
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Создание главного контейнера интерфейса
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LegendaHubContainer"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- Главное окно меню
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 0, 0, 0) -- Изначально размер 0 для анимации появления
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35) -- Темный стильный фон
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

-- Скругление углов главного окна
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = mainFrame

-- Верхняя панель (Header)
local headerFrame = Instance.new("Frame")
headerFrame.Name = "Header"
headerFrame.Size = UDim2.new(1, 0, 0, 45)
headerFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
headerFrame.BorderSizePixel = 0
headerFrame.Parent = mainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 12)
headerCorner.Parent = headerFrame

-- Текст названия хаба
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, -60, 1, 0)
titleLabel.Position = UDim2.new(0, 15, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "LegendaHub"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 20
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = headerFrame

-- Градиент для текста (эффект свечения)
local textUIGradient = Instance.new("UIGradient")
textUIGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 210, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(58, 123, 213))
})
textUIGradient.Parent = titleLabel

-- Кнопка закрытия (X)
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 35, 0, 35)
closeButton.Position = UDim2.new(1, -40, 0, 5)
closeButton.BackgroundTransparency = 1
closeButton.Text = "×"
closeButton.TextColor3 = Color3.fromRGB(180, 180, 190)
closeButton.TextSize = 28
closeButton.Font = Enum.Font.Gotham
closeButton.Parent = headerFrame

-- Область для будущего контента/функций
local contentFrame = Instance.new("Frame")
contentFrame.Name = "Content"
contentFrame.Size = UDim2.new(1, -20, 1, -65)
contentFrame.Position = UDim2.new(0, 10, 0, 55)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

-- Заглушка внутри меню
local placeholderText = Instance.new("TextLabel")
placeholderText.Size = UDim2.new(1, 0, 1, 0)
placeholderText.BackgroundTransparency = 1
placeholderText.Text = "Ожидание подключения функций..."
placeholderText.TextColor3 = Color3.fromRGB(100, 100, 120)
placeholderText.TextSize = 14
placeholderText.Font = Enum.Font.GothamItalic
placeholderText.Parent = contentFrame

-- Логика перетаскивания меню мышкой (Drag)
local dragging, dragInput, dragStart, startPos
local function update(input)
    local delta = input.Position - dragStart
    mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

headerFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

headerFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseBehavior or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then update(input) end
end)

-- Анимация плавного появления при старте скрипта
task.wait(0.5) -- Небольшая пауза перед прогрузкой
mainFrame:TweenSize(
    UDim2.new(0, 400, 0, 250), -- Конечный размер меню (Ширина, Высота)
    Enum.EasingDirection.Out,
    Enum.EasingStyle.Quart,
    0.6,
    true
)

-- Интерактив для кнопки закрытия
closeButton.MouseEnter:Connect(function()
    closeButton.TextColor3 = Color3.fromRGB(255, 75, 75)
end)

closeButton.MouseLeave:Connect(function()
    closeButton.TextColor3 = Color3.fromRGB(180, 180, 190)
end)

closeButton.MouseButton1Click:Connect(function()
    -- Анимация закрытия
    mainFrame:TweenSize(UDim2.new(0, 0, 0, 0), Enum.EasingDirection.In, Enum.EasingStyle.Quart, 0.4, true, function()
        screenGui:Destroy() -- Полное удаление интерфейса
    end)
end)
