
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local selectedPlayer
local running = false
local killDelay = 10
local loopId = 0

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "AutoController"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(340, 470)
main.Position = UDim2.new(0.5, -170, 0.5, -235)
main.BackgroundColor3 = Color3.fromRGB(23, 23, 34)
main.BorderSizePixel = 0
main.Active = true
main.Parent = gui

Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

-- Drag support
local dragging = false
local dragStart, startPos

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 48)
titleBar.BackgroundTransparency = 1
titleBar.Active = true
titleBar.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -55, 1, 0)
title.Position = UDim2.fromOffset(15, 0)
title.BackgroundTransparency = 1
title.Text = "AUTO CONTROLLER"
title.TextColor3 = Color3.fromRGB(240, 230, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 19
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(28, 28)
close.Position = UDim2.new(1, -38, 0, 10)
close.BackgroundColor3 = Color3.fromRGB(180, 55, 75)
close.Text = "X"
close.TextColor3 = Color3.new(1, 1, 1)
close.Font = Enum.Font.GothamBold
close.TextSize = 14
close.Parent = titleBar

Instance.new("UICorner", close).CornerRadius = UDim.new(0, 6)

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

close.MouseButton1Click:Connect(function()
    main.Visible = false
end)

-- UI helpers
local function makeLabel(text, y, height)
    local obj = Instance.new("TextLabel")
    obj.Position = UDim2.fromOffset(15, y)
    obj.Size = UDim2.new(1, -30, 0, height)
    obj.BackgroundTransparency = 1
    obj.Text = text
    obj.TextColor3 = Color3.fromRGB(235, 235, 245)
    obj.Font = Enum.Font.GothamBold
    obj.TextSize = 13
    obj.TextXAlignment = Enum.TextXAlignment.Left
    obj.Parent = main
    return obj
end

local function makeButton(text, x, y, w, h, color)
    local obj = Instance.new("TextButton")
    obj.Position = UDim2.fromOffset(x, y)
    obj.Size = UDim2.fromOffset(w, h)
    obj.BackgroundColor3 = color
    obj.Text = text
    obj.TextColor3 = Color3.new(1, 1, 1)
    obj.Font = Enum.Font.GothamBold
    obj.TextSize = 13
    obj.BorderSizePixel = 0
    obj.Parent = main
    Instance.new("UICorner", obj).CornerRadius = UDim.new(0, 7)
    return obj
end

makeLabel("PLAYER SEARCH", 53, 22)

local search = Instance.new("TextBox")
search.Position = UDim2.fromOffset(15, 78)
search.Size = UDim2.new(1, -30, 0, 32)
search.BackgroundColor3 = Color3.fromRGB(38, 38, 53)
search.TextColor3 = Color3.new(1, 1, 1)
search.PlaceholderText = "Search username..."
search.PlaceholderColor3 = Color3.fromRGB(150, 150, 165)
search.Text = ""
search.Font = Enum.Font.Gotham
search.TextSize = 13
search.ClearTextOnFocus = false
search.Parent = main
Instance.new("UICorner", search).CornerRadius = UDim.new(0, 6)

makeLabel("ONLINE PLAYERS", 120, 22)

local refresh = makeButton(
    "REFRESH", 245, 117, 80, 27,
    Color3.fromRGB(100, 70, 180)
)

local list = Instance.new("ScrollingFrame")
list.Position = UDim2.fromOffset(15, 148)
list.Size = UDim2.fromOffset(310, 155)
list.BackgroundColor3 = Color3.fromRGB(32, 32, 45)
list.BorderSizePixel = 0
list.ScrollBarThickness = 4
list.Parent = main
Instance.new("UICorner", list).CornerRadius = UDim.new(0, 7)

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 5)
layout.Parent = list

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 5)
padding.PaddingLeft = UDim.new(0, 5)
padding.Parent = list

local selectedLabel = makeLabel("Selected: None", 310, 25)

makeLabel("KILL DELAY (SECONDS)", 345, 25)

local delayBox = Instance.new("TextBox")
delayBox.Position = UDim2.fromOffset(225, 342)
delayBox.Size = UDim2.fromOffset(100, 30)
delayBox.BackgroundColor3 = Color3.fromRGB(38, 38, 53)
delayBox.TextColor3 = Color3.new(1, 1, 1)
delayBox.Text = "10"
delayBox.Font = Enum.Font.GothamBold
delayBox.TextSize = 14
delayBox.Parent = main
Instance.new("UICorner", delayBox).CornerRadius = UDim.new(0, 6)

local start = makeButton(
    "START", 15, 390, 150, 38,
    Color3.fromRGB(105, 75, 205)
)

local stop = makeButton(
    "STOP", 175, 390, 150, 38,
    Color3.fromRGB(180, 55, 75)
)

local status = makeLabel("STATUS: OFF", 435, 25)

-- Player list
local function updateList()
    for _, child in ipairs(list:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    local query = string.lower(search.Text)

    for _, target in ipairs(Players:GetPlayers()) do
        if target ~= player then
            local matches =
                string.find(string.lower(target.Name), query, 1, true)
                or string.find(string.lower(target.DisplayName), query, 1, true)

            if matches then
                local b = Instance.new("TextButton")
                b.Size = UDim2.new(1, -10, 0, 30)
                b.BackgroundColor3 = Color3.fromRGB(48, 48, 67)
                b.TextColor3 = Color3.new(1, 1, 1)
                b.TextSize = 12
                b.Font = Enum.Font.Gotham
                b.Text = target.DisplayName .. "  @" .. target.Name
                b.Parent = list

                Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)

                b.MouseButton1Click:Connect(function()
                    selectedPlayer = target
                    selectedLabel.Text = "Selected: @" .. target.Name
                end)
            end
        end
    end

    task.wait()
    list.CanvasSize = UDim2.fromOffset(
        0, layout.AbsoluteContentSize.Y + 10
    )
end

refresh.MouseButton1Click:Connect(updateList)
search:GetPropertyChangedSignal("Text"):Connect(updateList)

Players.PlayerAdded:Connect(updateList)

Players.PlayerRemoving:Connect(function(target)
    if selectedPlayer == target then
        selectedPlayer = nil
        selectedLabel.Text = "Selected: None"
        running = false
        loopId += 1
        status.Text = "STATUS: TARGET LEFT"
    end
    updateList()
end)

-- Local preview loop
local function runLoop(id)
    task.spawn(function()
        while running and loopId == id do
            local character = player.Character
                or player.CharacterAdded:Wait()

            local humanoid = character:WaitForChild("Humanoid")

            local target = selectedPlayer
            local targetCharacter = target and target.Character
            local targetRoot = targetCharacter
                and targetCharacter:FindFirstChild("HumanoidRootPart")

            local root = character:FindFirstChild("HumanoidRootPart")

            if root and targetRoot then
                root.CFrame = targetRoot.CFrame * CFrame.new(3, 0, 0)
            end

            local remaining = killDelay

            while remaining > 0 and running and loopId == id do
                status.Text = "STATUS: ON | " .. remaining .. "s"
                task.wait(1)
                remaining -= 1
            end

            if running and loopId == id then
                if humanoid.Health > 0 then
                    humanoid.Health = 0
                end

                player.CharacterAdded:Wait()
                task.wait(0.5)
            end
        end
    end)
end

start.MouseButton1Click:Connect(function()
    if not selectedPlayer then
        status.Text = "STATUS: SELECT A PLAYER"
        return
    end

    local value = tonumber(delayBox.Text)

    if not value or value < 1 then
        status.Text = "STATUS: INVALID DELAY"
        return
    end

    killDelay = math.clamp(value, 1, 300)
    running = true
    loopId += 1

    status.Text = "STATUS: ON"
    runLoop(loopId)
end)

stop.MouseButton1Click:Connect(function()
    running = false
    loopId += 1
    status.Text = "STATUS: OFF"
end)

-- Right Shift toggle
UIS.InputBegan:Connect(function(input, processed)
    if input.KeyCode == Enum.KeyCode.RightShift then
        main.Visible = not main.Visible
    end
end)

updateList()
