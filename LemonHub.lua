--[[
╔══════════════════════════════════════════════════════════════╗
║   LemonHub UI Library  v3.0.0                                ║
║   Author : JoshuaLee                                         ║
║   Scale  : 65%  →  Window 442 × 299                         ║
║                                                              ║
║   FIXES v3:                                                  ║
║   • 65% layout fully correct & readable                      ║
║   • Minimize / Close buttons always on top, never clipped    ║
║   • Drag: only fires when drag started on titlebar           ║
║     (other simultaneous inputs won't move the window)        ║
║   • Open animation: title expands L→R, then body drops down ║
║   • Droplet size: 80×80 (large, clearly visible)            ║
╚══════════════════════════════════════════════════════════════╝

USAGE:
    local Library = loadstring(...)()
    local Win = Library:CreateWindow({ Title = "LemonHub | Freemium | JoshuaLee" })
    local Tab = Win:CreateTab({ Name = "Main", Icon = "🍋" })
    Tab:AddButton({ Name = "Say Hi", Callback = function() print("Hi!") end })
    Tab:AddToggle({ Name = "God Mode", Default = false, Callback = function(v) end })
    Tab:AddSlider({ Name = "Speed", Min = 16, Max = 200, Default = 50, Callback = function(v) end })
    Tab:AddTextbox({ Name = "Name", Placeholder = "Enter...", Callback = function(t) end })
    Tab:AddDropdown({ Name = "Fruit", Options = {"Apple","Lemon","Orange"}, Callback = function(v) end })
    Tab:AddKeybind({ Name = "Toggle", Default = Enum.KeyCode.RightShift, Callback = function() end })
    Tab:AddSection("Info")
    Tab:AddLabel("Welcome to LemonHub!")
    Tab:AddParagraph("About", "Free UI library for Roblox.")
]]

-- ═══════════════════════════════════════════
--  SERVICES
-- ═══════════════════════════════════════════
local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui          = game:GetService("CoreGui")
local LocalPlayer      = Players.LocalPlayer

-- ═══════════════════════════════════════════
--  SCALE  (65% of 100% base values)
--  Tweak S to resize everything uniformly.
-- ═══════════════════════════════════════════
local S = 0.65
local function px(n) return math.max(1, math.round(n * S)) end

-- ═══════════════════════════════════════════
--  THEME PALETTE
-- ═══════════════════════════════════════════
local T = {
    -- Accents
    Accent       = Color3.fromHex("#FFD800"),
    AccentAmber  = Color3.fromHex("#FFB300"),
    AccentHover  = Color3.fromHex("#FFE566"),
    AccentGreen  = Color3.fromHex("#00FF2A"),
    -- Backgrounds
    BG           = Color3.fromHex("#111111"),
    Surface      = Color3.fromHex("#1C1C1C"),
    SurfaceAlt   = Color3.fromHex("#222222"),
    SurfaceHov   = Color3.fromHex("#2C2C2C"),
    TitleBG      = Color3.fromHex("#0C0C0C"),
    Sidebar      = Color3.fromHex("#161616"),
    -- Tabs
    TabNormal    = Color3.fromHex("#1A1A1A"),
    TabHov       = Color3.fromHex("#242424"),
    TabActive    = Color3.fromHex("#242424"),
    -- Text
    TextPri      = Color3.fromHex("#FFFFFF"),
    TextSec      = Color3.fromHex("#AAAAAA"),
    TextAcc      = Color3.fromHex("#FFD800"),
    TextMute     = Color3.fromHex("#555555"),
    -- Controls
    ToggleOn     = Color3.fromHex("#FFD800"),
    ToggleOff    = Color3.fromHex("#333333"),
    SliderFill   = Color3.fromHex("#FFD800"),
    SliderBg     = Color3.fromHex("#2A2A2A"),
    InputBg      = Color3.fromHex("#161616"),
    InputBorder  = Color3.fromHex("#303030"),
    InputFocus   = Color3.fromHex("#FFD800"),
    Divider      = Color3.fromHex("#272727"),
    Black        = Color3.fromHex("#000000"),
}

local CRFull = UDim.new(1, 0)

-- ═══════════════════════════════════════════
--  LAYOUT CONSTANTS  (all scaled)
-- ═══════════════════════════════════════════
local WIN_W    = px(680)   -- 442
local WIN_H    = px(460)   -- 299
local TH       = px(44)    -- 29   title height
local SB_W     = px(160)   -- 104  sidebar width
local TAB_H    = px(36)    -- 23   tab button height
local CARD_H   = px(38)    -- 25   standard card
local CARD_SL  = px(60)    -- 39   slider card
local CARD_TB  = px(58)    -- 38   textbox card
local BTN_W    = px(72)    -- 47
local BTN_H    = px(24)    -- 16
local TOG_W    = px(44)    -- 29
local TOG_H    = px(22)    -- 14
local TOG_K    = px(16)    -- 10   knob size
local INP_H    = px(26)    -- 17
local KB_W     = px(88)    -- 57
local DD_W     = px(100)   -- 65
local DD_ROW   = px(28)    -- 18
local DROP_SZ  = 80        -- droplet pixel size (absolute, not scaled)
local NOTIF_W  = px(280)   -- 182
local NOTIF_H  = px(60)    -- 39
-- Radii
local CR       = px(7)
local CR_SM    = px(5)
local CR_XS    = px(4)
-- Fonts
local F_PRI    = math.max(9,  px(14))
local F_SEC    = math.max(8,  px(13))
local F_SM     = math.max(8,  px(12))
local F_XS     = math.max(7,  px(10))
local F_ICON   = math.max(10, px(17))
local F_LOGO   = math.max(12, px(20))
local F_DROP   = 36        -- droplet emoji (large, absolute)
-- Padding
local P_LG     = px(12)
local P_MD     = px(9)
local P_SM     = px(7)
local P_XS     = px(5)

-- ═══════════════════════════════════════════
--  HELPERS
-- ═══════════════════════════════════════════
local function Tween(obj, props, t, style, dir)
    TweenService:Create(obj, TweenInfo.new(
        t     or 0.18,
        style or Enum.EasingStyle.Quad,
        dir   or Enum.EasingDirection.Out
    ), props):Play()
end

local function New(cls, props)
    local o = Instance.new(cls)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then o[k] = v end
    end
    if props and props.Parent then o.Parent = props.Parent end
    return o
end

local function Crn(r, p)  New("UICorner",  { CornerRadius = UDim.new(0, r or CR), Parent = p }) end
local function Pad(l,r,t,b,p)
    New("UIPadding", {
        PaddingLeft=UDim.new(0,l), PaddingRight=UDim.new(0,r),
        PaddingTop=UDim.new(0,t),  PaddingBottom=UDim.new(0,b),
        Parent=p })
end
local function VList(gap, p)
    New("UIListLayout", {
        Padding=UDim.new(0,gap or 0),
        HorizontalAlignment=Enum.HorizontalAlignment.Center,
        SortOrder=Enum.SortOrder.LayoutOrder,
        Parent=p })
end
local function Strk(col, th, p)
    return New("UIStroke", { Color=col or T.InputBorder, Thickness=th or 1, Parent=p })
end
local function HovFx(b, n, h)
    b.MouseEnter:Connect(function() Tween(b,{BackgroundColor3=h},0.12) end)
    b.MouseLeave:Connect(function() Tween(b,{BackgroundColor3=n},0.12) end)
end

-- ── Safe drag: tracks the specific input object, ignores others ──────────────
local function MakeDraggable(handle, target)
    local activeInput = nil   -- the exact input that started the drag
    local startPos, startObj

    handle.InputBegan:Connect(function(inp)
        -- Only start a drag if nothing is already dragging this handle
        if activeInput then return end
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            activeInput = inp
            startObj    = inp.Position
            startPos    = target.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(inp)
        -- Only respond to the exact input that started the drag
        if inp ~= activeInput then return end
        if inp.UserInputType == Enum.UserInputType.MouseMovement
        or inp.UserInputType == Enum.UserInputType.Touch then
            local d = inp.Position - startObj
            target.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)

    UserInputService.InputEnded:Connect(function(inp)
        if inp == activeInput then
            activeInput = nil
        end
    end)
end

-- ═══════════════════════════════════════════
--  LIBRARY
-- ═══════════════════════════════════════════
local Library = {}
Library.__index = Library

function Library:CreateWindow(cfg)
    cfg = cfg or {}
    local title = cfg.Title or "LemonHub | Freemium | JoshuaLee"

    -- ── ScreenGui ────────────────────────────────────────
    local sg = New("ScreenGui", {
        Name           = "LemonHubUI",
        ResetOnSpawn   = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
    })
    local ok = pcall(function() sg.Parent = CoreGui end)
    if not ok then sg.Parent = LocalPlayer:WaitForChild("PlayerGui") end

    -- ── Root frame (ClipsDescendants = false → scrollbars never clipped) ──
    local win = New("Frame", {
        Name             = "Window",
        Size             = UDim2.new(0, WIN_W, 0, WIN_H),
        Position         = UDim2.new(0.5, -WIN_W/2, 0.5, -WIN_H/2),
        BackgroundColor3 = T.BG,
        BorderSizePixel  = 0,
        ClipsDescendants = false,
        Visible          = false,   -- starts hidden; shown via animation
        Parent           = sg,
    })
    Crn(CR, win)
    Strk(T.Accent, 1, win)

    -- Shadow behind window
    local shadow = New("Frame", {
        Name                   = "Shadow",
        AnchorPoint            = Vector2.new(0.5, 0.5),
        Size                   = UDim2.new(1, px(22), 1, px(22)),
        Position               = UDim2.new(0.5, 0, 0.5, px(4)),
        BackgroundColor3       = T.Black,
        BackgroundTransparency = 0.5,
        BorderSizePixel        = 0,
        ZIndex                 = 0,
        Parent                 = win,
    })
    Crn(CR + px(4), shadow)

    -- Inner clip frame (clips body so content doesn't spill past rounded corners)
    local clip = New("Frame", {
        Name                   = "Clip",
        Size                   = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        ClipsDescendants       = true,
        ZIndex                 = 1,
        Parent                 = win,
    })
    Crn(CR, clip)

    -- ── Title Bar ─────────────────────────────────────────
    local titleBar = New("Frame", {
        Name             = "TitleBar",
        Size             = UDim2.new(1, 0, 0, TH),
        BackgroundColor3 = T.TitleBG,
        BorderSizePixel  = 0,
        ZIndex           = 10,
        Parent           = clip,
    })
    -- Gold underline
    New("Frame", {
        Size             = UDim2.new(1, 0, 0, 1),
        Position         = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = T.Accent,
        BorderSizePixel  = 0,
        ZIndex           = 11,
        Parent           = titleBar,
    })
    -- 🍋 icon left
    New("TextLabel", {
        Size                   = UDim2.new(0, px(26), 1, 0),
        Position               = UDim2.new(0, P_SM, 0, 0),
        BackgroundTransparency = 1,
        Text                   = "🍋",
        TextSize               = F_LOGO,
        Font                   = Enum.Font.GothamBold,
        ZIndex                 = 12,
        Parent                 = titleBar,
    })
    -- Centered title text
    New("TextLabel", {
        Name                   = "TitleLbl",
        Size                   = UDim2.new(1, -px(100), 1, 0),
        Position               = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Text                   = title,
        TextColor3             = T.TextPri,
        TextSize               = F_SEC,
        Font                   = Enum.Font.GothamBold,
        TextXAlignment         = Enum.TextXAlignment.Center,
        ZIndex                 = 12,
        Parent                 = titleBar,
    })

    -- ── Title Buttons ─────────────────────────────────────
    --  IMPORTANT: parented to `win` (NOT clip) so they are NEVER clipped.
    --  They float above everything via ZIndex = 30.
    local BTN_SZ_W = px(26)
    local BTN_SZ_H = px(20)
    local BTN_TOP  = math.floor((TH - BTN_SZ_H) / 2)

    local function MakeTitleBtn(icon, xOff, col)
        local b = New("TextButton", {
            Size             = UDim2.new(0, BTN_SZ_W, 0, BTN_SZ_H),
            Position         = UDim2.new(1, xOff, 0, BTN_TOP),
            BackgroundColor3 = T.SurfaceAlt,
            BorderSizePixel  = 0,
            Text             = icon,
            TextColor3       = col or T.TextPri,
            TextSize         = F_SM,
            Font             = Enum.Font.GothamBold,
            AutoButtonColor  = false,
            ZIndex           = 30,    -- always on top
            Parent           = win,   -- parent = win, not clip
        })
        Crn(CR_XS, b)
        HovFx(b, T.SurfaceAlt, T.SurfaceHov)
        return b
    end
    -- xOff: negative = from right edge of win
    local closeBtn    = MakeTitleBtn("✕", -(BTN_SZ_W + P_XS),          Color3.fromHex("#FF5050"))
    local minimizeBtn = MakeTitleBtn("─", -(BTN_SZ_W*2 + P_XS*2 + 2),  T.TextSec)

    -- ── Body ──────────────────────────────────────────────
    local body = New("Frame", {
        Name                   = "Body",
        Size                   = UDim2.new(1, 0, 1, -TH),
        Position               = UDim2.new(0, 0, 0, TH),
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        ZIndex                 = 5,
        Parent                 = clip,
    })

    -- ── Sidebar ───────────────────────────────────────────
    local sidebar = New("Frame", {
        Name             = "Sidebar",
        Size             = UDim2.new(0, SB_W, 1, 0),
        BackgroundColor3 = T.Sidebar,
        BorderSizePixel  = 0,
        ZIndex           = 6,
        Parent           = body,
    })
    -- Right-edge divider
    New("Frame", {
        Size             = UDim2.new(0, 1, 1, 0),
        Position         = UDim2.new(1, -1, 0, 0),
        BackgroundColor3 = T.Divider,
        BorderSizePixel  = 0,
        ZIndex           = 7,
        Parent           = sidebar,
    })

    -- Scrollable tab list
    local tabScroll = New("ScrollingFrame", {
        Name                 = "TabList",
        Size                 = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel      = 0,
        ScrollBarThickness   = px(3),
        ScrollBarImageColor3 = T.Accent,
        CanvasSize           = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize  = Enum.AutomaticSize.Y,
        ZIndex               = 7,
        Parent               = sidebar,
    })
    VList(px(4), tabScroll)
    Pad(P_XS, P_XS, P_SM, P_SM, tabScroll)

    -- ── Content Area ──────────────────────────────────────
    local contentArea = New("Frame", {
        Name             = "Content",
        Size             = UDim2.new(1, -SB_W, 1, 0),
        Position         = UDim2.new(0, SB_W, 0, 0),
        BackgroundColor3 = T.Surface,
        BorderSizePixel  = 0,
        ClipsDescendants = true,
        ZIndex           = 6,
        Parent           = body,
    })

    -- ── Dragging (safe: tracks specific input object) ─────
    MakeDraggable(titleBar, win)

    -- ══════════════════════════════════════════
    --  DROPLET  (minimized badge)
    --  Size: 80×80 absolute pixels
    -- ══════════════════════════════════════════
    local droplet = New("TextButton", {
        Name             = "Droplet",
        Size             = UDim2.new(0, DROP_SZ, 0, DROP_SZ),
        Position         = UDim2.new(0.5, -DROP_SZ/2, 0.5, -DROP_SZ/2),
        BackgroundColor3 = T.AccentAmber,
        BorderSizePixel  = 0,
        Text             = "🍋",
        TextSize         = F_DROP,
        Font             = Enum.Font.GothamBold,
        AutoButtonColor  = false,
        ZIndex           = 30,
        Visible          = false,
        Parent           = sg,
    })
    Crn(18, droplet)   -- squircle shape
    Strk(T.Black, 3, droplet)
    HovFx(droplet, T.AccentAmber, T.AccentHover)
    MakeDraggable(droplet, droplet)

    -- ══════════════════════════════════════════
    --  OPEN ANIMATION
    --  Step 1: title bar expands left→right (width: 0 → WIN_W, height = TH)
    --  Step 2: body drops down (height: TH → WIN_H)
    -- ══════════════════════════════════════════
    local function PlayOpenAnimation()
        win.Visible          = true
        win.ClipsDescendants = true
        -- Start: only title bar visible (zero width)
        win.Size     = UDim2.new(0, 0, 0, TH)
        win.Position = UDim2.new(0.5, 0, 0.5, -TH/2)

        -- Phase 1: expand title bar width left→right
        Tween(win, {
            Size     = UDim2.new(0, WIN_W, 0, TH),
            Position = UDim2.new(0.5, -WIN_W/2, 0.5, -TH/2),
        }, 0.30, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

        task.delay(0.32, function()
            -- Phase 2: expand height downward (full window)
            Tween(win, {
                Size     = UDim2.new(0, WIN_W, 0, WIN_H),
                Position = UDim2.new(0.5, -WIN_W/2, 0.5, -WIN_H/2),
            }, 0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        end)

        task.delay(0.62, function()
            win.ClipsDescendants = false
        end)
    end

    -- Play immediately on creation
    PlayOpenAnimation()

    -- ══════════════════════════════════════════
    --  MINIMIZE  →  show droplet
    -- ══════════════════════════════════════════
    local minimized = false

    minimizeBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            -- Collapse window
            Tween(win, {
                Size     = UDim2.new(0, WIN_W, 0, 0),
                BackgroundTransparency = 1,
            }, 0.20, Enum.EasingStyle.Quart)
            task.delay(0.21, function()
                win.Visible     = false
                droplet.Visible = true
                droplet.Size    = UDim2.new(0, 0, 0, 0)
                Tween(droplet, { Size = UDim2.new(0, DROP_SZ, 0, DROP_SZ) },
                      0.28, Enum.EasingStyle.Back)
            end)
        else
            -- Restore with full open animation from droplet position
            local dp = droplet.AbsolutePosition
            win.Position = UDim2.new(0, dp.X + DROP_SZ/2 - WIN_W/2, 0, dp.Y)
            Tween(droplet, { Size = UDim2.new(0, 0, 0, 0) }, 0.15)
            task.delay(0.16, function()
                droplet.Visible = false
                win.BackgroundTransparency = 0
                PlayOpenAnimation()
            end)
        end
    end)

    droplet.MouseButton1Click:Connect(function()
        minimized       = false
        local dp = droplet.AbsolutePosition
        win.Position = UDim2.new(0, dp.X + DROP_SZ/2 - WIN_W/2, 0, dp.Y)
        Tween(droplet, { Size = UDim2.new(0, 0, 0, 0) }, 0.15)
        task.delay(0.16, function()
            droplet.Visible = false
            win.BackgroundTransparency = 0
            PlayOpenAnimation()
        end)
    end)

    closeBtn.MouseButton1Click:Connect(function()
        Tween(win, {
            Size = UDim2.new(0, WIN_W, 0, 0),
            BackgroundTransparency = 1,
        }, 0.18)
        task.delay(0.20, function() sg:Destroy() end)
    end)

    -- ══════════════════════════════════════════
    --  TAB SYSTEM
    -- ══════════════════════════════════════════
    local tabs      = {}
    local activeTab = nil

    local function SelectTab(td)
        for _, t in ipairs(tabs) do
            t.Page.Visible = false
            Tween(t.Btn, { BackgroundColor3 = T.TabNormal }, 0.13)
            t.Lbl.TextColor3 = T.TextSec
            Tween(t.Bar, { BackgroundTransparency = 1 }, 0.13)
        end
        td.Page.Visible = true
        Tween(td.Btn, { BackgroundColor3 = T.TabActive }, 0.13)
        td.Lbl.TextColor3 = T.TextAcc
        Tween(td.Bar, { BackgroundTransparency = 0 }, 0.13)
        activeTab = td
    end

    -- ══════════════════════════════════════════
    --  WINDOW OBJECT
    -- ══════════════════════════════════════════
    local Window = {}
    Window.__index = Window

    -- ── CreateTab ────────────────────────────────────────
    function Window:CreateTab(tcfg)
        tcfg = tcfg or {}
        local tName = tcfg.Name or "Tab"
        local tIcon = tcfg.Icon or ""

        -- Tab button
        local tabBtn = New("TextButton", {
            Size             = UDim2.new(1, 0, 0, TAB_H),
            BackgroundColor3 = T.TabNormal,
            BorderSizePixel  = 0,
            Text             = "",
            AutoButtonColor  = false,
            ZIndex           = 8,
            Parent           = tabScroll,
        })
        Crn(CR_SM, tabBtn)

        -- Left accent bar (indicator)
        local bar = New("Frame", {
            Size                   = UDim2.new(0, px(3), 0.56, 0),
            Position               = UDim2.new(0, 0, 0.22, 0),
            BackgroundColor3       = T.Accent,
            BackgroundTransparency = 1,
            BorderSizePixel        = 0,
            ZIndex                 = 9,
            Parent                 = tabBtn,
        })
        Crn(px(3), bar)

        -- Icon
        New("TextLabel", {
            Size                   = UDim2.new(0, px(18), 1, 0),
            Position               = UDim2.new(0, P_SM, 0, 0),
            BackgroundTransparency = 1,
            Text                   = tIcon,
            TextSize               = F_ICON,
            Font                   = Enum.Font.GothamBold,
            ZIndex                 = 9,
            Parent                 = tabBtn,
        })

        -- Name
        local nameLbl = New("TextLabel", {
            Size                   = UDim2.new(1, -px(30), 1, 0),
            Position               = UDim2.new(0, px(26), 0, 0),
            BackgroundTransparency = 1,
            Text                   = tName,
            TextColor3             = T.TextSec,
            TextSize               = F_SM,
            Font                   = Enum.Font.GothamSemibold,
            TextXAlignment         = Enum.TextXAlignment.Left,
            ZIndex                 = 9,
            Parent                 = tabBtn,
        })

        -- Content scroll page
        local page = New("ScrollingFrame", {
            Size                 = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel      = 0,
            ScrollBarThickness   = px(3),
            ScrollBarImageColor3 = T.Accent,
            CanvasSize           = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize  = Enum.AutomaticSize.Y,
            Visible              = false,
            ZIndex               = 7,
            Parent               = contentArea,
        })
        VList(px(5), page)
        Pad(P_SM, P_MD + px(2), P_SM, P_SM, page)

        local td = { Btn = tabBtn, Page = page, Bar = bar, Lbl = nameLbl }
        table.insert(tabs, td)
        if #tabs == 1 then SelectTab(td) end

        tabBtn.MouseButton1Click:Connect(function() SelectTab(td) end)
        HovFx(tabBtn, T.TabNormal, T.TabHov)

        -- ──────────────────────────────────────────
        --  WIDGET FACTORY
        -- ──────────────────────────────────────────
        local function Card(h)
            local c = New("Frame", {
                Size             = UDim2.new(1, 0, 0, h or CARD_H),
                BackgroundColor3 = T.SurfaceAlt,
                BorderSizePixel  = 0,
                ZIndex           = 8,
                Parent           = page,
            })
            Crn(CR_SM, c)
            return c
        end

        local Tab = {}
        Tab.__index = Tab

        -- ── Section ──────────────────────────────
        function Tab:AddSection(name)
            local w = New("Frame", {
                Size                   = UDim2.new(1, 0, 0, px(22)),
                BackgroundTransparency = 1,
                ZIndex                 = 8,
                Parent                 = page,
            })
            New("TextLabel", {
                Size                   = UDim2.new(1, -P_SM, 0, px(14)),
                Position               = UDim2.new(0, P_XS, 0, px(4)),
                BackgroundTransparency = 1,
                Text                   = (name or "Section"):upper(),
                TextColor3             = T.Accent,
                TextSize               = F_XS,
                Font                   = Enum.Font.GothamBold,
                TextXAlignment         = Enum.TextXAlignment.Left,
                ZIndex                 = 9,
                Parent                 = w,
            })
            New("Frame", {
                Size             = UDim2.new(1, -P_XS, 0, 1),
                Position         = UDim2.new(0, P_XS/2, 1, -1),
                BackgroundColor3 = T.Divider,
                BorderSizePixel  = 0,
                ZIndex           = 9,
                Parent           = w,
            })
        end

        -- ── Label ────────────────────────────────
        function Tab:AddLabel(text)
            local c = Card(px(30))
            New("TextLabel", {
                Size                   = UDim2.new(1, -P_MD, 1, 0),
                Position               = UDim2.new(0, P_SM, 0, 0),
                BackgroundTransparency = 1,
                Text                   = text or "",
                TextColor3             = T.TextSec,
                TextSize               = F_SM,
                Font                   = Enum.Font.Gotham,
                TextXAlignment         = Enum.TextXAlignment.Left,
                TextWrapped            = true,
                ZIndex                 = 9,
                Parent                 = c,
            })
        end

        -- ── Paragraph ────────────────────────────
        function Tab:AddParagraph(ptitle, pbody)
            local c = New("Frame", {
                Size             = UDim2.new(1, 0, 0, 0),
                AutomaticSize    = Enum.AutomaticSize.Y,
                BackgroundColor3 = T.SurfaceAlt,
                BorderSizePixel  = 0,
                ZIndex           = 8,
                Parent           = page,
            })
            Crn(CR_SM, c)
            Pad(P_SM, P_SM, P_XS, P_XS, c)
            New("UIListLayout", {
                Padding   = UDim.new(0, px(3)),
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent    = c,
            })
            New("TextLabel", {
                Size                   = UDim2.new(1, 0, 0, px(16)),
                BackgroundTransparency = 1,
                Text                   = ptitle or "",
                TextColor3             = T.TextPri,
                TextSize               = F_SM,
                Font                   = Enum.Font.GothamBold,
                TextXAlignment         = Enum.TextXAlignment.Left,
                ZIndex                 = 9,
                Parent                 = c,
            })
            New("TextLabel", {
                Size                   = UDim2.new(1, 0, 0, 0),
                AutomaticSize          = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Text                   = pbody or "",
                TextColor3             = T.TextSec,
                TextSize               = F_XS,
                Font                   = Enum.Font.Gotham,
                TextXAlignment         = Enum.TextXAlignment.Left,
                TextWrapped            = true,
                ZIndex                 = 9,
                Parent                 = c,
            })
        end

        -- ── Button ───────────────────────────────
        function Tab:AddButton(bcfg)
            bcfg    = bcfg or {}
            local c = Card(CARD_H)
            New("TextLabel", {
                Size                   = UDim2.new(1, -(BTN_W + P_MD*2), 1, 0),
                Position               = UDim2.new(0, P_SM, 0, 0),
                BackgroundTransparency = 1,
                Text                   = bcfg.Name or "Button",
                TextColor3             = T.TextPri,
                TextSize               = F_SM,
                Font                   = Enum.Font.GothamSemibold,
                TextXAlignment         = Enum.TextXAlignment.Left,
                ZIndex                 = 9,
                Parent                 = c,
            })
            local btn = New("TextButton", {
                Size             = UDim2.new(0, BTN_W, 0, BTN_H),
                Position         = UDim2.new(1, -(BTN_W + P_SM), 0.5, -BTN_H/2),
                BackgroundColor3 = T.Accent,
                BorderSizePixel  = 0,
                Text             = "Run",
                TextColor3       = T.Black,
                TextSize         = F_XS,
                Font             = Enum.Font.GothamBold,
                AutoButtonColor  = false,
                ZIndex           = 9,
                Parent           = c,
            })
            Crn(CR_XS, btn)
            btn.MouseButton1Click:Connect(function()
                Tween(btn, { BackgroundColor3 = T.AccentAmber,
                             Size = UDim2.new(0, BTN_W - px(3), 0, BTN_H - px(2)) }, 0.07)
                task.delay(0.12, function()
                    Tween(btn, { BackgroundColor3 = T.Accent,
                                 Size = UDim2.new(0, BTN_W, 0, BTN_H) }, 0.1)
                end)
                if bcfg.Callback then task.spawn(bcfg.Callback) end
            end)
            btn.MouseEnter:Connect(function() Tween(btn,{BackgroundColor3=T.AccentHover},0.1) end)
            btn.MouseLeave:Connect(function() Tween(btn,{BackgroundColor3=T.Accent},0.1) end)
        end

        -- ── Toggle ───────────────────────────────
        function Tab:AddToggle(tcfg2)
            tcfg2   = tcfg2 or {}
            local v = tcfg2.Default == true
            local c = Card(CARD_H)
            New("TextLabel", {
                Size                   = UDim2.new(1, -(TOG_W + P_MD*2), 1, 0),
                Position               = UDim2.new(0, P_SM, 0, 0),
                BackgroundTransparency = 1,
                Text                   = tcfg2.Name or "Toggle",
                TextColor3             = T.TextPri,
                TextSize               = F_SM,
                Font                   = Enum.Font.GothamSemibold,
                TextXAlignment         = Enum.TextXAlignment.Left,
                ZIndex                 = 9,
                Parent                 = c,
            })
            local track = New("Frame", {
                Size             = UDim2.new(0, TOG_W, 0, TOG_H),
                Position         = UDim2.new(1, -(TOG_W + P_SM), 0.5, -TOG_H/2),
                BackgroundColor3 = v and T.ToggleOn or T.ToggleOff,
                BorderSizePixel  = 0,
                ZIndex           = 9,
                Parent           = c,
            })
            Crn(nil, track); track.UICorner.CornerRadius = CRFull

            local kOff = UDim2.new(0, px(3), 0.5, -TOG_K/2)
            local kOn  = UDim2.new(1, -(TOG_K + px(3)), 0.5, -TOG_K/2)
            local knob = New("Frame", {
                Size             = UDim2.new(0, TOG_K, 0, TOG_K),
                Position         = v and kOn or kOff,
                BackgroundColor3 = T.TextPri,
                BorderSizePixel  = 0,
                ZIndex           = 10,
                Parent           = track,
            })
            Crn(nil, knob); knob.UICorner.CornerRadius = CRFull

            -- Invisible hit zone over whole card
            local hit = New("TextButton", {
                Size                   = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text                   = "",
                ZIndex                 = 11,
                Parent                 = c,
            })
            hit.MouseButton1Click:Connect(function()
                v = not v
                Tween(track, { BackgroundColor3 = v and T.ToggleOn or T.ToggleOff }, 0.15)
                Tween(knob,  { Position = v and kOn or kOff }, 0.18, Enum.EasingStyle.Back)
                if tcfg2.Callback then task.spawn(tcfg2.Callback, v) end
            end)
            local ctrl = {}
            function ctrl:Set(val)
                v = val
                Tween(track, { BackgroundColor3 = v and T.ToggleOn or T.ToggleOff }, 0.15)
                Tween(knob,  { Position = v and kOn or kOff }, 0.18, Enum.EasingStyle.Back)
                if tcfg2.Callback then task.spawn(tcfg2.Callback, v) end
            end
            function ctrl:Get() return v end
            return ctrl
        end

        -- ── Slider ───────────────────────────────
        function Tab:AddSlider(scfg)
            scfg    = scfg or {}
            local mn = scfg.Min     or 0
            local mx = scfg.Max     or 100
            local v  = math.clamp(scfg.Default or mn, mn, mx)
            local c  = Card(CARD_SL)

            New("TextLabel", {
                Size                   = UDim2.new(0.55, 0, 0, px(15)),
                Position               = UDim2.new(0, P_SM, 0, P_XS),
                BackgroundTransparency = 1,
                Text                   = scfg.Name or "Slider",
                TextColor3             = T.TextPri,
                TextSize               = F_SM,
                Font                   = Enum.Font.GothamSemibold,
                TextXAlignment         = Enum.TextXAlignment.Left,
                ZIndex                 = 9,
                Parent                 = c,
            })
            local valLbl = New("TextLabel", {
                Size                   = UDim2.new(0.45, -P_SM, 0, px(15)),
                Position               = UDim2.new(0.55, 0, 0, P_XS),
                BackgroundTransparency = 1,
                Text                   = tostring(v),
                TextColor3             = T.Accent,
                TextSize               = F_SM,
                Font                   = Enum.Font.GothamBold,
                TextXAlignment         = Enum.TextXAlignment.Right,
                ZIndex                 = 9,
                Parent                 = c,
            })

            local TRK_Y = px(26)
            local TRK_H = px(5)
            local trackBg = New("Frame", {
                Size             = UDim2.new(1, -(P_SM*2), 0, TRK_H),
                Position         = UDim2.new(0, P_SM, 0, TRK_Y),
                BackgroundColor3 = T.SliderBg,
                BorderSizePixel  = 0,
                ZIndex           = 9,
                Parent           = c,
            })
            Crn(nil, trackBg); trackBg.UICorner.CornerRadius = CRFull

            local p0   = (v - mn) / (mx - mn)
            local fill = New("Frame", {
                Size             = UDim2.new(p0, 0, 1, 0),
                BackgroundColor3 = T.SliderFill,
                BorderSizePixel  = 0,
                ZIndex           = 10,
                Parent           = trackBg,
            })
            Crn(nil, fill); fill.UICorner.CornerRadius = CRFull

            local TK    = px(12)
            local thumb = New("Frame", {
                Size             = UDim2.new(0, TK, 0, TK),
                Position         = UDim2.new(p0, -TK/2, 0.5, -TK/2),
                BackgroundColor3 = T.Accent,
                BorderSizePixel  = 0,
                ZIndex           = 11,
                Parent           = trackBg,
            })
            Crn(nil, thumb); thumb.UICorner.CornerRadius = CRFull
            New("UIStroke", { Color = T.BG, Thickness = px(2), Parent = thumb })

            local sliding = false
            local function Upd(ix)
                local p = math.clamp((ix - trackBg.AbsolutePosition.X) / trackBg.AbsoluteSize.X, 0, 1)
                v = math.floor(mn + (mx - mn) * p)
                valLbl.Text = tostring(v)
                Tween(fill,  { Size     = UDim2.new(p, 0, 1, 0)           }, 0.04)
                Tween(thumb, { Position = UDim2.new(p, -TK/2, 0.5, -TK/2) }, 0.04)
                if scfg.Callback then task.spawn(scfg.Callback, v) end
            end

            trackBg.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1
                or inp.UserInputType == Enum.UserInputType.Touch then
                    sliding = true; Upd(inp.Position.X)
                end
            end)
            UserInputService.InputChanged:Connect(function(inp)
                if not sliding then return end
                if inp.UserInputType == Enum.UserInputType.MouseMovement
                or inp.UserInputType == Enum.UserInputType.Touch then
                    Upd(inp.Position.X)
                end
            end)
            UserInputService.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1
                or inp.UserInputType == Enum.UserInputType.Touch then
                    sliding = false
                end
            end)

            local ctrl = {}
            function ctrl:Set(val)
                v = math.clamp(val, mn, mx)
                local p2 = (v - mn) / (mx - mn)
                valLbl.Text = tostring(v)
                Tween(fill,  { Size     = UDim2.new(p2, 0, 1, 0)            }, 0.1)
                Tween(thumb, { Position = UDim2.new(p2, -TK/2, 0.5, -TK/2)  }, 0.1)
                if scfg.Callback then task.spawn(scfg.Callback, v) end
            end
            function ctrl:Get() return v end
            return ctrl
        end

        -- ── Textbox ──────────────────────────────
        function Tab:AddTextbox(boxcfg)
            boxcfg  = boxcfg or {}
            local c = Card(CARD_TB)

            New("TextLabel", {
                Size                   = UDim2.new(1, -P_MD, 0, px(15)),
                Position               = UDim2.new(0, P_SM, 0, P_XS),
                BackgroundTransparency = 1,
                Text                   = boxcfg.Name or "Textbox",
                TextColor3             = T.TextPri,
                TextSize               = F_SM,
                Font                   = Enum.Font.GothamSemibold,
                TextXAlignment         = Enum.TextXAlignment.Left,
                ZIndex                 = 9,
                Parent                 = c,
            })

            local iFrame = New("Frame", {
                Size             = UDim2.new(1, -(P_SM*2), 0, INP_H),
                Position         = UDim2.new(0, P_SM, 0, px(20)),
                BackgroundColor3 = T.InputBg,
                BorderSizePixel  = 0,
                ZIndex           = 9,
                Parent           = c,
            })
            Crn(CR_XS, iFrame)
            local stroke = Strk(T.InputBorder, 1, iFrame)

            local box = New("TextBox", {
                Size                   = UDim2.new(1, -P_MD, 1, 0),
                Position               = UDim2.new(0, P_XS, 0, 0),
                BackgroundTransparency = 1,
                PlaceholderText        = boxcfg.Placeholder  or "Enter...",
                PlaceholderColor3      = T.TextMute,
                Text                   = boxcfg.Default      or "",
                TextColor3             = T.TextPri,
                TextSize               = F_XS,
                Font                   = Enum.Font.Gotham,
                TextXAlignment         = Enum.TextXAlignment.Left,
                ClearTextOnFocus       = boxcfg.ClearOnFocus ~= false,
                ZIndex                 = 10,
                Parent                 = iFrame,
            })
            box.Focused:Connect(function()   Tween(stroke, { Color = T.InputFocus  }, 0.12) end)
            box.FocusLost:Connect(function(enter)
                Tween(stroke, { Color = T.InputBorder }, 0.12)
                if boxcfg.Callback then task.spawn(boxcfg.Callback, box.Text, enter) end
            end)

            local ctrl = {}
            function ctrl:Set(t) box.Text = t end
            function ctrl:Get() return box.Text end
            return ctrl
        end

        -- ── Dropdown ─────────────────────────────
        function Tab:AddDropdown(dcfg)
            dcfg    = dcfg or {}
            local opts = dcfg.Options or {}
            local sel  = dcfg.Default or (opts[1] or "")
            local open = false

            local c = Card(CARD_H)
            c.ClipsDescendants = false
            c.ZIndex           = 12

            New("TextLabel", {
                Size                   = UDim2.new(1, -(DD_W + P_MD*2), 1, 0),
                Position               = UDim2.new(0, P_SM, 0, 0),
                BackgroundTransparency = 1,
                Text                   = dcfg.Name or "Dropdown",
                TextColor3             = T.TextPri,
                TextSize               = F_SM,
                Font                   = Enum.Font.GothamSemibold,
                TextXAlignment         = Enum.TextXAlignment.Left,
                ZIndex                 = 13,
                Parent                 = c,
            })

            local DDH = px(21)
            local selBtn = New("TextButton", {
                Size             = UDim2.new(0, DD_W, 0, DDH),
                Position         = UDim2.new(1, -(DD_W + P_SM), 0.5, -DDH/2),
                BackgroundColor3 = T.InputBg,
                BorderSizePixel  = 0,
                Text             = "",
                AutoButtonColor  = false,
                ZIndex           = 13,
                Parent           = c,
            })
            Crn(CR_XS, selBtn)
            Strk(T.InputBorder, 1, selBtn)

            local selLbl = New("TextLabel", {
                Size                   = UDim2.new(1, -px(14), 1, 0),
                Position               = UDim2.new(0, P_XS, 0, 0),
                BackgroundTransparency = 1,
                Text                   = sel,
                TextColor3             = T.TextPri,
                TextSize               = F_XS,
                Font                   = Enum.Font.Gotham,
                TextXAlignment         = Enum.TextXAlignment.Left,
                TextTruncate           = Enum.TextTruncate.AtEnd,
                ZIndex                 = 14,
                Parent                 = selBtn,
            })
            local arrow = New("TextLabel", {
                Size                   = UDim2.new(0, px(11), 1, 0),
                Position               = UDim2.new(1, -px(12), 0, 0),
                BackgroundTransparency = 1,
                Text                   = "▾",
                TextColor3             = T.Accent,
                TextSize               = F_XS,
                Font                   = Enum.Font.GothamBold,
                ZIndex                 = 14,
                Parent                 = selBtn,
            })

            -- Dropdown list in sg (avoids all clipping)
            local listH   = math.min(#opts, 5) * DD_ROW
            local listFrm = New("Frame", {
                Size             = UDim2.new(0, DD_W, 0, 0),
                BackgroundColor3 = T.SurfaceHov,
                BorderSizePixel  = 0,
                ClipsDescendants = true,
                ZIndex           = 60,
                Visible          = false,
                Parent           = sg,
            })
            Crn(CR_XS, listFrm)
            Strk(T.InputBorder, 1, listFrm)

            local listScroll = New("ScrollingFrame", {
                Size                 = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                BorderSizePixel      = 0,
                ScrollBarThickness   = px(3),
                ScrollBarImageColor3 = T.Accent,
                CanvasSize           = UDim2.new(0, 0, 0, 0),
                AutomaticCanvasSize  = Enum.AutomaticSize.Y,
                ZIndex               = 61,
                Parent               = listFrm,
            })
            VList(0, listScroll)

            for _, opt in ipairs(opts) do
                local ob = New("TextButton", {
                    Size             = UDim2.new(1, 0, 0, DD_ROW),
                    BackgroundColor3 = T.SurfaceHov,
                    BorderSizePixel  = 0,
                    Text             = opt,
                    TextColor3       = T.TextPri,
                    TextSize         = F_XS,
                    Font             = Enum.Font.Gotham,
                    AutoButtonColor  = false,
                    ZIndex           = 62,
                    Parent           = listScroll,
                })
                HovFx(ob, T.SurfaceHov, T.SurfaceAlt)
                ob.MouseButton1Click:Connect(function()
                    sel = opt; selLbl.Text = opt
                    open = false
                    Tween(arrow,  { Rotation = 0 }, 0.12)
                    Tween(listFrm,{ Size = UDim2.new(0, DD_W, 0, 0) }, 0.12)
                    task.delay(0.13, function() listFrm.Visible = false end)
                    if dcfg.Callback then task.spawn(dcfg.Callback, opt) end
                end)
            end

            local function PosDD()
                local ap = selBtn.AbsolutePosition
                local as = selBtn.AbsoluteSize
                listFrm.Position = UDim2.new(0, ap.X, 0, ap.Y + as.Y + px(3))
                listFrm.Size     = UDim2.new(0, as.X, 0, 0)
            end

            selBtn.MouseButton1Click:Connect(function()
                open = not open; PosDD()
                if open then
                    listFrm.Visible = true
                    Tween(arrow,  { Rotation = 180 }, 0.12)
                    Tween(listFrm,{ Size = UDim2.new(0, DD_W, 0, listH) }, 0.15, Enum.EasingStyle.Back)
                else
                    Tween(arrow,  { Rotation = 0 }, 0.12)
                    Tween(listFrm,{ Size = UDim2.new(0, DD_W, 0, 0) }, 0.12)
                    task.delay(0.13, function() listFrm.Visible = false end)
                end
            end)

            local ctrl = {}
            function ctrl:Set(v2) sel = v2; selLbl.Text = v2; if dcfg.Callback then task.spawn(dcfg.Callback, v2) end end
            function ctrl:Get() return sel end
            return ctrl
        end

        -- ── Keybind ──────────────────────────────
        function Tab:AddKeybind(kcfg)
            kcfg    = kcfg or {}
            local bound     = kcfg.Default or Enum.KeyCode.Unknown
            local listening = false
            local c = Card(CARD_H)

            New("TextLabel", {
                Size                   = UDim2.new(1, -(KB_W + P_MD*2), 1, 0),
                Position               = UDim2.new(0, P_SM, 0, 0),
                BackgroundTransparency = 1,
                Text                   = kcfg.Name or "Keybind",
                TextColor3             = T.TextPri,
                TextSize               = F_SM,
                Font                   = Enum.Font.GothamSemibold,
                TextXAlignment         = Enum.TextXAlignment.Left,
                ZIndex                 = 9,
                Parent                 = c,
            })

            local kBtn = New("TextButton", {
                Size             = UDim2.new(0, KB_W, 0, BTN_H),
                Position         = UDim2.new(1, -(KB_W + P_SM), 0.5, -BTN_H/2),
                BackgroundColor3 = T.InputBg,
                BorderSizePixel  = 0,
                Text             = bound == Enum.KeyCode.Unknown and "None" or bound.Name,
                TextColor3       = T.Accent,
                TextSize         = F_XS,
                Font             = Enum.Font.GothamBold,
                AutoButtonColor  = false,
                ZIndex           = 9,
                Parent           = c,
            })
            Crn(CR_XS, kBtn)
            Strk(T.InputBorder, 1, kBtn)

            kBtn.MouseButton1Click:Connect(function()
                listening = true
                kBtn.Text = "..."
                kBtn.TextColor3 = T.TextSec
            end)
            UserInputService.InputBegan:Connect(function(inp, gpe)
                if listening and inp.UserInputType == Enum.UserInputType.Keyboard then
                    listening = false
                    bound     = inp.KeyCode
                    kBtn.Text = inp.KeyCode.Name
                    kBtn.TextColor3 = T.Accent
                elseif not listening and not gpe
                   and inp.UserInputType == Enum.UserInputType.Keyboard
                   and inp.KeyCode == bound then
                    if kcfg.Callback then task.spawn(kcfg.Callback) end
                end
            end)

            local ctrl = {}
            function ctrl:Set(k) bound = k; kBtn.Text = k.Name end
            function ctrl:Get() return bound end
            return ctrl
        end

        return Tab
    end -- CreateTab

    -- ── Notify toast ──────────────────────────────────────
    function Window:Notify(ncfg)
        ncfg = ncfg or {}
        local nf = New("Frame", {
            Size             = UDim2.new(0, NOTIF_W, 0, NOTIF_H),
            Position         = UDim2.new(1, px(10), 1, -(NOTIF_H + px(10))),
            BackgroundColor3 = T.Surface,
            BorderSizePixel  = 0,
            ZIndex           = 100,
            Parent           = sg,
        })
        Crn(CR_SM, nf)
        Strk(T.Accent, 1, nf)
        New("TextLabel", {
            Size                   = UDim2.new(1, -P_MD, 0, px(17)),
            Position               = UDim2.new(0, P_SM, 0, P_XS),
            BackgroundTransparency = 1,
            Text                   = ncfg.Title   or "Notification",
            TextColor3             = T.Accent,
            TextSize               = F_SM,
            Font                   = Enum.Font.GothamBold,
            TextXAlignment         = Enum.TextXAlignment.Left,
            ZIndex                 = 101,
            Parent                 = nf,
        })
        New("TextLabel", {
            Size                   = UDim2.new(1, -P_MD, 0, px(18)),
            Position               = UDim2.new(0, P_SM, 0, px(20)),
            BackgroundTransparency = 1,
            Text                   = ncfg.Content or "",
            TextColor3             = T.TextSec,
            TextSize               = F_XS,
            Font                   = Enum.Font.Gotham,
            TextXAlignment         = Enum.TextXAlignment.Left,
            TextWrapped            = true,
            ZIndex                 = 101,
            Parent                 = nf,
        })
        Tween(nf, { Position = UDim2.new(1, -(NOTIF_W + px(10)), 1, -(NOTIF_H + px(10))) },
              0.28, Enum.EasingStyle.Back)
        task.delay(ncfg.Duration or 3.5, function()
            Tween(nf, { Position = UDim2.new(1, px(10), 1, -(NOTIF_H + px(10))) }, 0.2)
            task.delay(0.22, function() nf:Destroy() end)
        end)
    end

    function Window:Toggle()
        if win.Visible then
            Tween(win, { Size = UDim2.new(0, WIN_W, 0, 0), BackgroundTransparency = 1 }, 0.18)
            task.delay(0.19, function() win.Visible = false end)
        else
            win.BackgroundTransparency = 0
            PlayOpenAnimation()
        end
    end

    setmetatable(Window, Window)
    return Window
end

setmetatable(Library, Library)
return Library
