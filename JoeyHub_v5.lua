local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- ══════════════════════════════════════
--         ตัวแปรระบบ
-- ══════════════════════════════════════
local RunService = game:GetService("RunService")
local Players    = game:GetService("Players")
local speaker    = Players.LocalPlayer

-- ── บิน ──
local nowe     = false
local flySpeed = 50
local flyConn  = nil
local bg, bv   = nil, nil

-- ── เดิน ──
local walkEnabled  = false
local defaultWalk  = 16
local walkSpeedVal = 50

-- ── กระโดด ──
local jumpEnabled  = false
local defaultJump  = 50
local jumpPowerVal = 150

-- ── เล็ง ──
local aimbotEnabled = false
local targetPlayer  = nil
local aimbotConn    = nil

-- ── ESP ──
local espEnabled    = false
local espData       = {}  -- { [player] = { highlight, billboard } }

-- ══════════════════════════════════════
--         Helper
-- ══════════════════════════════════════
local function getHum()
    local chr = speaker.Character
    return chr and chr:FindFirstChildWhichIsA("Humanoid")
end

-- ══════════════════════════════════════
--         Helper: Humanoid States
-- ══════════════════════════════════════
local ALL_STATES = {
    Enum.HumanoidStateType.Climbing,
    Enum.HumanoidStateType.FallingDown,
    Enum.HumanoidStateType.Flying,
    Enum.HumanoidStateType.Freefall,
    Enum.HumanoidStateType.GettingUp,
    Enum.HumanoidStateType.Jumping,
    Enum.HumanoidStateType.Landed,
    Enum.HumanoidStateType.Physics,
    Enum.HumanoidStateType.PlatformStanding,
    Enum.HumanoidStateType.Ragdoll,
    Enum.HumanoidStateType.Running,
    Enum.HumanoidStateType.RunningNoPhysics,
    Enum.HumanoidStateType.Seated,
    Enum.HumanoidStateType.StrafingNoPhysics,
    Enum.HumanoidStateType.Swimming,
}

local function enableAllStates(hum)
    for _, s in ipairs(ALL_STATES) do hum:SetStateEnabled(s, true) end
    hum:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
end

local function disableAllStates(hum)
    for _, s in ipairs(ALL_STATES) do hum:SetStateEnabled(s, false) end
    hum:ChangeState(Enum.HumanoidStateType.Swimming)
end

-- ══════════════════════════════════════
--         ระบบบิน
-- ══════════════════════════════════════
local function startFly()
    local chr = speaker.Character
    if not chr then return end
    local hum = chr:FindFirstChildWhichIsA("Humanoid")
    if not hum then return end

    local isR6  = hum.RigType == Enum.HumanoidRigType.R6
    local torso = isR6 and chr:FindFirstChild("Torso") or chr:FindFirstChild("UpperTorso")
    if not torso then return end

    if chr:FindFirstChild("Animate") then chr.Animate.Disabled = true end
    for _, track in ipairs(hum:GetPlayingAnimationTracks()) do track:AdjustSpeed(0) end

    disableAllStates(hum)
    hum.PlatformStand = true

    bg = Instance.new("BodyGyro", torso)
    bg.P = 9e4; bg.maxTorque = Vector3.new(9e9,9e9,9e9); bg.D = 100; bg.cframe = torso.CFrame

    bv = Instance.new("BodyVelocity", torso)
    bv.velocity = Vector3.new(0,0.1,0); bv.maxForce = Vector3.new(9e9,9e9,9e9)

    local cam = workspace.CurrentCamera
    local curSpeed = 0
    local lastDir  = Vector3.new(0,0.1,0)

    flyConn = RunService.Heartbeat:Connect(function(dt)
        if not nowe then return end
        if not chr:FindFirstChild("HumanoidRootPart") then return end

        local md    = hum.MoveDirection
        local camCF = cam.CoordinateFrame
        local wishDir = Vector3.zero

        if md.Magnitude > 0.1 then
            local camFlat  = Vector3.new(camCF.LookVector.X, 0, camCF.LookVector.Z)
            local camRight = Vector3.new(camCF.RightVector.X, 0, camCF.RightVector.Z)
            if camFlat.Magnitude  > 0 then camFlat  = camFlat.Unit  end
            if camRight.Magnitude > 0 then camRight = camRight.Unit end
            local fwdAmt   = md:Dot(camFlat)
            local rightAmt = md:Dot(camRight)
            wishDir = camCF.LookVector * fwdAmt + camRight * rightAmt
            if wishDir.Magnitude > 0 then wishDir = wishDir.Unit end
        end

        local targetSpeed = wishDir.Magnitude > 0.1 and flySpeed or 0
        local accel       = wishDir.Magnitude > 0.1 and 80 or 120
        curSpeed = curSpeed + (targetSpeed - curSpeed) * math.min(accel * dt, 1)

        if wishDir.Magnitude > 0.1 then lastDir = wishDir end

        if curSpeed > 0.5 then
            bv.velocity = lastDir * curSpeed
            local tiltAngle = math.rad(math.clamp(curSpeed / math.max(flySpeed,1) * 30, 0, 30))
            bg.cframe = camCF * CFrame.Angles(-tiltAngle, 0, 0)
        else
            bv.velocity = Vector3.zero
            bg.cframe   = camCF
        end
    end)
end

local function stopFly()
    if flyConn then flyConn:Disconnect(); flyConn = nil end
    if bg then bg:Destroy(); bg = nil end
    if bv then bv:Destroy(); bv = nil end
    local chr = speaker.Character
    if not chr then return end
    local hum = chr:FindFirstChildWhichIsA("Humanoid")
    if hum then enableAllStates(hum); hum.PlatformStand = false end
    if chr:FindFirstChild("Animate") then chr.Animate.Disabled = false end
end

local function toggleFly(state)
    nowe = state
    if nowe then startFly() else stopFly() end
end

-- ══════════════════════════════════════
--         ระบบเดินเร็ว
-- ══════════════════════════════════════
local function applyWalkSpeed()
    local hum = getHum()
    if not hum then return end
    hum.WalkSpeed = walkEnabled and walkSpeedVal or defaultWalk
end

local function toggleWalk(state)
    walkEnabled = state
    if state then
        local hum = getHum()
        if hum then defaultWalk = hum.WalkSpeed end
    end
    applyWalkSpeed()
end

local function setWalkSpeed(value)
    walkSpeedVal = value * 10
    if walkEnabled then applyWalkSpeed() end
end

-- ══════════════════════════════════════
--         ระบบกระโดดสูง
-- ══════════════════════════════════════
local jumpConn = nil

local function stopJumpLoop()
    if jumpConn then jumpConn:Disconnect(); jumpConn = nil end
    local hum = getHum()
    if hum then
        pcall(function() hum.UseJumpPower = true end)
        hum.JumpPower = defaultJump
    end
end

local function startJumpLoop()
    local hum = getHum()
    if hum then
        pcall(function() hum.UseJumpPower = true end)
        defaultJump = hum.JumpPower
    end
    jumpConn = RunService.Heartbeat:Connect(function()
        if not jumpEnabled then return end
        local h = getHum()
        if not h then return end
        pcall(function() h.UseJumpPower = true end)
        if h.JumpPower ~= jumpPowerVal then
            h.JumpPower = jumpPowerVal
        end
    end)
end

local function toggleJump(state)
    jumpEnabled = state
    if state then startJumpLoop() else stopJumpLoop() end
end

local function setJumpPower(value)
    jumpPowerVal = value * 30
end

-- ══════════════════════════════════════
--         ระบบเล็งผู้เล่น (Aimbot)
-- ══════════════════════════════════════
local function stopAimbot()
    aimbotEnabled = false
    if aimbotConn then aimbotConn:Disconnect(); aimbotConn = nil end
end

local function startAimbot()
    if aimbotConn then aimbotConn:Disconnect(); aimbotConn = nil end

    aimbotConn = RunService.Heartbeat:Connect(function()
        if not aimbotEnabled then return end
        if not targetPlayer then return end

        -- ตรวจว่า target ยังอยู่ในเกม
        local targetChr = targetPlayer.Character
        if not targetChr then return end
        local targetRoot = targetChr:FindFirstChild("HumanoidRootPart")
        if not targetRoot then return end

        -- ตัวเองต้องมี HumanoidRootPart
        local myChr = speaker.Character
        if not myChr then return end
        local myRoot = myChr:FindFirstChild("HumanoidRootPart")
        if not myRoot then return end

        -- หันกล้องไปทาง target
        local cam       = workspace.CurrentCamera
        local myPos     = myRoot.Position
        local targetPos = targetRoot.Position

        -- คำนวณทิศทาง
        local direction = (targetPos - myPos)
        if direction.Magnitude < 0.1 then return end

        -- หมุนกล้องไปทาง target แบบ smooth
        local goalCF = CFrame.lookAt(myPos + Vector3.new(0,1.5,0), targetPos)
        cam.CFrame   = cam.CFrame:Lerp(goalCF, 0.2)
    end)
end

local function toggleAimbot(state)
    aimbotEnabled = state
    if state then
        if targetPlayer == nil then
            -- ยังไม่ได้เลือก target
            aimbotEnabled = false
            return
        end
        startAimbot()
    else
        stopAimbot()
    end
end

-- ══════════════════════════════════════
--         ระบบ ESP
-- ══════════════════════════════════════

-- สร้าง ESP ให้ผู้เล่น 1 คน
local function addESP(plr)
    if plr == speaker then return end
    if espData[plr] then return end  -- มีแล้ว

    local chr = plr.Character
    if not chr then return end

    -- Highlight = กรอบแดงมองทะลุกำแพง
    local hl = Instance.new("Highlight")
    hl.Name            = "ESP_Highlight"
    hl.FillColor       = Color3.fromRGB(255, 0, 0)
    hl.OutlineColor    = Color3.fromRGB(255, 80, 80)
    hl.FillTransparency    = 0.55
    hl.OutlineTransparency = 0
    hl.DepthMode       = Enum.HighlightDepthMode.AlwaysOnTop  -- มองทะลุกำแพง
    hl.Parent          = chr

    -- BillboardGui = ชื่อเหนือหัว
    local hrp = chr:FindFirstChild("HumanoidRootPart") or chr:FindFirstChild("Torso") or chr:FindFirstChild("UpperTorso")
    local bb  = nil
    if hrp then
        bb = Instance.new("BillboardGui")
        bb.Name          = "ESP_Name"
        bb.Adornee       = hrp
        bb.AlwaysOnTop   = true   -- มองทะลุกำแพง
        bb.Size          = UDim2.new(0, 120, 0, 30)
        bb.StudsOffset   = Vector3.new(0, 3.5, 0)
        bb.Parent        = hrp

        local nameLabel = Instance.new("TextLabel", bb)
        nameLabel.Size              = UDim2.new(1, 0, 1, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text              = plr.Name
        nameLabel.TextColor3        = Color3.fromRGB(255, 80, 80)
        nameLabel.TextStrokeColor3  = Color3.fromRGB(0, 0, 0)
        nameLabel.TextStrokeTransparency = 0
        nameLabel.TextSize          = 15
        nameLabel.Font              = Enum.Font.GothamBold
        nameLabel.TextScaled        = false
    end

    espData[plr] = { highlight = hl, billboard = bb }
end

-- ลบ ESP ของผู้เล่น 1 คน
local function removeESP(plr)
    local data = espData[plr]
    if not data then return end
    pcall(function() if data.highlight then data.highlight:Destroy() end end)
    pcall(function() if data.billboard then data.billboard:Destroy() end end)
    espData[plr] = nil
end

-- ลบ ESP ทั้งหมด
local function clearAllESP()
    for plr, _ in pairs(espData) do
        removeESP(plr)
    end
    espData = {}
end

-- เปิด ESP → ใส่ให้ทุกคนในเซิร์ฟ
local function startESP()
    for _, plr in ipairs(Players:GetPlayers()) do
        addESP(plr)
        -- ถ้าผู้เล่นยังไม่มี character รอแล้วค่อยใส่
        plr.CharacterAdded:Connect(function()
            if espEnabled then
                task.wait(0.5)
                addESP(plr)
            end
        end)
    end
    -- ผู้เล่นที่เข้ามาใหม่ระหว่างเปิด ESP
    Players.PlayerAdded:Connect(function(plr)
        if not espEnabled then return end
        plr.CharacterAdded:Connect(function()
            task.wait(0.5)
            addESP(plr)
        end)
    end)
end

local function toggleESP(state)
    espEnabled = state
    if state then
        startESP()
    else
        clearAllESP()
    end
end

-- ถ้าผู้เล่นออกจากเกมขณะ ESP เปิด → ลบข้อมูลออก
Players.PlayerRemoving:Connect(function(plr)
    removeESP(plr)
end)
speaker.CharacterAdded:Connect(function(char)
    task.wait(0.7)
    nowe    = false
    flyConn = nil
    bg      = nil
    bv      = nil
    local hum = char:FindFirstChildWhichIsA("Humanoid")
    if hum then
        hum.PlatformStand = false
        if walkEnabled then hum.WalkSpeed = walkSpeedVal end
        if jumpEnabled then
            if jumpConn then jumpConn:Disconnect(); jumpConn = nil end
            startJumpLoop()
        end
    end
    local anim = char:FindFirstChild("Animate")
    if anim then anim.Disabled = false end
end)

-- ══════════════════════════════════════
--              WindUI
-- ══════════════════════════════════════
local Window = WindUI:CreateWindow({
    Title  = "Joey Hub",
    Icon   = "bird",
    Author = "by MINHAJ",
})

Window:EditOpenButton({
    Title           = "JoeyHub",
    Icon            = "monitor",
    CornerRadius    = UDim.new(0, 16),
    StrokeThickness = 2,
    Color           = ColorSequence.new(
        Color3.fromHex("0f7bff"),
        Color3.fromHex("0ff3ff")
    ),
    OnlyMobile = false,
    Enabled    = true,
    Draggable  = true,
})

Window:Tag({
    Title  = "v1",
    Icon   = "bird",
    Color  = Color3.fromHex("#30ff6a"),
    Radius = 13,
})

-- ══════════════════════════════════════
--         Tab Main
-- ══════════════════════════════════════
local Tab = Window:Tab({ Title = "Main", Icon = "book", Locked = false })

Tab:Toggle({
    Title = "Fly", Desc = "", Icon = "bird", Type = "Checkbox", Value = false,
    Callback = function(state) toggleFly(state) end
})

Tab:Slider({
    Title = "Fly Speed", Desc = "", Step = 1,
    Value = { Min = 1, Max = 50, Default = 10 },
    Callback = function(value) flySpeed = value * 5 end
})

Tab:Toggle({
    Title = "Walk Speed", Desc = "", Icon = "person-standing", Type = "Checkbox", Value = false,
    Callback = function(state) toggleWalk(state) end
})

Tab:Slider({
    Title = "Walk Speed Value", Desc = "", Step = 1,
    Value = { Min = 1, Max = 50, Default = 5 },
    Callback = function(value) setWalkSpeed(value) end
})

Tab:Toggle({
    Title = "High Jump", Desc = "", Icon = "arrow-up", Type = "Checkbox", Value = false,
    Callback = function(state) toggleJump(state) end
})

Tab:Slider({
    Title = "Jump Power", Desc = "", Step = 1,
    Value = { Min = 1, Max = 50, Default = 5 },
    Callback = function(value) setJumpPower(value) end
})

-- ══════════════════════════════════════
--         Tab Players
-- ══════════════════════════════════════
local Tabtwo = Window:Tab({ Title = "Players", Icon = "user", Locked = false })

-- ── สร้างรายชื่อผู้เล่น ──
local function getPlayerList()
    local list = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= speaker then
            table.insert(list, plr.Name)
        end
    end
    return list
end

-- Dropdown เลือกชื่อผู้เล่น
local playerDropdown = Tabtwo:Dropdown({
    Title    = "Select Player",
    Desc     = "",
    Values   = getPlayerList(),
    Value    = "",
    Callback = function(selectedName)
        if not selectedName or selectedName == "" then
            targetPlayer = nil
            return
        end
        local found = Players:FindFirstChild(selectedName)
        targetPlayer = found or nil
        -- ถ้า aimbot เปิดอยู่ → เริ่มหันไปหา target ใหม่ทันที
        if aimbotEnabled and targetPlayer then
            startAimbot()
        end
    end
})

-- ปุ่ม Refresh รายชื่อ (ใช้ :Set() แทน UpdateValues)
Tabtwo:Button({
    Title    = "Refresh Player List",
    Desc     = "",
    Icon     = "refresh-cw",
    Callback = function()
        -- รีเซ็ต target ถ้าผู้เล่นที่เลือกออกไปแล้ว
        if targetPlayer and not Players:FindFirstChild(targetPlayer.Name) then
            targetPlayer = nil
            if aimbotEnabled then stopAimbot() end
        end
        -- ล้างค่าเดิมแล้วใส่ใหม่ผ่าน Set
        pcall(function()
            playerDropdown:Set(getPlayerList())
        end)
        -- แจ้งจำนวนผู้เล่นปัจจุบัน
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title    = "Player List",
            Text     = "Players in server: " .. tostring(#Players:GetPlayers() - 1),
            Duration = 3,
        })
    end
})

-- Toggle Aimbot
Tabtwo:Toggle({
    Title    = "Aimbot",
    Desc     = "",
    Icon     = "crosshair",
    Type     = "Checkbox",
    Value    = false,
    Callback = function(state)
        if state and targetPlayer == nil then
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title    = "Aimbot",
                Text     = "กรุณาเลือกชื่อผู้เล่นก่อน!",
                Duration = 3,
            })
            return
        end
        toggleAimbot(state)
    end
})

-- ถ้าผู้เล่นที่กำลัง aim ออกจากเกม → หยุด aimbot อัตโนมัติ
Players.PlayerRemoving:Connect(function(plr)
    if targetPlayer and targetPlayer == plr then
        targetPlayer = nil
        if aimbotEnabled then stopAimbot() end
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title    = "Aimbot",
            Text     = "Target ออกจากเกมแล้ว",
            Duration = 3,
        })
    end
end)

-- Toggle ESP
Tabtwo:Toggle({
    Title    = "ESP Players",
    Desc     = "",
    Icon     = "eye",
    Type     = "Checkbox",
    Value    = false,
    Callback = function(state)
        toggleESP(state)
    end
})

-- ══════════════════════════════════════
--         Tab Settings
-- ══════════════════════════════════════
local Tabthree = Window:Tab({ Title = "Settings", Icon = "settings", Locked = false })

-- ── ระบบ FPS Boost ──
local fpsEnabled   = false
local Lighting     = game:GetService("Lighting")
local savedData    = {}  -- เก็บค่าเดิมของ part ไว้ restore

local function applyFPSBoost()
    -- ── 1. Lighting ──
    savedData.Brightness          = Lighting.Brightness
    savedData.GlobalShadows       = Lighting.GlobalShadows
    savedData.FogEnd              = Lighting.FogEnd

    Lighting.GlobalShadows        = false   -- ลบเงาทั้งหมด
    Lighting.Brightness           = 2       -- แสงสว่างขึ้น (ไม่ต้องคำนวณแสง)
    Lighting.FogEnd               = 100000  -- ลบหมอก

    -- ลบ Effects ใน Lighting (Bloom, Blur, etc.)
    for _, effect in ipairs(Lighting:GetChildren()) do
        if effect:IsA("PostEffect") or effect:IsA("Sky") then
            effect.Enabled = false
        end
    end

    -- ── 2. Workspace ──
    workspace.StreamingEnabled = false  -- ปิด streaming ถ้าทำได้
    pcall(function()
        workspace.Terrain.WaterWaveSize     = 0
        workspace.Terrain.WaterWaveSpeed    = 0
        workspace.Terrain.WaterReflectance  = 0
        workspace.Terrain.WaterTransparency = 0
        workspace.Terrain.Decoration        = false
    end)

    -- ── 3. เปลี่ยน Material + ลบเงาของ Part ทั้งหมด ──
    local count = 0
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj:IsA("Terrain") then
            -- เก็บค่าเดิม (เก็บแค่ index เพื่อไม่กิน memory มาก)
            savedData[obj] = {
                Material    = obj.Material,
                CastShadow  = obj.CastShadow,
                Reflectance = obj.Reflectance,
            }
            obj.Material    = Enum.Material.SmoothPlastic  -- เปลี่ยนเป็น plastic
            obj.CastShadow  = false                        -- ลบเงา
            obj.Reflectance = 0                            -- ไม่สะท้อนแสง
            count = count + 1
            -- yield ทุก 200 part เพื่อไม่ freeze เกม
            if count % 200 == 0 then task.wait() end
        end
    end

    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title    = "FPS Boost",
        Text     = "เปิดใช้งานแล้ว! (" .. count .. " parts)",
        Duration = 4,
    })
end

local function removeFPSBoost()
    -- ── คืน Lighting ──
    if savedData.GlobalShadows ~= nil then
        Lighting.GlobalShadows = savedData.GlobalShadows
        Lighting.Brightness    = savedData.Brightness
        Lighting.FogEnd        = savedData.FogEnd
    end
    for _, effect in ipairs(Lighting:GetChildren()) do
        if effect:IsA("PostEffect") or effect:IsA("Sky") then
            effect.Enabled = true
        end
    end
    pcall(function() workspace.Terrain.Decoration = true end)

    -- ── คืน Part ──
    local count = 0
    for obj, data in pairs(savedData) do
        if typeof(obj) == "Instance" and obj:IsA("BasePart") then
            pcall(function()
                obj.Material    = data.Material
                obj.CastShadow  = data.CastShadow
                obj.Reflectance = data.Reflectance
            end)
            count = count + 1
            if count % 200 == 0 then task.wait() end
        end
    end

    -- ล้าง table
    savedData = {}
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title    = "FPS Boost",
        Text     = "ปิดและคืนค่าเดิมแล้ว",
        Duration = 3,
    })
end

local function toggleFPSBoost(state)
    fpsEnabled = state
    if state then
        task.spawn(applyFPSBoost)
    else
        task.spawn(removeFPSBoost)
    end
end

Tabthree:Toggle({
    Title    = "FPS Boost",
    Desc     = "",
    Icon     = "zap",
    Type     = "Checkbox",
    Value    = false,
    Callback = function(state)
        toggleFPSBoost(state)
    end
})
