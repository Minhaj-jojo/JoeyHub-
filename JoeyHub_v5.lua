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
local espData       = {}

-- ── TP ──
local savedPosition  = nil
local tweenSpeed     = 10
local tweenTPTarget  = nil

-- ── สี ──
local espFillColor    = Color3.fromRGB(255, 0, 0)      -- สี fill ESP
local espOutlineColor = Color3.fromRGB(255, 80, 80)    -- สีขอบ ESP
local guiAccentColor  = Color3.fromHex("0f7bff")       -- สี accent GUI

-- ── ภาษา ──
local currentLang = "EN"  -- EN / TH / KH

local LANG = {
    EN = {
        -- Window
        windowTitle  = "Joey Hub",
        windowAuthor = "by MINHAJ",
        tagTitle     = "v1",
        -- Main Tab
        tabMain      = "Main",
        fly          = "Fly",
        flySpeed     = "Fly Speed",
        walkSpeed    = "Walk Speed",
        walkSpeedVal = "Walk Speed Value",
        highJump     = "High Jump",
        jumpPower    = "Jump Power",
        savePos      = "Save Position",
        tpSaved      = "TP to Saved",
        tweenSaved   = "Tween to Saved",
        tweenSpeed   = "Tween Speed",
        -- Players Tab
        tabPlayers   = "Players",
        selectPlayer = "Select Player",
        refreshList  = "Refresh Player List",
        aimbot       = "Aimbot",
        aimbotNear   = "Aimbot Near",
        range        = "Range",
        espPlayers   = "ESP Players",
        espColor     = "ESP Color",
        tpPlayer     = "TP to Player",
        tweenPlayer  = "Tween to Player",
        tweenSpeedP  = "Tween Speed",
        -- Settings Tab
        tabSettings  = "Settings",
        fpsBoost     = "FPS Boost",
        guiColor     = "GUI Accent Color",
        langSelect   = "Language",
        resetGUI     = "Reset GUI (Apply Language)",
    },
    TH = {
        windowTitle  = "Joey Hub",
        windowAuthor = "โดย MINHAJ",
        tagTitle     = "v1",
        tabMain      = "หลัก",
        fly          = "บิน",
        flySpeed     = "ความเร็วบิน",
        walkSpeed    = "วิ่งเร็ว",
        walkSpeedVal = "ค่าความเร็วเดิน",
        highJump     = "กระโดดสูง",
        jumpPower    = "แรงกระโดด",
        savePos      = "บันทึกตำแหน่ง",
        tpSaved      = "วาปไปตำแหน่งที่บันทึก",
        tweenSaved   = "เคลื่อนที่ไปตำแหน่งที่บันทึก",
        tweenSpeed   = "ความเร็ว Tween",
        tabPlayers   = "ผู้เล่น",
        selectPlayer = "เลือกผู้เล่น",
        refreshList  = "รีเฟรชรายชื่อผู้เล่น",
        aimbot       = "เล็งอัตโนมัติ",
        aimbotNear   = "เล็งคนใกล้ที่สุด",
        range        = "ระยะ",
        espPlayers   = "มองทะลุผู้เล่น",
        espColor     = "สี ESP",
        tpPlayer     = "วาปไปหาผู้เล่น",
        tweenPlayer  = "เคลื่อนที่ไปหาผู้เล่น",
        tweenSpeedP  = "ความเร็ว Tween",
        tabSettings  = "ตั้งค่า",
        fpsBoost     = "เพิ่ม FPS",
        guiColor     = "สีหลักของ GUI",
        langSelect   = "ภาษา",
        resetGUI     = "รีเซ็ต GUI (ใช้ภาษาที่เลือก)",
    },
    KH = {
        windowTitle  = "Joey Hub",
        windowAuthor = "ដោយ MINHAJ",
        tagTitle     = "v1",
        tabMain      = "មេ",
        fly          = "ហោះ",
        flySpeed     = "ល្បឿនហោះ",
        walkSpeed    = "ដើរលឿន",
        walkSpeedVal = "តម្លៃល្បឿនដើរ",
        highJump     = "លោតខ្ពស់",
        jumpPower    = "កម្លាំងលោត",
        savePos      = "រក្សាទីតាំង",
        tpSaved      = "TP ទៅទីតាំងដែលបានរក្សា",
        tweenSaved   = "រំកិលទៅទីតាំងដែលបានរក្សា",
        tweenSpeed   = "ល្បឿន Tween",
        tabPlayers   = "អ្នកលេង",
        selectPlayer = "ជ្រើសរើសអ្នកលេង",
        refreshList  = "ធ្វើតារាងអ្នកលេងឡើងវិញ",
        aimbot       = "កំណត់គោលដៅ",
        aimbotNear   = "កំណត់គោលដៅជិតបំផុត",
        range        = "ចម្ងាយ",
        espPlayers   = "មើលអ្នកលេងតាមរយៈជញ្ជាំង",
        espColor     = "ពណ៌ ESP",
        tpPlayer     = "TP ទៅអ្នកលេង",
        tweenPlayer  = "រំកិលទៅអ្នកលេង",
        tweenSpeedP  = "ល្បឿន Tween",
        tabSettings  = "ការកំណត់",
        fpsBoost     = "បង្កើន FPS",
        guiColor     = "ពណ៌ GUI",
        langSelect   = "ភាសា",
        resetGUI     = "កំណត់ GUI ឡើងវិញ (អនុវត្តភាសា)",
    },
}

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
            aimbotEnabled = false
            return
        end
        startAimbot()
    else
        stopAimbot()
    end
end

-- ══════════════════════════════════════
--     ระบบเล็งผู้เล่นใกล้ที่สุด (Aimbot Near)
-- ══════════════════════════════════════
local aimbotNearEnabled = false
local aimbotNearRange   = 100   -- Default Slider=10 → 10*10=100 studs
local aimbotNearConn    = nil

-- หาผู้เล่นที่ใกล้ที่สุดในระยะที่กำหนด
local function getNearestPlayer()
    local myChr = speaker.Character
    if not myChr then return nil end
    local myRoot = myChr:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end

    local nearest   = nil
    local nearestDist = aimbotNearRange  -- จะเล็งเฉพาะในระยะ

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == speaker then continue end
        local chr  = plr.Character
        if not chr then continue end
        local root = chr:FindFirstChild("HumanoidRootPart")
        if not root then continue end
        -- ตรวจว่า Humanoid ยังมีชีวิต
        local hum = chr:FindFirstChildWhichIsA("Humanoid")
        if not hum or hum.Health <= 0 then continue end

        local dist = (root.Position - myRoot.Position).Magnitude
        if dist < nearestDist then
            nearestDist = dist
            nearest     = plr
        end
    end

    return nearest
end

local function stopAimbotNear()
    aimbotNearEnabled = false
    if aimbotNearConn then aimbotNearConn:Disconnect(); aimbotNearConn = nil end
end

local function startAimbotNear()
    if aimbotNearConn then aimbotNearConn:Disconnect(); aimbotNearConn = nil end

    aimbotNearConn = RunService.Heartbeat:Connect(function()
        if not aimbotNearEnabled then return end

        local myChr = speaker.Character
        if not myChr then return end
        local myRoot = myChr:FindFirstChild("HumanoidRootPart")
        if not myRoot then return end

        -- หาคนใกล้ที่สุดทุก frame
        local nearPlr = getNearestPlayer()
        if not nearPlr then return end

        local targetChr  = nearPlr.Character
        if not targetChr then return end
        local targetRoot = targetChr:FindFirstChild("HumanoidRootPart")
        if not targetRoot then return end

        local cam       = workspace.CurrentCamera
        local myPos     = myRoot.Position
        local targetPos = targetRoot.Position + Vector3.new(0, 1.5, 0)  -- เล็งที่หัว

        if (targetPos - myPos).Magnitude < 0.1 then return end

        local goalCF = CFrame.lookAt(myPos + Vector3.new(0, 1.5, 0), targetPos)
        cam.CFrame   = cam.CFrame:Lerp(goalCF, 0.2)
    end)
end

local function toggleAimbotNear(state)
    aimbotNearEnabled = state
    if state then
        startAimbotNear()
    else
        stopAimbotNear()
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

    -- Highlight = กรอบมองทะลุกำแพง
    local hl = Instance.new("Highlight")
    hl.Name                = "ESP_Highlight"
    hl.FillColor           = espFillColor
    hl.OutlineColor        = espOutlineColor
    hl.FillTransparency    = 0.55
    hl.OutlineTransparency = 0
    hl.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent              = chr

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
        nameLabel.Size                   = UDim2.new(1, 0, 1, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text                   = plr.Name
        nameLabel.TextColor3             = espOutlineColor
        nameLabel.TextStrokeColor3       = Color3.fromRGB(0, 0, 0)
        nameLabel.TextStrokeTransparency = 0
        nameLabel.TextSize               = 15
        nameLabel.Font                   = Enum.Font.GothamBold
        nameLabel.TextScaled             = false
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

-- ══════════════════════════════════════
--         ระบบ TP (Teleport)
-- ══════════════════════════════════════
local TweenService = game:GetService("TweenService")

-- ── บันทึกตำแหน่ง ──
local function savePosition()
    local chr = speaker.Character
    if not chr then return end
    local hrp = chr:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    savedPosition = hrp.CFrame
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "TP", Text = "บันทึกตำแหน่งแล้ว!", Duration = 2,
    })
end

-- ── วาปทันที ──
local function tpToSaved()
    if not savedPosition then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "TP", Text = "ยังไม่ได้บันทึกตำแหน่ง!", Duration = 2,
        })
        return
    end
    local chr = speaker.Character
    if not chr then return end
    local hrp = chr:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    hrp.CFrame = savedPosition
end

-- ── Tween ไปตำแหน่งที่บันทึก ──
local function tweenToSaved()
    if not savedPosition then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "TP", Text = "ยังไม่ได้บันทึกตำแหน่ง!", Duration = 2,
        })
        return
    end
    local chr = speaker.Character
    if not chr then return end
    local hrp = chr:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local hum = chr:FindFirstChildWhichIsA("Humanoid")

    -- หยุดการเคลื่อนที่ระหว่าง tween
    if hum then hum.WalkSpeed = 0 end

    local dist     = (savedPosition.Position - hrp.Position).Magnitude
    -- tweenSpeed 1-20 → เวลา = dist / (tweenSpeed * 20) วินาที
    local duration = math.max(dist / (tweenSpeed * 20), 0.3)

    local tween = TweenService:Create(
        hrp,
        TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
        { CFrame = savedPosition }
    )
    tween:Play()
    tween.Completed:Connect(function()
        if hum then hum.WalkSpeed = walkEnabled and walkSpeedVal or defaultWalk end
    end)
end

-- ── Tween ไปหาผู้เล่น ──
local function tweenToPlayer(plr)
    if not plr then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "TP", Text = "ยังไม่ได้เลือกผู้เล่น!", Duration = 2,
        })
        return
    end
    local myChr = speaker.Character
    if not myChr then return end
    local myHRP = myChr:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end
    local myHum = myChr:FindFirstChildWhichIsA("Humanoid")

    local targetChr  = plr.Character
    if not targetChr then return end
    local targetHRP  = targetChr:FindFirstChild("HumanoidRootPart")
    if not targetHRP then return end

    local goalCF   = targetHRP.CFrame * CFrame.new(0, 0, 3)  -- ยืนหน้าเป้า
    local dist     = (goalCF.Position - myHRP.Position).Magnitude
    local duration = math.max(dist / (tweenSpeed * 20), 0.3)

    if myHum then myHum.WalkSpeed = 0 end

    local tween = TweenService:Create(
        myHRP,
        TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
        { CFrame = goalCF }
    )
    tween:Play()
    tween.Completed:Connect(function()
        if myHum then myHum.WalkSpeed = walkEnabled and walkSpeedVal or defaultWalk end
    end)
end

-- ── วาปทันทีไปหาผู้เล่น ──
local function tpToPlayer(plr)
    if not plr then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "TP", Text = "ยังไม่ได้เลือกผู้เล่น!", Duration = 2,
        })
        return
    end
    local myChr = speaker.Character
    if not myChr then return end
    local myHRP = myChr:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end
    local targetChr = plr.Character
    if not targetChr then return end
    local targetHRP = targetChr:FindFirstChild("HumanoidRootPart")
    if not targetHRP then return end
    myHRP.CFrame = targetHRP.CFrame * CFrame.new(0, 0, 3)
end

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
--         buildGUI (เรียกซ้ำได้)
-- ══════════════════════════════════════
local WindUI    -- ประกาศ upvalue ให้ buildGUI อัปเดตได้

local function buildGUI()
    local L = LANG[currentLang]

    -- ── ลบ GUI เก่าออกทั้งหมด ──
    for _, v in ipairs(speaker.PlayerGui:GetChildren()) do
        if v:IsA("ScreenGui") then
            v:Destroy()
        end
    end
    task.wait(0.1)

    -- ── โหลด WindUI ใหม่ ──
    WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

    -- ── สร้าง Window ──
    local Window = WindUI:CreateWindow({
        Title  = L.windowTitle,
        Icon   = "bird",
        Author = L.windowAuthor,
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
        OnlyMobile = false, Enabled = true, Draggable = true,
    })

    Window:Tag({ Title=L.tagTitle, Icon="bird", Color=Color3.fromHex("#30ff6a"), Radius=13 })

    -- ════ Tab Main ════
    local Tab = Window:Tab({ Title=L.tabMain, Icon="book", Locked=false })

    Tab:Toggle({ Title=L.fly,         Desc="", Icon="bird",            Type="Checkbox", Value=false, Callback=function(s) toggleFly(s) end })
    Tab:Slider({ Title=L.flySpeed,    Desc="", Step=1, Value={Min=1,Max=50,Default=10}, Callback=function(v) flySpeed=v*5 end })
    Tab:Toggle({ Title=L.walkSpeed,   Desc="", Icon="person-standing", Type="Checkbox", Value=false, Callback=function(s) toggleWalk(s) end })
    Tab:Slider({ Title=L.walkSpeedVal,Desc="", Step=1, Value={Min=1,Max=50,Default=5},  Callback=function(v) setWalkSpeed(v) end })
    Tab:Toggle({ Title=L.highJump,    Desc="", Icon="arrow-up",        Type="Checkbox", Value=false, Callback=function(s) toggleJump(s) end })
    Tab:Slider({ Title=L.jumpPower,   Desc="", Step=1, Value={Min=1,Max=50,Default=5},  Callback=function(v) setJumpPower(v) end })
    Tab:Button({ Title=L.savePos,     Desc="", Icon="map-pin",    Callback=function() savePosition() end })
    Tab:Button({ Title=L.tpSaved,     Desc="", Icon="map-pin",    Callback=function() tpToSaved() end })
    Tab:Button({ Title=L.tweenSaved,  Desc="", Icon="navigation", Callback=function() tweenToSaved() end })
    Tab:Slider({ Title=L.tweenSpeed,  Desc="", Step=1, Value={Min=1,Max=20,Default=10}, Callback=function(v) tweenSpeed=v end })

    -- ════ Tab Players ════
    local Tabtwo = Window:Tab({ Title=L.tabPlayers, Icon="user", Locked=false })

    local function getPlayerList()
        local list = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= speaker then table.insert(list, plr.Name) end
        end
        return list
    end

    local playerDropdown = Tabtwo:Dropdown({
        Title=L.selectPlayer, Desc="", Values=getPlayerList(), Value="",
        Callback=function(n)
            if not n or n=="" then targetPlayer=nil return end
            local f = Players:FindFirstChild(n)
            targetPlayer = f or nil
            if aimbotEnabled and targetPlayer then startAimbot() end
        end
    })

    Tabtwo:Button({ Title=L.refreshList, Desc="", Icon="refresh-cw",
        Callback=function()
            if targetPlayer and not Players:FindFirstChild(targetPlayer.Name) then
                targetPlayer=nil
                if aimbotEnabled then stopAimbot() end
            end
            pcall(function() playerDropdown:Set(getPlayerList()) end)
            game:GetService("StarterGui"):SetCore("SendNotification",{
                Title="Players", Text=tostring(#Players:GetPlayers()-1).." players", Duration=2,
            })
        end
    })

    Tabtwo:Button({ Title=L.tpPlayer,   Desc="", Icon="map-pin",   Callback=function() tpToPlayer(targetPlayer) end })
    Tabtwo:Button({ Title=L.tweenPlayer,Desc="", Icon="navigation", Callback=function() tweenToPlayer(targetPlayer) end })
    Tabtwo:Slider({ Title=L.tweenSpeedP,Desc="", Step=1, Value={Min=1,Max=20,Default=10}, Callback=function(v) tweenSpeed=v end })

    Tabtwo:Toggle({ Title=L.aimbot, Desc="", Icon="crosshair", Type="Checkbox", Value=false,
        Callback=function(s)
            if s and targetPlayer==nil then
                game:GetService("StarterGui"):SetCore("SendNotification",{
                    Title="Aimbot", Text="กรุณาเลือกผู้เล่นก่อน!", Duration=3,
                })
                return
            end
            toggleAimbot(s)
        end
    })
    Tabtwo:Toggle({ Title=L.aimbotNear, Desc="", Icon="crosshair", Type="Checkbox", Value=false, Callback=function(s) toggleAimbotNear(s) end })
    Tabtwo:Slider({ Title=L.range,      Desc="", Step=1, Value={Min=1,Max=20,Default=10}, Callback=function(v) aimbotNearRange=v*10 end })
    Tabtwo:Toggle({ Title=L.espPlayers, Desc="", Icon="eye", Type="Checkbox", Value=false, Callback=function(s) toggleESP(s) end })

    Tabtwo:ColorPicker({
        Title    = L.espColor,
        Desc     = "",
        Value    = espFillColor,
        Callback = function(color)
            espFillColor    = color
            -- ปรับ outline ให้สว่างกว่า fill เล็กน้อย
            espOutlineColor = Color3.new(
                math.min(color.R + 0.2, 1),
                math.min(color.G + 0.2, 1),
                math.min(color.B + 0.2, 1)
            )
            -- อัปเดต ESP ที่เปิดอยู่ทันที
            for plr, data in pairs(espData) do
                if data.highlight then
                    data.highlight.FillColor    = espFillColor
                    data.highlight.OutlineColor = espOutlineColor
                end
                if data.billboard then
                    local lbl = data.billboard:FindFirstChildOfClass("TextLabel")
                    if lbl then lbl.TextColor3 = espOutlineColor end
                end
            end
        end
    })

    Players.PlayerRemoving:Connect(function(plr)
        if targetPlayer and targetPlayer==plr then
            targetPlayer=nil
            if aimbotEnabled then stopAimbot() end
            game:GetService("StarterGui"):SetCore("SendNotification",{Title="Aimbot",Text="Target ออกจากเกม",Duration=3})
        end
    end)

    -- ════ Tab Settings ════
    local Tabthree = Window:Tab({ Title=L.tabSettings, Icon="settings", Locked=false })

    -- FPS Boost
    local fpsEnabled = false
    local Lighting   = game:GetService("Lighting")
    local savedData  = {}

    local function applyFPSBoost()
        savedData.Brightness    = Lighting.Brightness
        savedData.GlobalShadows = Lighting.GlobalShadows
        savedData.FogEnd        = Lighting.FogEnd
        Lighting.GlobalShadows  = false
        Lighting.Brightness     = 2
        Lighting.FogEnd         = 100000
        for _, e in ipairs(Lighting:GetChildren()) do
            if e:IsA("PostEffect") or e:IsA("Sky") then e.Enabled=false end
        end
        pcall(function()
            workspace.Terrain.WaterWaveSize=0; workspace.Terrain.WaterWaveSpeed=0
            workspace.Terrain.WaterReflectance=0; workspace.Terrain.Decoration=false
        end)
        local count=0
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and not obj:IsA("Terrain") then
                savedData[obj]={Material=obj.Material,CastShadow=obj.CastShadow,Reflectance=obj.Reflectance}
                obj.Material=Enum.Material.SmoothPlastic; obj.CastShadow=false; obj.Reflectance=0
                count=count+1
                if count%200==0 then task.wait() end
            end
        end
        game:GetService("StarterGui"):SetCore("SendNotification",{Title="FPS Boost",Text="เปิดแล้ว! ("..count.." parts)",Duration=4})
    end

    local function removeFPSBoost()
        if savedData.GlobalShadows~=nil then
            Lighting.GlobalShadows=savedData.GlobalShadows
            Lighting.Brightness=savedData.Brightness
            Lighting.FogEnd=savedData.FogEnd
        end
        for _, e in ipairs(Lighting:GetChildren()) do
            if e:IsA("PostEffect") or e:IsA("Sky") then e.Enabled=true end
        end
        pcall(function() workspace.Terrain.Decoration=true end)
        local count=0
        for obj, data in pairs(savedData) do
            if typeof(obj)=="Instance" and obj:IsA("BasePart") then
                pcall(function() obj.Material=data.Material; obj.CastShadow=data.CastShadow; obj.Reflectance=data.Reflectance end)
                count=count+1
                if count%200==0 then task.wait() end
            end
        end
        savedData={}
        game:GetService("StarterGui"):SetCore("SendNotification",{Title="FPS Boost",Text="ปิดแล้ว",Duration=3})
    end

    Tabthree:Toggle({ Title=L.fpsBoost, Desc="", Icon="zap", Type="Checkbox", Value=false,
        Callback=function(s)
            fpsEnabled=s
            if s then task.spawn(applyFPSBoost) else task.spawn(removeFPSBoost) end
        end
    })

    -- GUI Accent ColorPicker
    Tabthree:ColorPicker({
        Title    = L.guiColor,
        Desc     = "",
        Value    = guiAccentColor,
        Callback = function(color)
            guiAccentColor = color
            -- อัปเดต OpenButton สีใหม่ทันที
            Window:EditOpenButton({
                Title           = "JoeyHub",
                Icon            = "monitor",
                CornerRadius    = UDim.new(0, 16),
                StrokeThickness = 2,
                Color           = ColorSequence.new(color, color),
                OnlyMobile = false, Enabled = true, Draggable = true,
            })
        end
    })

    -- Language Dropdown
    local langMap = { English="EN", ["ภาษาไทย"]="TH", ["ភាសាខ្មែរ"]="KH" }
    local langDefault = currentLang=="TH" and "ภาษาไทย" or currentLang=="KH" and "ភាសាខ្មែរ" or "English"

    Tabthree:Dropdown({
        Title=L.langSelect, Desc="", Values={"English","ภาษาไทย","ភាសាខ្មែរ"}, Value=langDefault,
        Callback=function(val) currentLang = langMap[val] or "EN" end
    })

    -- Reset GUI Button
    Tabthree:Button({
        Title=L.resetGUI, Desc="", Icon="refresh-cw",
        Callback=function()
            task.spawn(function()
                task.wait(0.1)
                buildGUI()  -- เรียก rebuild ด้วยภาษาใหม่
                game:GetService("StarterGui"):SetCore("SendNotification",{
                    Title="GUI", Text="เปลี่ยนภาษาเรียบร้อย!", Duration=3,
                })
            end)
        end
    })
end

-- ── เรียก buildGUI ครั้งแรก ──
buildGUI()
