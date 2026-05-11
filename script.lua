-- Защита от повторного запуска скрипта
if game:GetService("CoreGui"):FindFirstChild("LegendaHubMobile") then
    game:GetService("CoreGui"):FindFirstChild("LegendaHubMobile"):Destroy()
end

-- Создание главного контейнера
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LegendaHubMobile"
ScreenGui.Parent = game:GetService("CoreGui")

-- ==========================================
-- КНОПКА «L» (ОТКРЫТИЕ/СКРЫТИЕ)
-- ==========================================
local ToggleButton = Instance.new("TextButton")
local ButtonCorner = Instance.new("UICorner")

ToggleButton.Name = "L_Button"
ToggleButton.Parent = ScreenGui
ToggleButton.Position = UDim2.new(0.02, 0, 0.3, 0)
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
ToggleButton.Text = "L"
ToggleButton.TextColor3 = Color3.fromRGB(0, 210, 255)
ToggleButton.TextSize = 26
ToggleButton.Draggable = true -- Можно перетаскивать пальцем

ButtonCorner.CornerRadius = UDim.new(1, 0)
ButtonCorner.Parent = ToggleButton

-- ==========================================
-- ГЛАВНОЕ ОКНО МЕНЮ
-- ==========================================
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
MainFrame.Size = UDim2.new(0, 300, 0, 200)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)

-- Логика кнопки
ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- (Логика функций фармера пропущена для краткости, доступна в полной версии)
-- [Специализированные функции для PS99]
