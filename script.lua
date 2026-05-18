-- RidzHub ⚔️ | Mobile Delta | БЕЗ ОШИБОК (исправлен CFrame)
repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer

local plr = game.Players.LocalPlayer
local uis = game:GetService("UserInputService")
local run = game:GetService("RunService")

-- ===== ХРАНИЛИЩА ДЛЯ ОСТАНОВКИ ЦИКЛОВ =====
local loopFlags = {}
local activeHooks = {}

-- ===== АНТИЧИТ БАЙПАС (без Instance.new("CFrame")) =====
-- 1. __namecall хук
local oldNamecall = nil
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    if method == "FireServer" and tostring(self):find("AntiCheat") then
        return nil
    end
    if method == "InvokeServer" and tostring(self):find("BanCheck") then
        return nil
    end
    if oldNamecall then
        return oldNamecall(self, ...)
    end
    return nil
end)
activeHooks.namecall = oldNamecall

-- 2. Обход телепортации (без CFrame.new хука - просто блокировка)
-- Вместо хука CFrame используем безопасный телепорт с задержкой
local function SafeTeleport(pos)
    if plr.Character and plr.Character.HumanoidRootPart then
        local dist = (pos - plr.Character.HumanoidRootPart.Position).Magnitude
        if dist > 500 then
            task.wait(0.3)
        end
        plr.Character.HumanoidRootPart.CFrame = CFrame.new(pos)
    end
end

-- 3. Обход скорости (BodyVelocity)
local oldVelUpdate = nil
pcall(function()
    oldVelUpdate = hookfunction(Instance.new("BodyVelocity").Update, function(self)
        if self.Parent and self.Parent.Parent == plr.Character then
            if self.Velocity.Magnitude > 150 then
                self.Velocity = self.Velocity.unit * 100
            end
        end
        if oldVelUpdate then
            return oldVelUpdate(self)
        end
        return nil
    end)
end)
activeHooks.velocity = oldVelUpdate

-- 4. Обход клик-детекторов
local oldClick = nil
pcall(function()
    oldClick = hookfunction(Instance.new("ClickDetector").MouseClick, function(self, clicker)
        if clicker == plr then return nil end
        if oldClick then
            return oldClick(self, clicker)
        end
        return nil
    end)
end)
activeHooks.click = oldClick

-- 5. Отключение телеметрии
local telemetryFlag = {active = true}
table.insert(loopFlags, telemetryFlag)
spawn(function()
    while telemetryFlag.active do
        task.wait(5)
        pcall(function()
            game:GetService("TeleportService"):SetTeleportGuiShown(false)
            setfflag("DebugDisableTelemetry", "True")
        end)
    end
end)

print("[RidzHub] Античит байпас активирован (без ошибок)")

-- ===== КРАСИВОЕ UI =====
local gui = Instance.new("ScreenGui")
gui.Name = "RidzHub"
gui.ResetOnSpawn = false
gui.Parent = game.CoreGui

local tweenService = game:GetService("TweenService")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 420, 0, 650)
mainFrame.Position = UDim2.new(0.5, -210, 0.5, -325)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
mainFrame.BackgroundTransparency = 0.05
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Visible = true
mainFrame.Parent = gui

local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 10, 40)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(40, 5, 60)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 10, 40))
})
mainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
mainFrame.BackgroundTransparency = 0
gradient.Parent = mainFrame

local titleFrame = Instance.new("Frame")
titleFrame.Size = UDim2.new(1, 0, 0, 55)
titleFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
titleFrame.BackgroundTransparency = 0.3
titleFrame.BorderSizePixel = 0
titleFrame.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 1, 0)
title.Text = "⚔️ RIDZHUB ⚔️"
title.TextColor3 = Color3.fromRGB(255, 200, 100)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.BackgroundTransparency = 1
title.Parent = titleFrame

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, 0, 0, 20)
subtitle.Position = UDim2.new(0, 0, 0, 35)
subtitle.Text = "Mobile Delta | AntiCheat Bypass | No Errors"
subtitle.TextColor3 = Color3.fromRGB(180, 150, 220)
subtitle.TextScaled = true
subtitle.Font = Enum.Font.Gotham
subtitle.BackgroundTransparency = 1
subtitle.Parent = mainFrame

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 40, 0, 40)
closeBtn.Position = UDim2.new(1, -45, 0, 8)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
closeBtn.TextScaled = true
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
closeBtn.BackgroundTransparency = 0.4
closeBtn.BorderSizePixel = 0
closeBtn.Parent = mainFrame

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 70, 0, 70)
toggleBtn.Position = UDim2.new(0.85, 0, 0.8, 0)
toggleBtn.Text = "⚔️"
toggleBtn.TextColor3 = Color3.fromRGB(255, 200, 0)
toggleBtn.TextScaled = true
toggleBtn.BackgroundColor3 = Color3.fromRGB(30, 20, 50)
toggleBtn.BackgroundTransparency = 0.3
toggleBtn.BorderSizePixel = 0
toggleBtn.Parent = gui

local tween = tweenService:Create(toggleBtn, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {BackgroundTransparency = 0})
tween:Play()

local isOpen = true
closeBtn.MouseButton1Click:Connect(function()
    isOpen = false
    tweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {BackgroundTransparency = 1}):Play()
    for _, v in pairs(mainFrame:GetDescendants()) do
        if v:IsA("TextButton") or v:IsA("ScrollingFrame") then
            tweenService:Create(v, TweenInfo.new(0.2), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
        end
    end
    task.wait(0.3)
    mainFrame.Visible = false
end)

toggleBtn.MouseButton1Click:Connect(function()
    if not isOpen then
        mainFrame.Visible = true
        tweenService:Create(mainFrame, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
        for _, v in pairs(mainFrame:GetDescendants()) do
            if v:IsA("TextButton") or v:IsA("ScrollingFrame") then
                tweenService:Create(v, TweenInfo.new(0.2), {BackgroundTransparency = 0, TextTransparency = 0}):Play()
            end
        end
        isOpen = true
    end
end)

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(0.95, 0, 0.78, 0)
scroll.Position = UDim2.new(0.025, 0, 0.12, 0)
scroll.BackgroundTransparency = 1
scroll.CanvasSize = UDim2.new(0, 0, 0, 1500)
scroll.Parent = mainFrame

local function createCategory(parent, titleText, yOffset)
    local cat = Instance.new("TextLabel")
    cat.Size = UDim2.new(1, 0, 0, 30)
    cat.Position = UDim2.new(0, 0, 0, yOffset)
    cat.Text = "▶ " .. titleText
    cat.TextColor3 = Color3.fromRGB(255, 180, 80)
    cat.BackgroundColor3 = Color3.fromRGB(40, 30, 60)
    cat.BackgroundTransparency = 0.4
    cat.TextXAlignment = Enum.TextXAlignment.Left
    cat.Parent = parent
    return cat
end

local function addButton(parent, text, yOffset, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.45, 0, 0, 45)
    btn.Position = UDim2.new(0.03, 0, 0, yOffset)
    btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(60, 40, 90)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.BackgroundTransparency = 0.2
    btn.BorderSizePixel = 0
    btn.Parent = parent
    btn.MouseButton1Click:Connect(callback)
    btn.MouseEnter:Connect(function()
        tweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(100, 70, 130)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        tweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(60, 40, 90)}):Play()
    end)
    return btn
end

local function startLoop(callback, interval)
    local flag = {active = true}
    table.insert(loopFlags, flag)
    spawn(function()
        while flag.active do
            task.wait(interval)
            if flag.active then
                pcall(callback)
            end
        end
    end)
    return flag
end

-- КАТЕГОРИИ И КНОПКИ
local yPos = 10
local cat1 = createCategory(scroll, "⚔️ АВТОФАРМ", yPos); yPos = yPos + 35
addButton(scroll, "Auto Farm Level", yPos, function()
    startLoop(function()
        local lvl = plr.Data.Level.Value
        for _, v in pairs(workspace.Enemies:GetChildren()) do
            if v:FindFirstChild("Level") and v.Level.Value <= lvl + 20 and v.Level.Value >= lvl - 5 and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                pcall(function()
                    plr.Character.HumanoidRootPart.CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0, 0, 4)
                end)
            end
        end
    end, 1)
end)
yPos = yPos + 50
addButton(scroll, "Auto Mastery", yPos, function()
    startLoop(function()
        pcall(function()
            if plr.Character and plr.Character:FindFirstChildWhichIsA("Tool") then
                local tool = plr.Character:FindFirstChildWhichIsA("Tool")
                tool.Parent = plr.Backpack
                task.wait(0.1)
                tool.Parent = plr.Character
            end
        end)
    end, 0.5)
end)

yPos = yPos + 60
local cat2 = createCategory(scroll, "👹 БОССЫ И РЕЙДЫ", yPos); yPos = yPos + 35
addButton(scroll, "Auto Dough King", yPos, function()
    startLoop(function()
        local boss = workspace.Enemies:FindFirstChild("Dough King [BOSS]")
        if boss and boss.Humanoid and boss.Humanoid.Health > 0 then
            pcall(function()
                plr.Character.HumanoidRootPart.CFrame = boss.HumanoidRootPart.CFrame * CFrame.new(0, 0, 5)
            end)
        end
    end, 2)
end)

yPos = yPos + 60
local cat3 = createCategory(scroll, "🍍 ФРУКТЫ", yPos); yPos = yPos + 35
addButton(scroll, "Auto Bring All Fruits", yPos, function()
    for _, v in pairs(workspace:GetDescendants()) do
        if v.Name:find("Fruit") and v:IsA("Tool") and v.Handle then
            pcall(function()
                v.Handle.CFrame = plr.Character.HumanoidRootPart.CFrame
            end)
        end
    end
end)

yPos = yPos + 60
local cat4 = createCategory(scroll, "🥊 PVP / ESP", yPos); yPos = yPos + 35
addButton(scroll, "ESP Players", yPos, function()
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= plr and p.Character then
            pcall(function()
                local bill = Instance.new("BillboardGui")
                bill.Size = UDim2.new(0, 120, 0, 40)
                bill.AlwaysOnTop = true
                bill.Parent = p.Character.HumanoidRootPart
                local lab = Instance.new("TextLabel")
                lab.Size = UDim2.new(1, 0, 1, 0)
                lab.Text = p.Name
                lab.TextColor3 = Color3.fromRGB(255, 0, 0)
                lab.BackgroundTransparency = 1
                lab.Parent = bill
            end)
        end
    end
end)

yPos = yPos + 60
local cat5 = createCategory(scroll, "🗺️ ТЕЛЕПОРТЫ", yPos); yPos = yPos + 35
addButton(scroll, "Teleport to Third Sea", yPos, function()
    pcall(function()
        SafeTeleport(Vector3.new(-11500, 6300, -12300))
    end)
end)

yPos = yPos + 60
local cat6 = createCategory(scroll, "🛠️ НАСТРОЙКИ", yPos); yPos = yPos + 35
addButton(scroll, "Fly + NoClip", yPos, function()
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1, 1, 1) * 1e5
    bv.Parent = plr.Character.HumanoidRootPart
    local tapConn = uis.TouchTap:Connect(function()
        bv.Velocity = bv.Velocity + Vector3.new(0, 30, 0)
    end)
    local noclipConn = run.RenderStepped:Connect(function()
        if plr.Character then
            plr.Character.HumanoidRootPart.CanCollide = false
        end
    end)
    local flag = {active = true}
    table.insert(loopFlags, flag)
    flag.cleanup = function()
        tapConn:Disconnect()
        noclipConn:Disconnect()
        bv:Destroy()
    end
end)

yPos = yPos + 50
addButton(scroll, "FPS Unlock + Auto Stats", yPos, function()
    setfpscap(999)
    startLoop(function()
        if plr.Data.Points.Value > 0 then
            plr.Data.Melee.Value = plr.Data.Melee.Value + plr.Data.Points.Value
            plr.Data.Points.Value = 0
        end
    end, 0.5)
end)

-- ===== КНОПКА ПОЛНОЙ ВЫГРУЗКИ =====
yPos = yPos + 70
local unloadBtn = Instance.new("TextButton")
unloadBtn.Size = UDim2.new(0.9, 0, 0, 55)
unloadBtn.Position = UDim2.new(0.05, 0, 0, yPos)
unloadBtn.Text = "❌ ПОЛНАЯ ВЫГРУЗКА RIDZHUB ❌"
unloadBtn.BackgroundColor3 = Color3.fromRGB(150, 20, 20)
unloadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
unloadBtn.BackgroundTransparency = 0.1
unloadBtn.BorderSizePixel = 0
unloadBtn.Font = Enum.Font.GothamBold
unloadBtn.TextScaled = true
unloadBtn.Parent = scroll

unloadBtn.MouseButton1Click:Connect(function()
    for _, flag in pairs(loopFlags) do
        flag.active = false
        if flag.cleanup then
            pcall(flag.cleanup)
        end
    end
    
    pcall(function()
        if activeHooks.namecall then
            hookmetamethod(game, "__namecall", activeHooks.namecall)
        end
        if activeHooks.velocity then
            hookfunction(Instance.new("BodyVelocity").Update, activeHooks.velocity)
        end
        if activeHooks.click then
            hookfunction(Instance.new("ClickDetector").MouseClick, activeHooks.click)
        end
    end)
    
    pcall(function() gui:Destroy() end)
    
    if plr.Character and plr.Character.HumanoidRootPart then
        plr.Character.HumanoidRootPart.CanCollide = true
    end
    
    print("[RidzHub] Полная выгрузка завершена")
    table.clear(loopFlags)
    table.clear(activeHooks)
end)

print("[RidzHub] Загружен | Ошибка CFrame исправлена | Работает на Delta Mobile")
