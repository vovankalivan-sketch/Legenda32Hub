--[[
    Pet Simulator 99 - Backrooms Ultimate Farmer v2.0
    Delta Executor (Android/iOS)
    - Полное меню (GUI)
    - Автовыгрузка предыдущей версии
    - Ноклип, фарм, анти-энтити, поиск топ-яйца
]]

-- ===== АВТОВЫГРУЗКА СТАРОЙ ВЕРСИИ =====
if shared.BackroomsFarmer then
    shared.BackroomsFarmer.Unload()
end

-- ===== СОЗДАНИЕ МЕНЮ =====
local player = game:GetService("Players").LocalPlayer
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BackroomsFarmerGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Главная рамка
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 260, 0, 350)
mainFrame.Position = UDim2.new(0.5, -130, 0.2, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

-- Заголовок
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Text = "Backrooms Farmer v2.0"
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18
title.Parent = mainFrame

-- Кнопка закрытия меню (она же Unload)
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -30, 0, 0)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Text = "X"
closeButton.Font = Enum.Font.SourceSansBold
closeButton.TextSize = 18
closeButton.Parent = mainFrame
closeButton.MouseButton1Click:Connect(function()
    shared.BackroomsFarmer.Unload()
end)

-- Контейнер для чекбоксов
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -10, 1, -40)
scrollFrame.Position = UDim2.new(0, 5, 0, 35)
scrollFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 5
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 450)
scrollFrame.Parent = mainFrame

-- Функция создания чекбокса
local function createToggle(text, yPos, callback)
    local toggle = Instance.new("Frame")
    toggle.Size = UDim2.new(1, -10, 0, 30)
    toggle.Position = UDim2.new(0, 5, 0, yPos)
    toggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    toggle.Parent = scrollFrame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Text = text
    label.Font = Enum.Font.SourceSans
    label.TextSize = 14
    label.Parent = toggle

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 50, 0, 24)
    button.Position = UDim2.new(0.75, 0, 0, 3)
    button.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Text = "OFF"
    button.Font = Enum.Font.SourceSansBold
    button.TextSize = 14
    button.Parent = toggle

    local state = false
    button.MouseButton1Click:Connect(function()
        state = not state
        button.Text = state and "ON" or "OFF"
        button.BackgroundColor3 = state and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(100, 100, 100)
        callback(state)
    end)
    return toggle
end

-- Переменные состояний
local settings = {
    farmFragments = true,
    avoidEntities = true,
    clickPortals = true,
    openEggs = true,
    autoJump = true,
    noclipEnabled = true,
    searchBestEgg = true,
    speedBoost = 30
}

-- Создаём переключатели
createToggle("Сбор фрагментов", 10, function(v) settings.farmFragments = v end)
createToggle("Анти-энтити", 45, function(v) settings.avoidEntities = v end)
createToggle("Клик порталов", 80, function(v) settings.clickPortals = v end)
createToggle("Открытие яиц", 115, function(v) settings.openEggs = v end)
createToggle("Авто-прыжок", 150, function(v) settings.autoJump = v end)
createToggle("Ноклип", 185, function(v) settings.noclipEnabled = v end)
createToggle("Поиск топ-яйца", 220, function(v) settings.searchBestEgg = v end)

-- Слайдер скорости
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0.7, 0, 0, 30)
speedLabel.Position = UDim2.new(0, 5, 0, 260)
speedLabel.BackgroundTransparency = 1
speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
speedLabel.Text = "Скорость: 30"
speedLabel.Font = Enum.Font.SourceSans
speedLabel.TextSize = 14
speedLabel.Parent = scrollFrame

local speedSlider = Instance.new("TextBox")
speedSlider.Size = UDim2.new(0, 50, 0, 24)
speedSlider.Position = UDim2.new(0.75, 0, 0, 263)
speedSlider.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
speedSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
speedSlider.Text = "30"
speedSlider.Font = Enum.Font.SourceSans
speedSlider.TextSize = 14
speedSlider.Parent = scrollFrame
speedSlider.FocusLost:Connect(function()
    local num = tonumber(speedSlider.Text)
    if num and num >= 16 and num <= 100 then
        settings.speedBoost = num
        speedLabel.Text = "Скорость: " .. num
    else
        speedSlider.Text = settings.speedBoost
    end
end)

-- Кнопка полной выгрузки
local unloadButton = Instance.new("TextButton")
unloadButton.Size = UDim2.new(1, -10, 0, 30)
unloadButton.Position = UDim2.new(0, 5, 0, 300)
unloadButton.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
unloadButton.TextColor3 = Color3.fromRGB(255, 255, 255)
unloadButton.Text = "ВЫГРУЗИТЬ СКРИПТ"
unloadButton.Font = Enum.Font.SourceSansBold
unloadButton.TextSize = 14
unloadButton.Parent = scrollFrame
unloadButton.MouseButton1Click:Connect(function()
    shared.BackroomsFarmer.Unload()
end)

-- ===== ЛОГИКА ФАРМА =====
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local connections = {}
local farmLoopRunning = false

local entityNames = {"hound", "faceling", "smiler", "skin stealer", "clump"}
local fragmentName = "Fragment"
local portalName = "Portal"
local topPetKeywords = {"titanic", "gargantuan", "huge", "titanium", "mythic", "divine"}

-- Ноклип
local function noclipLoop()
    while settings.noclipEnabled do
        if character and character:FindFirstChild("HumanoidRootPart") then
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide == true then
                    part.CanCollide = false
                end
            end
        end
        task.wait(0.1)
    end
end

-- Поиск топ-яйца
local function findBestEgg()
    local bestEgg, bestScore = nil, -1
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("ClickDetector") then
            local score = 0
            local name = obj.Name:lower()
            for _, kw in ipairs(topPetKeywords) do
                if name:find(kw) then score += 10 end
            end
            for _, child in ipairs(obj:GetDescendants()) do
                if child:IsA("StringValue") or child:IsA("ObjectValue") then
                    for _, kw in ipairs(topPetKeywords) do
                        if child.Name:lower():find(kw) then score += 5 end
                    end
                end
            end
            if score > bestScore then bestScore = score; bestEgg = obj end
        end
    end
    return bestEgg
end

-- Телепорт
local function teleportTo(target)
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    local root = character.HumanoidRootPart
    local pos = target.PrimaryPart and target.PrimaryPart.Position or target:GetPivot().p
    local tweenInfo = TweenInfo.new((root.Position - pos).Magnitude / settings.speedBoost, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(root, tweenInfo, {CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))})
    tween:Play()
    tween.Completed:Wait()
end

-- Клик по яйцу
local function clickEgg(egg)
    if egg and egg:FindFirstChild("ClickDetector") then
        fireclickdetector(egg.ClickDetector)
        task.wait(0.3)
    end
end

-- Основной фермерский цикл
local function farmLoop()
    while farmLoopRunning do
        if not character or not character:FindFirstChild("HumanoidRootPart") then
            character = player.Character
            if character then humanoid = character:WaitForChild("Humanoid") end
            task.wait(1)
            continue
        end
        if humanoid then
            if settings.autoJump and humanoid:GetState() ~= Enum.HumanoidStateType.Freefall then
                humanoid.Jump = true
            end
            humanoid.WalkSpeed = settings.speedBoost
        end

        -- Сбор фрагментов
        if settings.farmFragments then
            for _, part in ipairs(workspace:GetDescendants()) do
                if part:IsA("Part") and part.Name == fragmentName and part:FindFirstChild("ClickDetector") then
                    if (character.HumanoidRootPart.Position - part.Position).Magnitude < 80 then
                        fireclickdetector(part.ClickDetector)
                        task.wait(0.1)
                    end
                end
            end
        end

        -- Анти-энтити
        if settings.avoidEntities then
            local root = character.HumanoidRootPart
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("Model") or v:IsA("Part") then
                    for _, ename in ipairs(entityNames) do
                        if v.Name:lower():find(ename) then
                            local pos = v:IsA("Model") and (v:FindFirstChild("HumanoidRootPart") or v.PrimaryPart) and (v.HumanoidRootPart or v.PrimaryPart).Position or v.Position
                            if pos and (root.Position - pos).Magnitude < 18 then
                                root.CFrame = root.CFrame + Vector3.new(math.random(-40,40), 0, math.random(-40,40))
                                break
                            end
                        end
                    end
                end
            end
        end

        -- Портал-кликер
        if settings.clickPortals then
            for _, part in ipairs(workspace:GetDescendants()) do
                if part:IsA("Part") and (part.Name == portalName or part.Name:lower():find("portal")) and part:FindFirstChild("ClickDetector") then
                    fireclickdetector(part.ClickDetector)
                    task.wait(0.5)
                end
            end
        end

        -- Поиск топ-яйца и открытие
        if settings.searchBestEgg then
            local bestEgg = findBestEgg()
            if bestEgg then
                teleportTo(bestEgg)
                for _ = 1, 15 do
                    clickEgg(bestEgg)
                end
            end
        end

        -- Открытие остальных яиц (если нет топ-яйца или просто включена опция)
        if settings.openEggs and not settings.searchBestEgg then
            for _, egg in ipairs(workspace:GetDescendants()) do
                if egg:IsA("Model") and egg:FindFirstChild("ClickDetector") and egg.Name:lower():find("egg") then
                    clickEgg(egg)
                    task.wait(0.1)
                end
            end
        end

        task.wait(0.3)
    end
end

-- Запуск/остановка
local function startFarm()
    farmLoopRunning = true
    task.spawn(farmLoop)
    task.spawn(noclipLoop)
end

local function stopFarm()
    farmLoopRunning = false
    -- удаляем все активные твины и соединения
    for _, conn in ipairs(connections) do
        conn:Disconnect()
    end
    connections = {}
    if screenGui then
        screenGui:Destroy()
    end
end

-- Сохраняем объект для выгрузки
shared.BackroomsFarmer = {
    Unload = stopFarm
}

-- Стартуем
startFarm()
