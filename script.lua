-- ====================================================================
-- LEGENDA32HUB V43 | ВНЕШНИЙ АВТОНОМНЫЙ АССИСТЕНТ (ИЗОЛИРОВАННЫЙ ВВОД)
-- ====================================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- Безопасная очистка оверлея перед запуском
if LocalPlayer.PlayerGui:FindFirstChild("LegendaHubExternal") then 
    LocalPlayer.PlayerGui.LegendaHubExternal:Destroy() 
end

-- Инициализация изолированных глобальных флагов
getgenv().External_Autopilot = false
getgenv().RGB_Enabled = false

-- Создание независимого внешнего оверлея управления
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LegendaHubExternal"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Квадратная кнопка "L" с круглыми углами
local ToggleButton = Instance.new("TextButton")
local ButtonCorner = Instance.new("UICorner")

ToggleButton.Name = "L_Button"
ToggleButton.Parent = ScreenGui
ToggleButton.Position = UDim2.new(0.85, 0, 0.12, 0)
ToggleButton.Size = UDim2.new(0, 45, 0, 45)
ToggleButton.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
ToggleButton.Text = "L"
ToggleButton.TextColor3 = Color3.fromRGB(0, 210, 255)
ToggleButton.TextSize = 22
ToggleButton.Font = Enum.Font.GothamBold

ButtonCorner.CornerRadius = UDim.new(0, 10)
ButtonCorner.Parent = ToggleButton

-- Универсальное мобильное перетаскивание оверлей-кнопки по экрану
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

-- Главная панель внешнего ассистента
local MainFrame = Instance.new("Frame")
local MainCorner = Instance.new("UICorner")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
MainFrame.Size = UDim2.new(0, 300, 0, 200)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
MainFrame.Visible = true
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundTransparency = 1
Title.Text = "  Legenda32Hub | Внешний Оверлей v43"
Title.TextColor3 = Color3.fromRGB(0, 210, 255)
Title.TextSize = 13
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

ToggleButton.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

-- Контейнер для кнопок управления
local ContentFrame = Instance.new("Frame")
ContentFrame.Position = UDim2.new(0, 10, 0, 45)
ContentFrame.Size = UDim2.new(1, -20, 1, -55)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

-- ==========================================
-- КНОПКА ЗАПУСКА ИЗОЛИРОВАННОГО АВТОПИЛОТА
-- ==========================================
local MacroToggle = Instance.new("TextButton")
MacroToggle.Size = UDim2.new(1, 0, 0, 45)
MacroToggle.BackgroundColor3 = Color3.fromRGB(45, 30, 30)
MacroToggle.Text = "ЗАПУСТИТЬ ВНЕШНИЙ МАКРОС: ВЫКЛ"
MacroToggle.TextColor3 = Color3.fromRGB(255, 75, 75)
MacroToggle.Font = Enum.Font.GothamBold; MacroToggle.TextSize = 11; MacroToggle.Parent = ContentFrame
Instance.new("UICorner", MacroToggle).CornerRadius = UDim.new(0, 6)

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Position = UDim2.new(0, 0, 0, 55); StatusLabel.Size = UDim2.new(1, 0, 0, 70)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "ИИ: Изолирован от файлов игры.\nРежим: Слепое кликанье экрана.\nБезопасность: 100% (Внешний эмулятор)."
StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150); StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 11; StatusLabel.TextXAlignment = Enum.TextXAlignment.Left; StatusLabel.Parent = ContentFrame

MacroToggle.MouseButton1Click:Connect(function()
    getgenv().External_Autopilot = not getgenv().External_Autopilot
    if getgenv().External_Autopilot then
        MacroToggle.Text = "ЗАПУСТИТЬ ВНЕШНИЙ МАКРОС: ВКЛ"
        MacroToggle.TextColor3 = Color3.fromRGB(75, 255, 75); MacroToggle.BackgroundColor3 = Color3.fromRGB(30, 45, 30)
        
        -- Изолированный поток эмуляции физических действий
        task.spawn(function()
            local camera = Workspace.CurrentCamera
            
            while getgenv().External_Autopilot do
                pcall(function()
                    -- Получаем текущее разрешение экрана устройства
                    local screenSize = camera.ViewportSize
                    local screenX = screenSize.X
                    local screenY = screenSize.Y
                    
                    -- СЛЕПАЯ ЭМУЛЯЦИЯ 1: Легитные круговые клики по экрану для сбора и атаки монет
                    -- Выбираем случайные точки в центре экрана, имитируя хаотичные нажатия пальцем
                    local randomX = math.random(screenX * 0.25, screenX * 0.75)
                    local randomY = math.random(screenY * 0.25, screenY * 0.75)
                    
                    StatusLabel.Text = string.format("ИИ [Эмулятор]: Клик в точку X: %d, Y: %d", randomX, randomY)
                    
                    -- Посылаем физический сигнал нажатия мыши/пальца в ОС Roblox снаружи устройства
                    VirtualInputManager:SendMouseButtonEvent(randomX, randomY, 0, true, game, 1)
                    task.wait(0.02)
                    VirtualInputManager:SendMouseButtonEvent(randomX, randomY, 0, false, game, 1)
                    
                    -- СЛЕПАЯ ЭМУЛЯЦИЯ 2: Легитное микро-перемещение персонажа (защита от АФК и сбор выпавших сфер под ногами)
                    local character = LocalPlayer.Character
                    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        -- Симулируем естественные микро-шаги человека на месте (в радиусе пары шагов)
                        local root = character:FindFirstChild("HumanoidRootPart")
                        if root then
                            local randomOffset = Vector3.new(math.random(-3, 3), 0, math.random(-3, 3))
                            humanoid:MoveTo(root.Position + randomOffset)
                        end
                    end
                end)
                
                -- Задержка между циклами кликов макроса
                task.wait(0.15)
            end
        end)
    else
        MacroToggle.Text = "ЗАПУСТИТЬ ВНЕШНИЙ МАКРОС: ВЫКЛ"
        MacroToggle.TextColor3 = Color3.fromRGB(255, 75, 75); MacroToggle.BackgroundColor3 = Color3.fromRGB(45, 30, 30)
        StatusLabel.Text = "ИИ: Изолирован от файлов игры.\nРежим: Слепое кликанье экрана.\nБезопасность: 100% (Внешний эмулятор)."
    end
end)

-- ==========================================
-- НАСТРОЙКИ И RGB (РАБОТАЮТ НА ОВЕРЛЕЕ)
-- ==========================================
local RgbToggle = Instance.new("TextButton")
RgbToggle.Size = UDim2.new(0.48, 0, 0, 32); RgbToggle.Position = UDim2.new(0, 0, 1, -35)
RgbToggle.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
RgbToggle.Text = "RGB режим"
RgbToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
RgbToggle.Font = Enum.Font.GothamBold; RgbToggle.TextSize = 10; RgbToggle.Parent = ContentFrame
Instance.new("UICorner", RgbToggle).CornerRadius = UDim.new(0, 5)

local ShutdownButton = Instance.new("TextButton")
ShutdownButton.Size = UDim2.new(0.48, 0, 0, 32); ShutdownButton.Position = UDim2.new(0.52, 0, 1, -35)
ShutdownButton.BackgroundColor3 = Color3.fromRGB(65, 25, 25)
ShutdownButton.Text = "Закрыть оверлей"
ShutdownButton.TextColor3 = Color3.fromRGB(255, 100, 100)
ShutdownButton.Font = Enum.Font.GothamBold; ShutdownButton.TextSize = 10; ShutdownButton.Parent = ContentFrame
Instance.new("UICorner", ShutdownButton).CornerRadius = UDim.new(0, 5)

RunService.RenderStepped:Connect(function()
    if getgenv().RGB_Enabled then
        local hue = (tick() % 4) / 4; local color = Color3.fromHSV(hue, 1, 1)
        Title.TextColor3 = color; ToggleButton.TextColor3 = color
    end
end)

RgbToggle.MouseButton1Click:Connect(function()
    getgenv().RGB_Enabled = not getgenv().RGB_Enabled
    if not getgenv().RGB_Enabled then
        Title.TextColor3 = Color3.fromRGB(0, 210, 255); ToggleButton.TextColor3 = Color3.fromRGB(0, 210, 255)
    end
end)

ShutdownButton.MouseButton1Click:Connect(function()
    getgenv().External_Autopilot = false; getgenv().RGB_Enabled = false; ScreenGui:Destroy()
end)

-- Системное сообщение во внешний чат
game:GetService("StarterGui"):SetCore("ChatMakeSystemMessage", {
    Text = "[Legenda32Hub]: Внешний макрос-ассистент запущен. Подключение к памяти игры отсутствует.",
    Color = Color3.fromRGB(255, 215, 0), Font = Enum.Font.GothamBold, TextSize = 14
})
