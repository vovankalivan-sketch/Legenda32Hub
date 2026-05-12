-- Загрузка точной копии UI библиотеки Gamesense
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/focat69/gamesense/refs/heads/main/source"))()

-- Создание точной копии оригинального окна Skeet (зеленый акцент на "sense")
local Window = Library:New({
    Name = "gamesense",
    Padding = 6
})

-- Сервисы Roblox для работы функций
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

-- Таблицы состояний (Config)
local Config = {
    Rage = { SilentAim = false, Wallbang = false, HitboxSize = 2, AntiAim = false, SpinSpeed = 50 },
    Legit = { Triggerbot = false },
    Visuals = { EspBoxes = false, EspTracers = false, EspNames = false, EspColor = Color3.fromRGB(0, 255, 140) },
    Misc = { BunnyHop = false, NoRecoil = false, FovMultiplier = 1 }
}

-- ==========================================
-- 1. ВКЛАДКА: RAGE (Жёсткий аимбот / HvH)
-- ==========================================
local RageTab = Window:CreateTab({ Name = "Rage" })

RageTab:Button({ Name = "Enable Ragebot" }) -- Визуальный маркер

-- Сектор Аима
RunService.RenderStepped:Connect(function()
    if Config.Rage.SilentAim then
        -- Поиск ближайшей головы противника
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team and player.Character and player.Character:FindFirstChild("Head") then
                local Head = player.Character.Head
                if Config.Rage.Wallbang or player.Character:FindFirstChild("HumanoidRootPart") then
                    -- Модификация хитбокса (Hitbox Expander)
                    Head.Size = Vector3.new(Config.Rage.HitboxSize, Config.Rage.HitboxSize, Config.Rage.HitboxSize)
                    Head.CanCollide = false
                end
            end
        end
    end
    
    -- Функция Anti-Aim (Вращение тела для защиты от чужих аимов)
    if Config.Rage.AntiAim and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(Config.Rage.SpinSpeed), 0)
    end
end)

-- Элементы интерфейса Rage
-- (Имитация функций скеета: переключатели и ползунки)
-- Примечание: В реальной библиотеке Skeet элементы привязываются через логику Tab:Компонент

-- ==========================================
-- 2. ВКЛАДКА: LEGIT (Незаметная игра)
-- ==========================================
local LegitTab = Window:CreateTab({ Name = "Legit" })

-- Автовыстрел при наведении (Triggerbot)
RunService.RenderStepped:Connect(function()
    if Config.Legit.Triggerbot then
        local Mouse = LocalPlayer:GetMouse()
        if Mouse.Target and Mouse.Target.Parent:FindFirstChild("Humanoid") then
            local targetPlayer = Players:GetPlayerFromCharacter(Mouse.Target.Parent)
            if targetPlayer and targetPlayer.Team ~= LocalPlayer.Team then
                -- Эмуляция клика / выстрела (зависит от структуры оружия в Blox Strike)
                print("[Skeet] Triggerbot: Выстрел!")
            end
        end
    end
end)

-- ==========================================
-- 3. ВКЛАДКА: VISUALS (Продвинутый ESP / Валхак)
-- ==========================================
local VisualsTab = Window:CreateTab({ Name = "Visuals" })

-- Логика отрисовки 2D ESP (Boxes / Трейсеры)
local function CreateESP(player)
    local Box = Drawing.new("Square")
    Box.Visible = false
    Box.Color = Config.Visuals.EspColor
    Box.Thickness = 1
    Box.Filled = false

    local Tracer = Drawing.new("Line")
    Tracer.Visible = false
    Tracer.Color = Config.Visuals.EspColor
    Tracer.Thickness = 1

    RunService.RenderStepped:Connect(function()
        if player and player.Character outdoors and player.Character:FindFirstChild("HumanoidRootPart") and player ~= LocalPlayer and player.Team ~= LocalPlayer.Team then
            local RootPart = player.Character.HumanoidRootPart
            local Position, OnScreen = Camera:WorldToViewportPoint(RootPart.Position)

            if OnScreen then
                -- Логика Боксов (Квадраты вокруг врагов)
                if Config.Visuals.EspBoxes then
                    Box.Size = Vector2.new(2000 / Position.Z, 3000 / Position.Z)
                    Box.Position = Vector2.new(Position.X - Box.Size.X / 2, Position.Y - Box.Size.Y / 2)
                    Box.Visible = true
                else
                    Box.Visible = false
                end

                -- Логика Трейсеров (Линии до врагов)
                if Config.Visuals.EspTracers then
                    Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    Tracer.To = Vector2.new(Position.X, Position.Y)
                    Tracer.Visible = true
                else
                    Tracer.Visible = false
                end
            else
                Box.Visible = false
                Tracer.Visible = false
            end
        else
            Box.Visible = false
            Tracer.Visible = false
        end
    end)
end

-- Включение ESP для всех текущих и новых игроков
for _, p in pairs(Players:GetPlayers()) do CreateESP(p) end
Players.PlayerAdded:Connect(CreateESP)

-- ==========================================
-- 4. ВКЛАДКА: MISC (Движок и Функции)
-- ==========================================
local MiscTab = Window:CreateTab({ Name = "Misc" })

-- BunnyHop (Автоматический распрыг при зажатом пробеле)
local UserInputService = game:GetService("UserInputService")
RunService.RenderStepped:Connect(function()
    if Config.Misc.BunnyHop and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.Jump = true
        end
    end
end)


-- ==========================================
-- ТРИГГЕРЫ ДЛЯ ДЕМОНСТРАЦИИ (Включение функций через ручные тумблеры Config)
-- Раскомментируйте нужные строки ниже для жесткого теста:
Config.Visuals.EspBoxes = true
Config.Visuals.EspTracers = true
Config.Rage.SilentAim = true
Config.Misc.BunnyHop = true
-- ==========================================

print("[Skeet.cc] Интерфейс и функции успешно инициализированы для Blox Strike.")
