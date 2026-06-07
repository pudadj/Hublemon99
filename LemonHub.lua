--[[
╔══════════════════════════════════════════════════════╗
║          LemonHub UI Library  v2.1.0                 ║
║          Scale : 65%  (442 × 299)                    ║
║          Author: JoshuaLee                           ║
╚══════════════════════════════════════════════════════╝
  100% reference → 65% actual
  Window  : 680×460  → 442×299
  TitleH  : 44       → 29
  Sidebar : 160      → 104
  TabBtn  : 38       → 25
  CardH   : 40       → 26
  SliderH : 62       → 40
  TextBox : 62       → 40
  FontPri : 13       → 8
  FontSec : 12       → 8
  FontSm  : 11       → 7
  FontAcc : 10       → 7
]]

-- ═══════════════════════════════════════════════
--  SERVICES
-- ═══════════════════════════════════════════════
local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui          = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- ═══════════════════════════════════════════════
--  SCALE CONSTANT  (change this to resize all)
-- ═══════════════════════════════════════════════
local S = 0.65  -- 65%

-- Integer-safe scale helper
local function px(n) return math.round(n * S) end

-- ═══════════════════════════════════════════════
--  THEME
-- ═══════════════════════════════════════════════
local T = {
    Accent      = Color3.fromHex("#FFD800"),
    AccentAmber = Color3.fromHex("#FFB300"),
    AccentHover = Color3.fromHex("#FFE566"),
    AccentGreen = Color3.fromHex("#00FF2A"),

    BG          = Color3.fromHex("#111111"),
    Surface     = Color3.fromHex("#1A1A1A"),
    SurfaceAlt  = Color3.fromHex("#202020"),
    SurfaceHov  = Color3.fromHex("#2A2A2A"),
    TitleBG     = Color3.fromHex("#0C0C0C"),

    Sidebar     = Color3.fromHex("#141414"),
    TabNormal   = Color3.fromHex("#181818"),
    TabHov      = Color3.fromHex("#222222"),
    TabActive   = Color3.fromHex("#222222"),

    TextPri     = Color3.fromHex("#FFFFFF"),
    TextSec     = Color3.fromHex("#AAAAAA"),
    TextAcc     = Color3.fromHex("#FFD800"),
    TextMute    = Color3.fromHex("#555555"),

    ToggleOn    = Color3.fromHex("#FFD800"),
    ToggleOff   = Color3.fromHex("#333333"),
    SliderFill  = Color3.fromHex("#FFD800"),
    SliderBg    = Color3.fromHex("#2A2A2A"),
    InputBg     = Color3.fromHex("#161616"),
    InputBorder = Color3.fromHex("#2E2E2E"),
    InputFocus  = Color3.fromHex("#FFD800"),
    Divider     = Color3.fromHex("#242424"),
    Black       = Color3.fromHex("#000000"),
}

-- Scaled corner radii
local CR     = UDim.new(0, px(8))
local CRSm   = UDim.new(0, px(5))
local CRFull = UDim.new(1, 0)

-- ═══════════════════════════════════════════════
--  HELPERS
-- ═══════════════════════════════════════════════
local function Tween(obj, props, t, style, dir)
    TweenService:Create(obj,
        TweenInfo.new(t or 0.18,
            style or Enum.EasingStyle.Quad,
            dir   or Enum.EasingDirection.Out),
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

local function Corner(r, p)
    New("UICorner", { CornerRadius = r or CR, Parent = p })
end

local function Pad(l, r, t, b, p)
    New("UIPadding", {
        PaddingLeft   = UDim.new(0, l),
        PaddingRight  = UDim.new(0, r),
        PaddingTop    = UDim.new(0, t),
        PaddingBottom = UDim.new(0, b),
        Parent        = p,
    })
end

local function List(gap, ha, p)
    New("UIListLayout", {
        Padding             = UDim.new(0, gap or 0),
        HorizontalAlignment = ha or Enum.HorizontalAlignment.Left,
        SortOrder           = Enum.SortOrder.LayoutOrder,
        Parent              = p,
    })
end

local function Stroke(col, thick, p)
    return New("UIStroke", {
        Color     = col   or T.InputBorder,
        Thickness = thick or 1,
        Parent    = p,
    })
end

local function HoverFx(btn, norm, hov)
    btn.MouseEnter:Connect(function() Tween(btn, { BackgroundColor3 = hov  }, 0.12) end)
    btn.MouseLeave:Connect(function() Tween(btn, { BackgroundColor3 = norm }, 0.12) end)
end

local function MakeDraggable(handle, target)
    local dragging, dragStart, startPos
    handle.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = inp.Position
            startPos  = target.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement
                      or inp.UserInputType == Enum.UserInputType.Touch) then
            local d = inp.Position - dragStart
            target.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- ═══════════════════════════════════════════════
--  SCALED LAYOUT CONSTANTS
-- ═══════════════════════════════════════════════
-- Base (100%)  →  Scaled (65%)
local WIN_W     = px(680)   -- 442
local WIN_H     = px(460)   -- 299
local TITLE_H   = px(44)    -- 29
local SIDEBAR_W = px(160)   -- 104
local TAB_H     = px(38)    -- 25
local CARD_H    = px(40)    -- 26
local CARD_SL   = px(62)    -- 40   (slider card)
local CARD_TB   = px(62)    -- 40   (textbox card)
local BTN_W     = px(76)    -- 49
local BTN_H     = px(26)    -- 17
local TOG_W     = px(46)    -- 30
local TOG_H     = px(24)    -- 16
local TOG_KNOB  = px(18)    -- 12
local INP_H     = px(28)    -- 18
local KB_W      = px(92)    -- 60
local DD_BTN_W  = px(106)   -- 69
local DD_ROW_H  = px(30)    -- 20
local DROP_W    = px(35)    -- 250   (droplet badge)
local DROP_H    = px(35)    -- 250
local NOTIF_W   = px(290)   -- 189
local NOTIF_H   = px(64)    -- 42

-- Font sizes
local FS_PRI  = px(13)      -- 8
local FS_SEC  = px(12)      -- 8
local FS_SM   = px(11)      -- 7
local FS_XS   = px(10)      -- 7
local FS_ICON = px(16)      -- 10
local FS_LOGO = px(20)      -- 13
local FS_DROP = px(28)      -- 18

-- Padding values
local PAD_LG  = px(12)      -- 8
local PAD_MD  = px(10)      -- 7
local PAD_SM  = px(8)       -- 5
local PAD_XS  = px(6)       -- 4
local PAD_TAB = px(14)      -- 9

-- ═══════════════════════════════════════════════
--  LIBRARY
-- ═══════════════════════════════════════════════
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

    -- ── Window ────────────────────────────────────────────
    local win = New("Frame", {
        Name             = "Window",
        Size             = UDim2.new(0, WIN_W, 0, WIN_H),
        Position         = UDim2.new(0.5, -WIN_W/2, 0.5, -WIN_H/2),
        BackgroundColor3 = T.BG,
        BorderSizePixel  = 0,
        ClipsDescendants = false,
        Parent           = sg,
    })
    Corner(UDim.new(0, px(10)), win)
    Stroke(T.Accent, 1, win)

    -- Shadow
    local shadow = New("Frame", {
        Name                   = "Shadow",
        Size                   = UDim2.new(1, px(20), 1, px(20)),
        Position               = UDim2.new(0, -px(10), 0, -px(3)),
        BackgroundColor3       = T.Black,
        BackgroundTransparency = 0.55,
        BorderSizePixel        = 0,
        ZIndex                 = 0,
        Parent                 = win,
    })
    Corner(UDim.new(0, px(14)), shadow)

    -- Clip frame (inner, clips body content)
    local clip = New("Frame", {
        Name                   = "Clip",
        Size                   = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        ClipsDescendants       = true,
        ZIndex                 = 1,
        Parent                 = win,
    })
    Corner(UDim.new(0, px(10)), clip)

    -- ── Title Bar ─────────────────────────────────────────
    local titleBar = New("Frame", {
        Name             = "TitleBar",
        Size             = UDim2.new(1, 0, 0, TITLE_H),
        BackgroundColor3 = T.TitleBG,
        BorderSizePixel  = 0,
        ZIndex           = 10,
        Parent           = clip,
    })
    -- Gold bottom line
    New("Frame", {
        Size             = UDim2.new(1, 0, 0, 1),
        Position         = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = T.Accent,
        BorderSizePixel  = 0,
        ZIndex           = 11,
        Parent           = titleBar,
    })
    -- 🍋 icon
    New("TextLabel", {
        Size                   = UDim2.new(0, px(24), 1, 0),
        Position               = UDim2.new(0, px(8), 0, 0),
        BackgroundTransparency = 1,
        Text                   = "🍋",
        TextSize               = FS_LOGO,
        Font                   = Enum.Font.GothamBold,
        ZIndex                 = 11,
        Parent                 = titleBar,
    })
    -- Title (centered)
    New("TextLabel", {
        Name                   = "Title",
        Size                   = UDim2.new(1, -px(90), 1, 0),
        Position               = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Text                   = title,
        TextColor3             = T.TextPri,
        TextSize               = FS_PRI,
        Font                   = Enum.Font.GothamBold,
        TextXAlignment         = Enum.TextXAlignment.Center,
        ZIndex                 = 11,
        Parent                 = titleBar,
    })

    -- ── Title Buttons (parented to win to avoid clip) ─────
    local function MakeTitleBtn(icon, xOff, col)
        local b = New("TextButton", {
            Size             = UDim2.new(0, px(28), 0, px(22)),
            Position         = UDim2.new(1, xOff, 0, math.floor((TITLE_H - px(22)) / 2)),
            BackgroundColor3 = T.SurfaceAlt,
            BorderSizePixel  = 0,
            Text             = icon,
            TextColor3       = col or T.TextPri,
            TextSize         = FS_PRI,
            Font             = Enum.Font.GothamBold,
            AutoButtonColor  = false,
            ZIndex           = 20,
            Parent           = win,  -- NOT clip → never clipped
        })
        Corner(UDim.new(0, px(4)), b)
        HoverFx(b, T.SurfaceAlt, T.SurfaceHov)
        return b
    end
    local closeBtn    = MakeTitleBtn("✕", -px(8),  Color3.fromHex("#FF5555"))
    local minimizeBtn = MakeTitleBtn("─", -px(42), T.TextSec)

    -- ── Body ──────────────────────────────────────────────
    local body = New("Frame", {
        Name                   = "Body",
        Size                   = UDim2.new(1, 0, 1, -TITLE_H),
        Position               = UDim2.new(0, 0, 0, TITLE_H),
        BackgroundTransparency = 1,
        BorderSizePixel        = 0,
        ZIndex                 = 5,
        Parent                 = clip,
    })

    -- ── Sidebar ───────────────────────────────────────────
    local sidebar = New("Frame", {
        Name             = "Sidebar",
        Size             = UDim2.new(0, SIDEBAR_W, 1, 0),
        BackgroundColor3 = T.Sidebar,
        BorderSizePixel  = 0,
        ZIndex           = 6,
        Parent           = body,
    })
    New("Frame", {   -- divider line
        Size             = UDim2.new(0, 1, 1, 0),
        Position         = UDim2.new(1, -1, 0, 0),
        BackgroundColor3 = T.Divider,
        BorderSizePixel  = 0,
        ZIndex           = 7,
        Parent           = sidebar,
    })

    -- Scrollable tab list
    local tabScroll = New("ScrollingFrame", {
        Name                 = "TabScroll",
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
    List(px(4), Enum.HorizontalAlignment.Center, tabScroll)
    Pad(PAD_XS, PAD_XS, PAD_SM, PAD_SM, tabScroll)

    -- ── Content area ──────────────────────────────────────
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

    -- ── Drag ──────────────────────────────────────────────
    MakeDraggable(titleBar, win)

    -- ── Droplet (minimized badge) ─────────────────────────
    local droplet = New("TextButton", {
        Name             = "Droplet",
        Size             = UDim2.new(0, DROP_W, 0, DROP_H),
        Position         = UDim2.new(0.5, -DROP_W/2, 0.5, -DROP_H/2),
        BackgroundColor3 = T.AccentAmber,
        BorderSizePixel  = 0,
        Text             = "🍋",
        TextSize         = FS_DROP,
        Font             = Enum.Font.GothamBold,
        AutoButtonColor  = false,
        ZIndex           = 30,
        Visible          = false,
        Parent           = sg,
    })
    Corner(UDim.new(0, px(10)), droplet)
    Stroke(T.Black, 2, droplet)
    HoverFx(droplet, T.AccentAmber, T.AccentHover)
    MakeDraggable(droplet, droplet)

    -- ── Minimize / Restore / Close ────────────────────────
    local minimized = false

    minimizeBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            Tween(win, { Size = UDim2.new(0, WIN_W, 0, 0), BackgroundTransparency = 1 },
                  0.2, Enum.EasingStyle.Quart)
            task.delay(0.21, function()
                win.Visible     = false
                droplet.Visible = true
                droplet.Size    = UDim2.new(0, 0, 0, 0)
                Tween(droplet, { Size = UDim2.new(0, DROP_W, 0, DROP_H) },
                      0.25, Enum.EasingStyle.Back)
            end)
        else
            droplet.Visible = false
            win.Visible     = true
            win.Size        = UDim2.new(0, WIN_W, 0, 0)
            win.BackgroundTransparency = 0
            Tween(win, { Size = UDim2.new(0, WIN_W, 0, WIN_H) },
                  0.25, Enum.EasingStyle.Back)
        end
    end)

    droplet.MouseButton1Click:Connect(function()
        minimized       = false
        droplet.Visible = false
        win.Visible     = true
        win.Size        = UDim2.new(0, WIN_W, 0, 0)
        win.BackgroundTransparency = 0
        Tween(win, { Size = UDim2.new(0, WIN_W, 0, WIN_H) },
              0.25, Enum.EasingStyle.Back)
    end)

    closeBtn.MouseButton1Click:Connect(function()
        Tween(win, { Size = UDim2.new(0, WIN_W, 0, 0), BackgroundTransparency = 1 }, 0.18)
        task.delay(0.2, function() sg:Destroy() end)
    end)

    -- ═══════════════════════════════════════════
    --  TAB SYSTEM
    -- ═══════════════════════════════════════════
    local tabs      = {}
    local activeTab = nil

    local function SelectTab(td)
        for _, t in ipairs(tabs) do
            t.Page.Visible                      = false
            Tween(t.Button, { BackgroundColor3 = T.TabNormal }, 0.13)
            t.NameLabel.TextColor3              = T.TextSec
            t.Indicator.BackgroundTransparency  = 1
        end
        td.Page.Visible = true
        Tween(td.Button, { BackgroundColor3 = T.TabActive }, 0.13)
        td.NameLabel.TextColor3 = T.TextAcc
        Tween(td.Indicator, { BackgroundTransparency = 0 }, 0.13)
        activeTab = td
    end

    -- ═══════════════════════════════════════════
    --  WINDOW OBJECT
    -- ═══════════════════════════════════════════
    local Window = {}
    Window.__index = Window

    -- ── CreateTab ────────────────────────────────────────
    function Window:CreateTab(tcfg)
        tcfg = tcfg or {}
        local tName = tcfg.Name or "Tab"
        local tIcon = tcfg.Icon or ""

        -- Tab button
        local tabBtn = New("TextButton", {
            Name             = "Tab_" .. tName,
            Size             = UDim2.new(1, 0, 0, TAB_H),
            BackgroundColor3 = T.TabNormal,
            BorderSizePixel  = 0,
            Text             = "",
            AutoButtonColor  = false,
            ZIndex           = 8,
            Parent           = tabScroll,
        })
        Corner(UDim.new(0, px(6)), tabBtn)

        -- Left accent indicator bar
        local indicator = New("Frame", {
            Size                   = UDim2.new(0, px(3), 0.55, 0),
            Position               = UDim2.new(0, 0, 0.225, 0),
            BackgroundColor3       = T.Accent,
            BackgroundTransparency = 1,
            BorderSizePixel        = 0,
            ZIndex                 = 9,
            Parent                 = tabBtn,
        })
        Corner(UDim.new(0, px(3)), indicator)

        -- Icon
        New("TextLabel", {
            Size                   = UDim2.new(0, px(20), 1, 0),
            Position               = UDim2.new(0, px(8), 0, 0),
            BackgroundTransparency = 1,
            Text                   = tIcon,
            TextSize               = FS_ICON,
            Font                   = Enum.Font.GothamBold,
            ZIndex                 = 9,
            Parent                 = tabBtn,
        })

        -- Name label
        local nameLabel = New("TextLabel", {
            Name                   = "Name",
            Size                   = UDim2.new(1, -px(32), 1, 0),
            Position               = UDim2.new(0, px(28), 0, 0),
            BackgroundTransparency = 1,
            Text                   = tName,
            TextColor3             = T.TextSec,
            TextSize               = FS_PRI,
            Font                   = Enum.Font.GothamSemibold,
            TextXAlignment         = Enum.TextXAlignment.Left,
            ZIndex                 = 9,
            Parent                 = tabBtn,
        })

        -- Content page (scrollable)
        local page = New("ScrollingFrame", {
            Name                 = "Page_" .. tName,
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
        List(px(5), Enum.HorizontalAlignment.Center, page)
        Pad(PAD_SM, PAD_TAB, PAD_SM, PAD_SM, page)

        -- Register
        local td = {
            Name      = tName,
            Button    = tabBtn,
            Page      = page,
            Indicator = indicator,
            NameLabel = nameLabel,
        }
        table.insert(tabs, td)
        if #tabs == 1 then SelectTab(td) end

        tabBtn.MouseButton1Click:Connect(function() SelectTab(td) end)
        HoverFx(tabBtn, T.TabNormal, T.TabHov)

        -- ─────────────────────────────────────────
        --  WIDGET FACTORY (scoped to this tab/page)
        -- ─────────────────────────────────────────
        local function BaseCard(h)
            local c = New("Frame", {
                Size             = UDim2.new(1, 0, 0, h or CARD_H),
                BackgroundColor3 = T.SurfaceAlt,
                BorderSizePixel  = 0,
                ZIndex           = 8,
                Parent           = page,
            })
            Corner(CR, c)
            return c
        end

        local Tab = {}
        Tab.__index = Tab

        -- ── Section ─────────────────────────────────────
        function Tab:AddSection(name)
            local w = New("Frame", {
                Size                   = UDim2.new(1, 0, 0, px(20)),
                BackgroundTransparency = 1,
                ZIndex                 = 8,
                Parent                 = page,
            })
            New("TextLabel", {
                Size                   = UDim2.new(1, -px(6), 1, -px(4)),
                Position               = UDim2.new(0, px(3), 0, px(2)),
                BackgroundTransparency = 1,
                Text                   = (name or "Section"):upper(),
                TextColor3             = T.Accent,
                TextSize               = FS_XS,
                Font                   = Enum.Font.GothamBold,
                TextXAlignment         = Enum.TextXAlignment.Left,
                ZIndex                 = 9,
                Parent                 = w,
            })
            New("Frame", {
                Size             = UDim2.new(1, -px(3), 0, 1),
                Position         = UDim2.new(0, px(2), 1, -1),
                BackgroundColor3 = T.Divider,
                BorderSizePixel  = 0,
                ZIndex           = 9,
                Parent           = w,
            })
        end

        -- ── Label ────────────────────────────────────────
        function Tab:AddLabel(text)
            local c = BaseCard(px(28))
            New("TextLabel", {
                Size                   = UDim2.new(1, -PAD_LG, 1, 0),
                Position               = UDim2.new(0, PAD_SM, 0, 0),
                BackgroundTransparency = 1,
                Text                   = text or "",
                TextColor3             = T.TextSec,
                TextSize               = FS_SEC,
                Font                   = Enum.Font.Gotham,
                TextXAlignment         = Enum.TextXAlignment.Left,
                TextWrapped            = true,
                ZIndex                 = 9,
                Parent                 = c,
            })
        end

        -- ── Paragraph ────────────────────────────────────
        function Tab:AddParagraph(ptitle, pbody)
            local c = New("Frame", {
                Size             = UDim2.new(1, 0, 0, 0),
                AutomaticSize    = Enum.AutomaticSize.Y,
                BackgroundColor3 = T.SurfaceAlt,
                BorderSizePixel  = 0,
                ZIndex           = 8,
                Parent           = page,
            })
            Corner(CR, c)
            Pad(PAD_SM, PAD_SM, PAD_XS, PAD_XS, c)
            List(px(3), Enum.HorizontalAlignment.Left, c)
            New("TextLabel", {
                Size                   = UDim2.new(1, 0, 0, px(16)),
                BackgroundTransparency = 1,
                Text                   = ptitle or "",
                TextColor3             = T.TextPri,
                TextSize               = FS_PRI,
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
                TextSize               = FS_SEC,
                Font                   = Enum.Font.Gotham,
                TextXAlignment         = Enum.TextXAlignment.Left,
                TextWrapped            = true,
                ZIndex                 = 9,
                Parent                 = c,
            })
        end

        -- ── Button ───────────────────────────────────────
        function Tab:AddButton(bcfg)
            bcfg    = bcfg or {}
            local c = BaseCard(CARD_H)

            New("TextLabel", {
                Size                   = UDim2.new(1, -(BTN_W + PAD_LG*2), 1, 0),
                Position               = UDim2.new(0, PAD_SM, 0, 0),
                BackgroundTransparency = 1,
                Text                   = bcfg.Name or "Button",
                TextColor3             = T.TextPri,
                TextSize               = FS_PRI,
                Font                   = Enum.Font.GothamSemibold,
                TextXAlignment         = Enum.TextXAlignment.Left,
                ZIndex                 = 9,
                Parent                 = c,
            })

            local btn = New("TextButton", {
                Size             = UDim2.new(0, BTN_W, 0, BTN_H),
                Position         = UDim2.new(1, -(BTN_W + PAD_SM), 0.5, -BTN_H/2),
                BackgroundColor3 = T.Accent,
                BorderSizePixel  = 0,
                Text             = "Run",
                TextColor3       = T.Black,
                TextSize         = FS_SEC,
                Font             = Enum.Font.GothamBold,
                AutoButtonColor  = false,
                ZIndex           = 9,
                Parent           = c,
            })
            Corner(UDim.new(0, px(5)), btn)

            btn.MouseButton1Click:Connect(function()
                Tween(btn, { BackgroundColor3 = T.AccentAmber,
                             Size = UDim2.new(0, BTN_W - px(4), 0, BTN_H - px(2)) }, 0.07)
                task.delay(0.12, function()
                    Tween(btn, { BackgroundColor3 = T.Accent,
                                 Size = UDim2.new(0, BTN_W, 0, BTN_H) }, 0.1)
                end)
                if bcfg.Callback then task.spawn(bcfg.Callback) end
            end)
            btn.MouseEnter:Connect(function() Tween(btn, { BackgroundColor3 = T.AccentHover }, 0.1) end)
            btn.MouseLeave:Connect(function() Tween(btn, { BackgroundColor3 = T.Accent },      0.1) end)
        end

        -- ── Toggle ───────────────────────────────────────
        function Tab:AddToggle(tcfg2)
            tcfg2   = tcfg2 or {}
            local v = tcfg2.Default == true
            local c = BaseCard(CARD_H)

            New("TextLabel", {
                Size                   = UDim2.new(1, -(TOG_W + PAD_LG*2), 1, 0),
                Position               = UDim2.new(0, PAD_SM, 0, 0),
                BackgroundTransparency = 1,
                Text                   = tcfg2.Name or "Toggle",
                TextColor3             = T.TextPri,
                TextSize               = FS_PRI,
                Font                   = Enum.Font.GothamSemibold,
                TextXAlignment         = Enum.TextXAlignment.Left,
                ZIndex                 = 9,
                Parent                 = c,
            })

            local track = New("Frame", {
                Size             = UDim2.new(0, TOG_W, 0, TOG_H),
                Position         = UDim2.new(1, -(TOG_W + PAD_SM), 0.5, -TOG_H/2),
                BackgroundColor3 = v and T.ToggleOn or T.ToggleOff,
                BorderSizePixel  = 0,
                ZIndex           = 9,
                Parent           = c,
            })
            Corner(CRFull, track)

            local knobOff = UDim2.new(0, px(3), 0.5, -TOG_KNOB/2)
            local knobOn  = UDim2.new(1, -(TOG_KNOB + px(3)), 0.5, -TOG_KNOB/2)

            local knob = New("Frame", {
                Size             = UDim2.new(0, TOG_KNOB, 0, TOG_KNOB),
                Position         = v and knobOn or knobOff,
                BackgroundColor3 = T.TextPri,
                BorderSizePixel  = 0,
                ZIndex           = 10,
                Parent           = track,
            })
            Corner(CRFull, knob)

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
                Tween(knob,  { Position = v and knobOn or knobOff }, 0.18, Enum.EasingStyle.Back)
                if tcfg2.Callback then task.spawn(tcfg2.Callback, v) end
            end)

            local ctrl = {}
            function ctrl:Set(val)
                v = val
                Tween(track, { BackgroundColor3 = v and T.ToggleOn or T.ToggleOff }, 0.15)
                Tween(knob,  { Position = v and knobOn or knobOff }, 0.18, Enum.EasingStyle.Back)
                if tcfg2.Callback then task.spawn(tcfg2.Callback, v) end
            end
            function ctrl:Get() return v end
            return ctrl
        end

        -- ── Slider ───────────────────────────────────────
        function Tab:AddSlider(scfg)
            scfg    = scfg or {}
            local mn = scfg.Min     or 0
            local mx = scfg.Max     or 100
            local v  = math.clamp(scfg.Default or mn, mn, mx)
            local c  = BaseCard(CARD_SL)

            New("TextLabel", {
                Size                   = UDim2.new(0.58, 0, 0, px(16)),
                Position               = UDim2.new(0, PAD_SM, 0, PAD_XS),
                BackgroundTransparency = 1,
                Text                   = scfg.Name or "Slider",
                TextColor3             = T.TextPri,
                TextSize               = FS_PRI,
                Font                   = Enum.Font.GothamSemibold,
                TextXAlignment         = Enum.TextXAlignment.Left,
                ZIndex                 = 9,
                Parent                 = c,
            })
            local valLbl = New("TextLabel", {
                Size                   = UDim2.new(0.42, -PAD_SM, 0, px(16)),
                Position               = UDim2.new(0.58, 0, 0, PAD_XS),
                BackgroundTransparency = 1,
                Text                   = tostring(v),
                TextColor3             = T.Accent,
                TextSize               = FS_PRI,
                Font                   = Enum.Font.GothamBold,
                TextXAlignment         = Enum.TextXAlignment.Right,
                ZIndex                 = 9,
                Parent                 = c,
            })

            local TRACK_Y = px(28)
            local trackBg = New("Frame", {
                Size             = UDim2.new(1, -PAD_LG*2, 0, px(5)),
                Position         = UDim2.new(0, PAD_SM, 0, TRACK_Y),
                BackgroundColor3 = T.SliderBg,
                BorderSizePixel  = 0,
                ZIndex           = 9,
                Parent           = c,
            })
            Corner(CRFull, trackBg)

            local pct0 = (v - mn) / (mx - mn)
            local fill = New("Frame", {
                Size             = UDim2.new(pct0, 0, 1, 0),
                BackgroundColor3 = T.SliderFill,
                BorderSizePixel  = 0,
                ZIndex           = 10,
                Parent           = trackBg,
            })
            Corner(CRFull, fill)

            local TH = px(12)
            local thumb = New("Frame", {
                Size             = UDim2.new(0, TH, 0, TH),
                Position         = UDim2.new(pct0, -TH/2, 0.5, -TH/2),
                BackgroundColor3 = T.Accent,
                BorderSizePixel  = 0,
                ZIndex           = 11,
                Parent           = trackBg,
            })
            Corner(CRFull, thumb)
            New("UIStroke", { Color = T.BG, Thickness = px(2), Parent = thumb })

            local sliding = false
            local function Upd(ix)
                local p = math.clamp((ix - trackBg.AbsolutePosition.X) / trackBg.AbsoluteSize.X, 0, 1)
                v = math.floor(mn + (mx - mn) * p)
                valLbl.Text = tostring(v)
                Tween(fill,  { Size     = UDim2.new(p, 0, 1, 0)      }, 0.04)
                Tween(thumb, { Position = UDim2.new(p, -TH/2, 0.5, -TH/2) }, 0.04)
                if scfg.Callback then task.spawn(scfg.Callback, v) end
            end
            trackBg.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1
                or inp.UserInputType == Enum.UserInputType.Touch then
                    sliding = true; Upd(inp.Position.X)
                end
            end)
            UserInputService.InputChanged:Connect(function(inp)
                if sliding and (inp.UserInputType == Enum.UserInputType.MouseMovement
                             or inp.UserInputType == Enum.UserInputType.Touch) then
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
                Tween(fill,  { Size     = UDim2.new(p2, 0, 1, 0)           }, 0.1)
                Tween(thumb, { Position = UDim2.new(p2, -TH/2, 0.5, -TH/2) }, 0.1)
                if scfg.Callback then task.spawn(scfg.Callback, v) end
            end
            function ctrl:Get() return v end
            return ctrl
        end

        -- ── Textbox ──────────────────────────────────────
        function Tab:AddTextbox(boxcfg)
            boxcfg  = boxcfg or {}
            local c = BaseCard(CARD_TB)

            New("TextLabel", {
                Size                   = UDim2.new(1, -PAD_LG, 0, px(16)),
                Position               = UDim2.new(0, PAD_SM, 0, PAD_XS),
                BackgroundTransparency = 1,
                Text                   = boxcfg.Name or "Textbox",
                TextColor3             = T.TextPri,
                TextSize               = FS_PRI,
                Font                   = Enum.Font.GothamSemibold,
                TextXAlignment         = Enum.TextXAlignment.Left,
                ZIndex                 = 9,
                Parent                 = c,
            })

            local inputF = New("Frame", {
                Size             = UDim2.new(1, -PAD_LG*2, 0, INP_H),
                Position         = UDim2.new(0, PAD_SM, 0, px(20)),
                BackgroundColor3 = T.InputBg,
                BorderSizePixel  = 0,
                ZIndex           = 9,
                Parent           = c,
            })
            Corner(UDim.new(0, px(5)), inputF)
            local stroke = Stroke(T.InputBorder, 1, inputF)

            New("TextBox", {
                Size                   = UDim2.new(1, -PAD_LG, 1, 0),
                Position               = UDim2.new(0, PAD_XS, 0, 0),
                BackgroundTransparency = 1,
                PlaceholderText        = boxcfg.Placeholder  or "Enter text...",
                PlaceholderColor3      = T.TextMute,
                Text                   = boxcfg.Default      or "",
                TextColor3             = T.TextPri,
                TextSize               = FS_SEC,
                Font                   = Enum.Font.Gotham,
                TextXAlignment         = Enum.TextXAlignment.Left,
                ClearTextOnFocus       = boxcfg.ClearOnFocus ~= false,
                ZIndex                 = 10,
                Parent                 = inputF,
            }):GetPropertyChangedSignal("Text"):Connect(function() end)

            -- store ref to box for events
            local box = inputF:FindFirstChildOfClass("TextBox")
            if box then
                box.Focused:Connect(function()
                    Tween(stroke, { Color = T.InputFocus  }, 0.13)
                end)
                box.FocusLost:Connect(function(enter)
                    Tween(stroke, { Color = T.InputBorder }, 0.13)
                    if boxcfg.Callback then task.spawn(boxcfg.Callback, box.Text, enter) end
                end)
            end

            local ctrl = {}
            function ctrl:Set(t)  if box then box.Text = t end end
            function ctrl:Get()   return box and box.Text or "" end
            return ctrl
        end

        -- ── Dropdown ─────────────────────────────────────
        function Tab:AddDropdown(dcfg)
            dcfg    = dcfg or {}
            local opts = dcfg.Options or {}
            local sel  = dcfg.Default or (opts[1] or "")
            local open = false

            local c = BaseCard(CARD_H)
            c.ClipsDescendants = false
            c.ZIndex           = 12

            New("TextLabel", {
                Size                   = UDim2.new(1, -(DD_BTN_W + PAD_LG*2), 1, 0),
                Position               = UDim2.new(0, PAD_SM, 0, 0),
                BackgroundTransparency = 1,
                Text                   = dcfg.Name or "Dropdown",
                TextColor3             = T.TextPri,
                TextSize               = FS_PRI,
                Font                   = Enum.Font.GothamSemibold,
                TextXAlignment         = Enum.TextXAlignment.Left,
                ZIndex                 = 13,
                Parent                 = c,
            })

            local selBtn = New("TextButton", {
                Size             = UDim2.new(0, DD_BTN_W, 0, px(22)),
                Position         = UDim2.new(1, -(DD_BTN_W + PAD_SM), 0.5, -px(11)),
                BackgroundColor3 = T.InputBg,
                BorderSizePixel  = 0,
                Text             = "",
                AutoButtonColor  = false,
                ZIndex           = 13,
                Parent           = c,
            })
            Corner(UDim.new(0, px(5)), selBtn)
            Stroke(T.InputBorder, 1, selBtn)

            local selLbl = New("TextLabel", {
                Size                   = UDim2.new(1, -px(16), 1, 0),
                Position               = UDim2.new(0, PAD_XS, 0, 0),
                BackgroundTransparency = 1,
                Text                   = sel,
                TextColor3             = T.TextPri,
                TextSize               = FS_SEC,
                Font                   = Enum.Font.Gotham,
                TextXAlignment         = Enum.TextXAlignment.Left,
                TextTruncate           = Enum.TextTruncate.AtEnd,
                ZIndex                 = 14,
                Parent                 = selBtn,
            })
            local arrow = New("TextLabel", {
                Size                   = UDim2.new(0, px(12), 1, 0),
                Position               = UDim2.new(1, -px(13), 0, 0),
                BackgroundTransparency = 1,
                Text                   = "▾",
                TextColor3             = T.Accent,
                TextSize               = FS_SM,
                Font                   = Enum.Font.GothamBold,
                ZIndex                 = 14,
                Parent                 = selBtn,
            })

            -- Dropdown list in ScreenGui (avoids clip)
            local listH = math.min(#opts, 6) * DD_ROW_H
            local listFrame = New("Frame", {
                Size             = UDim2.new(0, DD_BTN_W, 0, 0),
                BackgroundColor3 = T.SurfaceHov,
                BorderSizePixel  = 0,
                ClipsDescendants = true,
                ZIndex           = 50,
                Visible          = false,
                Parent           = sg,
            })
            Corner(UDim.new(0, px(5)), listFrame)
            Stroke(T.InputBorder, 1, listFrame)

            local listScroll = New("ScrollingFrame", {
                Size                 = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                BorderSizePixel      = 0,
                ScrollBarThickness   = px(3),
                ScrollBarImageColor3 = T.Accent,
                CanvasSize           = UDim2.new(0, 0, 0, 0),
                AutomaticCanvasSize  = Enum.AutomaticSize.Y,
                ZIndex               = 51,
                Parent               = listFrame,
            })
            List(0, Enum.HorizontalAlignment.Center, listScroll)

            for _, opt in ipairs(opts) do
                local ob = New("TextButton", {
                    Size             = UDim2.new(1, 0, 0, DD_ROW_H),
                    BackgroundColor3 = T.SurfaceHov,
                    BorderSizePixel  = 0,
                    Text             = opt,
                    TextColor3       = T.TextPri,
                    TextSize         = FS_SEC,
                    Font             = Enum.Font.Gotham,
                    AutoButtonColor  = false,
                    ZIndex           = 52,
                    Parent           = listScroll,
                })
                HoverFx(ob, T.SurfaceHov, T.SurfaceAlt)
                ob.MouseButton1Click:Connect(function()
                    sel = opt; selLbl.Text = opt
                    open = false
                    Tween(arrow,     { Rotation = 0 }, 0.13)
                    Tween(listFrame, { Size = UDim2.new(0, DD_BTN_W, 0, 0) }, 0.13)
                    task.delay(0.14, function() listFrame.Visible = false end)
                    if dcfg.Callback then task.spawn(dcfg.Callback, opt) end
                end)
            end

            local function PosDD()
                local ap = selBtn.AbsolutePosition
                local as = selBtn.AbsoluteSize
                listFrame.Position = UDim2.new(0, ap.X, 0, ap.Y + as.Y + px(3))
                listFrame.Size     = UDim2.new(0, as.X, 0, 0)
            end

            selBtn.MouseButton1Click:Connect(function()
                open = not open
                PosDD()
                if open then
                    listFrame.Visible = true
                    Tween(arrow,     { Rotation = 180 }, 0.13)
                    Tween(listFrame, { Size = UDim2.new(0, DD_BTN_W, 0, listH) }, 0.15, Enum.EasingStyle.Back)
                else
                    Tween(arrow,     { Rotation = 0 }, 0.13)
                    Tween(listFrame, { Size = UDim2.new(0, DD_BTN_W, 0, 0) }, 0.13)
                    task.delay(0.14, function() listFrame.Visible = false end)
                end
            end)

            local ctrl = {}
            function ctrl:Set(v2)
                sel = v2; selLbl.Text = v2
                if dcfg.Callback then task.spawn(dcfg.Callback, v2) end
            end
            function ctrl:Get() return sel end
            return ctrl
        end

        -- ── Keybind ──────────────────────────────────────
        function Tab:AddKeybind(kcfg)
            kcfg    = kcfg or {}
            local bound     = kcfg.Default or Enum.KeyCode.Unknown
            local listening = false
            local c = BaseCard(CARD_H)

            New("TextLabel", {
                Size                   = UDim2.new(1, -(KB_W + PAD_LG*2), 1, 0),
                Position               = UDim2.new(0, PAD_SM, 0, 0),
                BackgroundTransparency = 1,
                Text                   = kcfg.Name or "Keybind",
                TextColor3             = T.TextPri,
                TextSize               = FS_PRI,
                Font                   = Enum.Font.GothamSemibold,
                TextXAlignment         = Enum.TextXAlignment.Left,
                ZIndex                 = 9,
                Parent                 = c,
            })

            local kBtn = New("TextButton", {
                Size             = UDim2.new(0, KB_W, 0, BTN_H),
                Position         = UDim2.new(1, -(KB_W + PAD_SM), 0.5, -BTN_H/2),
                BackgroundColor3 = T.InputBg,
                BorderSizePixel  = 0,
                Text             = bound == Enum.KeyCode.Unknown and "None" or bound.Name,
                TextColor3       = T.Accent,
                TextSize         = FS_SM,
                Font             = Enum.Font.GothamBold,
                AutoButtonColor  = false,
                ZIndex           = 9,
                Parent           = c,
            })
            Corner(UDim.new(0, px(5)), kBtn)
            Stroke(T.InputBorder, 1, kBtn)

            kBtn.MouseButton1Click:Connect(function()
                listening      = true
                kBtn.Text      = "..."
                kBtn.TextColor3 = T.TextSec
            end)
            UserInputService.InputBegan:Connect(function(inp, gpe)
                if listening and inp.UserInputType == Enum.UserInputType.Keyboard then
                    listening       = false
                    bound           = inp.KeyCode
                    kBtn.Text       = inp.KeyCode.Name
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

    -- ── Notify ────────────────────────────────────────────
    function Window:Notify(ncfg)
        ncfg    = ncfg or {}
        local nf = New("Frame", {
            Size             = UDim2.new(0, NOTIF_W, 0, NOTIF_H),
            Position         = UDim2.new(1, px(10), 1, -(NOTIF_H + px(10))),
            BackgroundColor3 = T.Surface,
            BorderSizePixel  = 0,
            ZIndex           = 100,
            Parent           = sg,
        })
        Corner(UDim.new(0, px(7)), nf)
        Stroke(T.Accent, 1, nf)
        New("TextLabel", {
            Size                   = UDim2.new(1, -PAD_LG, 0, px(18)),
            Position               = UDim2.new(0, PAD_SM, 0, PAD_XS),
            BackgroundTransparency = 1,
            Text                   = ncfg.Title   or "Notification",
            TextColor3             = T.Accent,
            TextSize               = FS_PRI,
            Font                   = Enum.Font.GothamBold,
            TextXAlignment         = Enum.TextXAlignment.Left,
            ZIndex                 = 101,
            Parent                 = nf,
        })
        New("TextLabel", {
            Size                   = UDim2.new(1, -PAD_LG, 0, px(20)),
            Position               = UDim2.new(0, PAD_SM, 0, px(22)),
            BackgroundTransparency = 1,
            Text                   = ncfg.Content or "",
            TextColor3             = T.TextSec,
            TextSize               = FS_SEC,
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
        win.Visible = not win.Visible
    end

    setmetatable(Window, Window)
    return Window
end

setmetatable(Library, Library)
return Library
