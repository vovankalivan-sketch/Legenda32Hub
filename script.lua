--[[
    Legenda32Hub | Mobile Optimized
    GitHub: https://raw.githubusercontent.com/vovankalivan-sketch/Legenda32Hub/refs/heads/main/script.lua
]]

--// Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--// Character Handler
local function getCharacter()
    return LocalPlayer.Character
end

local function getHRP()
    local char = getCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid()
    local char = getCharacter()
    return char and char:FindFirstChild("Humanoid")
end

--// Config
local Settings = {
    Fly = {Enabled = false, Speed = 50, VerticalSpeed = 0},
    Speed = {Enabled = false, Value = 16},
    Jump = {Enabled = false, Power = 100},
    AutoFarm = {Enabled = false, Target = "Grass"},
    ESP = {Enabled = false, Color = Color3.fromRGB(255, 0, 0)},
    NoClip = {Enabled = false}
}

--// Fly System
local FlyConnections = {}
local function flySystem()
    local hrp = getHRP()
    if not hrp then return end
    
    -- Clean old
    for _, v in pairs(hrp:GetChildren()) do
        if v.Name == "FlyGyro" or v.Name == "FlyVelocity" then
            v:Destroy()
        end
    end
    
    local gyro = Instance.new("BodyGyro")
    gyro.Name = "FlyGyro"
    gyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    gyro.P = 9e4
    gyro.Parent = hrp
    
    local velocity = Instance.new("BodyVelocity")
    velocity.Name = "FlyVelocity"
    velocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    velocity.P = 9e4
    velocity.Velocity = Vector3.zero
    velocity.Parent = hrp
    
    local connection = RunService.Heartbeat:Connect(function()
        if not getHRP() or not Settings.Fly.Enabled then
            disconnectFly()
            return
        end
        
        gyro.CFrame = Camera.CFrame
        local moveDirection = Vector3.zero
        local cameraCFrame = Camera.CFrame
        
        -- Keyboard controls
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDirection = moveDirection + cameraCFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDirection = moveDirection - cameraCFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDirection = moveDirection - cameraCFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDirection = moveDirection + cameraCFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveDirection = moveDirection + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            moveDirection = moveDirection - Vector3.new(0, 1, 0)
        end
        
        if moveDirection.Magnitude > 0 then
            velocity.Velocity = moveDirection.Unit * Settings.Fly.Speed
        else
            velocity.Velocity = Vector3.new(0, Settings.Fly.VerticalSpeed, 0)
        end
    end)
    
    table.insert(FlyConnections, connection)
end

function disconnectFly()
    for _, conn in ipairs(FlyConnections) do
        conn:Disconnect()
    end
    FlyConnections = {}
    
    local hrp = getHRP()
    if hrp then
        for _, v in pairs(hrp:GetChildren()) do
            if v.Name == "FlyGyro" or v.Name == "FlyVelocity" then
                v:Destroy()
            end
        end
    end
end

--// Speed System
local function speedSystem()
    local humanoid = getHumanoid()
    if humanoid then
        humanoid.WalkSpeed = Settings.Speed.Enabled and Settings.Speed.Value or 16
    end
end

--// Jump System
local function jumpSystem()
    local humanoid = getHumanoid()
    if humanoid then
        humanoid.JumpPower = Settings.Jump.Enabled and Settings.Jump.Power or 50
        humanoid.UseJumpPower = true
    end
end

--// Tween Utility
local function createTween(obj, props, duration)
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(obj, tweenInfo, props)
    tween:Play()
    return tween
end

--// Teleport System
local function teleportForward()
    local hrp = getHRP()
    if not hrp then return end
    createTween(hrp, {CFrame = hrp.CFrame + hrp.CFrame.LookVector * 10}, 0.2)
end

local function teleportTo(target)
    local hrp = getHRP()
    if not target or not hrp then return end
    createTween(hrp, {CFrame = CFrame.new(target)}, 0.3)
end

--// AutoFarm System
local AutoFarmConnection
local function autoFarmSystem()
    if AutoFarmConnection then
        AutoFarmConnection:Disconnect()
        AutoFarmConnection = nil
    end
    
    if not Settings.AutoFarm.Enabled then return end
    
    AutoFarmConnection = RunService.Heartbeat:Connect(function()
        local char = getCharacter()
        if not char then return end
        
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name == Settings.AutoFarm.Target then
                firetouchinterest(char.PrimaryPart or getHRP(), obj, 0)
                firetouchinterest(char.PrimaryPart or getHRP(), obj, 1)
            end
        end
    end)
end

--// ESP System
local ESPObjects = {}
local function espSystem()
    -- Clear old ESP
    for _, highlight in ipairs(ESPObjects) do
        if highlight and highlight.Parent then
            highlight:Destroy()
        end
    end
    ESPObjects = {}
    
    if not Settings.ESP.Enabled then return end
    
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj ~= getCharacter() then
            local highlight = Instance.new("Highlight")
            highlight.FillColor = Settings.ESP.Color
            highlight.FillTransparency = 0.5
            highlight.OutlineColor = Color3.new(1, 1, 1)
            highlight.OutlineTransparency = 0
            highlight.Parent = obj
            table.insert(ESPObjects, highlight)
        end
    end
end

--// NoClip System
local NoClipConnection
local function noClipSystem()
    if NoClipConnection then
        NoClipConnection:Disconnect()
        NoClipConnection = nil
    end
    
    local char = getCharacter()
    if not char then return end
    
    if Settings.NoClip.Enabled then
        NoClipConnection = RunService.Stepped:Connect(function()
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    end
end

--// GUI Creation
local function createGUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "Legenda32Hub"
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    ScreenGui.ResetOnSpawn = false
    
    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 250, 0, 350)
    MainFrame.Position = UDim2.new(0.5, -125, 0.5, -175)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = ScreenGui
    
    -- Title
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    Title.BorderSizePixel = 0
    Title.Text = "Legenda32 Hub | Delta"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 16
    Title.Font = Enum.Font.GothamBold
    Title.Parent = MainFrame
    
    -- Close Button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(1, -30, 0, 0)
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    CloseButton.BorderSizePixel = 0
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 16
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Parent = MainFrame
    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
        disconnectFly()
        Settings.Fly.Enabled = false
        Settings.Speed.Enabled = false
    end)
    
    -- Toggle creation function
    local function createToggle(y, name, callback)
        local Frame = Instance.new("Frame")
        Frame.Size = UDim2.new(1, -10, 0, 35)
        Frame.Position = UDim2.new(0, 5, 0, y)
        Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        Frame.BorderSizePixel = 0
        Frame.Parent = MainFrame
        
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(0.7, 0, 1, 0)
        Label.BackgroundTransparency = 1
        Label.Text = name
        Label.TextColor3 = Color3.fromRGB(255, 255, 255)
        Label.TextSize = 14
        Label.Font = Enum.Font.Gotham
        Label.Parent = Frame
        
        local Toggle = Instance.new("TextButton")
        Toggle.Size = UDim2.new(0, 60, 0, 25)
        Toggle.Position = UDim2.new(1, -65, 0.5, -12)
        Toggle.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
        Toggle.BorderSizePixel = 0
        Toggle.Text = "OFF"
        Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
        Toggle.TextSize = 12
        Toggle.Font = Enum.Font.GothamBold
        Toggle.Parent = Frame
        
        local enabled = false
        Toggle.MouseButton1Click:Connect(function()
            enabled = not enabled
            Toggle.BackgroundColor3 = enabled and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(60, 60, 75)
            Toggle.Text = enabled and "ON" or "OFF"
            callback(enabled)
        end)
    end
    
    -- Create toggles
    createToggle(40, "Fly Hack", function(v)
        Settings.Fly.Enabled = v
        if v then flySystem() else disconnectFly() end
    end)
    
    createToggle(80, "Speed Hack", function(v)
        Settings.Speed.Enabled = v
        Settings.Speed.Value = v and 50 or 16
        speedSystem()
    end)
    
    createToggle(120, "Infinite Jump", function(v)
        Settings.Jump.Enabled = v
        jumpSystem()
    end)
    
    createToggle(160, "Auto Farm", function(v)
        Settings.AutoFarm.Enabled = v
        autoFarmSystem()
    end)
    
    createToggle(200, "ESP", function(v)
        Settings.ESP.Enabled = v
        espSystem()
    end)
    
    createToggle(240, "NoClip", function(v)
        Settings.NoClip.Enabled = v
        noClipSystem()
    end)
    
    -- Teleport Button
    local TeleportBtn = Instance.new("TextButton")
    TeleportBtn.Size = UDim2.new(1, -10, 0, 35)
    TeleportBtn.Position = UDim2.new(0, 5, 0, 285)
    TeleportBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    TeleportBtn.BorderSizePixel = 0
    TeleportBtn.Text = "Teleport Forward"
    TeleportBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    TeleportBtn.TextSize = 14
    TeleportBtn.Font = Enum.Font.GothamBold
    TeleportBtn.Parent = MainFrame
    TeleportBtn.MouseButton1Click:Connect(teleportForward)
    
    -- Info Text
    local InfoText = Instance.new("TextLabel")
    InfoText.Size = UDim2.new(1, 0, 0, 20)
    InfoText.Position = UDim2.new(0, 0, 1, -20)
    InfoText.BackgroundTransparency = 1
    InfoText.Text = "github.com/vovankalivan-sketch/Legenda32Hub"
    InfoText.TextColor3 = Color3.fromRGB(150, 150, 150)
    InfoText.TextSize = 10
    InfoText.Font = Enum.Font.Gotham
    InfoText.Parent = MainFrame
end

--// Character Added Handler
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.1)
    if Settings.Fly.Enabled then
        flySystem()
    end
    if Settings.Speed.Enabled then
        speedSystem()
    end
    if Settings.Jump.Enabled then
        jumpSystem()
    end
end)

--// Initialize
createGUI()
print("Legenda32Hub loaded! GitHub: vovankalivan-sketch/Legenda32Hub")
print("Delta Client optimized | Mobile Ready")
