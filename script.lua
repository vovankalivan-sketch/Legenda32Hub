-- RidzHub ⚔️ Mobile Delta (Blox Fruits)
repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer

local plr = game.Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "RidzHub"
gui.Parent = game.CoreGui
gui.ResetOnSpawn = false

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 400, 0, 550)
frame.Position = UDim2.new(0.5, -200, 0.5, -275)
frame.BackgroundColor3 = Color3.fromRGB(20,20,30)
frame.BackgroundTransparency = 0.15
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,40)
title.Text = "RidzHub ⚔️ | Mobile Delta"
title.BackgroundColor3 = Color3.fromRGB(180,0,0)
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true
title.Parent = frame

local list = Instance.new("ScrollingFrame")
list.Size = UDim2.new(1,0,1,-40)
list.Position = UDim2.new(0,0,0,40)
list.BackgroundTransparency = 1
list.CanvasSize = UDim2.new(0,0,0,900)
list.Parent = frame

local function btn(text, y, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.9,0,0,50)
    b.Position = UDim2.new(0.05,0,0,y)
    b.Text = text
    b.BackgroundColor3 = Color3.fromRGB(40,40,60)
    b.TextColor3 = Color3.new(1,1,1)
    b.TextScaled = true
    b.Parent = list
    b.MouseButton1Click:Connect(callback)
    return y + 55
end

local y = 10

-- Auto Farm Level (мобильная версия)
y = btn("⚔️ Auto Farm Level (Mobile)", y, function()
    spawn(function()
        while true do task.wait(1)
            local lvl = plr.Data.Level.Value
            for _, v in pairs(workspace.Enemies:GetChildren()) do
                if v:FindFirstChild("Level") and v.Level.Value <= lvl + 15 and v.Level.Value >= lvl - 5 and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
                    plr.Character.HumanoidRootPart.CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0,0,4)
                    task.wait(0.3)
                    -- тап по экрану (эмуляция атаки)
                    local ts = game:GetService("UserInputService")
                    if ts.TouchEnabled then
                        ts:SendTouchEvent(1, ts:GetMouseLocation().X, ts:GetMouseLocation().Y, true)
                        task.wait(0.1)
                        ts:SendTouchEvent(0, ts:GetMouseLocation().X, ts:GetMouseLocation().Y, false)
                    end
                end
            end
        end
    end)
end)

y = btn("🌊 Auto Sea Beast", y, function()
    spawn(function()
        while true do task.wait(2)
            for _, v in pairs(workspace:GetDescendants()) do
                if v.Name == "SeaBeast" and v:FindFirstChild("HumanoidRootPart") then
                    plr.Character.HumanoidRootPart.CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0,10,5)
                end
            end
        end
    end)
end)

y = btn("🍍 Auto Bring Fruits", y, function()
    for _, v in pairs(workspace:GetDescendants()) do
        if v.Name:find("Fruit") and v:IsA("Tool") and v.Handle then
            v.Handle.CFrame = plr.Character.HumanoidRootPart.CFrame
        end
    end
end)

y = btn("🥊 Auto Bounty + ESP", y, function()
    -- простой ESP на телефоне
    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= plr and p.Character then
            local bill = Instance.new("BillboardGui")
            bill.Size = UDim2.new(0,100,0,30)
            bill.AlwaysOnTop = true
            bill.Parent = p.Character.HumanoidRootPart
            local lab = Instance.new("TextLabel")
            lab.Size = UDim2.new(1,0,1,0)
            lab.Text = p.Name.." | "..tostring(math.floor((plr.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude)).."m"
            lab.TextColor3 = Color3.new(1,0,0)
            lab.BackgroundTransparency = 1
            lab.Parent = bill
        end
    end
    spawn(function()
        while true do task.wait(4)
            for _, p in pairs(game.Players:GetPlayers()) do
                if p ~= plr and p.Character then
                    plr.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,3)
                end
            end
        end
    end)
end)

y = btn("🗺️ Teleport Third Sea", y, function()
    plr.Character.HumanoidRootPart.CFrame = CFrame.new(-11500, 6300, -12300)
end)

y = btn("🚀 Fly + NoClip (Mobile)", y, function()
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1,1,1)*1e5
    bv.Parent = plr.Character.HumanoidRootPart
    local uis = game:GetService("UserInputService")
    uis.TouchTap:Connect(function()
        bv.Velocity = bv.Velocity + Vector3.new(0,30,0)
    end)
    game:GetService("RunService").RenderStepped:Connect(function()
        if plr.Character then
            plr.Character.HumanoidRootPart.CanCollide = false
        end
    end)
end)

y = btn("🛠️ FPS Unlocker + Auto Stats", y, function()
    setfpscap(999)
    spawn(function()
        while true do task.wait(0.5)
            if plr.Data.Points.Value > 0 then
                plr.Data.Melee.Value = plr.Data.Melee.Value + plr.Data.Points.Value
                plr.Data.Points.Value = 0
            end
        end
    end)
end)

print("RidzHub Mobile Delta загружен | Тапни кнопки пальцем")
