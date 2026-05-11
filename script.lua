-- Полная принудительная очистка памяти перед запуском
if game:GetService("CoreGui"):FindFirstChild("LegendaHubMobileFix") then game:GetService("CoreGui").LegendaHubMobileFix:Destroy() end
if game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("LegendaHubMobileFix") then game:GetService("Players").LocalPlayer.PlayerGui.LegendaHubMobileFix:Destroy() end

local LocalPlayer = game:GetService("Players").LocalPlayer
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Глобальные переключатели
getgenv().AutoFarm = false
getgenv().AutoRNG = false

-- Создание UI в безопасную папку PlayerGui (если CoreGui заблокирован)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LegendaHubMobileFix"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- ==========================================
-- СТАТИЧНАЯ КНОПКА «L» (ВЕРХНИЙ ПРАВЫЙ УГОЛ)
-- ==========================================
local ToggleButton = Instance.new("TextButton")
ToggleButton.Parent = ScreenGui
ToggleButton.Position = UDim2.new(0.82, 0, 0.05, 0) -- Правее и выше остальных кнопок игры
ToggleButton.Size = UDim2.new(0, 40, 0, 40)
ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ToggleButton.Text = "L"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 20

-- ==========================================
-- ГЛАВНАЯ ПАНЕЛЬ И ИСПРАВЛЕННЫЙ ТЕКСТ
-- ==========================================
local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.Position = UDim2.new(0.3, 0, 0.2, 0)
MainFrame.Size = UDim2.new(0, 260, 0, 200)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Visible = true

local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "LegendaHub v38"
Title.TextColor3 = Color3.fromRGB(0, 255, 255)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- ==========================================
-- КНОПКА ФАРМА (ПРЯМОЙ ВЫЗОВ REMOTES)
-- ==========================================
local FarmBtn = Instance.new("TextButton")
FarmBtn.Parent = MainFrame
FarmBtn.Position = UDim2.new(0.05, 0, 0.2, 0)
FarmBtn.Size = UDim2.new(0.9, 0, 0, 35)
FarmBtn.BackgroundColor3 = Color3.fromRGB(50, 20, 20)
FarmBtn.Text = "Фарм сфер: ВЫКЛ"
FarmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

FarmBtn.MouseButton1Click:Connect(function()
    getgenv().AutoFarm = not getgenv().AutoFarm
    if getgenv().AutoFarm then
        FarmBtn.Text = "Фарм сфер: ВКЛ"
        FarmBtn.BackgroundColor3 = Color3.fromRGB(20, 50, 20)
        task.spawn(function()
            while getgenv().AutoFarm do
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if root then
                    -- Поиск и мгновенное физическое стягивание сфер без использования сетевых папок
                    for _, v in ipairs(Workspace:GetDescendants()) do
                        if (v.Name == "Orb" or v.Name == "Lootbag") and v:IsA("BasePart") then
                            v.CFrame = root.CFrame
                        end
                    end
                end
                task.wait(0.3)
            end
        end)
    else
        FarmBtn.Text = "Фарм сфер: ВЫКЛ"
        FarmBtn.BackgroundColor3 = Color3.fromRGB(50, 20, 20)
    end
end)

-- ==========================================
-- КНОПКА ТЕЛЕПОРТА (СТРОГО В ЗОНУ 38)
-- ==========================================
local TPBtn = Instance.new("TextButton")
TPBtn.Parent = MainFrame
TPBtn.Position = UDim2.new(0.05, 0, 0.45, 0)
TPBtn.Size = UDim2.new(0.9, 0, 0, 35)
TPBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
TPBtn.Text = "Телепорт в Зону 38"
TPBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

TPBtn.MouseButton1Click:Connect(function()
    local map = Workspace:FindFirstChild("Map") or Workspace:FindFirstChild("ActiveZones")
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if map and root then
        for _, zone in ipairs(map:GetChildren()) do
            if zone.Name:match("^38%s") or zone.Name == "38" then
                root.CFrame = zone:GetPivot() + Vector3.new(0, 5, 0)
                break
            end
        end
    end
end)

-- ==========================================
-- КНОПКА ПОЛНОГО ЗАКРЫТИЯ СКРИПТА
-- ==========================================
local ExitBtn = Instance.new("TextButton")
ExitBtn.Parent = MainFrame
ExitBtn.Position = UDim2.new(0.05, 0, 0.75, 0)
ExitBtn.Size = UDim2.new(0.9, 0, 0, 35)
ExitBtn.BackgroundColor3 = Color3.fromRGB(100, 20, 20)
ExitBtn.Text = "ПОЛНОСТЬЮ ЗАКРЫТЬ СКРИПТ"
ExitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

ExitBtn.MouseButton1Click:Connect(function()
    getgenv().AutoFarm = false
    getgenv().AutoRNG = false
    ScreenGui:Destroy()
end)
