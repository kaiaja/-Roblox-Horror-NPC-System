-- Place in StarterPlayer > StarterPlayerScripts.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local remote = ReplicatedStorage:WaitForChild("HorrorNPCEvent")
local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "HorrorNPCDialogue"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")
local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(430, 270)
frame.Position = UDim2.new(0.5, -215, 1, -290)
frame.BackgroundColor3 = Color3.fromRGB(25, 23, 30)
frame.Visible = false
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 14)
local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, -24, 0, 75)
label.Position = UDim2.fromOffset(12, 8)
label.TextWrapped = true
label.TextColor3 = Color3.new(1, 1, 1)
label.BackgroundTransparency = 1
label.Font = Enum.Font.GothamBold
label.TextSize = 18
label.Text = "Shopkeeper: Hello!"
label.Parent = frame
local choices = {{"Say hello", "hello"}, {"How are you?", "how"}, {"Anything strange?", "strange"}, {"Goodbye", "bye"}}
for i, data in ipairs(choices) do
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -24, 0, 37)
    button.Position = UDim2.fromOffset(12, 82 + (i - 1) * 44)
    button.Text = data[1]
    button.Font = Enum.Font.Gotham
    button.TextSize = 16
    button.TextColor3 = Color3.new(1, 1, 1)
    button.BackgroundColor3 = Color3.fromRGB(70, 55, 86)
    button.Parent = frame
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)
    button.MouseButton1Click:Connect(function()
        remote:FireServer("Choice", data[2])
        if data[2] == "bye" then task.delay(1.5, function() frame.Visible = false end) end
    end)
end
remote.OnClientEvent:Connect(function(action, value)
    if action == "Dialogue" then
        label.Text = "Shopkeeper: Assalamu alaikum!"
        frame.Visible = true
    elseif action == "Reply" then
        label.Text = "Shopkeeper: " .. tostring(value)
    elseif action == "Scare" then
        local flash = Instance.new("Frame")
        flash.Size = UDim2.fromScale(1, 1)
        flash.BackgroundColor3 = Color3.fromRGB(170, 15, 20)
        flash.BackgroundTransparency = 0.15
        flash.ZIndex = 100
        flash.Parent = gui
        if type(value) == "string" and value ~= "" then
            local sound = Instance.new("Sound")
            sound.SoundId = value
            sound.Volume = 0.65
            sound.Parent = gui
            sound:Play()
            sound.Ended:Connect(function() sound:Destroy() end)
            task.delay(6, function() if sound.Parent then sound:Destroy() end end)
        end
        TweenService:Create(flash, TweenInfo.new(0.55), {BackgroundTransparency = 1}):Play()
        task.delay(0.6, function() flash:Destroy() end)
    end
end)
