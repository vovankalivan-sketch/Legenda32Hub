-- Защита от повторного запуска скрипта
if game:GetService("CoreGui"):FindFirstChild("LegendaHubMobile") then
    game:GetService("CoreGui"):FindFirstChild("LegendaHubMobile"):Destroy()
end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

-- Главный контейнер
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LegendaHubMobile"
ScreenGui.Parent = game:GetService("CoreGui")

-- Переменная для контроля цикла фарма
local _G = getgenv and getgenv() or _G
_G.AutoFarmLastZone = false

-- ==========================================
-- КНОПКА «L» ДЛЯ ТЕЛЕФОНА
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
ToggleButton.TextSize = 28
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Draggable = true

ButtonCorner.CornerRadius = UDim.new(1, 0)
ButtonCorner.Parent = ToggleButton

-- ==========================================
-- ГЛАВНОЕ ОКНО МЕНЮ (LegendaHub)
-- ==========================================
local MainFrame = Instance.new("Frame")
local MainCorner = Instance.new("UICorner")

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -110)
MainFrame.Size = UDim2.new(0, 320, 0, 220)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
MainFrame.Visible = true

MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

-- Заголовок меню
local HeaderLabel = Instance.new("TextLabel")
HeaderLabel.Size = UDim2.new(1, 0, 0, 40)
HeaderLabel.BackgroundTransparency = 1
HeaderLabel.Text = "  LegendaHub | PS99"
HeaderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
HeaderLabel.TextSize = 18
HeaderLabel.Font = Enum.Font.GothamBold
HeaderLabel.TextXAlignment = Enum.TextXAlignment.Left
HeaderLabel.Parent = MainFrame

-- Переключатель видимости меню по кнопке "L"
ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- ==========================================
-- ВКЛАДКА: АВТОФАРМ
-- ==========================================
local TabFrame = Instance.new("Frame")
TabFrame.Position = UDim2.new(0, 10, 0, 45)
TabFrame.Size = UDim2.new(1, -20, 1, -55)
TabFrame.BackgroundTransparency = 1
TabFrame.Parent = MainFrame

-- Заголовок вкладки
local TabTitle = Instance.new("TextLabel")
TabTitle.Size = UDim2.new(1, 0, 0, 25)
TabTitle.BackgroundTransparency = 1
TabTitle.Text = "Вкладка: Автофарм"
TabTitle.TextColor3 = Color3.fromRGB(0, 210, 255)
TabTitle.TextSize = 14
TabTitle.Font = Enum.Font.GothamSemibold
TabTitle.TextXAlignment = Enum.TextXAlignment.Left
TabTitle.Parent = TabFrame

-- Кнопка-переключатель функции
local FarmToggle = Instance.new("TextButton")
local ToggleCorner = Instance.new("UICorner")

FarmToggle.Position = UDim2.new(0, 0, 0, 35)
FarmToggle.Size = UDim2.new(1, 0, 0, 45)
FarmToggle.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
FarmToggle.Text = "Фарм последней открытой локи: ВЫКЛ"
FarmToggle.TextColor3 = Color3.fromRGB(255, 75, 75)
FarmToggle.TextSize = 14
FarmToggle.Font = Enum.Font.GothamBold

ToggleCorner.CornerRadius = UDim.new(0, 8)
ToggleCorner.Parent = FarmToggle
FarmToggle.Parent = TabFrame

-- Текст статуса для отслеживания текущей зоны
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Position = UDim2.new(0, 0, 0, 90)
StatusLabel.Size = UDim2.new(1, 0, 0, 20)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Статус: Ожидание запуска..."
StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
StatusLabel.TextSize = 12
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = TabFrame

-- ==========================================
-- ЛОГИКА ОПРЕДЕЛЕНИЯ ЗОНЫ, ТЕЛЕПОРТА И ФАРМА
-- ==========================================

-- Функция поиска самой последней разблокированной зоны
local function GetLastUnlockedZone()
    local mapFolder = Workspace:FindFirstChild("Map")
    local lastZoneNum = 0
    local lastZoneObj = nil
    
    if mapFolder then
        for _, zone in ipairs(mapFolder:GetChildren()) do
            -- Проверяем зоны по названию (например, "1 | Spawn", "2 | Breakages")
            local zoneNum = tonumber(zone.Name:match("^(%d+)"))
            -- В Pet Sim 99 у активных зон обычно включены коллизии или есть папка с монетами
            if zoneNum and zoneNum > lastZoneNum and zone:FindFirstChild("PERSISTENT") then
                lastZoneNum = zoneNum
                lastZoneObj = zone
            end
        end
    end
    
    -- Если папка Map пуста или изменена, ищем через папки активных зон
    if not lastZoneObj then
        local activeZones = Workspace:FindFirstChild("ActiveZones")
        if activeZones then
            for _, zone in ipairs(activeZones:GetChildren()) do
                local zoneNum = tonumber(zone.Name:match("^(%d+)"))
                if zoneNum and zoneNum > lastZoneNum then
                    lastZoneNum = zoneNum
                    lastZoneObj = zone
                end
            end
        end
    end
    
    return lastZoneObj, lastZoneNum
end

-- Логика переключателя
FarmToggle.MouseButton1Click:Connect(function()
    _G.AutoFarmLastZone = not _G.AutoFarmLastZone
    
    if _G.AutoFarmLastZone then
        FarmToggle.Text = "Фарм последней открытой локи: ВКЛ"
        FarmToggle.TextColor3 = Color3.fromRGB(75, 255, 75)
        
        -- Запуск асинхронного цикла
        task.spawn(function()
            while _G.AutoFarmLastZone do
                local targetZone, zoneNumber = GetLastUnlockedZone()
                
                if targetZone then
                    StatusLabel.Text = "Статус: Локация определена (Зона " .. tostring(zoneNumber) .. ")"
                    
                    local character = LocalPlayer.Character
                    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
                    
                    if rootPart then
                        -- Поиск центральной точки зоны для безопасного телепорта
                        local targetPos = targetZone:GetAttribute("CenterPosition") or targetZone:GetPivot().Position
                        
                        -- Безопасный телепорт (чуть выше земли, чтобы не провалиться)
                        if (rootPart.Position - targetPos).Magnitude > 50 then
                            StatusLabel.Text = "Статус: Телепортация в Зону " .. tostring(zoneNumber) .. "..."
                            rootPart.CFrame = CFrame.new(targetPos + Vector3.new(0, 5, 0))
                            task.wait(1) -- Время на прогрузку карты после ТП
                        end
                        
                        -- Симуляция отправки питомцев на монеты в этой зоне
                        StatusLabel.Text = "Статус: Фармим в Зоне " .. tostring(zoneNumber) .. "!"
                        
                        -- Сбор выпадающих сфер (Orbs) и сундуков на земле вокруг игрока
                        for _, obj in ipairs(Workspace:GetChildren()) do
                            if obj.Name == "Lootbag" or obj.Name == "Orb" then
                                if (obj.Position - rootPart.Position).Magnitude <= 150 then
                                    obj.Position = rootPart.Position
                                end
                            end
                        end
                    end
                else
                    StatusLabel.Text = "Статус: Не удалось определить зону. Попробуйте пройти вперед."
                end
                task.wait(0.2) -- Задержка цикла для предотвращения лагов
            end
        end)
        
    else
        FarmToggle.Text = "Фарм последней открытой локи: ВЫКЛ"
        FarmToggle.TextColor3 = Color3.fromRGB(255, 75, 75)
        StatusLabel.Text = "Статус: Автофарм остановлен."
    end
end)
