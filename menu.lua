local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local Camera = workspace.CurrentCamera

-- Состояния функций
local flyEnabled = false
local aimEnabled = false
local espEnabled = false
local flySpeed = 50

-- --- СОЗДАНИЕ GUI ---
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AdminPanel"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 200, 0, 220)
MainFrame.Position = UDim2.new(0.05, 0, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- Позволяет перетаскивать меню мышкой

local function createButton(text, pos, color)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(0, 180, 0, 40)
    btn.Position = pos
    btn.Text = text
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 18
    btn.BorderSizePixel = 0
    return btn
end

local aimBtn = createButton("Aim: OFF", UDim2.new(0, 10, 0, 20), Color3.fromRGB(80, 0, 0))
local espBtn = createButton("ESP (WH): OFF", UDim2.new(0, 10, 0, 80), Color3.fromRGB(80, 0, 0))
local flyBtn = createButton("Fly: OFF", UDim2.new(0, 10, 0, 140), Color3.fromRGB(80, 0, 0))

-- --- ФУНКЦИЯ AIM ---
local function getClosestPlayer()
    local closest = nil
    local dist = math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local pos, onScreen = Camera:WorldToScreenPoint(p.Character.HumanoidRootPart.Position)
            if onScreen then
                local mouseDist = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(pos.X, pos.Y)).Magnitude
                if mouseDist < dist then
                    dist = mouseDist
                    closest = p.Character.HumanoidRootPart
                end
            end
        end
    end
    return closest
end

RunService.RenderStepped:Connect(function()
    if aimEnabled then
        local target = getClosestPlayer()
        if target then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
        end
    end
end)

-- --- ФУНКЦИЯ ESP ---
local function updateESP()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= Player and p.Character then
            local highlight = p.Character:FindFirstChild("AdminHighlight")
            if espEnabled then
                if not highlight then
                    highlight = Instance.new("Highlight")
                    highlight.Name = "AdminHighlight"
                    highlight.FillColor = Color3.new(1, 0, 0)
                    highlight.FillTransparency = 0.5
                    highlight.OutlineColor = Color3.new(1, 1, 1)
                    highlight.Parent = p.Character
                end
            elseif highlight then
                highlight:Destroy()
            end
        end
    end
end

-- --- ФУНКЦИЯ FLY ---
local bv, bg
RunService.RenderStepped:Connect(function()
    local char = Player.Character
    if flyEnabled and char and char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        if not bv then
            bv = Instance.new("BodyVelocity", hrp)
            bv.MaxForce = Vector3.new(1, 1, 1) * math.huge
            bg = Instance.new("BodyGyro", hrp)
            bg.MaxTorque = Vector3.new(1, 1, 1) * math.huge
        end
        
        local moveDir = Vector3.new(0,0,0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= Camera.CFrame.LookVector:Cross(Vector3.new(0,1,0)) end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += Camera.CFrame.LookVector:Cross(Vector3.new(0,1,0)) end
        
        bv.Velocity = moveDir * flySpeed
        bg.CFrame = Camera.CFrame
    else
        if bv then bv:Destroy() bv = nil end
        if bg then bg:Destroy() bg = nil end
    end
end)

-- --- ЛОГИКА КНОПОК ---
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.E then
        aimEnabledd = not aimEnabled
    end
end)

aimBtn.MouseButton1Click:Connect(function()
    aimEnabled = not aimEnabled
    aimBtn.Text = "Aim: " .. (aimEnabled and "ON" or "OFF")
    aimBtn.BackgroundColor3 = aimEnabled and Color3.fromRGB(0, 80, 0) or Color3.fromRGB(80, 0, 0)
end)

espBtn.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    espBtn.Text = "ESP: " .. (espEnabled and "ON" or "OFF")
    espBtn.BackgroundColor3 = espEnabled and Color3.fromRGB(0, 80, 0) or Color3.fromRGB(80, 0, 0)
    updateESP()
end)

flyBtn.MouseButton1Click:Connect(function()
    flyEnabled = not flyEnabled
    flyBtn.Text = "Fly: " .. (flyEnabled and "ON" or "OFF")
    flyBtn.BackgroundColor3 = flyEnabled and Color3.fromRGB(0, 80, 0) or Color3.fromRGB(80, 0, 0)
end)

-- Периодическое обновление ESP
task.spawn(function()
    while task.wait(1) do
        if espEnabled then updateESP() end
    end
end)
