--[[
╔══════════════════════════════════════════════════════╗
║          LemonHub UI Library  v2.0.0                 ║
║          Theme : LemonHub  |  Freemium               ║
║          Author: JoshuaLee                           ║
╚══════════════════════════════════════════════════════╝

QUICK START:
    local Library = loadstring(...)()
    local Window  = Library:CreateWindow({ Title = "LemonHub | Freemium | JoshuaLee" })
    local Tab     = Window:CreateTab({ Name = "Main", Icon = "🍋" })
    Tab:AddButton({ Name = "Hello", Callback = function() print("hi") end })
]]

-- ════════════════════════════════════════════════
--  SERVICES
-- ════════════════════════════════════════════════
local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui          = game:GetService("CoreGui")
local RunService       = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- ════════════════════════════════════════════════
--  THEME
-- ════════════════════════════════════════════════
local T = {
    Accent        = Color3.fromHex("#FFD800"),
    AccentAmber   = Color3.fromHex("#FFB300"),
    AccentHover   = Color3.fromHex("#FFE566"),
    AccentGreen   = Color3.fromHex("#00FF2A"),

    BG            = Color3.fromHex("#111111"),
    Surface       = Color3.fromHex("#1A1A1A"),
    SurfaceAlt    = Color3.fromHex("#202020"),
    SurfaceHov    = Color3.fromHex("#2A2A2A"),
    TitleBG       = Color3.fromHex("#0C0C0C"),

    Sidebar       = Color3.fromHex("#141414"),
    TabNormal     = Color3.fromHex("#181818"),
    TabHov        = Color3.fromHex("#222222"),
    TabActive     = Color3.fromHex("#222222"),

    TextPri       = Color3.fromHex("#FFFFFF"),
    TextSec       = Color3.fromHex("#AAAAAA"),
    TextAcc       = Color3.fromHex("#FFD800"),
    TextMute      = Color3.fromHex("#555555"),

    ToggleOn      = Color3.fromHex("#FFD800"),
    ToggleOff     = Color3.fromHex("#333333"),
    SliderFill    = Color3.fromHex("#FFD800"),
    SliderBg      = Color3.fromHex("#2A2A2A"),
    InputBg       = Color3.fromHex("#161616"),
    InputBorder   = Color3.fromHex("#2E2E2E"),
    InputFocus    = Color3.fromHex("#FFD800"),
    Divider       = Color3.fromHex("#242424"),
    Black         = Color3.fromHex("#000000"),

    CR            = UDim.new(0, 8),
    CRSm          = UDim.new(0, 5),
    CRFull        = UDim.new(1, 0),
}

-- ════════════════════════════════════════════════
--  HELPERS
-- ════════════════════════════════════════════════
local function Tween(obj, props, t, style, dir)
    TweenService:Create(obj,
        TweenInfo.new(t or 0.18, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out),
        props):Play()
end

local function New(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then inst[k] = v end
    end
    if props and props.Parent then inst.Parent = props.Parent end
    return inst
end

local function Corner(r, p)  New("UICorner",  { CornerRadius = r or T.CR, Parent = p }) end
local function Pad(l,r,t,b,p) New("UIPadding",{ PaddingLeft=UDim.new(0,l), PaddingRight=UDim.new(0,r), PaddingTop=UDim.new(0,t), PaddingBottom=UDim.new(0,b), Parent=p }) end
local function List(gap, ha, p)
    New("UIListLayout",{ Padding=UDim.new(0,gap or 0), HorizontalAlignment=ha or Enum.HorizontalAlignment.Left, SortOrder=Enum.SortOrder.LayoutOrder, Parent=p })
end

local function Stroke(col, thick, p)
    return New("UIStroke", { Color=col or T.InputBorder, Thickness=thick or 1, Parent=p })
end

local function HoverFx(btn, norm, hov)
    btn.MouseEnter:Connect(function()  Tween(btn,{BackgroundColor3=hov},0.12) end)
    btn.MouseLeave:Connect(function()  Tween(btn,{BackgroundColor3=norm},0.12) end)
end

-- Drag helper (returns dragger function used in InputBegan)
local function MakeDraggable(handle, target)
    local dragging, dragStart, startPos
    handle.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = inp.Position; startPos = target.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement
                      or inp.UserInputType == Enum.UserInputType.Touch) then
            local d = inp.Position - dragStart
            target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+d.X,
                                        startPos.Y.Scale, startPos.Y.Offset+d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- ════════════════════════════════════════════════
--  LIBRARY
-- ════════════════════════════════════════════════
local Library = {}
Library.__index = Library

function Library:CreateWindow(cfg)
    cfg = cfg or {}
    local title   = cfg.Title or "LemonHub | Freemium | JoshuaLee"
    -- Fixed window size: 680 wide × 460 tall (title 44 + body 416)
    local W, H    = 680, 460
    local TITLE_H = 44
    local SIDEBAR_W = 160

    -- ── ScreenGui ──────────────────────────────────────────
    local sg = New("ScreenGui", {
        Name           = "LemonHubUI",
        ResetOnSpawn   = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
    })
    local ok = pcall(function() sg.Parent = CoreGui end)
    if not ok then sg.Parent = LocalPlayer:WaitForChild("PlayerGui") end

    -- ── Window Frame ───────────────────────────────────────
    -- ClipsDescendants = FALSE so sidebar scrollbar & dropdowns never clip
    local win = New("Frame", {
        Name             = "Window",
        Size             = UDim2.new(0, W, 0, H),
        Position         = UDim2.new(0.5, -W/2, 0.5, -H/2),
        BackgroundColor3 = T.BG,
        BorderSizePixel  = 0,
        ClipsDescendants = false,   -- ← IMPORTANT: lets scroll bars be visible
        Parent           = sg,
    })
    Corner(UDim.new(0,10), win)
    Stroke(T.Accent, 1.5, win)

    -- Drop shadow via UIGradient trick inside a back frame
    local shadow = New("Frame", {
        Name             = "Shadow",
        Size             = UDim2.new(1, 24, 1, 24),
        Position         = UDim2.new(0, -12, 0, -4),
        BackgroundColor3 = T.Black,
        BackgroundTransparency = 0.55,
        BorderSizePixel  = 0,
        ZIndex           = 0,
        Parent           = win,
    })
    Corner(UDim.new(0,16), shadow)

    -- Clip mask frame (sits on top, clips body content properly)
    local clipFrame = New("Frame", {
        Name             = "ClipFrame",
        Size             = UDim2.new(1,0,1,0),
        BackgroundTransparency = 1,
        BorderSizePixel  = 0,
        ClipsDescendants = true,
        ZIndex           = 1,
        Parent           = win,
    })
    Corner(UDim.new(0,10), clipFrame)

    -- ── Title Bar ──────────────────────────────────────────
    local titleBar = New("Frame", {
        Name             = "TitleBar",
        Size             = UDim2.new(1, 0, 0, TITLE_H),
        BackgroundColor3 = T.TitleBG,
        BorderSizePixel  = 0,
        ZIndex           = 10,
        Parent           = clipFrame,
    })

    -- Bottom gold line under title
    New("Frame", {
        Size             = UDim2.new(1,0,0,1),
        Position         = UDim2.new(0,0,1,-1),
        BackgroundColor3 = T.Accent,
        BorderSizePixel  = 0,
        ZIndex           = 11,
        Parent           = titleBar,
    })

    -- 🍋 icon
    New("TextLabel", {
        Size             = UDim2.new(0,30,1,0),
        Position         = UDim2.new(0,10,0,0),
        BackgroundTransparency = 1,
        Text             = "🍋",
        TextSize         = 20,
        Font             = Enum.Font.GothamBold,
        ZIndex           = 11,
        Parent           = titleBar,
    })

    -- Centered title
    New("TextLabel", {
        Name             = "Title",
        Size             = UDim2.new(1, -120, 1, 0),
        Position         = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Text             = title,
        TextColor3       = T.TextPri,
        TextSize         = 13,
        Font             = Enum.Font.GothamBold,
        TextXAlignment   = Enum.TextXAlignment.Center,
        ZIndex           = 11,
        Parent           = titleBar,
    })

    -- ── Title Buttons (outside clipFrame to never be clipped) ──
    local function MakeTitleBtn(icon, offsetX, txtCol)
        local b = New("TextButton", {
            Size             = UDim2.new(0, 28, 0, 22),
            Position         = UDim2.new(1, offsetX, 0, (TITLE_H-22)/2),
            BackgroundColor3 = T.SurfaceAlt,
            BorderSizePixel  = 0,
            Text             = icon,
            TextColor3       = txtCol or T.TextPri,
            TextSize         = 13,
            Font             = Enum.Font.GothamBold,
            ZIndex           = 20,   -- above everything
            Parent           = win,  -- parent to win, NOT clipFrame
        })
        Corner(UDim.new(0,5), b)
        HoverFx(b, T.SurfaceAlt, T.SurfaceHov)
        return b
    end
    local closeBtn    = MakeTitleBtn("✕", -10,  Color3.fromHex("#FF5555"))
    local minimizeBtn = MakeTitleBtn("─", -44,  T.TextSec)

    -- ── Body ───────────────────────────────────────────────
    local body = New("Frame", {
        Name             = "Body",
        Size             = UDim2.new(1, 0, 1, -TITLE_H),
        Position         = UDim2.new(0, 0, 0, TITLE_H),
        BackgroundTransparency = 1,
        BorderSizePixel  = 0,
        ZIndex           = 5,
        Parent           = clipFrame,
    })

    -- ── Sidebar ────────────────────────────────────────────
    local sidebar = New("Frame", {
        Name             = "Sidebar",
        Size             = UDim2.new(0, SIDEBAR_W, 1, 0),
        BackgroundColor3 = T.Sidebar,
        BorderSizePixel  = 0,
        ZIndex           = 6,
        Parent           = body,
    })
    -- Right divider
    New("Frame", {
        Size             = UDim2.new(0,1,1,0),
        Position         = UDim2.new(1,-1,0,0),
        BackgroundColor3 = T.Divider,
        BorderSizePixel  = 0,
        ZIndex           = 7,
        Parent           = sidebar,
    })

    -- Tab list uses a ScrollingFrame so it CAN scroll when tabs overflow
    local tabScrollFrame = New("ScrollingFrame", {
        Name                 = "TabScroll",
        Size                 = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel      = 0,
        ScrollBarThickness   = 3,
        ScrollBarImageColor3 = T.Accent,
        CanvasSize           = UDim2.new(0,0,0,0),
        AutomaticCanvasSize  = Enum.AutomaticSize.Y,
        ZIndex               = 7,
        Parent               = sidebar,
    })
    List(4, Enum.HorizontalAlignment.Center, tabScrollFrame)
    Pad(6,6,8,8, tabScrollFrame)

    -- ── Content area ───────────────────────────────────────
    local contentArea = New("Frame", {
        Name             = "ContentArea",
        Size             = UDim2.new(1, -SIDEBAR_W, 1, 0),
        Position         = UDim2.new(0, SIDEBAR_W, 0, 0),
        BackgroundColor3 = T.Surface,
        BorderSizePixel  = 0,
        ClipsDescendants = true,
        ZIndex           = 6,
        Parent           = body,
    })

    -- ── Dragging ───────────────────────────────────────────
    MakeDraggable(titleBar, win)

    -- ── Minimized droplet ──────────────────────────────────
    -- A rounded square that looks like a water-drop / badge, amber colored
    local droplet = New("TextButton", {
        Name             = "Droplet",
        Size             = UDim2.new(0, 54, 0, 54),
        Position         = UDim2.new(0.5, -27, 0.5, -27),
        BackgroundColor3 = T.AccentAmber,
        BorderSizePixel  = 0,
        Text             = "🍋",
        TextSize         = 28,
        Font             = Enum.Font.GothamBold,
        ZIndex           = 30,
        AutoButtonColor  = false,
        Visible          = false,
        Parent           = sg,
    })
    Corner(UDim.new(0, 14), droplet)
    Stroke(T.Black, 2.5, droplet)
    -- Small glow ring
    New("UIStroke", {
        Color     = T.Accent,
        Thickness = 1,
        Parent    = droplet,
    })
    HoverFx(droplet, T.AccentAmber, T.AccentHover)
    MakeDraggable(droplet, droplet)

    -- ── Minimize / Close logic ─────────────────────────────
    local minimized = false
    minimizeBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            -- Shrink window out
            Tween(win, {Size=UDim2.new(0,W,0,0), BackgroundTransparency=1}, 0.22, Enum.EasingStyle.Quart)
            task.delay(0.22, function()
                win.Visible = false
                droplet.Visible = true
                Tween(droplet, {Size=UDim2.new(0,54,0,54)}, 0.25, Enum.EasingStyle.Back)
            end)
        else
            -- Restore
            droplet.Visible = false
            win.Visible = true
            win.Size = UDim2.new(0,W,0,0)
            win.BackgroundTransparency = 0
            Tween(win, {Size=UDim2.new(0,W,0,H)}, 0.25, Enum.EasingStyle.Back)
        end
    end)

    -- Click droplet to restore
    droplet.MouseButton1Click:Connect(function()
        minimized = false
        droplet.Visible = false
        win.Visible = true
        win.Size = UDim2.new(0,W,0,0)
        win.BackgroundTransparency = 0
        Tween(win, {Size=UDim2.new(0,W,0,H)}, 0.25, Enum.EasingStyle.Back)
    end)

    closeBtn.MouseButton1Click:Connect(function()
        Tween(win, {Size=UDim2.new(0,W,0,0), BackgroundTransparency=1}, 0.2)
        task.delay(0.22, function() sg:Destroy() end)
    end)

    -- ════════════════════════════════════════════
    --  TAB SYSTEM
    -- ════════════════════════════════════════════
    local tabs      = {}
    local activeTab = nil

    local function SelectTab(td)
        for _, t in ipairs(tabs) do
            t.Page.Visible = false
            Tween(t.Button, {BackgroundColor3 = T.TabNormal}, 0.14)
            t.NameLabel.TextColor3 = T.TextSec
            t.Indicator.BackgroundTransparency = 1
        end
        td.Page.Visible = true
        Tween(td.Button, {BackgroundColor3 = T.TabActive}, 0.14)
        td.NameLabel.TextColor3 = T.TextAcc
        Tween(td.Indicator, {BackgroundTransparency=0}, 0.14)
        activeTab = td
    end

    -- ════════════════════════════════════════════
    --  WINDOW OBJECT
    -- ════════════════════════════════════════════
    local Window = {}
    Window.__index = Window

    function Window:CreateTab(tcfg)
        tcfg = tcfg or {}
        local tName = tcfg.Name or "Tab"
        local tIcon = tcfg.Icon or ""

        -- ── Tab button ──────────────────────────────────
        local tabBtn = New("TextButton", {
            Name             = "Tab_"..tName,
            Size             = UDim2.new(1, 0, 0, 38),
            BackgroundColor3 = T.TabNormal,
            BorderSizePixel  = 0,
            Text             = "",
            AutoButtonColor  = false,
            ZIndex           = 8,
            Parent           = tabScrollFrame,
        })
        Corner(UDim.new(0,7), tabBtn)

        -- Left accent bar
        local indicator = New("Frame", {
            Size             = UDim2.new(0,3,0.55,0),
            Position         = UDim2.new(0,0,0.225,0),
            BackgroundColor3 = T.Accent,
            BackgroundTransparency = 1,
            BorderSizePixel  = 0,
            ZIndex           = 9,
            Parent           = tabBtn,
        })
        Corner(UDim.new(0,3), indicator)

        -- Icon
        New("TextLabel", {
            Size             = UDim2.new(0,22,1,0),
            Position         = UDim2.new(0,10,0,0),
            BackgroundTransparency = 1,
            Text             = tIcon,
            TextSize         = 16,
            Font             = Enum.Font.GothamBold,
            ZIndex           = 9,
            Parent           = tabBtn,
        })

        -- Name
        local nameLabel = New("TextLabel", {
            Name             = "Name",
            Size             = UDim2.new(1,-36,1,0),
            Position         = UDim2.new(0,34,0,0),
            BackgroundTransparency = 1,
            Text             = tName,
            TextColor3       = T.TextSec,
            TextSize         = 13,
            Font             = Enum.Font.GothamSemibold,
            TextXAlignment   = Enum.TextXAlignment.Left,
            ZIndex           = 9,
            Parent           = tabBtn,
        })

        -- ── Content page (ScrollingFrame) ───────────────
        local page = New("ScrollingFrame", {
            Name                 = "Page_"..tName,
            Size                 = UDim2.new(1,0,1,0),
            BackgroundTransparency = 1,
            BorderSizePixel      = 0,
            ScrollBarThickness   = 4,
            ScrollBarImageColor3 = T.Accent,
            CanvasSize           = UDim2.new(0,0,0,0),
            AutomaticCanvasSize  = Enum.AutomaticSize.Y,
            Visible              = false,
            ZIndex               = 7,
            Parent               = contentArea,
        })
        List(6, Enum.HorizontalAlignment.Center, page)
        Pad(10,14,10,14, page)

        -- Register
        local td = { Name=tName, Button=tabBtn, Page=page, Indicator=indicator, NameLabel=nameLabel }
        table.insert(tabs, td)
        if #tabs == 1 then SelectTab(td) end

        tabBtn.MouseButton1Click:Connect(function() SelectTab(td) end)
        HoverFx(tabBtn, T.TabNormal, T.TabHov)

        -- ════════════════════════════════════
        --  WIDGET HELPERS (scoped to this tab)
        -- ════════════════════════════════════
        local function BaseCard(h)
            local c = New("Frame", {
                Size             = UDim2.new(1,0,0,h or 40),
                BackgroundColor3 = T.SurfaceAlt,
                BorderSizePixel  = 0,
                ZIndex           = 8,
                Parent           = page,
            })
            Corner(T.CR, c)
            return c
        end

        local Tab = {}
        Tab.__index = Tab

        -- ── Section ──────────────────────────────────────
        function Tab:AddSection(name)
            local w = New("Frame", {
                Size             = UDim2.new(1,0,0,26),
                BackgroundTransparency = 1,
                ZIndex           = 8,
                Parent           = page,
            })
            New("TextLabel", {
                Size             = UDim2.new(1,-8,1,-6),
                Position         = UDim2.new(0,4,0,3),
                BackgroundTransparency = 1,
                Text             = (name or "Section"):upper(),
                TextColor3       = T.Accent,
                TextSize         = 10,
                Font             = Enum.Font.GothamBold,
                TextXAlignment   = Enum.TextXAlignment.Left,
                ZIndex           = 9,
                Parent           = w,
            })
            New("Frame", {
                Size             = UDim2.new(1,-4,0,1),
                Position         = UDim2.new(0,2,1,-1),
                BackgroundColor3 = T.Divider,
                BorderSizePixel  = 0,
                ZIndex           = 9,
                Parent           = w,
            })
        end

        -- ── Label ─────────────────────────────────────────
        function Tab:AddLabel(text)
            local c = BaseCard(34)
            New("TextLabel", {
                Size             = UDim2.new(1,-16,1,0),
                Position         = UDim2.new(0,12,0,0),
                BackgroundTransparency = 1,
                Text             = text or "",
                TextColor3       = T.TextSec,
                TextSize         = 13,
                Font             = Enum.Font.Gotham,
                TextXAlignment   = Enum.TextXAlignment.Left,
                TextWrapped      = true,
                ZIndex           = 9,
                Parent           = c,
            })
        end

        -- ── Paragraph ─────────────────────────────────────
        function Tab:AddParagraph(ptitle, pbody)
            local c = New("Frame", {
                Size             = UDim2.new(1,0,0,0),
                AutomaticSize    = Enum.AutomaticSize.Y,
                BackgroundColor3 = T.SurfaceAlt,
                BorderSizePixel  = 0,
                ZIndex           = 8,
                Parent           = page,
            })
            Corner(T.CR, c)
            Pad(12,12,8,8, c)
            List(4, Enum.HorizontalAlignment.Left, c)
            New("TextLabel", {
                Size             = UDim2.new(1,0,0,18),
                BackgroundTransparency = 1,
                Text             = ptitle or "",
                TextColor3       = T.TextPri,
                TextSize         = 13,
                Font             = Enum.Font.GothamBold,
                TextXAlignment   = Enum.TextXAlignment.Left,
                ZIndex           = 9,
                Parent           = c,
            })
            New("TextLabel", {
                Size             = UDim2.new(1,0,0,0),
                AutomaticSize    = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Text             = pbody or "",
                TextColor3       = T.TextSec,
                TextSize         = 12,
                Font             = Enum.Font.Gotham,
                TextXAlignment   = Enum.TextXAlignment.Left,
                TextWrapped      = true,
                ZIndex           = 9,
                Parent           = c,
            })
        end

        -- ── Button ────────────────────────────────────────
        function Tab:AddButton(bcfg)
            bcfg = bcfg or {}
            local c = BaseCard(40)

            New("TextLabel", {
                Size             = UDim2.new(1,-100,1,0),
                Position         = UDim2.new(0,12,0,0),
                BackgroundTransparency = 1,
                Text             = bcfg.Name or "Button",
                TextColor3       = T.TextPri,
                TextSize         = 13,
                Font             = Enum.Font.GothamSemibold,
                TextXAlignment   = Enum.TextXAlignment.Left,
                ZIndex           = 9,
                Parent           = c,
            })

            local btn = New("TextButton", {
                Size             = UDim2.new(0,76,0,26),
                Position         = UDim2.new(1,-84,0.5,-13),
                BackgroundColor3 = T.Accent,
                BorderSizePixel  = 0,
                Text             = "Run",
                TextColor3       = T.Black,
                TextSize         = 12,
                Font             = Enum.Font.GothamBold,
                AutoButtonColor  = false,
                ZIndex           = 9,
                Parent           = c,
            })
            Corner(UDim.new(0,6), btn)

            btn.MouseButton1Click:Connect(function()
                Tween(btn,{BackgroundColor3=T.AccentAmber,Size=UDim2.new(0,72,0,23)},0.07)
                task.delay(0.12, function()
                    Tween(btn,{BackgroundColor3=T.Accent,Size=UDim2.new(0,76,0,26)},0.1)
                end)
                if bcfg.Callback then task.spawn(bcfg.Callback) end
            end)
            btn.MouseEnter:Connect(function() Tween(btn,{BackgroundColor3=T.AccentHover},0.1) end)
            btn.MouseLeave:Connect(function() Tween(btn,{BackgroundColor3=T.Accent},0.1) end)
        end

        -- ── Toggle ────────────────────────────────────────
        function Tab:AddToggle(tcfg2)
            tcfg2 = tcfg2 or {}
            local val = tcfg2.Default == true
            local c   = BaseCard(40)

            New("TextLabel", {
                Size             = UDim2.new(1,-70,1,0),
                Position         = UDim2.new(0,12,0,0),
                BackgroundTransparency = 1,
                Text             = tcfg2.Name or "Toggle",
                TextColor3       = T.TextPri,
                TextSize         = 13,
                Font             = Enum.Font.GothamSemibold,
                TextXAlignment   = Enum.TextXAlignment.Left,
                ZIndex           = 9,
                Parent           = c,
            })

            local track = New("Frame", {
                Size             = UDim2.new(0,46,0,24),
                Position         = UDim2.new(1,-54,0.5,-12),
                BackgroundColor3 = val and T.ToggleOn or T.ToggleOff,
                BorderSizePixel  = 0,
                ZIndex           = 9,
                Parent           = c,
            })
            Corner(T.CRFull, track)

            local knob = New("Frame", {
                Size             = UDim2.new(0,18,0,18),
                Position         = val and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9),
                BackgroundColor3 = T.TextPri,
                BorderSizePixel  = 0,
                ZIndex           = 10,
                Parent           = track,
            })
            Corner(T.CRFull, knob)

            local hit = New("TextButton", {
                Size             = UDim2.new(1,0,1,0),
                BackgroundTransparency = 1,
                Text             = "",
                ZIndex           = 11,
                Parent           = c,
            })
            hit.MouseButton1Click:Connect(function()
                val = not val
                Tween(track,{BackgroundColor3 = val and T.ToggleOn or T.ToggleOff},0.16)
                Tween(knob,{Position = val and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9)},0.18,Enum.EasingStyle.Back)
                if tcfg2.Callback then task.spawn(tcfg2.Callback, val) end
            end)

            local ctrl = {}
            function ctrl:Set(v)
                val = v
                Tween(track,{BackgroundColor3 = val and T.ToggleOn or T.ToggleOff},0.16)
                Tween(knob,{Position = val and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9)},0.18,Enum.EasingStyle.Back)
                if tcfg2.Callback then task.spawn(tcfg2.Callback, val) end
            end
            function ctrl:Get() return val end
            return ctrl
        end

        -- ── Slider ────────────────────────────────────────
        function Tab:AddSlider(scfg)
            scfg     = scfg or {}
            local mn = scfg.Min     or 0
            local mx = scfg.Max     or 100
            local v  = math.clamp(scfg.Default or mn, mn, mx)
            local c  = BaseCard(62)

            -- Label row
            New("TextLabel", {
                Size             = UDim2.new(0.6,0,0,22),
                Position         = UDim2.new(0,12,0,8),
                BackgroundTransparency = 1,
                Text             = scfg.Name or "Slider",
                TextColor3       = T.TextPri,
                TextSize         = 13,
                Font             = Enum.Font.GothamSemibold,
                TextXAlignment   = Enum.TextXAlignment.Left,
                ZIndex           = 9,
                Parent           = c,
            })
            local valLbl = New("TextLabel", {
                Size             = UDim2.new(0.4,-12,0,22),
                Position         = UDim2.new(0.6,0,0,8),
                BackgroundTransparency = 1,
                Text             = tostring(v),
                TextColor3       = T.Accent,
                TextSize         = 13,
                Font             = Enum.Font.GothamBold,
                TextXAlignment   = Enum.TextXAlignment.Right,
                ZIndex           = 9,
                Parent           = c,
            })

            -- Track
            local trackBg = New("Frame", {
                Size             = UDim2.new(1,-24,0,6),
                Position         = UDim2.new(0,12,0,40),
                BackgroundColor3 = T.SliderBg,
                BorderSizePixel  = 0,
                ZIndex           = 9,
                Parent           = c,
            })
            Corner(T.CRFull, trackBg)

            local pct = (v-mn)/(mx-mn)
            local fill = New("Frame", {
                Size             = UDim2.new(pct,0,1,0),
                BackgroundColor3 = T.SliderFill,
                BorderSizePixel  = 0,
                ZIndex           = 10,
                Parent           = trackBg,
            })
            Corner(T.CRFull, fill)

            local thumb = New("Frame", {
                Size             = UDim2.new(0,14,0,14),
                Position         = UDim2.new(pct,-7,0.5,-7),
                BackgroundColor3 = T.Accent,
                BorderSizePixel  = 0,
                ZIndex           = 11,
                Parent           = trackBg,
            })
            Corner(T.CRFull, thumb)
            New("UIStroke",{Color=T.BG,Thickness=2,Parent=thumb})

            local sliding = false
            local function Upd(ix)
                local ap = trackBg.AbsolutePosition.X
                local as = trackBg.AbsoluteSize.X
                local p  = math.clamp((ix-ap)/as,0,1)
                v = math.floor(mn+(mx-mn)*p)
                valLbl.Text = tostring(v)
                Tween(fill,  {Size=UDim2.new(p,0,1,0)},0.04)
                Tween(thumb, {Position=UDim2.new(p,-7,0.5,-7)},0.04)
                if scfg.Callback then task.spawn(scfg.Callback, v) end
            end
            trackBg.InputBegan:Connect(function(inp)
                if inp.UserInputType==Enum.UserInputType.MouseButton1
                or inp.UserInputType==Enum.UserInputType.Touch then
                    sliding=true; Upd(inp.Position.X)
                end
            end)
            UserInputService.InputChanged:Connect(function(inp)
                if sliding and (inp.UserInputType==Enum.UserInputType.MouseMovement
                             or inp.UserInputType==Enum.UserInputType.Touch) then
                    Upd(inp.Position.X)
                end
            end)
            UserInputService.InputEnded:Connect(function(inp)
                if inp.UserInputType==Enum.UserInputType.MouseButton1
                or inp.UserInputType==Enum.UserInputType.Touch then sliding=false end
            end)

            local ctrl = {}
            function ctrl:Set(val2)
                v = math.clamp(val2,mn,mx)
                local p2 = (v-mn)/(mx-mn)
                valLbl.Text = tostring(v)
                Tween(fill,  {Size=UDim2.new(p2,0,1,0)},0.1)
                Tween(thumb, {Position=UDim2.new(p2,-7,0.5,-7)},0.1)
                if scfg.Callback then task.spawn(scfg.Callback, v) end
            end
            function ctrl:Get() return v end
            return ctrl
        end

        -- ── Textbox ───────────────────────────────────────
        function Tab:AddTextbox(boxcfg)
            boxcfg = boxcfg or {}
            local c = BaseCard(62)

            New("TextLabel", {
                Size             = UDim2.new(1,-16,0,22),
                Position         = UDim2.new(0,12,0,6),
                BackgroundTransparency = 1,
                Text             = boxcfg.Name or "Textbox",
                TextColor3       = T.TextPri,
                TextSize         = 13,
                Font             = Enum.Font.GothamSemibold,
                TextXAlignment   = Enum.TextXAlignment.Left,
                ZIndex           = 9,
                Parent           = c,
            })

            local inputF = New("Frame", {
                Size             = UDim2.new(1,-24,0,28),
                Position         = UDim2.new(0,12,0,28),
                BackgroundColor3 = T.InputBg,
                BorderSizePixel  = 0,
                ZIndex           = 9,
                Parent           = c,
            })
            Corner(UDim.new(0,6), inputF)
            local stroke = Stroke(T.InputBorder,1,inputF)

            local box = New("TextBox", {
                Size             = UDim2.new(1,-16,1,0),
                Position         = UDim2.new(0,8,0,0),
                BackgroundTransparency = 1,
                PlaceholderText  = boxcfg.Placeholder or "Enter text...",
                PlaceholderColor3 = T.TextMute,
                Text             = boxcfg.Default or "",
                TextColor3       = T.TextPri,
                TextSize         = 12,
                Font             = Enum.Font.Gotham,
                TextXAlignment   = Enum.TextXAlignment.Left,
                ClearTextOnFocus = boxcfg.ClearOnFocus ~= false,
                ZIndex           = 10,
                Parent           = inputF,
            })
            box.Focused:Connect(function()   Tween(stroke,{Color=T.InputFocus},0.14) end)
            box.FocusLost:Connect(function(enter)
                Tween(stroke,{Color=T.InputBorder},0.14)
                if boxcfg.Callback then task.spawn(boxcfg.Callback, box.Text, enter) end
            end)

            local ctrl = {}
            function ctrl:Set(t) box.Text = t end
            function ctrl:Get() return box.Text end
            return ctrl
        end

        -- ── Dropdown ──────────────────────────────────────
        function Tab:AddDropdown(dcfg)
            dcfg = dcfg or {}
            local opts = dcfg.Options or {}
            local sel  = dcfg.Default or (opts[1] or "")
            local open = false

            -- Card with extra bottom space when open
            local c = BaseCard(40)
            c.ClipsDescendants = false
            c.ZIndex = 12

            New("TextLabel", {
                Size             = UDim2.new(1,-120,1,0),
                Position         = UDim2.new(0,12,0,0),
                BackgroundTransparency = 1,
                Text             = dcfg.Name or "Dropdown",
                TextColor3       = T.TextPri,
                TextSize         = 13,
                Font             = Enum.Font.GothamSemibold,
                TextXAlignment   = Enum.TextXAlignment.Left,
                ZIndex           = 13,
                Parent           = c,
            })

            local selBtn = New("TextButton", {
                Size             = UDim2.new(0,106,0,28),
                Position         = UDim2.new(1,-114,0.5,-14),
                BackgroundColor3 = T.InputBg,
                BorderSizePixel  = 0,
                Text             = "",
                AutoButtonColor  = false,
                ZIndex           = 13,
                Parent           = c,
            })
            Corner(UDim.new(0,6), selBtn)
            Stroke(T.InputBorder,1,selBtn)

            local selLbl = New("TextLabel", {
                Size             = UDim2.new(1,-20,1,0),
                Position         = UDim2.new(0,8,0,0),
                BackgroundTransparency = 1,
                Text             = sel,
                TextColor3       = T.TextPri,
                TextSize         = 12,
                Font             = Enum.Font.Gotham,
                TextXAlignment   = Enum.TextXAlignment.Left,
                TextTruncate     = Enum.TextTruncate.AtEnd,
                ZIndex           = 14,
                Parent           = selBtn,
            })
            local arrow = New("TextLabel", {
                Size             = UDim2.new(0,14,1,0),
                Position         = UDim2.new(1,-16,0,0),
                BackgroundTransparency = 1,
                Text             = "▾",
                TextColor3       = T.Accent,
                TextSize         = 12,
                Font             = Enum.Font.GothamBold,
                ZIndex           = 14,
                Parent           = selBtn,
            })

            -- List rendered directly in screenGui to avoid clipping issues
            local listH = math.min(#opts, 6) * 30
            local listFrame = New("Frame", {
                Size             = UDim2.new(0,106,0,0),
                BackgroundColor3 = T.SurfaceHov,
                BorderSizePixel  = 0,
                ClipsDescendants = true,
                ZIndex           = 50,
                Visible          = false,
                Parent           = sg,
            })
            Corner(UDim.new(0,6), listFrame)
            Stroke(T.InputBorder,1,listFrame)

            -- Scrolling wrapper inside list for many options
            local listScroll = New("ScrollingFrame", {
                Size                 = UDim2.new(1,0,1,0),
                BackgroundTransparency = 1,
                BorderSizePixel      = 0,
                ScrollBarThickness   = 3,
                ScrollBarImageColor3 = T.Accent,
                CanvasSize           = UDim2.new(0,0,0,0),
                AutomaticCanvasSize  = Enum.AutomaticSize.Y,
                ZIndex               = 51,
                Parent               = listFrame,
            })
            List(0, Enum.HorizontalAlignment.Center, listScroll)

            for _, opt in ipairs(opts) do
                local ob = New("TextButton", {
                    Size             = UDim2.new(1,0,0,30),
                    BackgroundColor3 = T.SurfaceHov,
                    BorderSizePixel  = 0,
                    Text             = opt,
                    TextColor3       = T.TextPri,
                    TextSize         = 12,
                    Font             = Enum.Font.Gotham,
                    AutoButtonColor  = false,
                    ZIndex           = 52,
                    Parent           = listScroll,
                })
                HoverFx(ob, T.SurfaceHov, T.SurfaceAlt)
                ob.MouseButton1Click:Connect(function()
                    sel = opt; selLbl.Text = opt
                    open = false
                    Tween(arrow,{Rotation=0},0.14)
                    Tween(listFrame,{Size=UDim2.new(0,106,0,0)},0.14)
                    task.delay(0.15, function() listFrame.Visible=false end)
                    if dcfg.Callback then task.spawn(dcfg.Callback, opt) end
                end)
            end

            -- Position list below selBtn in screen space
            local function PositionList()
                local ap = selBtn.AbsolutePosition
                local as = selBtn.AbsoluteSize
                listFrame.Position = UDim2.new(0, ap.X, 0, ap.Y + as.Y + 4)
                listFrame.Size     = UDim2.new(0, as.X, 0, 0)
            end

            selBtn.MouseButton1Click:Connect(function()
                open = not open
                PositionList()
                if open then
                    listFrame.Visible = true
                    Tween(arrow,{Rotation=180},0.14)
                    Tween(listFrame,{Size=UDim2.new(0,106,0,listH)},0.16,Enum.EasingStyle.Back)
                else
                    Tween(arrow,{Rotation=0},0.14)
                    Tween(listFrame,{Size=UDim2.new(0,106,0,0)},0.14)
                    task.delay(0.15, function() listFrame.Visible=false end)
                end
            end)

            local ctrl = {}
            function ctrl:Set(v) sel=v; selLbl.Text=v; if dcfg.Callback then task.spawn(dcfg.Callback,v) end end
            function ctrl:Get() return sel end
            return ctrl
        end

        -- ── Keybind ───────────────────────────────────────
        function Tab:AddKeybind(kcfg)
            kcfg = kcfg or {}
            local bound    = kcfg.Default or Enum.KeyCode.Unknown
            local listening = false
            local c = BaseCard(40)

            New("TextLabel", {
                Size             = UDim2.new(1,-110,1,0),
                Position         = UDim2.new(0,12,0,0),
                BackgroundTransparency = 1,
                Text             = kcfg.Name or "Keybind",
                TextColor3       = T.TextPri,
                TextSize         = 13,
                Font             = Enum.Font.GothamSemibold,
                TextXAlignment   = Enum.TextXAlignment.Left,
                ZIndex           = 9,
                Parent           = c,
            })

            local kBtn = New("TextButton", {
                Size             = UDim2.new(0,92,0,26),
                Position         = UDim2.new(1,-100,0.5,-13),
                BackgroundColor3 = T.InputBg,
                BorderSizePixel  = 0,
                Text             = bound == Enum.KeyCode.Unknown and "None" or bound.Name,
                TextColor3       = T.Accent,
                TextSize         = 11,
                Font             = Enum.Font.GothamBold,
                AutoButtonColor  = false,
                ZIndex           = 9,
                Parent           = c,
            })
            Corner(UDim.new(0,6), kBtn)
            Stroke(T.InputBorder,1,kBtn)

            kBtn.MouseButton1Click:Connect(function()
                listening = true
                kBtn.Text = "Press key..."
                kBtn.TextColor3 = T.TextSec
            end)
            UserInputService.InputBegan:Connect(function(inp, gpe)
                if listening and inp.UserInputType==Enum.UserInputType.Keyboard then
                    listening = false
                    bound = inp.KeyCode
                    kBtn.Text = inp.KeyCode.Name
                    kBtn.TextColor3 = T.Accent
                elseif not listening and not gpe
                   and inp.UserInputType==Enum.UserInputType.Keyboard
                   and inp.KeyCode == bound then
                    if kcfg.Callback then task.spawn(kcfg.Callback) end
                end
            end)

            local ctrl = {}
            function ctrl:Set(k) bound=k; kBtn.Text=k.Name end
            function ctrl:Get() return bound end
            return ctrl
        end

        return Tab
    end -- CreateTab

    -- ── Notify ─────────────────────────────────────────────
    function Window:Notify(ncfg)
        ncfg = ncfg or {}
        local nf = New("Frame", {
            Size             = UDim2.new(0,290,0,64),
            Position         = UDim2.new(1,10,1,-74),
            BackgroundColor3 = T.Surface,
            BorderSizePixel  = 0,
            ZIndex           = 100,
            Parent           = sg,
        })
        Corner(UDim.new(0,8), nf)
        Stroke(T.Accent,1,nf)
        New("TextLabel", {
            Size             = UDim2.new(1,-16,0,22),
            Position         = UDim2.new(0,12,0,8),
            BackgroundTransparency = 1,
            Text             = ncfg.Title or "Notification",
            TextColor3       = T.Accent,
            TextSize         = 13,
            Font             = Enum.Font.GothamBold,
            TextXAlignment   = Enum.TextXAlignment.Left,
            ZIndex           = 101,
            Parent           = nf,
        })
        New("TextLabel", {
            Size             = UDim2.new(1,-16,0,24),
            Position         = UDim2.new(0,12,0,32),
            BackgroundTransparency = 1,
            Text             = ncfg.Content or "",
            TextColor3       = T.TextSec,
            TextSize         = 12,
            Font             = Enum.Font.Gotham,
            TextXAlignment   = Enum.TextXAlignment.Left,
            TextWrapped      = true,
            ZIndex           = 101,
            Parent           = nf,
        })
        Tween(nf, {Position=UDim2.new(1,-300,1,-74)}, 0.3, Enum.EasingStyle.Back)
        task.delay(ncfg.Duration or 3.5, function()
            Tween(nf,{Position=UDim2.new(1,10,1,-74)},0.22)
            task.delay(0.23, function() nf:Destroy() end)
        end)
    end

    function Window:Toggle()
        win.Visible = not win.Visible
    end

    setmetatable(Window, Window)
    return Window
end

setmetatable(Library, Library)
return Library
