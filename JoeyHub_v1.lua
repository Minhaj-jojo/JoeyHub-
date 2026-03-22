-- ══════════════════════════════════════
--   Joey Hub v6 — Clean & Stable
-- ══════════════════════════════════════

-- ── Services ──
local RS      = game:GetService("RunService")
local Players = game:GetService("Players")
local TS      = game:GetService("TweenService")
local SG      = game:GetService("StarterGui")
local Light   = game:GetService("Lighting")
local plr     = Players.LocalPlayer

-- ══════════════════════════════════════
--   State Variables
-- ══════════════════════════════════════
local flyOn, flySpeed, flyConn, bg, bv = false, 50, nil, nil, nil
local walkOn, walkDef, walkVal         = false, 16, 50
local jumpOn, jumpDef, jumpVal         = false, 50, 150
local jumpConn                         = nil
local aimbotOn, aimbotConn, aimTarget  = false, nil, nil
local nearOn, nearConn, nearRange      = false, nil, 100
local espOn, espData                   = false, {}
local espFill    = Color3.fromRGB(255, 50, 50)
local espOutline = Color3.fromRGB(255, 130, 130)
local savedPos   = nil
local tweenSpd   = 10
local fpsSaved   = {}
local currentLang   = "EN"
local currentWindow = nil   -- เก็บ Window object ไว้ Destroy
local guiColor1 = Color3.fromHex("0f7bff")
local guiColor2 = Color3.fromHex("0ff3ff")

-- ══════════════════════════════════════
--   Lang Tables
-- ══════════════════════════════════════
local LANG = {
    EN = {
        main="Main", players="Players", settings="Settings",
        fly="Fly", flySpd="Fly Speed", walk="Walk Speed", walkVal="Walk Speed Value",
        jump="High Jump", jumpVal="Jump Power",
        savePos="Save Position", tpSaved="TP to Saved", tweenSaved="Tween to Saved", tweenSpd="Tween Speed",
        selPlr="Select Player", refresh="Refresh List",
        tpPlr="TP to Player", tweenPlr="Tween to Player", tweenSpdP="Tween Speed",
        aimbot="Aimbot", nearAim="Aimbot Near", range="Range", esp="ESP Players", espColor="ESP Color",
        fps="FPS Boost", guiColor="GUI Color", lang="Language", reset="Reset GUI (Apply Language)", guiColor="GUI Color",
    },
    TH = {
        main="หลัก", players="ผู้เล่น", settings="ตั้งค่า",
        fly="บิน", flySpd="ความเร็วบิน", walk="วิ่งเร็ว", walkVal="ค่าความเร็ว",
        jump="กระโดดสูง", jumpVal="แรงกระโดด",
        savePos="บันทึกตำแหน่ง", tpSaved="วาปไปที่บันทึก", tweenSaved="เคลื่อนที่ไปที่บันทึก", tweenSpd="ความเร็ว Tween",
        selPlr="เลือกผู้เล่น", refresh="รีเฟรชรายชื่อ",
        tpPlr="วาปไปหาผู้เล่น", tweenPlr="เคลื่อนที่ไปหาผู้เล่น", tweenSpdP="ความเร็ว Tween",
        aimbot="เล็งอัตโนมัติ", nearAim="เล็งคนใกล้สุด", range="ระยะ", esp="มองทะลุ", espColor="สี ESP",
        fps="เพิ่ม FPS", guiColor="สีหลัก GUI", lang="ภาษา", reset="รีเซ็ต GUI (เปลี่ยนภาษา)",
    },
    KH = {
        main="មេ", players="អ្នកលេង", settings="ការកំណត់",
        fly="ហោះ", flySpd="ល្បឿនហោះ", walk="ដើរលឿន", walkVal="តម្លៃល្បឿន",
        jump="លោតខ្ពស់", jumpVal="កម្លាំងលោត",
        savePos="រក្សាទីតាំង", tpSaved="TP ទៅទីតាំង", tweenSaved="រំកិលទៅទីតាំង", tweenSpd="ល្បឿន Tween",
        selPlr="ជ្រើសអ្នកលេង", refresh="ធ្វើបញ្ជីឡើងវិញ",
        tpPlr="TP ទៅអ្នកលេង", tweenPlr="រំកិលទៅអ្នកលេង", tweenSpdP="ល្បឿន Tween",
        aimbot="កំណត់គោលដៅ", nearAim="គោលដៅជិតបំផុត", range="ចម្ងាយ", esp="មើលទ្លុះជញ្ជាំង", espColor="ពណ៌ ESP",
        fps="បង្កើន FPS", guiColor="ពណ៌ GUI", lang="ភាសា", reset="កំណត់ GUI ឡើងវិញ",
    },
}

-- ══════════════════════════════════════
--   Helpers
-- ══════════════════════════════════════
local function getHum() local c=plr.Character; return c and c:FindFirstChildWhichIsA("Humanoid") end
local function getHRP() local c=plr.Character; return c and c:FindFirstChild("HumanoidRootPart") end
local function notify(t,m) pcall(function() SG:SetCore("SendNotification",{Title=t,Text=m,Duration=3}) end) end

local STATES = {
    Enum.HumanoidStateType.Climbing, Enum.HumanoidStateType.FallingDown,
    Enum.HumanoidStateType.Flying,   Enum.HumanoidStateType.Freefall,
    Enum.HumanoidStateType.GettingUp,Enum.HumanoidStateType.Jumping,
    Enum.HumanoidStateType.Landed,   Enum.HumanoidStateType.Physics,
    Enum.HumanoidStateType.PlatformStanding, Enum.HumanoidStateType.Ragdoll,
    Enum.HumanoidStateType.Running,  Enum.HumanoidStateType.RunningNoPhysics,
    Enum.HumanoidStateType.Seated,   Enum.HumanoidStateType.StrafingNoPhysics,
    Enum.HumanoidStateType.Swimming,
}
local function setStates(hum, val)
    for _,s in ipairs(STATES) do hum:SetStateEnabled(s, val) end
    hum:ChangeState(val and Enum.HumanoidStateType.RunningNoPhysics or Enum.HumanoidStateType.Swimming)
end

-- ══════════════════════════════════════
--   Fly System
-- ══════════════════════════════════════
local function stopFly()
    flyOn = false
    if flyConn then flyConn:Disconnect(); flyConn=nil end
    if bg then bg:Destroy(); bg=nil end
    if bv then bv:Destroy(); bv=nil end
    local c=plr.Character; if not c then return end
    local h=c:FindFirstChildWhichIsA("Humanoid")
    if h then setStates(h,true); h.PlatformStand=false end
    local a=c:FindFirstChild("Animate"); if a then a.Disabled=false end
end

local function startFly()
    local c=plr.Character; if not c then return end
    local h=c:FindFirstChildWhichIsA("Humanoid"); if not h then return end
    local isR6 = h.RigType==Enum.HumanoidRigType.R6
    local torso = isR6 and c:FindFirstChild("Torso") or c:FindFirstChild("UpperTorso")
    if not torso then return end

    local a=c:FindFirstChild("Animate"); if a then a.Disabled=true end
    for _,t in ipairs(h:GetPlayingAnimationTracks()) do t:AdjustSpeed(0) end
    setStates(h, false); h.PlatformStand=true

    bg=Instance.new("BodyGyro",torso); bg.P=9e4; bg.maxTorque=Vector3.new(9e9,9e9,9e9); bg.D=100; bg.cframe=torso.CFrame
    bv=Instance.new("BodyVelocity",torso); bv.velocity=Vector3.new(0,.1,0); bv.maxForce=Vector3.new(9e9,9e9,9e9)

    local cam=workspace.CurrentCamera; local cur,last=0,Vector3.new(0,.1,0)
    flyConn=RS.Heartbeat:Connect(function(dt)
        if not flyOn or not c:FindFirstChild("HumanoidRootPart") then return end
        local md=h.MoveDirection; local cf=cam.CoordinateFrame
        local wish=Vector3.zero
        if md.Magnitude>.1 then
            local fl=Vector3.new(cf.LookVector.X,0,cf.LookVector.Z)
            local ri=Vector3.new(cf.RightVector.X,0,cf.RightVector.Z)
            if fl.Magnitude>0 then fl=fl.Unit end; if ri.Magnitude>0 then ri=ri.Unit end
            wish=cf.LookVector*md:Dot(fl)+ri*md:Dot(ri)
            if wish.Magnitude>0 then wish=wish.Unit end
        end
        local tgt=wish.Magnitude>.1 and flySpeed or 0
        cur=cur+(tgt-cur)*math.min((wish.Magnitude>.1 and 80 or 120)*dt,1)
        if wish.Magnitude>.1 then last=wish end
        if cur>.5 then
            bv.velocity=last*cur
            bg.cframe=cf*CFrame.Angles(-math.rad(math.clamp(cur/math.max(flySpeed,1)*30,0,30)),0,0)
        else bv.velocity=Vector3.zero; bg.cframe=cf end
    end)
end

local function toggleFly(s) flyOn=s; if s then startFly() else stopFly() end end

-- ══════════════════════════════════════
--   Walk Speed
-- ══════════════════════════════════════
local function toggleWalk(s)
    walkOn=s
    local h=getHum(); if not h then return end
    if s then walkDef=h.WalkSpeed; h.WalkSpeed=walkVal else h.WalkSpeed=walkDef end
end
local function setWalk(v) walkVal=v*10; if walkOn then local h=getHum(); if h then h.WalkSpeed=walkVal end end end

-- ══════════════════════════════════════
--   Jump Power
-- ══════════════════════════════════════
local function stopJump()
    jumpOn=false
    if jumpConn then jumpConn:Disconnect(); jumpConn=nil end
    local h=getHum(); if not h then return end
    pcall(function() h.UseJumpPower=true end); h.JumpPower=jumpDef
end

local function startJump()
    local h=getHum()
    if h then pcall(function() h.UseJumpPower=true end); jumpDef=h.JumpPower end
    jumpConn=RS.Heartbeat:Connect(function()
        if not jumpOn then return end
        local h2=getHum(); if not h2 then return end
        pcall(function() h2.UseJumpPower=true end)
        if h2.JumpPower~=jumpVal then h2.JumpPower=jumpVal end
    end)
end

local function toggleJump(s) jumpOn=s; if s then startJump() else stopJump() end end
local function setJump(v) jumpVal=v*30 end

-- ══════════════════════════════════════
--   Aimbot (Manual Target)
-- ══════════════════════════════════════
local function stopAimbot()
    aimbotOn=false; if aimbotConn then aimbotConn:Disconnect(); aimbotConn=nil end
end
local function startAimbot()
    if aimbotConn then aimbotConn:Disconnect(); aimbotConn=nil end
    aimbotConn=RS.Heartbeat:Connect(function()
        if not aimbotOn or not aimTarget then return end
        local tc=aimTarget.Character; if not tc then return end
        local tr=tc:FindFirstChild("HumanoidRootPart"); if not tr then return end
        local mr=getHRP(); if not mr then return end
        local cam=workspace.CurrentCamera
        if (tr.Position-mr.Position).Magnitude<.1 then return end
        cam.CFrame=cam.CFrame:Lerp(CFrame.lookAt(mr.Position+Vector3.new(0,1.5,0),tr.Position),0.2)
    end)
end
local function toggleAimbot(s)
    aimbotOn=s
    if s then
        if not aimTarget then notify("Aimbot","กรุณาเลือกผู้เล่นก่อน!"); aimbotOn=false; return end
        startAimbot()
    else stopAimbot() end
end

-- ══════════════════════════════════════
--   Aimbot Near
-- ══════════════════════════════════════
local function getNear()
    local mr=getHRP(); if not mr then return nil end
    local best,dist=nil,nearRange
    for _,p in ipairs(Players:GetPlayers()) do
        if p==plr then continue end
        local c=p.Character; if not c then continue end
        local r=c:FindFirstChild("HumanoidRootPart"); if not r then continue end
        local h=c:FindFirstChildWhichIsA("Humanoid"); if not h or h.Health<=0 then continue end
        local d=(r.Position-mr.Position).Magnitude
        if d<dist then dist=d; best=p end
    end
    return best
end

local function stopNear()
    nearOn=false; if nearConn then nearConn:Disconnect(); nearConn=nil end
end
local function startNear()
    if nearConn then nearConn:Disconnect(); nearConn=nil end
    nearConn=RS.Heartbeat:Connect(function()
        if not nearOn then return end
        local p=getNear(); if not p then return end
        local tc=p.Character; if not tc then return end
        local tr=tc:FindFirstChild("HumanoidRootPart"); if not tr then return end
        local mr=getHRP(); if not mr then return end
        if (tr.Position-mr.Position).Magnitude<.1 then return end
        workspace.CurrentCamera.CFrame=workspace.CurrentCamera.CFrame:Lerp(
            CFrame.lookAt(mr.Position+Vector3.new(0,1.5,0), tr.Position+Vector3.new(0,1.5,0)), 0.2)
    end)
end
local function toggleNear(s) nearOn=s; if s then startNear() else stopNear() end end

-- ══════════════════════════════════════
--   ESP
-- ══════════════════════════════════════
local function makeESP(p)
    if p==plr or espData[p] then return end
    local c=p.Character; if not c then return end
    local hl=Instance.new("Highlight")
    hl.FillColor=espFill; hl.OutlineColor=espOutline
    hl.FillTransparency=.55; hl.OutlineTransparency=0
    hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop; hl.Parent=c
    local hrp=c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso") or c:FindFirstChild("UpperTorso")
    local bb=nil
    if hrp then
        bb=Instance.new("BillboardGui"); bb.Adornee=hrp; bb.AlwaysOnTop=true
        bb.Size=UDim2.new(0,120,0,30); bb.StudsOffset=Vector3.new(0,3.5,0); bb.Parent=hrp
        local lbl=Instance.new("TextLabel",bb)
        lbl.Size=UDim2.new(1,0,1,0); lbl.BackgroundTransparency=1; lbl.Text=p.Name
        lbl.TextColor3=espOutline; lbl.TextStrokeTransparency=0; lbl.TextSize=15; lbl.Font=Enum.Font.GothamBold
    end
    espData[p]={hl=hl,bb=bb}
end

local function removeESP(p)
    local d=espData[p]; if not d then return end
    pcall(function() if d.hl then d.hl:Destroy() end end)
    pcall(function() if d.bb then d.bb:Destroy() end end)
    espData[p]=nil
end

local function updateESPColors()
    for _,d in pairs(espData) do
        if d.hl then d.hl.FillColor=espFill; d.hl.OutlineColor=espOutline end
        if d.bb then
            local l=d.bb:FindFirstChildOfClass("TextLabel")
            if l then l.TextColor3=espOutline end
        end
    end
end

local function toggleESP(s)
    espOn=s
    if s then
        for _,p in ipairs(Players:GetPlayers()) do makeESP(p) end
    else
        for p in pairs(espData) do removeESP(p) end; espData={}
    end
end

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function() task.wait(.5); if espOn then makeESP(p) end end)
end)
Players.PlayerRemoving:Connect(function(p)
    removeESP(p)
    if aimTarget==p then aimTarget=nil; if aimbotOn then stopAimbot() end end
end)

-- ══════════════════════════════════════
--   Teleport
-- ══════════════════════════════════════
local function savePos()
    local r=getHRP(); if not r then return end
    savedPos=r.CFrame; notify("TP","บันทึกตำแหน่งแล้ว ✅")
end

local function tpTo(cf)
    local r=getHRP(); if not r then return end; r.CFrame=cf
end

local function tweenTo(cf)
    local r=getHRP(); if not r then return end
    local h=getHum(); if h then h.WalkSpeed=0 end
    local d=(cf.Position-r.Position).Magnitude
    local tw=TS:Create(r,TweenInfo.new(math.max(d/(tweenSpd*20),.3),Enum.EasingStyle.Quad,Enum.EasingDirection.InOut),{CFrame=cf})
    tw:Play(); tw.Completed:Connect(function() if h then h.WalkSpeed=walkOn and walkVal or walkDef end end)
end

-- ══════════════════════════════════════
--   FPS Boost
-- ══════════════════════════════════════
local function applyFPS()
    fpsSaved.Brightness=Light.Brightness; fpsSaved.GlobalShadows=Light.GlobalShadows; fpsSaved.FogEnd=Light.FogEnd
    Light.GlobalShadows=false; Light.Brightness=2; Light.FogEnd=100000
    for _,e in ipairs(Light:GetChildren()) do
        if e:IsA("PostEffect") or e:IsA("Sky") then e.Enabled=false end
    end
    pcall(function() workspace.Terrain.WaterWaveSize=0; workspace.Terrain.Decoration=false end)
    local n=0
    for _,o in ipairs(workspace:GetDescendants()) do
        if o:IsA("BasePart") and not o:IsA("Terrain") then
            fpsSaved[o]={M=o.Material,CS=o.CastShadow,R=o.Reflectance}
            o.Material=Enum.Material.SmoothPlastic; o.CastShadow=false; o.Reflectance=0
            n=n+1; if n%200==0 then task.wait() end
        end
    end
    notify("FPS","เปิดแล้ว! ("..n.." parts)")
end

local function removeFPS()
    if fpsSaved.GlobalShadows~=nil then
        Light.GlobalShadows=fpsSaved.GlobalShadows; Light.Brightness=fpsSaved.Brightness; Light.FogEnd=fpsSaved.FogEnd
    end
    for _,e in ipairs(Light:GetChildren()) do
        if e:IsA("PostEffect") or e:IsA("Sky") then e.Enabled=true end
    end
    pcall(function() workspace.Terrain.Decoration=true end)
    local n=0
    for o,d in pairs(fpsSaved) do
        if typeof(o)=="Instance" and o:IsA("BasePart") then
            pcall(function() o.Material=d.M; o.CastShadow=d.CS; o.Reflectance=d.R end)
            n=n+1; if n%200==0 then task.wait() end
        end
    end
    fpsSaved={}; notify("FPS","ปิดแล้ว")
end

-- ══════════════════════════════════════
--   Respawn Reset
-- ══════════════════════════════════════
plr.CharacterAdded:Connect(function(c)
    task.wait(.7); flyOn=false; flyConn=nil; bg=nil; bv=nil
    local h=c:FindFirstChildWhichIsA("Humanoid"); if not h then return end
    h.PlatformStand=false
    if walkOn then h.WalkSpeed=walkVal end
    if jumpOn then if jumpConn then jumpConn:Disconnect(); jumpConn=nil end; startJump() end
    local a=c:FindFirstChild("Animate"); if a then a.Disabled=false end
end)

-- ══════════════════════════════════════
--   Build GUI
-- ══════════════════════════════════════
local WindUI

local SKIP = {RobloxGui=true,TouchGui=true,BubbleChat=true,ControlGui=true,PlayerList=true,Chat=true,TopBarApp=true}

local function buildGUI()
    local L = LANG[currentLang]

    -- ── ลบ Window เก่าและ ScreenGui ที่ค้าง ──
    if currentWindow then
        pcall(function() currentWindow:Destroy() end)
        currentWindow = nil
    end
    for _,v in ipairs(plr.PlayerGui:GetChildren()) do
        if v:IsA("ScreenGui") and not SKIP[v.Name] then
            pcall(function() v:Destroy() end)
        end
    end
    task.wait(0.2)

    -- โหลด WindUI ใหม่ทุกครั้ง
    WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

    local W = WindUI:CreateWindow({Title="Joey Hub", Icon="bird", Author="by MINHAJ"})
    currentWindow = W
    W:EditOpenButton({Title="JoeyHub",Icon="monitor",CornerRadius=UDim.new(0,16),StrokeThickness=2,
        Color=ColorSequence.new(guiColor1, guiColor2),OnlyMobile=false,Enabled=true,Draggable=true})
    W:Tag({Title="v1",Icon="bird",Color=Color3.fromHex("#30ff6a"),Radius=13})

    -- ════ MAIN ════
    local T1=W:Tab({Title=L.main,Icon="book",Locked=false})
    T1:Toggle({Title=L.fly,     Desc="",Icon="bird",           Type="Checkbox",Value=false,Callback=function(s) toggleFly(s) end})
    T1:Slider({Title=L.flySpd,  Desc="",Step=1,Value={Min=1,Max=50,Default=10},Callback=function(v) flySpeed=v*5 end})
    T1:Toggle({Title=L.walk,    Desc="",Icon="person-standing",Type="Checkbox",Value=false,Callback=function(s) toggleWalk(s) end})
    T1:Slider({Title=L.walkVal, Desc="",Step=1,Value={Min=1,Max=50,Default=5}, Callback=function(v) setWalk(v) end})
    T1:Toggle({Title=L.jump,    Desc="",Icon="arrow-up",       Type="Checkbox",Value=false,Callback=function(s) toggleJump(s) end})
    T1:Slider({Title=L.jumpVal, Desc="",Step=1,Value={Min=1,Max=50,Default=5}, Callback=function(v) setJump(v) end})
    T1:Button({Title=L.savePos,   Desc="",Icon="map-pin",  Callback=function() savePos() end})
    T1:Button({Title=L.tpSaved,   Desc="",Icon="map-pin",  Callback=function() if savedPos then tpTo(savedPos) else notify("TP","ยังไม่ได้บันทึก!") end end})
    T1:Button({Title=L.tweenSaved,Desc="",Icon="navigation",Callback=function() if savedPos then tweenTo(savedPos) else notify("TP","ยังไม่ได้บันทึก!") end end})
    T1:Slider({Title=L.tweenSpd,  Desc="",Step=1,Value={Min=1,Max=20,Default=10},Callback=function(v) tweenSpd=v end})

    -- ════ PLAYERS ════
    local T2=W:Tab({Title=L.players,Icon="user",Locked=false})

    local function getPList()
        local l={}; for _,p in ipairs(Players:GetPlayers()) do if p~=plr then table.insert(l,p.Name) end end; return l
    end

    local dd=T2:Dropdown({Title=L.selPlr,Desc="",Values=getPList(),Value="",
        Callback=function(n)
            aimTarget=n~="" and Players:FindFirstChild(n) or nil
            if aimbotOn and aimTarget then startAimbot() end
        end
    })
    T2:Button({Title=L.refresh,Desc="",Icon="refresh-cw",Callback=function()
        if aimTarget and not Players:FindFirstChild(aimTarget.Name) then
            aimTarget=nil; if aimbotOn then stopAimbot() end
        end
        pcall(function() dd:Set(getPList()) end)
        notify("Players",tostring(#Players:GetPlayers()-1).." players")
    end})
    T2:Button({Title=L.tpPlr,   Desc="",Icon="map-pin",  Callback=function()
        if not aimTarget then notify("TP","เลือกผู้เล่นก่อน!"); return end
        local r=aimTarget.Character and aimTarget.Character:FindFirstChild("HumanoidRootPart")
        if r then tpTo(r.CFrame*CFrame.new(0,0,3)) end
    end})
    T2:Button({Title=L.tweenPlr,Desc="",Icon="navigation",Callback=function()
        if not aimTarget then notify("TP","เลือกผู้เล่นก่อน!"); return end
        local r=aimTarget.Character and aimTarget.Character:FindFirstChild("HumanoidRootPart")
        if r then tweenTo(r.CFrame*CFrame.new(0,0,3)) end
    end})
    T2:Slider({Title=L.tweenSpdP,Desc="",Step=1,Value={Min=1,Max=20,Default=10},Callback=function(v) tweenSpd=v end})
    T2:Toggle({Title=L.aimbot,  Desc="",Icon="crosshair",Type="Checkbox",Value=false,Callback=function(s) toggleAimbot(s) end})
    T2:Toggle({Title=L.nearAim, Desc="",Icon="crosshair",Type="Checkbox",Value=false,Callback=function(s) toggleNear(s) end})
    T2:Slider({Title=L.range,   Desc="",Step=1,Value={Min=1,Max=20,Default=10},Callback=function(v) nearRange=v*10 end})
    T2:Toggle({Title=L.esp, Desc="",Icon="eye", Type="Checkbox",Value=false,Callback=function(s) toggleESP(s) end})

    T2:Colorpicker({
        Title        = L.espColor,
        Desc         = "",
        Default      = espFill,
        Transparency = 0,
        Locked       = false,
        Callback     = function(c)
            espFill    = c
            espOutline = Color3.new(math.min(c.R+.25,1), math.min(c.G+.25,1), math.min(c.B+.25,1))
            updateESPColors()
        end
    })

    -- ════ SETTINGS ════
    local T3=W:Tab({Title=L.settings,Icon="settings",Locked=false})
    local fpsOn=false
    T3:Toggle({Title=L.fps,Desc="",Icon="zap",Type="Checkbox",Value=false,Callback=function(s)
        fpsOn=s; if s then task.spawn(applyFPS) else task.spawn(removeFPS) end
    end})

    -- GUI Color
    T3:Colorpicker({
        Title        = L.guiColor,
        Desc         = "",
        Default      = guiColor1,
        Transparency = 0,
        Locked       = false,
        Callback     = function(c)
            guiColor1 = c
            guiColor2 = Color3.new(math.min(c.R+.15,1), math.min(c.G+.15,1), math.min(c.B+.15,1))
            -- อัปเดต OpenButton ทันที
            W:EditOpenButton({Title="JoeyHub",Icon="monitor",CornerRadius=UDim.new(0,16),StrokeThickness=2,
                Color=ColorSequence.new(guiColor1, guiColor2),OnlyMobile=false,Enabled=true,Draggable=true})
        end
    })

    local langMap={English="EN",["ภาษาไทย"]="TH",["ភាសាខ្មែរ"]="KH"}
    local langDef=currentLang=="TH" and "ภาษาไทย" or currentLang=="KH" and "ភាសាខ្មែរ" or "English"
    T3:Dropdown({Title=L.lang,Desc="",Values={"English","ภาษาไทย","ភាសាខ្មែរ"},Value=langDef,
        Callback=function(v) currentLang=langMap[v] or "EN" end
    })
    T3:Button({Title=L.reset,Desc="",Icon="refresh-cw",Callback=function()
        task.spawn(function() task.wait(.1); buildGUI(); notify("GUI","เปลี่ยนภาษาเรียบร้อย!") end)
    end})
end

buildGUI()
