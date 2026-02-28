local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")
local camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local flying = false
local speed = 100

-- Создаем GUI
local screenGui = Instance.new("ScreenGui", player.PlayerGui)
screenGui.Name = "FlyGui"

local mainButton = Instance.new("TextButton", screenGui)
mainButton.Size = UDim2.new(0, 150, 0, 50)
mainButton.Position = UDim2.new(0, 20, 0.5, -25)
mainButton.Text = "Fly: OFF"
mainButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
mainButton.TextColor3 = Color3.new(1, 1, 1)
mainButton.Font = Enum.Font.SourceSansBold
mainButton.TextSize = 20

-- Скругление углов
local corner = Instance.new("UICorner", mainButton)
corner.CornerRadius = UDim.new(0, 10)

-- Объекты полета
local bv = Instance.new("BodyVelocity")
bv.MaxForce = Vector3.new(0, 0, 0)
bv.Parent = rootPart

local bg = Instance.new("BodyGyro")
bg.MaxTorque = Vector3.new(0, 0, 0)
bg.P = 90000
bg.Parent = rootPart

-- Функция переключения полета и NoClip
local function toggleFly()
    flying = not flying
    
    if flying then
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        character.Humanoid.PlatformStand = true
        mainButton.Text = "Fly: ON"
        mainButton.BackgroundColor3 = Color3.fromRGB(60, 255, 60)
    else
        bv.MaxForce = Vector3.new(0, 0, 0)
        bg.MaxTorque = Vector3.new(0, 0, 0)
        character.Humanoid.PlatformStand = false
        mainButton.Text = "Fly: OFF"
        mainButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    end
end

-- Обработка клика
mainButton.MouseButton1Click:Connect(toggleFly)

-- Управление клавишей E
UIS.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.E then
        toggleFly()
    end
end)

-- Основной цикл (Полет + NoClip)
RunService.Stepped:Connect(function()
    if flying then
        -- Движение
        bv.Velocity = camera.CFrame.LookVector * speed
        bg.CFrame = camera.CFrame
        
        -- NoClip (отключаем коллизию всех частей тела)
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)
