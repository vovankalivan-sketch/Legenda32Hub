--[[
    Pet Simulator 99 – Backrooms Event Ultimate Farmer
    Delta Executor (Android/iOS)
    Функции:
    - Поиск топ-яйца (Титаник/Гаргантюа/Хуг/сильнейшие петы)
    - Телепорт к нему + автооткрытие
    - Ноклип (проход сквозь стены)
    - Автосбор фрагментов реальности
    - Анти-энтити (телепорт при опасности)
    - Автоклик порталов
    - Автооткрытие всех яиц
    - Бесконечный прыжок + ускорение
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Настройки
local noclipEnabled = true
local speedBoost = 30
local avoidEntities = true
local entityNames = {"hound", "faceling", "smiler", "skin stealer", "clump"}
local fragmentName = "Fragment"
local portalName = "Portal"

-- Список ключевых слов для топ-петов (ищем в названии яйца или его параметрах)
local topPetKeywords = {"titanic", "gargantuan", "huge", "titanium", "mythic", "divine"}

-- Ноклип
game:GetService("RunService").Stepped:Connect(function()
    if noclipEnabled and character and character:FindFirstChild("HumanoidRootPart") then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide == true then
                part.CanCollide = false
            end
        end
    end
end)

-- Поиск лучшего яйца по названию / петам внутри
local function findBestEgg()
    local bestEgg = nil
    local bestScore = -1
    -- Ищем все объекты, которые могут быть яйцами (обычно это модели с ClickDetector)
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("ClickDetector") then
            local name = obj.Name:lower()
            local score = 0
            -- Проверяем ключевые слова в имени яйца
            for _, kw in ipairs(topPetKeywords) do
                if name:find(kw) then
                    score = score + 10
                end
            end
            -- Проверяем наличие внутри объектов-петов с нужными именами (например, StringValue "PetList")
            for _, child in ipairs(obj:GetDescendants()) do
                if child:IsA("StringValue") or child:IsA("ObjectValue") then
                    local childName = child.Name:lower()
                    for _, kw in ipairs(topPetKeywords) do
                        if childName:find(kw) then score = score + 5 end
                    end
                end
            end
            if score > bestScore then
                bestScore = score
                bestEgg = obj
            end
        end
    end
    return bestEgg
end

-- Телепорт
local function teleportTo(target)
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    local root = character.HumanoidRootPart
    local pos = target.PrimaryPart and target.PrimaryPart.Position or target:GetPivot().p
    local tweenInfo = TweenInfo.new((root.Position - pos).Magnitude / speedBoost, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(root, tweenInfo, {CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))})
    tween:Play()
    tween.Completed:Wait()
end

-- Открытие яйца
local function clickEgg(egg)
    if egg and egg:FindFirstChild("ClickDetector") then
        fireclickdetector(egg.ClickDetector)
        wait(0.3)
    end
end

-- Анти-энтити
local function checkEntities()
    if not avoidEntities then return end
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Model") or v:IsA("Part") then
            local name = v.Name:lower()
            for _, ename in ipairs(entityNames) do
                if name:find(ename) then
                    local pos = v:IsA("Model") and (v:FindFirstChild("HumanoidRootPart") or v.PrimaryPart) and (v.HumanoidRootPart or v.PrimaryPart).Position or v.Position
                    if pos and (root.Position - pos).Magnitude < 18 then
                        root.CFrame = root.CFrame + Vector3.new(math.random(-40,40), 0, math.random(-40,40))
                        return
                    end
                end
            end
        end
    end
end

-- Сбор фрагментов
local function farmFragments()
    for _, part in ipairs(workspace:GetDescendants()) do
        if part:IsA("Part") and part.Name == fragmentName and part:FindFirstChild("ClickDetector") then
            local root = character and character:FindFirstChild("HumanoidRootPart")
            if root and (root.Position - part.Position).Magnitude < 80 then
                fireclickdetector(part.ClickDetector)
                wait(0.1)
            end
        end
    end
end

-- Портал-кликер
local function clickPortals()
    for _, part in ipairs(workspace:GetDescendants()) do
        if part:IsA("Part") and (part.Name == portalName or part.Name:lower():find("portal")) and part:FindFirstChild("ClickDetector") then
            fireclickdetector(part.ClickDetector)
            wait(0.5)
        end
    end
end

-- Главный цикл
print("Backrooms Ultimate Farmer запущен. Игрок: " .. player.Name)
local lastEggCheck = 0
while task.wait(0.1) do
    character = player.Character
    if not character then continue end
    humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then continue end

    -- Прыжок и скорость
    if humanoid:GetState() ~= Enum.HumanoidStateType.Freefall then
        humanoid.Jump = true
    end
    humanoid.WalkSpeed = speedBoost

    -- Раз в 5 сек перепроверяем топ-яйцо
    if tick() - lastEggCheck > 5 then
        lastEggCheck = tick()
        local bestEgg = findBestEgg()
        if bestEgg then
            teleportTo(bestEgg)
            for _ = 1, 15 do
                clickEgg(bestEgg)
                wait(0.35)
            end
        end
    end

    -- Стандартный фарм
    farmFragments()
    checkEntities()
    clickPortals()

    -- Фарм обычных яиц, если топ-яйцо не найдено
    if not findBestEgg() then
        for _, egg in pairs(workspace:GetDescendants()) do
            if egg:IsA("Model") and egg:FindFirstChild("ClickDetector") and egg.Name:lower():find("egg") then
                clickEgg(egg)
                wait(0.1)
            end
        end
    end
end
