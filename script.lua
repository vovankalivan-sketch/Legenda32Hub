-- ForestPS99 v2.0 | Pet Simulator 99 | Delta Client (телефон)
-- Авто-эвенты | ESP на блестящие лапы | Авто-прохождение | Полный фарм

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "ForestPS99_Ultimate"
gui.ResetOnSpawn = false
pcall(function() gui.Parent = CoreGui end)
if not gui.Parent then
    pcall(function() gui.Parent = LocalPlayer.PlayerGui end)
end
if not gui.Parent then return end

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 320, 0, 480)
main.Position = UDim2.new(0.5, -160, 0.5, -240)
main.BackgroundColor3 = Color3.fromRGB(15,15,35)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,40)
title.Text = "✨ ForestPS99 v2.0 | Ultimate"
title.BackgroundColor3 = Color3.fromRGB(35,35,60)
title.TextColor3 = Color3.fromRGB(255,220,100)
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.BorderSizePixel = 0
title.Parent = main

local close = Instance.new("TextButton")
close.Size = UDim2.new(0,40,1,0)
close.Position = UDim2.new(1,-40,0,0)
close.Text = "X"
close.TextColor3 = Color3.fromRGB(255,100,100)
close.BackgroundTransparency = 1
close.Font = Enum.Font.GothamBold
close.TextSize = 18
close.BorderSizePixel = 0
close.Parent = title
close.MouseButton1Click:Connect(function() gui:Destroy() end)

-- Вкладки
local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1,0,0,40)
tabBar.Position = UDim2.new(0,0,0,40)
tabBar.BackgroundColor3 = Color3.fromRGB(25,25,50)
tabBar.BorderSizePixel = 0
tabBar.Parent = main

local contentArea = Instance.new("Frame")
contentArea.Size = UDim2.new(1,0,1,-80)
contentArea.Position = UDim2.new(0,0,0,80)
contentArea.BackgroundColor3 = Color3.fromRGB(20,22,45)
contentArea.BorderSizePixel = 0
contentArea.Parent = main

local tabs = {}
local currentTab = nil

local function createTab(name, icon)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 80, 1, 0)
    btn.Text = icon .. " " .. name
    btn.TextColor3 = Color3.fromRGB(200,200,220)
    btn.BackgroundColor3 = Color3.fromRGB(30,30,55)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.BorderSizePixel = 0
    btn.Parent = tabBar
    
    local content = Instance.new("ScrollingFrame")
    content.Size = UDim2.new(1,0,1,0)
    content.BackgroundTransparency = 1
    content.ScrollBarThickness = 0
    content.BorderSizePixel = 0
    content.Parent = contentArea
    content.Visible = false
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = content
    
    btn.MouseButton1Click:Connect(function()
        for _, v in pairs(tabs) do
            v.content.Visible = false
            v.btn.BackgroundColor3 = Color3.fromRGB(30,30,55)
        end
        content.Visible = true
        btn.BackgroundColor3 = Color3.fromRGB(90,110,160)
        currentTab = name
        task.wait(0.1)
        if layout then
            content.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 20)
        end
    end)
    
    tabs[name] = {btn = btn, content = content, layout = layout}
    if not currentTab then btn.MouseButton1Click:Fire() end
    return content
end

local function addToggle(parent, text, callback)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, -12, 0, 38)
    f.BackgroundColor3 = Color3.fromRGB(30,32,55)
    f.BorderSizePixel = 0
    f.Parent = parent
    
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -60, 1, 0)
    l.Text = text
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.BackgroundTransparency = 1
    l.TextColor3 = Color3.fromRGB(220,220,240)
    l.Font = Enum.Font.Gotham
    l.TextSize = 11
    l.BorderSizePixel = 0
    l.Parent = f
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 50, 0, 26)
    btn.Position = UDim2.new(1, -55, 0.5, -13)
    btn.BackgroundColor3 = Color3.fromRGB(80,80,110)
    btn.Text = ""
    btn.BorderSizePixel = 0
    btn.Parent = f
    
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(70,180,70) or Color3.fromRGB(80,80,110)
        if callback then callback(state) end
    end)
end

local function addSlider(parent, text, minVal, maxVal, defaultVal, callback)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, -12, 0, 65)
    f.BackgroundColor3 = Color3.fromRGB(30,32,55)
    f.BorderSizePixel = 0
    f.Parent = parent
    
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1,0,0,20)
    l.Text = text .. ": " .. tostring(defaultVal)
    l.BackgroundTransparency = 1
    l.TextColor3 = Color3.fromRGB(220,220,240)
    l.Font = Enum.Font.Gotham
    l.TextSize = 11
    l.BorderSizePixel = 0
    l.Parent = f
    
    local bg = Instance.new("TextButton")
    bg.Size = UDim2.new(1, -20, 0, 16)
    bg.Position = UDim2.new(0, 10, 0, 35)
    bg.BackgroundColor3 = Color3.fromRGB(55,55,80)
    bg.Text = ""
    bg.BorderSizePixel = 0
    bg.Parent = f
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((defaultVal-minVal)/(maxVal-minVal), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(100,180,250)
    fill.BorderSizePixel = 0
    fill.Parent = bg
    
    local val = defaultVal
    local drag = false
    
    bg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then drag = true end
    end)
    bg.InputEnded:Connect(function() drag = false end)
    
    UserInputService.TouchMoved:Connect(function(input)
        if drag and bg and bg.AbsoluteSize.X > 0 then
            local percent = math.clamp((input.Position.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
            val = math.floor(minVal + (maxVal - minVal) * percent + 0.5)
            fill.Size = UDim2.new((val-minVal)/(maxVal-minVal), 0, 1, 0)
            l.Text = text .. ": " .. tostring(val)
            if callback then callback(val) end
        end
    end)
end

-- ========== НАСТРОЙКИ ==========
local S = {
    autoBreak = false,
    autoCollect = false,
    autoOpenEggs = false,
    autoUpgrade = false,
    autoZone = false,
    autoEvent = false,
    espShiny = false,
    fly = false,
    speed = 50,
    currentEvent = "Неизвестно"
}

-- ========== АВТО-ОПРЕДЕЛЕНИЕ ЭВЕНТА ==========
task.spawn(function()
    while wait(5) do
        if S.autoEvent then
            -- Ищем активный ивент
            local eventFound = false
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("Model") and v.Name:lower():find("event") then
                    S.currentEvent = v.Name
                    eventFound = true
                    -- Авто-телепорт к ивенту
                    if v:FindFirstChild("Part") then
                        pcall(function()
                            LocalPlayer.Character.HumanoidRootPart.CFrame = v.Part.CFrame
                        end)
                    elseif v:FindFirstChild("HumanoidRootPart") then
                        pcall(function()
                            LocalPlayer.Character.HumanoidRootPart.CFrame = v.HumanoidRootPart.CFrame
                        end)
                    end
                    break
                end
            end
            if not eventFound then
                -- Проверка на доску ивентов
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("Model") and (v.Name:lower():find("board") or v.Name:lower():find("eventboard")) then
                        if v:FindFirstChild("ClickDetector") then
                            pcall(function() v.ClickDetector:Click() end)
                        end
                        break
                    end
                end
            end
        end
    end
end)

-- ========== ESP НА БЛЕСТЯЩИЕ ЛАПЫ (SHINY PAWS) ==========
local espObjects = {}
local function createESP(part, color)
    if espObjects[part] then return end
    local box = Instance.new("BoxHandleAdornment")
    box.Size = part.Size
    box.Adornee = part
    box.Color3 = color
    box.Transparency = 0.5
    box.ZIndex = 10
    box.AlwaysOnTop = true
    box.Parent = gui
    
    local text = Instance.new("TextLabel")
    text.Text = "✨ БЛЕСТЯЩИЙ!"
    text.TextColor3 = Color3.fromRGB(255,255,0)
    text.BackgroundTransparency = 1
    text.TextScaled = true
    text.TextStrokeTransparency = 0.5
    -- Привязка текста к части (сложно, сделаем через BillboardGui позже, пока просто рамка)
    
    espObjects[part] = box
end

task.spawn(function()
    while wait(0.5) do
        if S.espShiny then
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("Model") and (v.Name:lower():find("shiny") or v.Name:lower():find("glitter") or v:FindFirstChild("ShinyTag")) then
                    local part = v:FindFirstChild("PrimaryPart") or v:FindFirstChild("Head") or v:FindFirstChild("HumanoidRootPart")
                    if part then
                        createESP(part, Color3.fromRGB(255,215,0))
                    end
                end
            end
        else
            for _, obj in pairs(espObjects) do
                pcall(function() obj:Destroy() end)
            end
            espObjects = {}
        end
    end
end)

-- ========== АВТО-ПРОХОЖДЕНИЕ ЗОН ==========
task.spawn(function()
    while wait(1) do
        if S.autoZone and LocalPlayer.Character then
            -- Ищем телепорт в следующую зону
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("Model") and (v.Name:lower():find("portal") or v.Name:lower():find("door") or v.Name:lower():find("zone")) then
                    if v:FindFirstChild("Part") and v.Part:FindFirstChild("TouchInterest") then
                        pcall(function()
                            LocalPlayer.Character.HumanoidRootPart.CFrame = v.Part.CFrame
                        end)
                        break
                    elseif v:FindFirstChild("HumanoidRootPart") then
                        pcall(function()
                            LocalPlayer.Character.HumanoidRootPart.CFrame = v.HumanoidRootPart.CFrame
                        end)
                        break
                    end
                end
            end
        end
    end
end)

-- ========== АВТО-СБОР И АВТО-ЛОМАНИЕ ==========
task.spawn(function()
    while wait(0.2) do
        if S.autoBreak and LocalPlayer.Character then
            local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if tool then
                pcall(function()
                    local remote = game:GetService("ReplicatedStorage"):FindFirstChild("BreakBlock")
                    if remote then remote:FireServer(tool, CFrame.new()) end
                end)
            end
        end
    end
end)

task.spawn(function()
    while wait(0.3) do
        if S.autoCollect then
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("Model") and (v.Name:lower():find("coin") or v.Name:lower():find("diamond") or v.Name:lower():find("chest") or v.Name:lower():find("orb")) then
                    local part = v:FindFirstChild("Part") or v:FindFirstChild("HumanoidRootPart")
                    if part then
                        pcall(function()
                            LocalPlayer.Character.HumanoidRootPart.CFrame = part.CFrame
                        end)
                        break
                    end
                end
            end
        end
    end
end)

-- ========== АВТО-ОТКРЫТИЕ ЯИЦ ==========
task.spawn(function()
    while wait(0.5) do
        if S.autoOpenEggs then
            local egg = LocalPlayer.Backpack:FindFirstChildWhichIsA("Tool") or LocalPlayer.Character:FindFirstChildWhichIsA("Tool")
            if egg and egg:FindFirstChild("ClickDetector") then
                pcall(function() egg.ClickDetector:Click() end)
            end
        end
    end
end)

-- ========== АВТО-АПГРЕЙД ==========
task.spawn(function()
    while wait(1) do
        if S.autoUpgrade then
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("Model") and (v.Name:lower():find("upgrade") or v.Name:lower():find("rebirth") or v.Name:lower():find("buy")) then
                    if v:FindFirstChild("ClickDetector") then
                        pcall(function() v.ClickDetector:Click() end)
                    end
                end
            end
        end
    end
end)

-- ========== FLY ==========
local flyActive = false
local bv, bg
task.spawn(function()
    while wait(0.1) do
        if S.fly and not flyActive then
            flyActive = true
            local c = LocalPlayer.Character
            if c and c:FindFirstChild("HumanoidRootPart") then
                bv = Instance.new("BodyVelocity")
                bv.MaxForce = Vector3.new(1e5,1e5,1e5)
                bv.Parent = c.HumanoidRootPart
                bg = Instance.new("BodyGyro")
                bg.MaxTorque = Vector3.new(1e5,1e5,1e5)
                bg.Parent = c.HumanoidRootPart
            end
        elseif not S.fly and flyActive then
            flyActive = false
            if bv then bv:Destroy() end
            if bg then bg:Destroy() end
        end
        if flyActive and bv and LocalPlayer.Character then
            pcall(function()
                local cam = workspace.CurrentCamera
                local move = Vector3.new()
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,1,0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0,1,0) end
                bv.Velocity = move.Unit * S.speed
                bg.CFrame = cam.CFrame
            end)
        end
    end
end)

-- ========== АНТИ-АФК ==========
task.spawn(function()
    while wait(55) do
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:Button1Down(Vector2.new(0,0))
            VirtualUser:Button1Up(Vector2.new(0,0))
        end)
    end
end)

-- ========== ПОСТРОЕНИЕ МЕНЮ ==========
local farmTab = createTab("Фарм", "⚡")
addToggle(farmTab, "Авто-ломание блоков", function(v) S.autoBreak = v end)
addToggle(farmTab, "Авто-сбор монет/сундуков", function(v) S.autoCollect = v end)
addToggle(farmTab, "Авто-открытие яиц", function(v) S.autoOpenEggs = v end)

local upgradeTab = createTab("Апгрейд", "🔧")
addToggle(upgradeTab, "Авто-апгрейд (Rebirth)", function(v) S.autoUpgrade = v end)
addToggle(upgradeTab, "Авто-прохождение зон", function(v) S.autoZone = v end)

local eventTab = createTab("Эвенты", "🎉")
addToggle(eventTab, "Авто-эвенты (новые)", function(v) S.autoEvent = v end)
local eventLabel = Instance.new("TextLabel")
eventLabel.Size = UDim2.new(1, -12, 0, 30)
eventLabel.Text = "Текущий ивент: " .. S.currentEvent
eventLabel.BackgroundColor3 = Color3.fromRGB(40,45,70)
eventLabel.TextColor3 = Color3.fromRGB(255,200,100)
eventLabel.Font = Enum.Font.Gotham
eventLabel.TextSize = 11
eventLabel.BorderSizePixel = 0
eventLabel.Parent = eventTab
task.spawn(function()
    while wait(2) do
        eventLabel.Text = "Текущий ивент: " .. S.currentEvent
    end
end)

local espTab = createTab("ESP", "👁️")
addToggle(espTab, "ESP на блестящие лапы", function(v) S.espShiny = v end)

local moveTab = createTab("Движение", "🚀")
addToggle(moveTab, "Fly (WASD+Space)", function(v) S.fly = v end)
addSlider(moveTab, "Скорость полета", 20, 250, 70, function(v) S.speed = v end)

pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification",{
        Title = "ForestPS99 v2.0",
        Text = "Ultimate загружен | Эвенты | ESP | Авто-прохождение",
        Duration = 3
    })
end)

print("ForestPS99 v2.0 | Pet Simulator 99 | Эвенты, ESP, Авто-прохождение")
