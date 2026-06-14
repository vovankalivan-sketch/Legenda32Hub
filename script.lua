--[[
    Ноклип + Бесконечный прыжок + Флай (Меню)
    Delta Executor (Android/iOS)
]]

local player = game:GetService("Players").LocalPlayer
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "NoclipJumpFlyGUI"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 200, 0, 160)
frame.Position = UDim2.new(0.5, -100, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 25)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Text = "Ноклип + Прыжок + Флай"
title.Font = Enum.Font.SourceSansBold
title.TextSize = 14

-- Функция создания переключателя
local function createToggle(y, text, callback)
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0, 50, 0, 24)
    btn.Position = UDim2.new(0, 10, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = "OFF"
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 14

    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(0, 100, 0, 24)
    lbl.Position = UDim2.new(0, 70, 0, y)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.Text = text
    lbl.Font = Enum.Font.SourceSans
    lbl.TextSize = 14

    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = state and "ON" or "OFF"
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(100, 100, 100)
        callback(state)
    end)
    return btn, lbl
end

local noclipActive = false
local jumpActive = false
local flyActive = false
local flyBodyVelocity = nil
local flyBodyGyro = nil
local verticalSpeed = 0

-- Ноклип
game:GetService("RunService").Stepped:Connect(function()
    if noclipActive and player.Character then
        for _, v in ipairs(player.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end)

-- Бесконечный прыжок
game:GetService("RunService").Heartbeat:Connect(function()
    if jumpActive and player.Character then
        local hum = player.Character:FindFirstChild("Humanoid")
        if hum and hum:GetState() == Enum.HumanoidStateType.Landed or hum:GetState() == Enum.HumanoidStateType.Running then
            hum.Jump = true
        end
    end
end)

-- Флай
local function updateFly()
    if not flyActive then
        if flyBodyVelocity then flyBodyVelocity:Destroy(); flyBodyVelocity = nil end
        if flyBodyGyro then flyBodyGyro:Destroy(); flyBodyGyro = nil end
        return
    end
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    local root = player.Character.HumanoidRootPart
    if not flyBodyVelocity then
        flyBodyVelocity = Instance.new("BodyVelocity")
        flyBodyVelocity.MaxForce = Vector3.new(400000, 400000, 400000)
        flyBodyVelocity.Velocity = Vector3.zero
        flyBodyVelocity.Parent = root
    end
    if not flyBodyGyro then
        flyBodyGyro = Instance.new("BodyGyro")
        flyBodyGyro.MaxTorque = Vector3.new(400000, 400000, 400000)
        flyBodyGyro.CFrame = root.CFrame
        flyBodyGyro.Parent = root
    end
    local hum = player.Character:FindFirstChild("Humanoid")
    if hum then
        local moveDir = hum.MoveDirection * 30 -- скорость полёта
        flyBodyVelocity.Velocity = moveDir + Vector3.new(0, verticalSpeed, 0)
        flyBodyGyro.CFrame = root.CFrame
    end
end

game:GetService("RunService").Heartbeat:Connect(updateFly)

-- Кнопки вверх/вниз появляются только при флае
local upBtn = Instance.new("TextButton", frame)
upBtn.Size = UDim2.new(0, 40, 0, 40)
upBtn.Position = UDim2.new(0.7, 0, 0.45, 0)
upBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 200)
upBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
upBtn.Text = "↑"
upBtn.Font = Enum.Font.SourceSansBold
upBtn.TextSize = 24
upBtn.Visible = false

local downBtn = Instance.new("TextButton", frame)
downBtn.Size = UDim2.new(0, 40, 0, 40)
downBtn.Position = UDim2.new(0.7, 0, 0.75, 0)
downBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
downBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
downBtn.Text = "↓"
downBtn.Font = Enum.Font.SourceSansBold
downBtn.TextSize = 24
downBtn.Visible = false

upBtn.MouseButton1Click:Connect(function()
    if flyActive then verticalSpeed = 50 end
end)
upBtn.MouseButton1Click:Connect(function() -- неправильно, надо исправить: две функции на одно событие, но я оставлю как есть для краткости, а лучше переписать ниже
end)

-- Исправленный обработчик для кнопок (переделаем ниже)
upBtn:Destroy()
downBtn:Destroy()
-- Создадим заново правильно
upBtn = Instance.new("TextButton", frame)
upBtn.Size = UDim2.new(0, 40, 0, 40)
upBtn.Position = UDim2.new(0.7, 0, 0.45, 0)
upBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 200)
upBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
upBtn.Text = "↑"
upBtn.Font = Enum.Font.SourceSansBold
upBtn.TextSize = 24
upBtn.Visible = false

downBtn = Instance.new("TextButton", frame)
downBtn.Size = UDim2.new(0, 40, 0, 40)
downBtn.Position = UDim2.new(0.7, 0, 0.75, 0)
downBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
downBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
downBtn.Text = "↓"
downBtn.Font = Enum.Font.SourceSansBold
downBtn.TextSize = 24
downBtn.Visible = false

upBtn.MouseButton1Down:Connect(function()
    if flyActive then verticalSpeed = 50 end
end)
upBtn.MouseButton1Up:Connect(function()
    verticalSpeed = 0
end)
downBtn.MouseButton1Down:Connect(function()
    if flyActive then verticalSpeed = -50 end
end)
downBtn.MouseButton1Up:Connect(function()
    verticalSpeed = 0
end)

-- Тогглы
createToggle(35, "Ноклип", function(v) noclipActive = v end)
createToggle(65, "Беск. прыжок", function(v) jumpActive = v end)
local flyToggle, flyLabel = createToggle(95, "Флай", function(v)
    flyActive = v
    upBtn.Visible = v
    downBtn.Visible = v
    if not v then
        verticalSpeed = 0
        if flyBodyVelocity then flyBodyVelocity:Destroy(); flyBodyVelocity = nil end
        if flyBodyGyro then flyBodyGyro:Destroy(); flyBodyGyro = nil end
    end
end)
