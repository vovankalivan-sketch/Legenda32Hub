--[[
    Ultimate меню: Ноклип, Прыжок, Флай, Скорость, X-Ray
    Для Delta Executor (Android/iOS)
]]
local p = game.Players.LocalPlayer
local gui = Instance.new("ScreenGui", p:WaitForChild("PlayerGui"))
gui.Name = "UltMenu"

local f = Instance.new("Frame", gui)
f.Size = UDim2.new(0, 200, 0, 210)
f.Position = UDim2.new(0.5, -100, 0.2, 0)
f.BackgroundColor3 = Color3.fromRGB(15,15,15)
f.Active = true
f.Draggable = true

local t = Instance.new("TextLabel", f)
t.Size = UDim2.new(1,0,0,24)
t.BackgroundColor3 = Color3.fromRGB(35,35,35)
t.TextColor3 = Color3.new(1,1,1)
t.Text = "Ultimate Cheats"
t.Font = Enum.Font.SourceSansBold
t.TextSize = 14

local function makeToggle(y, name, cb)
    local cont = Instance.new("Frame", f)
    cont.Size = UDim2.new(1,-20,0,26)
    cont.Position = UDim2.new(0,10,0,y)
    cont.BackgroundTransparency = 1
    local btn = Instance.new("TextButton", cont)
    btn.Size = UDim2.new(0,50,0,22)
    btn.BackgroundColor3 = Color3.fromRGB(80,80,80)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Text = "OFF"
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 13
    local lbl = Instance.new("TextLabel", cont)
    lbl.Size = UDim2.new(0,120,0,22)
    lbl.Position = UDim2.new(0,55,0,0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.new(1,1,1)
    lbl.Text = name
    lbl.Font = Enum.Font.SourceSans
    lbl.TextSize = 13
    local on = false
    btn.MouseButton1Click:Connect(function()
        on = not on
        btn.Text = on and "ON" or "OFF"
        btn.BackgroundColor3 = on and Color3.fromRGB(0,160,0) or Color3.fromRGB(80,80,80)
        cb(on)
    end)
    return btn
end

-- состояния
local noclipOn = false
local jumpOn = false
local flyOn = false
local xrayOn = false
local flySpeed = 0
local ws = 20
local bv, bg

-- ноклип
game:GetService("RunService").Stepped:Connect(function()
    if noclipOn and p.Character then
        for _,v in ipairs(p.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end)

-- бесконечный прыжок
game:GetService("RunService").Heartbeat:Connect(function()
    if jumpOn and p.Character then
        local h = p.Character:FindFirstChild("Humanoid")
        if h and h:GetState() == Enum.HumanoidStateType.Landed then
            h.Jump = true
        end
    end
end)

-- флай
local function setFly(v)
    flyOn = v
    if not v then
        if bv then bv:Destroy(); bv=nil end
        if bg then bg:Destroy(); bg=nil end
        flySpeed = 0
        return
    end
    local c = p.Character
    if not c or not c:FindFirstChild("HumanoidRootPart") then return end
    local root = c.HumanoidRootPart
    bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(400000,400000,400000)
    bv.Velocity = Vector3.zero
    bv.Parent = root
    bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(400000,400000,400000)
    bg.CFrame = root.CFrame
    bg.Parent = root
end

game:GetService("RunService").Heartbeat:Connect(function()
    if flyOn and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and bv and bg then
        local root = p.Character.HumanoidRootPart
        local h = p.Character:FindFirstChild("Humanoid")
        if h then
            bv.Velocity = h.MoveDirection * 25 + Vector3.new(0, flySpeed, 0)
            bg.CFrame = root.CFrame
        end
    end
end)

-- X-Ray (прозрачность всех частей, кроме игрока)
game:GetService("RunService").Heartbeat:Connect(function()
    if xrayOn then
        local char = p.Character
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and not obj:IsDescendantOf(char) then
                obj.Transparency = 0.8
            end
        end
    end
end)

-- применение скорости
game:GetService("RunService").Heartbeat:Connect(function()
    if p.Character then
        local h = p.Character:FindFirstChild("Humanoid")
        if h then h.WalkSpeed = ws end
    end
end)

-- меню
makeToggle(30, "Ноклип", function(v) noclipOn = v end)
makeToggle(55, "Беск. прыжок", function(v) jumpOn = v end)
local flyBtn = makeToggle(80, "Флай", function(v)
    setFly(v)
    up.Visible = v
    down.Visible = v
end)
makeToggle(105, "X-Ray", function(v) xrayOn = v end)

-- слайдер скорости
local speedLabel = Instance.new("TextLabel", f)
speedLabel.Size = UDim2.new(0, 120, 0, 22)
speedLabel.Position = UDim2.new(0, 10, 0, 135)
speedLabel.BackgroundTransparency = 1
speedLabel.TextColor3 = Color3.new(1,1,1)
speedLabel.Text = "Скорость: 20"
speedLabel.Font = Enum.Font.SourceSans
speedLabel.TextSize = 13

local speedBox = Instance.new("TextBox", f)
speedBox.Size = UDim2.new(0, 50, 0, 22)
speedBox.Position = UDim2.new(0.6, 0, 0, 135)
speedBox.BackgroundColor3 = Color3.fromRGB(50,50,50)
speedBox.TextColor3 = Color3.new(1,1,1)
speedBox.Text = "20"
speedBox.Font = Enum.Font.SourceSans
speedBox.TextSize = 13
speedBox.FocusLost:Connect(function()
    local n = tonumber(speedBox.Text)
    if n and n >= 16 and n <= 200 then
        ws = n
        speedLabel.Text = "Скорость: "..n
    else
        speedBox.Text = ws
    end
end)

-- кнопки флая
local up = Instance.new("TextButton", f)
up.Size = UDim2.new(0, 30, 0, 30)
up.Position = UDim2.new(0.75, 0, 0.47, 0)
up.BackgroundColor3 = Color3.fromRGB(50,50,200)
up.TextColor3 = Color3.new(1,1,1)
up.Text = "↑"
up.Font = Enum.Font.SourceSansBold
up.TextSize = 18
up.Visible = false
up.MouseButton1Down:Connect(function() if flyOn then flySpeed = 45 end end)
up.MouseButton1Up:Connect(function() flySpeed = 0 end)

local down = Instance.new("TextButton", f)
down.Size = UDim2.new(0, 30, 0, 30)
down.Position = UDim2.new(0.75, 0, 0.65, 0)
down.BackgroundColor3 = Color3.fromRGB(200,50,50)
down.TextColor3 = Color3.new(1,1,1)
down.Text = "↓"
down.Font = Enum.Font.SourceSansBold
down.TextSize = 18
down.Visible = false
down.MouseButton1Down:Connect(function() if flyOn then flySpeed = -45 end end)
down.MouseButton1Up:Connect(function() flySpeed = 0 end)
