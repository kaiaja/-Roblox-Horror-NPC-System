-- Place in ServerScriptService. Requires NPC model named Shopkeeper in Workspace.
local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage:WaitForChild("HorrorNPCConfig"))
local npc = workspace:WaitForChild(Config.NPCName)
local humanoid = npc:WaitForChild("Humanoid")
local root = npc:WaitForChild("HumanoidRootPart")
local head = npc:FindFirstChild("Head") or root
humanoid.WalkSpeed = Config.WalkSpeed
local origin = root.Position
local rng = Random.new()
local remote = ReplicatedStorage:FindFirstChild("HorrorNPCEvent") or Instance.new("RemoteEvent")
remote.Name = "HorrorNPCEvent"
remote.Parent = ReplicatedStorage
local prompt = Instance.new("ProximityPrompt")
prompt.Name = "TalkToNPC"
prompt.ActionText = "Talk"
prompt.ObjectText = Config.NPCName
prompt.MaxActivationDistance = Config.TalkDistance
prompt.RequiresLineOfSight = false
prompt.Parent = head
local talking = {}
local lastScare = {}
local function near(player, distance)
    local char = player.Character
    local playerRoot = char and char:FindFirstChild("HumanoidRootPart")
    return playerRoot and (playerRoot.Position - root.Position).Magnitude <= distance
end
prompt.Triggered:Connect(function(player)
    if not near(player, Config.TalkDistance + 3) then return end
    talking[player] = os.clock() + 25
    humanoid:MoveTo(root.Position)
    remote:FireClient(player, "Dialogue", "start")
end)
remote.OnServerEvent:Connect(function(player, action, choice)
    if action ~= "Choice" or type(choice) ~= "string" then return end
    if not talking[player] or os.clock() > talking[player] or not near(player, Config.TalkDistance + 4) then return end
    local replies = {
        hello = "Wa alaikum assalam! Welcome to my shop.",
        how = "I'm fine, thanks! How are you?",
        strange = "Did you hear something behind you...?",
        bye = "Come back soon!",
    }
    local reply = replies[choice]
    if not reply then return end
    remote:FireClient(player, "Reply", reply)
    if choice == "strange" and rng:NextNumber() < Config.JumpscareChance then
        local now = os.clock()
        if now - (lastScare[player] or -math.huge) >= Config.JumpscareCooldown then
            lastScare[player] = now
            remote:FireClient(player, "Scare", Config.JumpscareSoundId)
        end
    end
    if choice == "bye" then talking[player] = nil end
end)
Players.PlayerRemoving:Connect(function(player)
    talking[player] = nil
    lastScare[player] = nil
end)
local function nearestPlayer()
    local best, distance = nil, Config.DetectRadius
    for _, player in ipairs(Players:GetPlayers()) do
        if near(player, distance) then
            local charRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if charRoot then
                best = charRoot
                distance = (charRoot.Position - root.Position).Magnitude
            end
        end
    end
    return best
end
while humanoid.Health > 0 do
    local target = nearestPlayer()
    if target then
        humanoid:MoveTo(root.Position)
        local direction = Vector3.new(target.Position.X - root.Position.X, 0, target.Position.Z - root.Position.Z)
        if direction.Magnitude > 0.1 then
            root.CFrame = CFrame.lookAt(root.Position, root.Position + direction)
        end
        task.wait(0.5)
    else
        local destination = origin + Vector3.new(rng:NextNumber(-Config.WalkRadius, Config.WalkRadius), 0, rng:NextNumber(-Config.WalkRadius, Config.WalkRadius))
        local path = PathfindingService:CreatePath({AgentRadius = 2, AgentHeight = 5, AgentCanJump = true})
        local ok = pcall(function() path:ComputeAsync(root.Position, destination) end)
        if ok and path.Status == Enum.PathStatus.Success then
            for _, waypoint in ipairs(path:GetWaypoints()) do
                if nearestPlayer() then break end
                if waypoint.Action == Enum.PathWaypointAction.Jump then humanoid.Jump = true end
                humanoid:MoveTo(waypoint.Position)
                local reached = humanoid.MoveToFinished:Wait()
                if not reached then break end
            end
        end
        task.wait(Config.WanderDelay)
    end
end
