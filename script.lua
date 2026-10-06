local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local player = Players.LocalPlayer

player.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
end)

local configFileName = "VoidFocusConfig.json"
local settings = {
    flySpeed = 160,
    verticalFlySpeed = 220,
    orbitSpeed = 30
}

local function saveSettings()
    pcall(function()
        if writefile then
            writefile(configFileName, HttpService:JSONEncode(settings))
        end
    end)
end

local function loadSettings()
    pcall(function()
        if readfile and isfile and isfile(configFileName) then
            local data = HttpService:JSONDecode(readfile(configFileName))
            if data.flySpeed then settings.flySpeed = data.flySpeed end
            if data.verticalFlySpeed then settings.verticalFlySpeed = data.verticalFlySpeed end
            if data.orbitSpeed then settings.orbitSpeed = data.orbitSpeed end
        end
    end)
end
loadSettings()

local flySpeed = settings.flySpeed
local verticalFlySpeed = settings.verticalFlySpeed
local orbitSpeed = 30

local function getChar()
    local c = player.Character
    if not c then return nil, nil, nil end
    return c, c:FindFirstChildOfClass("Humanoid"), c:FindFirstChild("HumanoidRootPart")
end

local gui = Instance.new("ScreenGui")
gui.Name = "VoidFocusGui"
gui.ResetOnSpawn = false
gui.DisplayOrder = 999
gui.Parent = player:WaitForChild("PlayerGui")

local function showNotification(text, isSuccess)
    local notif = Instance.new("TextLabel")
    notif.Size = UDim2.new(0, 220, 0, 35)
    notif.Position = UDim2.new(0.5, -110, 0, 10)
    notif.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    notif.TextColor3 = Color3.fromRGB(255, 255, 255)
    notif.Font = Enum.Font.SourceSansBold
    notif.TextSize = 13
    notif.Text = text
    notif.TextStrokeTransparency = 0
    notif.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    notif.ZIndex = 10
    notif.Parent = gui
    
    Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 8)
    local str = Instance.new("UIStroke", notif)
    str.Color = isSuccess and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
    str.Thickness = 2
    
    TweenService:Create(notif, TweenInfo.new(0.3), {Position = UDim2.new(0.5, -110, 0, 50)}):Play()
    
    task.delay(2, function()
        if notif and notif.Parent then
            local tw = TweenService:Create(notif, TweenInfo.new(0.3), {BackgroundTransparency = 1, TextTransparency = 1, TextStrokeTransparency = 1})
            tw:Play()
            tw.Completed:Connect(function() notif:Destroy() end)
        end
    end)
end

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 480, 0, 240)
main.Position = UDim2.new(0.5, -240, 0.4, -120)
main.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
main.BackgroundTransparency = 0.05
main.ClipsDescendants = true
main.Active = true
main.Parent = gui

Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

local bgImage = Instance.new("ImageLabel")
bgImage.Name = "BackgroundImage"
bgImage.Size = UDim2.new(1, 0, 1, 0)
bgImage.BackgroundTransparency = 1
bgImage.Image = "rbxassetid://126054750024641"
bgImage.ScaleType = Enum.ScaleType.Slice
bgImage.ImageTransparency = 0.75
bgImage.ZIndex = 0
bgImage.Parent = main

local stroke = Instance.new("UIStroke")
stroke.Thickness = 2.5
stroke.Color = Color3.fromRGB(255, 30, 30)
stroke.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -40, 0, 30)
title.Position = UDim2.new(0, 15, 0, 5)
title.BackgroundTransparency = 1
title.Text = "VOID FOCUS HUB"
title.TextColor3 = Color3.fromRGB(255, 100, 100)
title.TextStrokeTransparency = 0
title.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 2
title.Parent = main

local titleStroke = Instance.new("UIStroke", title)
titleStroke.Thickness = 3
titleStroke.Color = Color3.fromRGB(255, 0, 0)
titleStroke.Transparency = 0

local function makeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragInput, dragStart, startPos
    local function updateDrag(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            updateDrag(input)
        end
    end)
end

makeDraggable(main, title)

local function styleButton(btn)
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(1, 0)
    
    local bStroke = Instance.new("UIStroke", btn)
    bStroke.Thickness = 2
    bStroke.Color = Color3.fromRGB(255, 50, 50)
    
    btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    btn.BackgroundTransparency = 0.05
    btn.TextColor3 = Color3.fromRGB(255, 180, 180)
    btn.TextStrokeTransparency = 0
    btn.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    btn.Font = Enum.Font.GothamBold
    btn.ZIndex = 2
    
    btn.MouseEnter:Connect(function()
        if btn:GetAttribute("Selecionado") then return end
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 0, 0), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        TweenService:Create(bStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(255, 200, 200)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        if btn:GetAttribute("Selecionado") then return end
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 0, 0), TextColor3 = Color3.fromRGB(255, 180, 180)}):Play()
        TweenService:Create(bStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(255, 50, 50)}):Play()
    end)
end

local mainScroll = Instance.new("ScrollingFrame")
mainScroll.Size = UDim2.new(1, -10, 1, -40)
mainScroll.Position = UDim2.new(0, 5, 0, 35)
mainScroll.BackgroundTransparency = 1
mainScroll.BorderSizePixel = 0
mainScroll.ScrollBarThickness = 5
mainScroll.ScrollBarImageColor3 = Color3.fromRGB(255, 30, 30)
mainScroll.CanvasSize = UDim2.new(0, 0, 0, 560)
mainScroll.ZIndex = 2
mainScroll.Parent = main

local btnFocus = Instance.new("TextButton")
btnFocus.Size = UDim2.new(0, 210, 0, 32)
btnFocus.Position = UDim2.new(0, 10, 0, 5)
btnFocus.Text = "FOCUS: OFF"
btnFocus.Parent = mainScroll
styleButton(btnFocus)

local btnFly = Instance.new("TextButton")
btnFly.Size = UDim2.new(0, 210, 0, 32)
btnFly.Position = UDim2.new(0, 240, 0, 5)
btnFly.Text = "FLY (BYPASS): OFF"
btnFly.Parent = mainScroll
styleButton(btnFly)

local flyDesc = Instance.new("TextLabel")
flyDesc.Size = UDim2.new(0, 210, 0, 20)
flyDesc.Position = UDim2.new(0, 240, 0, 39)
flyDesc.BackgroundTransparency = 1
flyDesc.Text = "Bypass ativo + Void unlock."
flyDesc.TextColor3 = Color3.fromRGB(255, 200, 200)
flyDesc.TextStrokeTransparency = 0
flyDesc.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
flyDesc.Font = Enum.Font.SourceSans
flyDesc.TextSize = 11
flyDesc.TextWrapped = true
flyDesc.ZIndex = 2
flyDesc.Parent = mainScroll

local div1 = Instance.new("Frame")
div1.Size = UDim2.new(1, -20, 0, 2)
div1.Position = UDim2.new(0, 10, 0, 70)
div1.BackgroundColor3 = Color3.fromRGB(255, 30, 30)
div1.BorderSizePixel = 0
div1.ZIndex = 2
div1.Parent = mainScroll

local subFocusBypass = Instance.new("TextLabel")
subFocusBypass.Size = UDim2.new(1, 0, 0, 20)
subFocusBypass.Position = UDim2.new(0, 0, 0, 80)
subFocusBypass.BackgroundTransparency = 1
subFocusBypass.Text = "UNLOCKED BY VOID TP (LISTA DE PLAYERS)"
subFocusBypass.TextColor3 = Color3.fromRGB(255, 130, 130)
subFocusBypass.TextStrokeTransparency = 0
subFocusBypass.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
subFocusBypass.Font = Enum.Font.SourceSansBold
subFocusBypass.TextSize = 13
subFocusBypass.ZIndex = 2
subFocusBypass.Parent = mainScroll

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -20, 0, 140)
scrollFrame.Position = UDim2.new(0, 10, 0, 105)
scrollFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
scrollFrame.BackgroundTransparency = 0.3
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 4
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 30, 30)
scrollFrame.ZIndex = 2
scrollFrame.Parent = mainScroll
Instance.new("UICorner", scrollFrame).CornerRadius = UDim.new(0, 8)

local listLayout = Instance.new("UIListLayout", scrollFrame)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 5)

local div2 = Instance.new("Frame")
div2.Size = UDim2.new(1, -20, 0, 2)
div2.Position = UDim2.new(0, 10, 0, 260)
div2.BackgroundColor3 = Color3.fromRGB(255, 30, 30)
div2.BorderSizePixel = 0
div2.ZIndex = 2
div2.Parent = mainScroll

local subPunchTitle = Instance.new("TextLabel")
subPunchTitle.Size = UDim2.new(1, 0, 0, 20)
subPunchTitle.Position = UDim2.new(0, 0, 0, 270)
subPunchTitle.BackgroundTransparency = 1
subPunchTitle.Text = "AUTO PUNCH OPTIONS"
subPunchTitle.TextColor3 = Color3.fromRGB(255, 130, 130)
subPunchTitle.TextStrokeTransparency = 0
subPunchTitle.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
subPunchTitle.Font = Enum.Font.SourceSansBold
subPunchTitle.TextSize = 13
subPunchTitle.ZIndex = 2
subPunchTitle.Parent = mainScroll

local punchBtn1 = Instance.new("TextButton")
punchBtn1.Size = UDim2.new(0, 210, 0, 32)
punchBtn1.Position = UDim2.new(0, 10, 0, 298)
punchBtn1.Text = "Adicionar Botão"
punchBtn1.Parent = mainScroll
styleButton(punchBtn1)

local punchBtn2 = Instance.new("TextButton")
punchBtn2.Size = UDim2.new(0, 210, 0, 32)
punchBtn2.Position = UDim2.new(0, 240, 0, 298)
punchBtn2.Text = "Remover Botão"
punchBtn2.Parent = mainScroll
styleButton(punchBtn2)

local punchBtn3 = Instance.new("TextButton")
punchBtn3.Size = UDim2.new(0, 440, 0, 35)
punchBtn3.Position = UDim2.new(0, 10, 0, 340)
punchBtn3.Text = "Auto Click: OFF"
punchBtn3.Parent = mainScroll
styleButton(punchBtn3)

local warnText = Instance.new("TextLabel")
warnText.Size = UDim2.new(1, -20, 0, 25)
warnText.Position = UDim2.new(0, 10, 0, 380)
warnText.BackgroundTransparency = 1
warnText.Text = "Proteção de 10s ativada ao ligar/desligar o Auto Click."
warnText.TextColor3 = Color3.fromRGB(255, 200, 200)
warnText.TextStrokeTransparency = 0
warnText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
warnText.TextSize = 10
warnText.TextWrapped = true
warnText.ZIndex = 2
warnText.Parent = mainScroll

local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.new(0, 45, 0, 45)
openBtn.Position = UDim2.new(0, 20, 0, 20)
openBtn.Text = "+"
openBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
openBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
openBtn.TextStrokeTransparency = 0
openBtn.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
openBtn.Font = Enum.Font.SourceSansBold
openBtn.TextSize = 32
openBtn.Visible = false
openBtn.Parent = gui
Instance.new("UICorner", openBtn).CornerRadius = UDim.new(1, 0)

local openStroke = Instance.new("UIStroke", openBtn)
openStroke.Thickness = 2
openStroke.Color = Color3.fromRGB(255, 50, 50)
makeDraggable(openBtn)

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 25, 0, 25)
minimizeBtn.Position = UDim2.new(1, -30, 0, 5)
minimizeBtn.BackgroundTransparency = 1
minimizeBtn.Text = "-"
minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeBtn.TextStrokeTransparency = 0
minimizeBtn.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
minimizeBtn.Font = Enum.Font.SourceSansBold
minimizeBtn.TextSize = 26
minimizeBtn.ZIndex = 3
minimizeBtn.Parent = main

minimizeBtn.MouseButton1Click:Connect(function()
    main.Visible = false
    openBtn.Visible = true
end)

openBtn.MouseButton1Click:Connect(function()
    openBtn.Visible = false
    main.Visible = true
end)

local focusUnlockedByVoid = false
local focusActive = false
local currentTarget = nil
local orbitAngle = 0
local flyActive = false
local flyMove = Vector3.zero
local flyUpValue = 0
local flyBodyVelocity, flyBodyGyro
local focusBodyPosition, focusBodyGyro

local playerButtons = {}

local function updatePlayersList()
    for _, child in pairs(scrollFrame:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    playerButtons = {}
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player then
            local pBtn = Instance.new("TextButton")
            pBtn.Size = UDim2.new(1, -10, 0, 30)
            pBtn.Text = p.DisplayName or p.Name
            pBtn.TextSize = 13
            pBtn.ZIndex = 4
            pBtn:SetAttribute("Selecionado", false)
            pBtn.Parent = scrollFrame
            styleButton(pBtn)
            playerButtons[p] = pBtn
            
            pBtn.MouseButton1Click:Connect(function()
                if not focusUnlockedByVoid then
                    showNotification("Desbloqueie caindo no void!", false)
                    return
                end
                
                for _, btn in pairs(playerButtons) do
                    btn:SetAttribute("Selecionado", false)
                    TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(0, 0, 0), TextColor3 = Color3.fromRGB(255, 180, 180)}):Play()
                end
                
                if currentTarget == p.Character then
                    focusActive = false
                    currentTarget = nil
                    if focusBodyPosition then focusBodyPosition:Destroy() focusBodyPosition = nil end
                    if focusBodyGyro then focusBodyGyro:Destroy() focusBodyGyro = nil end
                    showNotification("Foco desativado.", false)
                else
                    focusActive = true
                    currentTarget = p.Character
                    pBtn:SetAttribute("Selecionado", true)
                    TweenService:Create(pBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(160, 0, 0), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
                    showNotification("Focando em: " .. (p.DisplayName or p.Name), true)
                    
                    -- Força o teleporte imediato
                    local _, _, hrp = getChar()
                    local tHrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                    if hrp and tHrp then
                        hrp.CFrame = CFrame.new(tHrp.Position + Vector3.new(0, 4, 0))
                    end
                end
            end)
        end
    end
end

Players.PlayerAdded:Connect(updatePlayersList)
Players.PlayerRemoving:Connect(updatePlayersList)
updatePlayersList()

local function tpToRandomPlayer()
    local allPlrs = Players:GetPlayers()
    local validTargets = {}
    for _, p in pairs(allPlrs) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(validTargets, p.Character.HumanoidRootPart)
        end
    end
    if #validTargets > 0 then
        local randomRoot = validTargets[math.random(1, #validTargets)]
        local newChar = player.Character
        if newChar then
            local root = newChar:WaitForChild("HumanoidRootPart", 5)
            if root then
                local targetCF = randomRoot.CFrame + Vector3.new(0, 6, 0)
                local rayParams = RaycastParams.new()
                rayParams.FilterType = Enum.RaycastFilterType.Exclude
                rayParams.FilterDescendantsInstances = {newChar}
                
                local rayResult = workspace:Raycast(targetCF.Position, Vector3.new(0, 50, 0), rayParams)
                if rayResult then
                    targetCF = CFrame.new(rayResult.Position - Vector3.new(0, 4, 0))
                end
                
                root.CFrame = targetCF
                focusUnlockedByVoid = true
                subFocusBypass.Text = "FOCUS PLAYER DESBLOQUEADO!"
                subFocusBypass.TextColor3 = Color3.fromRGB(100, 255, 100)
                subFocusBypass.TextStrokeColor3 = Color3.fromRGB(0, 60, 0)
                showNotification("Void TP seguro executado!", true)
            end
        end
    end
end

local function startFly()
    local c, humanoid, root = getChar()
    if not root or not humanoid then return end
    if root:FindFirstChild("BodyVelocity") then root.BodyVelocity:Destroy() end
    if root:FindFirstChild("BodyGyro") then root.BodyGyro:Destroy() end
    
    flyBodyVelocity = Instance.new("BodyVelocity")
    flyBodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    flyBodyVelocity.Velocity = Vector3.zero
    flyBodyVelocity.Parent = root
    
    flyBodyGyro = Instance.new("BodyGyro")
    flyBodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    flyBodyGyro.CFrame = root.CFrame
    flyBodyGyro.Parent = root
    
    humanoid.PlatformStand = true
end

local function stopFly()
    if flyBodyVelocity then flyBodyVelocity:Destroy() end
    if flyBodyGyro then flyBodyGyro:Destroy() end
    local _, humanoid = getChar()
    if humanoid then humanoid.PlatformStand = false end
end

player.CharacterAdded:Connect(function(newChar)
    if flyActive then
        task.spawn(function()
            newChar:WaitForChild("HumanoidRootPart", 10)
            task.wait(0.2)
            tpToRandomPlayer()
            startFly()
        end)
    end
end)

UserInputService.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.KeyCode == Enum.KeyCode.W then flyMove += Vector3.new(0, 0, -1) end
    if i.KeyCode == Enum.KeyCode.S then flyMove += Vector3.new(0, 0, 1) end
    if i.KeyCode == Enum.KeyCode.A then flyMove += Vector3.new(-1, 0, 0) end
    if i.KeyCode == Enum.KeyCode.D then flyMove += Vector3.new(1, 0, 0) end
end)

UserInputService.InputEnded:Connect(function(i)
    if i.KeyCode == Enum.KeyCode.W then flyMove -= Vector3.new(0, 0, -1) end
    if i.KeyCode == Enum.KeyCode.S then flyMove -= Vector3.new(0, 0, 1) end
    if i.KeyCode == Enum.KeyCode.A then flyMove -= Vector3.new(-1, 0, 0) end
    if i.KeyCode == Enum.KeyCode.D then flyMove -= Vector3.new(1, 0, 0) end
end)

local flyControls = Instance.new("ScreenGui")
flyControls.Name = "VoidFlyControls"
flyControls.ResetOnSpawn = false
flyControls.DisplayOrder = 999
flyControls.Parent = player:WaitForChild("PlayerGui")

local flyFrame = Instance.new("Frame")
flyFrame.Size = UDim2.new(0, 70, 0, 150)
flyFrame.Position = UDim2.new(1, -85, 0.5, -75)
flyFrame.BackgroundTransparency = 1
flyFrame.Visible = false
flyFrame.ZIndex = 50
flyFrame.Parent = flyControls

local function createArrow(text, yPos, pressValue)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 60, 0, 60)
    b.Position = UDim2.new(0, 5, 0, yPos)
    b.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    b.TextColor3 = Color3.fromRGB(255, 100, 100)
    b.TextStrokeTransparency = 0
    b.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    b.Text = text
    b.Font = Enum.Font.SourceSansBold
    b.TextSize = 32
    b.ZIndex = 50
    b.Parent = flyFrame
    Instance.new("UICorner", b).CornerRadius = UDim.new(1, 0)
    local s = Instance.new("UIStroke", b)
    s.Color = Color3.fromRGB(255, 50, 50)
    s.Thickness = 2
    b.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            flyUpValue = pressValue
        end
    end)
    b.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if flyUpValue == pressValue then flyUpValue = 0 end
        end
    end)
end

createArrow("▲", 5, verticalFlySpeed)
createArrow("▼", 85, -verticalFlySpeed)

local debounceFocus = false
btnFocus.MouseButton1Click:Connect(function()
    if debounceFocus then return end
    debounceFocus = true
    
    if not focusUnlockedByVoid then
        showNotification("Caia no void primeiro!", false)
        task.wait(1.5)
        debounceFocus = false
        return
    end
    
    focusActive = not focusActive
    if focusActive then
        local _, _, currentHrp = getChar()
        if currentHrp then
            local closest = nil
            local dist = 75
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") then
                    if p.Character.Humanoid.Health > 0 then
                        local d = (currentHrp.Position - p.Character.HumanoidRootPart.Position).Magnitude
                        if d < dist then
                            dist = d
                            closest = p.Character
                        end
                    end
                end
            end
            currentTarget = closest
        end
        
        if currentTarget then
            btnFocus.Text = "FOCUS: ON"
            btnFocus.TextColor3 = Color3.fromRGB(255, 255, 255)
            TweenService:Create(btnFocus, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(160, 0, 0)}):Play()
            showNotification("Focus automático ativado.", true)
        else
            focusActive = false
            showNotification("Nenhum alvo próximo.", false)
        end
    else
        currentTarget = nil
        btnFocus.Text = "FOCUS: OFF"
        btnFocus.TextColor3 = Color3.fromRGB(255, 180, 180)
        TweenService:Create(btnFocus, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 0, 0)}):Play()
        showNotification("Focus desativado.", false)
    end
    
    task.wait(0.5)
    debounceFocus = false
end)

local debounceFly = false
btnFly.MouseButton1Click:Connect(function()
    if debounceFly then return end
    debounceFly = true
    
    flyActive = not flyActive
    if flyActive then
        btnFly.Text = "FLY (BYPASS): ON"
        btnFly.TextColor3 = Color3.fromRGB(255, 255, 255)
        TweenService:Create(btnFly, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(160, 0, 0)}):Play()
        flyFrame.Visible = true
        startFly()
        showNotification("Fly ativado.", true)
    else
        btnFly.Text = "FLY (BYPASS): OFF"
        btnFly.TextColor3 = Color3.fromRGB(255, 180, 180)
        TweenService:Create(btnFly, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 0, 0)}):Play()
        flyFrame.Visible = false
        stopFly()
        showNotification("Fly desativado.", false)
    end
    
    task.wait(0.5)
    debounceFly = false
end)

local punchButton = nil
local clickerActive = false
local isLocking = false

punchBtn1.MouseButton1Click:Connect(function()
    if not punchButton then
        punchButton = Instance.new("TextButton")
        punchButton.Size = UDim2.new(0, 40, 0, 40)
        punchButton.Position = UDim2.new(0.5, -20, 0.4, -20)
        punchButton.BackgroundColor3 = Color3.fromRGB(140, 0, 0)
        punchButton.Text = "PUNCH"
        punchButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        punchButton.TextStrokeTransparency = 0
        punchButton.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        punchButton.Font = Enum.Font.SourceSansBold
        punchButton.TextSize = 10
        punchButton.Parent = gui
        Instance.new("UICorner", punchButton).CornerRadius = UDim.new(1, 0)
        local pStr = Instance.new("UIStroke", punchButton)
        pStr.Thickness = 2
        pStr.Color = Color3.fromRGB(255, 50, 50)
        makeDraggable(punchButton)
        showNotification("Botão de Punch criado.", true)
    end
end)

punchBtn2.MouseButton1Click:Connect(function()
    if punchButton then
        punchButton:Destroy()
        punchButton = nil
        showNotification("Botão de Punch removido.", false)
    end
end)

punchBtn3.MouseButton1Click:Connect(function()
    if isLocking then return end
    clickerActive = not clickerActive
    isLocking = true
    punchBtn3.Active = false
    punchBtn3.BackgroundTransparency = 0.5
    if clickerActive then
        punchBtn3.Text = "Auto Click: ON"
        punchBtn3.TextColor3 = Color3.fromRGB(255, 255, 255)
        punchBtn3.BackgroundColor3 = Color3.fromRGB(160, 0, 0)
        showNotification("Auto Click Ligado.", true)
    else
        punchBtn3.Text = "Auto Click: OFF"
        punchBtn3.TextColor3 = Color3.fromRGB(255, 180, 180)
        punchBtn3.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        showNotification("Auto Click Desligado.", false)
    end
    task.wait(10)
    isLocking = false
    punchBtn3.Active = true
    punchBtn3.BackgroundTransparency = 0.35
end)

task.spawn(function()
    local VirtualInputManager = game:GetService("VirtualInputManager")
    while task.wait(0.2) do
        if clickerActive and punchButton and punchButton.Parent then
            local x = punchButton.AbsolutePosition.X + (punchButton.AbsoluteSize.X / 2)
            local y = punchButton.AbsolutePosition.Y + (punchButton.AbsoluteSize.Y / 2) + 36
            VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 1)
            VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 1)
        end
    end
end)

RunService.RenderStepped:Connect(function(dt)
    local currentChar, currentHum, currentHrp = getChar()
    if not currentHrp then return end
    
    if currentHrp.Position.Y < -300 and not focusUnlockedByVoid then
        tpToRandomPlayer()
    end

    if focusActive and currentTarget and focusUnlockedByVoid then
        local targetHrp = currentTarget:FindFirstChild("HumanoidRootPart")
        local targetHum = currentTarget:FindFirstChild("Humanoid")
        if targetHrp and targetHum and targetHum.Health > 0 then
            orbitAngle += dt * orbitSpeed
            
            local distToTarget = (currentHrp.Position - targetHrp.Position).Magnitude
            
            if distToTarget > 15 then
                -- Re-teleporta se ficou muito longe (anticheat puxou de volta ou ainda tá no spawn)
                currentHrp.CFrame = CFrame.new(targetHrp.Position + Vector3.new(0, 4, 0))
                currentHrp.AssemblyLinearVelocity = Vector3.zero
                currentHrp.AssemblyAngularVelocity = Vector3.zero
            else
                -- Orbita normal
                local pos = targetHrp.Position + Vector3.new(math.cos(orbitAngle) * 7, 3, math.sin(orbitAngle) * 7)
                currentHrp.CFrame = CFrame.new(pos, targetHrp.Position)
                currentHrp.AssemblyLinearVelocity = Vector3.zero
                currentHrp.AssemblyAngularVelocity = Vector3.zero
            end
        else
            focusActive = false
            currentTarget = nil
            btnFocus.Text = "FOCUS: OFF"
            btnFocus.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            btnFocus.TextColor3 = Color3.fromRGB(255, 180, 180)
            showNotification("Alvo eliminado ou perdido.", false)
        end
    end
    
    if flyActive and flyBodyVelocity and flyBodyGyro and currentHum and currentHum.Health > 0 then
        local cam = workspace.CurrentCamera
        local finalMove = Vector3.zero
        if currentHum.MoveDirection.Magnitude > 0 then
            finalMove = currentHum.MoveDirection * flySpeed
        elseif flyMove.Magnitude > 0 then
            local walkDir = cam.CFrame:VectorToWorldSpace(flyMove)
            finalMove = Vector3.new(walkDir.X, 0, walkDir.Z).Unit * flySpeed
        end
        flyBodyVelocity.Velocity = Vector3.new(finalMove.X, flyUpValue, finalMove.Z)
        flyBodyGyro.CFrame = cam.CFrame
    end
end)
