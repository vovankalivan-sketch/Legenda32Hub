--[[
    Ноклип + Бесконечный прыжок (Меню)
    Для Delta Executor (Android/iOS)
]]

local player = game:GetService("Players").LocalPlayer
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "NoclipJumpGUI"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 180, 0, 100)
frame.Position = UDim2.new(0.5, -90, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 25)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Text = "Ноклип + Прыжок"
title.Font = Enum.Font.SourceSansBold
title.TextSize = 14

local noclipBtn = Instance.new("TextButton", frame)
noclipBtn.Size = UDim2.new(0, 50, 0, 24)
noclipBtn.Position = UDim2.new(0, 10, 0, 35)
noclipBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
noclipBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
noclipBtn.Text = "OFF"
noclipBtn.Font = Enum.Font.SourceSansBold
noclipBtn.TextSize = 14

local noclipLabel = Instance.new("TextLabel", frame)
noclipLabel.Size = UDim2.new(0, 100, 0, 24)
noclipLabel.Position = UDim2.new(0, 70, 0, 35)
noclipLabel.BackgroundTransparency = 1
noclipLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
noclipLabel.Text = "Ноклип"
noclipLabel.Font = Enum.Font.SourceSans
noclipLabel.TextSize = 14

local jumpBtn = Instance.new("TextButton", frame)
jumpBtn.Size = UDim2.new(0, 50, 0, 24)
jumpBtn.Position = UDim2.new(0, 10, 0, 65)
jumpBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
jumpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
jumpBtn.Text = "OFF"
jumpBtn.Font = Enum.Font.SourceSansBold
jumpBtn.TextSize = 14

local jumpLabel = Instance.new("TextLabel", frame)
jumpLabel.Size = UDim2.new(0, 100, 0, 24)
jumpLabel.Position = UDim2.new(0, 70, 0, 65)
jumpLabel.BackgroundTransparency = 1
jumpLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
jumpLabel.Text = "Беск. прыжок"
jumpLabel.Font = Enum.Font.SourceSans
jumpLabel.TextSize = 14

local noclipActive = false
local jumpActive = false

-- Ноклип
game:GetService("RunService").Stepped:Connect(function()
    if noclipActive and player.Character then
        for _, v in ipairs(player.Character:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
    end
end)

-- Бесконечный прыжок
task.spawn(function()
    while task.wait() do
        if jumpActive and player.Character then
            local hum = player.Character:FindFirstChild("Humanoid")
            if hum and hum:GetState() ~= Enum.HumanoidStateType.Freefall then
                hum.Jump = true
            end
        end
    end
end)

noclipBtn.MouseButton1Click:Connect(function()
    noclipActive = not noclipActive
    noclipBtn.Text = noclipActive and "ON" or "OFF"
    noclipBtn.BackgroundColor3 = noclipActive and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(100, 100, 100)
end)

jumpBtn.MouseButton1Click:Connect(function()
    jumpActive = not jumpActive
    jumpBtn.Text = jumpActive and "ON" or "OFF"
    jumpBtn.BackgroundColor3 = jumpActive and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(100, 100, 100)
end)
