--[[
    ██╗     ███████╗███╗   ███╗ ██████╗ ███╗   ██╗██╗  ██╗██╗   ██╗██████╗
    ██║     ██╔════╝████╗ ████║██╔═══██╗████╗  ██║██║  ██║██║   ██║██╔══██╗
    ██║     █████╗  ██╔████╔██║██║   ██║██╔██╗ ██║███████║██║   ██║██████╔╝
    ██║     ██╔══╝  ██║╚██╔╝██║██║   ██║██║╚██╗██║██╔══██║██║   ██║██╔══██╗
    ███████╗███████╗██║ ╚═╝ ██║╚██████╔╝██║ ╚████║██║  ██║╚██████╔╝██████╔╝
    ╚══════╝╚══════╝╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═╝ ╚═════╝ ╚═════╝

    LemonHub UI Library v1.0.0
    Author  : LemonHub Framework
    License : MIT
    Desc    : A clean, modern Roblox UI Library inspired by Rayfield/Fluent/Linoria
              with a lemon-themed color palette.

    USAGE EXAMPLE:
    ──────────────
    local Library = loadstring(game:HttpGet("..."))()

    local Window = Library:CreateWindow({
        Title = "LemonHub | Freemium | PUDADJ",
        SubTitle = "v1.0.0",
    })

    local Tab = Window:CreateTab({ Name = "Main", Icon = "🍋" })

    Tab:AddButton({ Name = "Click Me", Callback = function() print("Hello!") end })
    Tab:AddToggle({ Name = "God Mode", Default = false, Callback = function(v) end })
    Tab:AddSlider({ Name = "WalkSpeed", Min = 16, Max = 100, Default = 16, Callback = function(v) end })
    Tab:AddTextbox({ Name = "Player", Placeholder = "Enter name...", Callback = function(t) end })
    Tab:AddDropdown({ Name = "Fruit", Options = {"Apple","Lemon","Orange"}, Callback = function(v) end })
    Tab:AddKeybind({ Name = "Toggle GUI", Default = Enum.KeyCode.RightShift, Callback = function() end })
    Tab:AddSection("Info")
    Tab:AddLabel("Welcome to LemonHub!")
    Tab:AddParagraph("About", "This is a free UI library.")
]]

-- ══════════════════════════════════════════════════════════════
--  SERVICES
-- ══════════════════════════════════════════════════════════════
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui          = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Mouse       = LocalPlayer:GetMouse()

-- ══════════════════════════════════════════════════════════════
--  THEME
-- ══════════════════════════════════════════════════════════════
local Theme = {
    -- Primary palette
    Accent        = Color3.fromHex("#FFD800"),   -- Lemon yellow
    AccentSecond  = Color3.fromHex("#FFB300"),   -- Amber
    AccentGreen   = Color3.fromHex("#00FF2A"),   -- Lime green
    AccentHover   = Color3.fromHex("#FFE566"),   -- Light lemon

    -- Backgrounds
    Background    = Color3.fromHex("#131313"),   -- Near-black
    Surface       = Color3.fromHex("#1C1C1C"),   -- Card bg
    SurfaceAlt    = Color3.fromHex("#242424"),   -- Slightly lighter
    SurfaceHover  = Color3.fromHex("#2C2C2C"),   -- Hover bg
    TitleBar      = Color3.fromHex("#0E0E0E"),   -- Title bg

    -- Sidebar
    Sidebar       = Color3.fromHex("#161616"),
    TabSelected   = Color3.fromHex("#FFD800"),
    TabDefault    = Color3.fromHex("#1C1C1C"),
    TabHover      = Color3.fromHex("#2A2A2A"),

    -- Text
    TextPrimary   = Color3.fromHex("#FFFFFF"),
    TextSecond    = Color3.fromHex("#AAAAAA"),
    TextAccent    = Color3.fromHex("#FFD800"),
    TextMuted     = Color3.fromHex("#666666"),

    -- Controls
    Toggle_On     = Color3.fromHex("#FFD800"),
    Toggle_Off    = Color3.fromHex("#3A3A3A"),
    SliderFill    = Color3.fromHex("#FFD800"),
    SliderBg      = Color3.fromHex("#2E2E2E"),
    InputBg       = Color3.fromHex("#1A1A1A"),
    InputBorder   = Color3.fromHex("#333333"),
    InputFocus    = Color3.fromHex("#FFD800"),
    Divider       = Color3.fromHex("#2A2A2A"),
    Shadow        = Color3.fromHex("#000000"),
    ButtonBg      = Color3.fromHex("#222222"),
    ButtonHover   = Color3.fromHex("#2E2E2E"),

    -- Misc
    CornerRadius  = UDim.new(0, 8),
    CornerSmall   = UDim.new(0, 5),
    CornerFull    = UDim.new(1, 0),
}

-- ══════════════════════════════════════════════════════════════
--  UTILITY HELPERS
-- ══════════════════════════════════════════════════════════════
local function Tween(obj, props, duration, style, direction)
    style     = style     or Enum.EasingStyle.Quad
    direction = direction or Enum.EasingDirection.Out
    local info = TweenInfo.new(duration or 0.2, style, direction)
    TweenService:Create(obj, info, props):Play()
end

local function Create(class, props, children)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then
            inst[k] = v
        end
    end
    for _, child in ipairs(children or {}) do
        child.Parent = inst
    end
    if props and props.Parent then
        inst.Parent = props.Parent
    end
    return inst
end

local function Corner(radius, parent)
    return Create("UICorner", { CornerRadius = radius or Theme.CornerRadius, Parent = parent })
end

local function Stroke(color, thickness, parent)
    return Create("UIStroke", {
        Color     = color or Theme.InputBorder,
        Thickness = thickness or 1,
        Parent    = parent,
    })
end

local function Shadow(parent, size, transparency)
    local s = Create("ImageLabel", {
        Name              = "Shadow",
        AnchorPoint       = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position          = UDim2.new(0.5, 0, 0.5, 4),
        Size              = UDim2.new(1, size or 20, 1, size or 20),
        ZIndex            = parent.ZIndex - 1,
        Image             = "rbxassetid://6014261993",
        ImageColor3       = Theme.Shadow,
        ImageTransparency = transparency or 0.5,
        ScaleType         = Enum.ScaleType.Slice,
        SliceCenter       = Rect.new(49, 49, 450, 450),
        Parent            = parent,
    })
    return s
end

local function HoverEffect(btn, normalColor, hoverColor)
    btn.MouseEnter:Connect(function()
        Tween(btn, { BackgroundColor3 = hoverColor }, 0.15)
    end)
    btn.MouseLeave:Connect(function()
        Tween(btn, { BackgroundColor3 = normalColor }, 0.15)
    end)
end

-- ══════════════════════════════════════════════════════════════
--  LIBRARY TABLE
-- ══════════════════════════════════════════════════════════════
local Library = {}
Library.__index = Library

-- ══════════════════════════════════════════════════════════════
--  CreateWindow
-- ══════════════════════════════════════════════════════════════
function Library:CreateWindow(config)
    config = config or {}
    local title    = config.Title    or "LemonHub | Freemium | PUDADJ"
    local subTitle = config.SubTitle or ""
    local size     = config.Size     or UDim2.new(0, 620, 0, 420)

    -- ── Root ScreenGui ────────────────────────────────────────
    local screenGui = Create("ScreenGui", {
        Name                  = "LemonHubUI",
        ResetOnSpawn          = false,
        ZIndexBehavior        = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset        = true,
    })

    -- Try to parent to CoreGui (executor), fall back to PlayerGui
    local ok = pcall(function() screenGui.Parent = CoreGui end)
    if not ok then
        screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    -- ── Main Window Frame ─────────────────────────────────────
    local windowFrame = Create("Frame", {
        Name             = "WindowFrame",
        Size             = size,
        Position         = UDim2.new(0.5, -310, 0.5, -210),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel  = 0,
        ClipsDescendants = true,
        Parent           = screenGui,
    })
    Corner(UDim.new(0, 10), windowFrame)
    Shadow(windowFrame, 30, 0.35)

    -- Outer accent stroke
    Stroke(Theme.Accent, 1.5, windowFrame)

    -- ── Title Bar ────────────────────────────────────────────
    local titleBar = Create("Frame", {
        Name             = "TitleBar",
        Size             = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = Theme.TitleBar,
        BorderSizePixel  = 0,
        ZIndex           = 3,
        Parent           = windowFrame,
    })
    -- Bottom border for title bar
    Create("Frame", {
        Size             = UDim2.new(1, 0, 0, 1),
        Position         = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel  = 0,
        ZIndex           = 4,
        Parent           = titleBar,
    })

    -- Lemon emoji icon
    Create("TextLabel", {
        Name             = "Icon",
        Size             = UDim2.new(0, 30, 1, 0),
        Position         = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text             = "🍋",
        TextSize         = 20,
        Font             = Enum.Font.GothamBold,
        ZIndex           = 4,
        Parent           = titleBar,
    })

    -- Title text
    Create("TextLabel", {
        Name             = "Title",
        Size             = UDim2.new(1, -120, 1, 0),
        Position         = UDim2.new(0, 44, 0, 0),
        BackgroundTransparency = 1,
        Text             = title,
        TextColor3       = Theme.TextPrimary,
        TextSize         = 14,
        Font             = Enum.Font.GothamBold,
        TextXAlignment   = Enum.TextXAlignment.Left,
        ZIndex           = 4,
        Parent           = titleBar,
    })

    -- ── Title Bar Buttons ──────────────────────────────────────
    local function MakeTitleBtn(icon, xPos, accentColor)
        local btn = Create("TextButton", {
            Size             = UDim2.new(0, 28, 0, 22),
            Position         = UDim2.new(1, xPos, 0.5, -11),
            BackgroundColor3 = Theme.SurfaceAlt,
            BorderSizePixel  = 0,
            Text             = icon,
            TextColor3       = accentColor or Theme.TextPrimary,
            TextSize         = 13,
            Font             = Enum.Font.GothamBold,
            ZIndex           = 5,
            Parent           = titleBar,
        })
        Corner(UDim.new(0, 5), btn)
        HoverEffect(btn, Theme.SurfaceAlt, Theme.SurfaceHover)
        return btn
    end

    local closeBtn    = MakeTitleBtn("✕", -10, Color3.fromHex("#FF4444"))
    local minimizeBtn = MakeTitleBtn("─", -42, Theme.TextSecond)

    -- ── Body (sidebar + content) ─────────────────────────────
    local body = Create("Frame", {
        Name             = "Body",
        Size             = UDim2.new(1, 0, 1, -42),
        Position         = UDim2.new(0, 0, 0, 42),
        BackgroundTransparency = 1,
        Parent           = windowFrame,
    })

    -- ── Sidebar ───────────────────────────────────────────────
    local sidebar = Create("Frame", {
        Name             = "Sidebar",
        Size             = UDim2.new(0, 150, 1, 0),
        BackgroundColor3 = Theme.Sidebar,
        BorderSizePixel  = 0,
        Parent           = body,
    })
    -- Right divider
    Create("Frame", {
        Size             = UDim2.new(0, 1, 1, 0),
        Position         = UDim2.new(1, -1, 0, 0),
        BackgroundColor3 = Theme.Divider,
        BorderSizePixel  = 0,
        Parent           = sidebar,
    })

    local tabListLayout = Create("UIListLayout", {
        Padding          = UDim.new(0, 4),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder        = Enum.SortOrder.LayoutOrder,
        Parent           = sidebar,
    })
    Create("UIPadding", {
        PaddingTop    = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 8),
        PaddingLeft   = UDim.new(0, 6),
        PaddingRight  = UDim.new(0, 6),
        Parent        = sidebar,
    })

    -- ── Content Area ──────────────────────────────────────────
    local contentArea = Create("Frame", {
        Name             = "ContentArea",
        Size             = UDim2.new(1, -150, 1, 0),
        Position         = UDim2.new(0, 150, 0, 0),
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel  = 0,
        ClipsDescendants = true,
        Parent           = body,
    })

    -- ── Dragging ─────────────────────────────────────────────
    do
        local dragging, dragStart, startPos
        titleBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                dragging  = true
                dragStart = input.Position
                startPos  = windowFrame.Position
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
                          or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                windowFrame.Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
    end

    -- ── Minimize / Close ─────────────────────────────────────
    local minimized = false
    minimizeBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            Tween(windowFrame, { Size = UDim2.new(0, 620, 0, 42) }, 0.25, Enum.EasingStyle.Quart)
        else
            Tween(windowFrame, { Size = size }, 0.25, Enum.EasingStyle.Quart)
        end
    end)
    closeBtn.MouseButton1Click:Connect(function()
        Tween(windowFrame, { Size = UDim2.new(0, 620, 0, 0) }, 0.2)
        task.delay(0.22, function() screenGui:Destroy() end)
    end)

    -- ══════════════════════════════════════════════════════════
    --  Tab system state
    -- ══════════════════════════════════════════════════════════
    local tabs       = {}
    local activeTab  = nil

    local function SetActiveTab(tabData)
        -- Hide all pages, deselect all buttons
        for _, t in ipairs(tabs) do
            t.Page.Visible = false
            -- Deselect tab button
            Tween(t.Button, { BackgroundColor3 = Theme.TabDefault }, 0.15)
            t.Button.TextLabel.TextColor3 = Theme.TextSecond
            if t.Indicator then
                Tween(t.Indicator, { BackgroundTransparency = 1 }, 0.15)
            end
        end
        -- Show selected
        tabData.Page.Visible = true
        Tween(tabData.Button, { BackgroundColor3 = Theme.SurfaceAlt }, 0.15)
        tabData.Button.TextLabel.TextColor3 = Theme.TextAccent
        if tabData.Indicator then
            Tween(tabData.Indicator, { BackgroundTransparency = 0 }, 0.15)
        end
        activeTab = tabData
    end

    -- ══════════════════════════════════════════════════════════
    --  Window Object
    -- ══════════════════════════════════════════════════════════
    local Window = {}
    Window.__index = Window

    -- ── CreateTab ────────────────────────────────────────────
    function Window:CreateTab(cfg)
        cfg = cfg or {}
        local name = cfg.Name or "Tab"
        local icon = cfg.Icon or ""

        -- ── Tab Button ─────────────────────────────────────
        local tabBtn = Create("TextButton", {
            Name             = "TabBtn_"..name,
            Size             = UDim2.new(1, 0, 0, 36),
            BackgroundColor3 = Theme.TabDefault,
            BorderSizePixel  = 0,
            Text             = "",
            AutoButtonColor  = false,
            ZIndex           = 2,
            Parent           = sidebar,
        })
        Corner(UDim.new(0, 7), tabBtn)

        -- Left accent indicator
        local indicator = Create("Frame", {
            Name             = "Indicator",
            Size             = UDim2.new(0, 3, 0.6, 0),
            Position         = UDim2.new(0, 0, 0.2, 0),
            BackgroundColor3 = Theme.Accent,
            BackgroundTransparency = 1,
            BorderSizePixel  = 0,
            ZIndex           = 3,
            Parent           = tabBtn,
        })
        Corner(UDim.new(0, 3), indicator)

        -- Icon label
        Create("TextLabel", {
            Name             = "IconLabel",
            Size             = UDim2.new(0, 24, 1, 0),
            Position         = UDim2.new(0, 10, 0, 0),
            BackgroundTransparency = 1,
            Text             = icon,
            TextSize         = 16,
            Font             = Enum.Font.GothamBold,
            ZIndex           = 3,
            Parent           = tabBtn,
        })

        -- Name label
        local nameLabel = Create("TextLabel", {
            Name             = "TextLabel",
            Size             = UDim2.new(1, -36, 1, 0),
            Position         = UDim2.new(0, 34, 0, 0),
            BackgroundTransparency = 1,
            Text             = name,
            TextColor3       = Theme.TextSecond,
            TextSize         = 13,
            Font             = Enum.Font.GothamSemibold,
            TextXAlignment   = Enum.TextXAlignment.Left,
            ZIndex           = 3,
            Parent           = tabBtn,
        })

        -- ── Tab Page (scroll frame) ─────────────────────────
        local page = Create("ScrollingFrame", {
            Name                 = "Page_"..name,
            Size                 = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel      = 0,
            ScrollBarThickness   = 4,
            ScrollBarImageColor3 = Theme.Accent,
            CanvasSize           = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize  = Enum.AutomaticSize.Y,
            Visible              = false,
            Parent               = contentArea,
        })
        Create("UIListLayout", {
            Padding          = UDim.new(0, 6),
            SortOrder        = Enum.SortOrder.LayoutOrder,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            Parent           = page,
        })
        Create("UIPadding", {
            PaddingTop    = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 10),
            PaddingLeft   = UDim.new(0, 10),
            PaddingRight  = UDim.new(0, 14),
            Parent        = page,
        })

        -- Register tab
        local tabData = {
            Name      = name,
            Button    = tabBtn,
            Page      = page,
            Indicator = indicator,
        }
        table.insert(tabs, tabData)

        -- Auto-select first tab
        if #tabs == 1 then
            SetActiveTab(tabData)
        end

        -- Click handler
        tabBtn.MouseButton1Click:Connect(function()
            SetActiveTab(tabData)
        end)
        HoverEffect(tabBtn, Theme.TabDefault, Theme.TabHover)

        -- ══════════════════════════════════════════════════
        --  Tab content helper
        -- ══════════════════════════════════════════════════
        local function MakeBaseCard(heightOffset)
            local card = Create("Frame", {
                Size             = UDim2.new(1, 0, 0, heightOffset or 40),
                BackgroundColor3 = Theme.SurfaceAlt,
                BorderSizePixel  = 0,
                Parent           = page,
            })
            Corner(Theme.CornerRadius, card)
            return card
        end

        local Tab = {}
        Tab.__index = Tab

        -- ── AddSection ───────────────────────────────────
        function Tab:AddSection(sectionName)
            local wrap = Create("Frame", {
                Size             = UDim2.new(1, 0, 0, 24),
                BackgroundTransparency = 1,
                Parent           = page,
            })
            Create("TextLabel", {
                Size             = UDim2.new(1, -8, 1, 0),
                Position         = UDim2.new(0, 4, 0, 0),
                BackgroundTransparency = 1,
                Text             = sectionName or "Section",
                TextColor3       = Theme.Accent,
                TextSize         = 11,
                Font             = Enum.Font.GothamBold,
                TextXAlignment   = Enum.TextXAlignment.Left,
                Parent           = wrap,
            })
            -- Divider line
            Create("Frame", {
                Size             = UDim2.new(1, -4, 0, 1),
                Position         = UDim2.new(0, 2, 1, -1),
                BackgroundColor3 = Theme.Divider,
                BorderSizePixel  = 0,
                Parent           = wrap,
            })
        end

        -- ── AddLabel ─────────────────────────────────────
        function Tab:AddLabel(text)
            local card = MakeBaseCard(34)
            Create("TextLabel", {
                Size             = UDim2.new(1, -16, 1, 0),
                Position         = UDim2.new(0, 12, 0, 0),
                BackgroundTransparency = 1,
                Text             = text or "Label",
                TextColor3       = Theme.TextSecond,
                TextSize         = 13,
                Font             = Enum.Font.Gotham,
                TextXAlignment   = Enum.TextXAlignment.Left,
                TextWrapped      = true,
                Parent           = card,
            })
        end

        -- ── AddParagraph ──────────────────────────────────
        function Tab:AddParagraph(title, body)
            local card = MakeBaseCard(60)
            card.AutomaticSize = Enum.AutomaticSize.Y
            Create("UIPadding", {
                PaddingTop    = UDim.new(0, 8),
                PaddingBottom = UDim.new(0, 8),
                PaddingLeft   = UDim.new(0, 12),
                PaddingRight  = UDim.new(0, 12),
                Parent        = card,
            })
            Create("UIListLayout", {
                Padding   = UDim.new(0, 4),
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent    = card,
            })
            Create("TextLabel", {
                Size             = UDim2.new(1, 0, 0, 18),
                BackgroundTransparency = 1,
                Text             = title or "Title",
                TextColor3       = Theme.TextPrimary,
                TextSize         = 13,
                Font             = Enum.Font.GothamBold,
                TextXAlignment   = Enum.TextXAlignment.Left,
                Parent           = card,
            })
            Create("TextLabel", {
                Size             = UDim2.new(1, 0, 0, 0),
                AutomaticSize    = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Text             = body or "",
                TextColor3       = Theme.TextSecond,
                TextSize         = 12,
                Font             = Enum.Font.Gotham,
                TextXAlignment   = Enum.TextXAlignment.Left,
                TextWrapped      = true,
                Parent           = card,
            })
        end

        -- ── AddButton ────────────────────────────────────
        function Tab:AddButton(cfg)
            cfg = cfg or {}
            local card = MakeBaseCard(38)

            Create("TextLabel", {
                Size             = UDim2.new(1, -90, 1, 0),
                Position         = UDim2.new(0, 12, 0, 0),
                BackgroundTransparency = 1,
                Text             = cfg.Name or "Button",
                TextColor3       = Theme.TextPrimary,
                TextSize         = 13,
                Font             = Enum.Font.GothamSemibold,
                TextXAlignment   = Enum.TextXAlignment.Left,
                Parent           = card,
            })

            local btn = Create("TextButton", {
                Size             = UDim2.new(0, 72, 0, 26),
                Position         = UDim2.new(1, -80, 0.5, -13),
                BackgroundColor3 = Theme.Accent,
                BorderSizePixel  = 0,
                Text             = "Execute",
                TextColor3       = Color3.fromHex("#000000"),
                TextSize         = 12,
                Font             = Enum.Font.GothamBold,
                AutoButtonColor  = false,
                Parent           = card,
            })
            Corner(UDim.new(0, 6), btn)

            btn.MouseButton1Click:Connect(function()
                -- Press animation
                Tween(btn, { BackgroundColor3 = Theme.AccentSecond, Size = UDim2.new(0, 68, 0, 24) }, 0.08)
                task.delay(0.1, function()
                    Tween(btn, { BackgroundColor3 = Theme.Accent, Size = UDim2.new(0, 72, 0, 26) }, 0.12)
                end)
                if cfg.Callback then cfg.Callback() end
            end)

            btn.MouseEnter:Connect(function()
                Tween(btn, { BackgroundColor3 = Theme.AccentHover }, 0.12)
            end)
            btn.MouseLeave:Connect(function()
                Tween(btn, { BackgroundColor3 = Theme.Accent }, 0.12)
            end)
        end

        -- ── AddToggle ────────────────────────────────────
        function Tab:AddToggle(cfg)
            cfg = cfg or {}
            local value = cfg.Default or false
            local card  = MakeBaseCard(38)

            Create("TextLabel", {
                Size             = UDim2.new(1, -70, 1, 0),
                Position         = UDim2.new(0, 12, 0, 0),
                BackgroundTransparency = 1,
                Text             = cfg.Name or "Toggle",
                TextColor3       = Theme.TextPrimary,
                TextSize         = 13,
                Font             = Enum.Font.GothamSemibold,
                TextXAlignment   = Enum.TextXAlignment.Left,
                Parent           = card,
            })

            -- Toggle track
            local track = Create("Frame", {
                Size             = UDim2.new(0, 44, 0, 22),
                Position         = UDim2.new(1, -54, 0.5, -11),
                BackgroundColor3 = value and Theme.Toggle_On or Theme.Toggle_Off,
                BorderSizePixel  = 0,
                Parent           = card,
            })
            Corner(Theme.CornerFull, track)

            -- Toggle knob
            local knob = Create("Frame", {
                Size             = UDim2.new(0, 16, 0, 16),
                Position         = value and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8),
                BackgroundColor3 = Theme.TextPrimary,
                BorderSizePixel  = 0,
                Parent           = track,
            })
            Corner(Theme.CornerFull, knob)

            -- Click hitbox over the card
            local hitbox = Create("TextButton", {
                Size             = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text             = "",
                ZIndex           = 2,
                Parent           = card,
            })

            hitbox.MouseButton1Click:Connect(function()
                value = not value
                Tween(track, { BackgroundColor3 = value and Theme.Toggle_On or Theme.Toggle_Off }, 0.18)
                Tween(knob, {
                    Position = value
                        and UDim2.new(1, -19, 0.5, -8)
                        or  UDim2.new(0, 3,  0.5, -8)
                }, 0.18, Enum.EasingStyle.Back)
                if cfg.Callback then cfg.Callback(value) end
            end)

            -- Return controller
            local toggleCtrl = {}
            function toggleCtrl:Set(v)
                value = v
                Tween(track, { BackgroundColor3 = value and Theme.Toggle_On or Theme.Toggle_Off }, 0.18)
                Tween(knob, {
                    Position = value
                        and UDim2.new(1, -19, 0.5, -8)
                        or  UDim2.new(0, 3,  0.5, -8)
                }, 0.18)
                if cfg.Callback then cfg.Callback(value) end
            end
            function toggleCtrl:Get() return value end
            return toggleCtrl
        end

        -- ── AddSlider ────────────────────────────────────
        function Tab:AddSlider(cfg)
            cfg = cfg or {}
            local min     = cfg.Min     or 0
            local max     = cfg.Max     or 100
            local default = cfg.Default or min
            local value   = math.clamp(default, min, max)

            local card = MakeBaseCard(58)

            -- Top row: name + value display
            Create("TextLabel", {
                Size             = UDim2.new(0.6, -12, 0, 22),
                Position         = UDim2.new(0, 12, 0, 8),
                BackgroundTransparency = 1,
                Text             = cfg.Name or "Slider",
                TextColor3       = Theme.TextPrimary,
                TextSize         = 13,
                Font             = Enum.Font.GothamSemibold,
                TextXAlignment   = Enum.TextXAlignment.Left,
                Parent           = card,
            })

            local valLabel = Create("TextLabel", {
                Size             = UDim2.new(0.4, -12, 0, 22),
                Position         = UDim2.new(0.6, 0, 0, 8),
                BackgroundTransparency = 1,
                Text             = tostring(value),
                TextColor3       = Theme.Accent,
                TextSize         = 13,
                Font             = Enum.Font.GothamBold,
                TextXAlignment   = Enum.TextXAlignment.Right,
                Parent           = card,
            })

            -- Track background
            local trackBg = Create("Frame", {
                Size             = UDim2.new(1, -24, 0, 6),
                Position         = UDim2.new(0, 12, 0, 38),
                BackgroundColor3 = Theme.SliderBg,
                BorderSizePixel  = 0,
                Parent           = card,
            })
            Corner(Theme.CornerFull, trackBg)

            -- Fill
            local fillPct = (value - min) / (max - min)
            local fill = Create("Frame", {
                Size             = UDim2.new(fillPct, 0, 1, 0),
                BackgroundColor3 = Theme.SliderFill,
                BorderSizePixel  = 0,
                Parent           = trackBg,
            })
            Corner(Theme.CornerFull, fill)

            -- Thumb
            local thumb = Create("Frame", {
                Size             = UDim2.new(0, 14, 0, 14),
                Position         = UDim2.new(fillPct, -7, 0.5, -7),
                BackgroundColor3 = Theme.Accent,
                BorderSizePixel  = 0,
                ZIndex           = 2,
                Parent           = trackBg,
            })
            Corner(Theme.CornerFull, thumb)
            Create("UIStroke", {
                Color     = Theme.Background,
                Thickness = 2,
                Parent    = thumb,
            })

            -- Drag logic
            local sliding = false
            local function UpdateSlider(inputX)
                local absPos  = trackBg.AbsolutePosition.X
                local absSize = trackBg.AbsoluteSize.X
                local pct     = math.clamp((inputX - absPos) / absSize, 0, 1)
                value         = math.floor(min + (max - min) * pct)
                valLabel.Text = tostring(value)
                Tween(fill,  { Size     = UDim2.new(pct, 0, 1, 0) }, 0.05)
                Tween(thumb, { Position = UDim2.new(pct, -7, 0.5, -7) }, 0.05)
                if cfg.Callback then cfg.Callback(value) end
            end

            trackBg.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                    sliding = true
                    UpdateSlider(input.Position.X)
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement
                             or input.UserInputType == Enum.UserInputType.Touch) then
                    UpdateSlider(input.Position.X)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                    sliding = false
                end
            end)

            local sliderCtrl = {}
            function sliderCtrl:Set(v)
                value = math.clamp(v, min, max)
                local pct = (value - min) / (max - min)
                valLabel.Text = tostring(value)
                Tween(fill,  { Size     = UDim2.new(pct, 0, 1, 0) }, 0.1)
                Tween(thumb, { Position = UDim2.new(pct, -7, 0.5, -7) }, 0.1)
                if cfg.Callback then cfg.Callback(value) end
            end
            function sliderCtrl:Get() return value end
            return sliderCtrl
        end

        -- ── AddTextbox ───────────────────────────────────
        function Tab:AddTextbox(cfg)
            cfg = cfg or {}
            local card = MakeBaseCard(58)

            Create("TextLabel", {
                Size             = UDim2.new(1, -16, 0, 20),
                Position         = UDim2.new(0, 12, 0, 6),
                BackgroundTransparency = 1,
                Text             = cfg.Name or "Textbox",
                TextColor3       = Theme.TextPrimary,
                TextSize         = 13,
                Font             = Enum.Font.GothamSemibold,
                TextXAlignment   = Enum.TextXAlignment.Left,
                Parent           = card,
            })

            local inputFrame = Create("Frame", {
                Size             = UDim2.new(1, -24, 0, 26),
                Position         = UDim2.new(0, 12, 0, 28),
                BackgroundColor3 = Theme.InputBg,
                BorderSizePixel  = 0,
                Parent           = card,
            })
            Corner(UDim.new(0, 6), inputFrame)
            local stroke = Stroke(Theme.InputBorder, 1, inputFrame)

            local box = Create("TextBox", {
                Size             = UDim2.new(1, -16, 1, 0),
                Position         = UDim2.new(0, 8, 0, 0),
                BackgroundTransparency = 1,
                PlaceholderText  = cfg.Placeholder or "Enter text...",
                PlaceholderColor3 = Theme.TextMuted,
                Text             = cfg.Default or "",
                TextColor3       = Theme.TextPrimary,
                TextSize         = 12,
                Font             = Enum.Font.Gotham,
                TextXAlignment   = Enum.TextXAlignment.Left,
                ClearTextOnFocus = cfg.ClearOnFocus ~= false,
                Parent           = inputFrame,
            })

            box.Focused:Connect(function()
                Tween(stroke, { Color = Theme.InputFocus }, 0.15)
            end)
            box.FocusLost:Connect(function(enter)
                Tween(stroke, { Color = Theme.InputBorder }, 0.15)
                if cfg.Callback then cfg.Callback(box.Text, enter) end
            end)

            local tbCtrl = {}
            function tbCtrl:Set(t) box.Text = t end
            function tbCtrl:Get() return box.Text end
            return tbCtrl
        end

        -- ── AddDropdown ──────────────────────────────────
        function Tab:AddDropdown(cfg)
            cfg = cfg or {}
            local options  = cfg.Options or {}
            local selected = cfg.Default or options[1] or ""
            local open     = false

            local card = MakeBaseCard(38)
            card.ClipsDescendants = false -- allow dropdown to overflow
            card.ZIndex = 5

            Create("TextLabel", {
                Size             = UDim2.new(1, -120, 1, 0),
                Position         = UDim2.new(0, 12, 0, 0),
                BackgroundTransparency = 1,
                Text             = cfg.Name or "Dropdown",
                TextColor3       = Theme.TextPrimary,
                TextSize         = 13,
                Font             = Enum.Font.GothamSemibold,
                TextXAlignment   = Enum.TextXAlignment.Left,
                ZIndex           = 6,
                Parent           = card,
            })

            -- Select button
            local selectBtn = Create("TextButton", {
                Size             = UDim2.new(0, 100, 0, 26),
                Position         = UDim2.new(1, -108, 0.5, -13),
                BackgroundColor3 = Theme.InputBg,
                BorderSizePixel  = 0,
                Text             = "",
                AutoButtonColor  = false,
                ZIndex           = 6,
                Parent           = card,
            })
            Corner(UDim.new(0, 6), selectBtn)
            Stroke(Theme.InputBorder, 1, selectBtn)

            local selectedLabel = Create("TextLabel", {
                Size             = UDim2.new(1, -22, 1, 0),
                Position         = UDim2.new(0, 8, 0, 0),
                BackgroundTransparency = 1,
                Text             = selected,
                TextColor3       = Theme.TextPrimary,
                TextSize         = 12,
                Font             = Enum.Font.Gotham,
                TextXAlignment   = Enum.TextXAlignment.Left,
                ZIndex           = 7,
                Parent           = selectBtn,
            })
            -- Arrow icon
            local arrow = Create("TextLabel", {
                Size             = UDim2.new(0, 14, 1, 0),
                Position         = UDim2.new(1, -16, 0, 0),
                BackgroundTransparency = 1,
                Text             = "▾",
                TextColor3       = Theme.Accent,
                TextSize         = 12,
                Font             = Enum.Font.GothamBold,
                ZIndex           = 7,
                Parent           = selectBtn,
            })

            -- Dropdown list frame (rendered over content)
            local listFrame = Create("Frame", {
                Size             = UDim2.new(0, 100, 0, 0),
                Position         = UDim2.new(1, -108, 1, 4),
                BackgroundColor3 = Theme.SurfaceHover,
                BorderSizePixel  = 0,
                ClipsDescendants = true,
                ZIndex           = 20,
                Visible          = false,
                Parent           = card,
            })
            Corner(UDim.new(0, 6), listFrame)
            Stroke(Theme.InputBorder, 1, listFrame)
            Create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent    = listFrame,
            })

            local targetHeight = #options * 28

            local function CloseDropdown()
                open = false
                Tween(arrow, { Rotation = 0 }, 0.15)
                Tween(listFrame, { Size = UDim2.new(0, 100, 0, 0) }, 0.15)
                task.delay(0.16, function() listFrame.Visible = false end)
            end

            -- Build option buttons
            for _, opt in ipairs(options) do
                local optBtn = Create("TextButton", {
                    Size             = UDim2.new(1, 0, 0, 28),
                    BackgroundColor3 = Theme.SurfaceHover,
                    BorderSizePixel  = 0,
                    Text             = opt,
                    TextColor3       = Theme.TextPrimary,
                    TextSize         = 12,
                    Font             = Enum.Font.Gotham,
                    AutoButtonColor  = false,
                    ZIndex           = 21,
                    Parent           = listFrame,
                })
                HoverEffect(optBtn, Theme.SurfaceHover, Theme.SurfaceAlt)
                optBtn.MouseButton1Click:Connect(function()
                    selected             = opt
                    selectedLabel.Text   = opt
                    if cfg.Callback then cfg.Callback(opt) end
                    CloseDropdown()
                end)
            end

            selectBtn.MouseButton1Click:Connect(function()
                open = not open
                if open then
                    listFrame.Visible = true
                    Tween(arrow, { Rotation = 180 }, 0.15)
                    Tween(listFrame, { Size = UDim2.new(0, 100, 0, targetHeight) }, 0.15)
                else
                    CloseDropdown()
                end
            end)

            local ddCtrl = {}
            function ddCtrl:Set(v)
                selected           = v
                selectedLabel.Text = v
                if cfg.Callback then cfg.Callback(v) end
            end
            function ddCtrl:Get() return selected end
            return ddCtrl
        end

        -- ── AddKeybind ───────────────────────────────────
        function Tab:AddKeybind(cfg)
            cfg = cfg or {}
            local boundKey  = cfg.Default or Enum.KeyCode.Unknown
            local listening = false

            local card = MakeBaseCard(38)

            Create("TextLabel", {
                Size             = UDim2.new(1, -100, 1, 0),
                Position         = UDim2.new(0, 12, 0, 0),
                BackgroundTransparency = 1,
                Text             = cfg.Name or "Keybind",
                TextColor3       = Theme.TextPrimary,
                TextSize         = 13,
                Font             = Enum.Font.GothamSemibold,
                TextXAlignment   = Enum.TextXAlignment.Left,
                Parent           = card,
            })

            local keyBtn = Create("TextButton", {
                Size             = UDim2.new(0, 82, 0, 26),
                Position         = UDim2.new(1, -90, 0.5, -13),
                BackgroundColor3 = Theme.InputBg,
                BorderSizePixel  = 0,
                Text             = boundKey == Enum.KeyCode.Unknown and "None" or boundKey.Name,
                TextColor3       = Theme.Accent,
                TextSize         = 11,
                Font             = Enum.Font.GothamBold,
                AutoButtonColor  = false,
                Parent           = card,
            })
            Corner(UDim.new(0, 6), keyBtn)
            Stroke(Theme.InputBorder, 1, keyBtn)

            keyBtn.MouseButton1Click:Connect(function()
                listening   = true
                keyBtn.Text = "..."
                keyBtn.TextColor3 = Theme.TextSecond
            end)

            UserInputService.InputBegan:Connect(function(input, gpe)
                if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                    listening        = false
                    boundKey         = input.KeyCode
                    keyBtn.Text      = input.KeyCode.Name
                    keyBtn.TextColor3 = Theme.Accent
                elseif not listening and input.UserInputType == Enum.UserInputType.Keyboard
                    and input.KeyCode == boundKey and not gpe then
                    if cfg.Callback then cfg.Callback() end
                end
            end)

            local kbCtrl = {}
            function kbCtrl:Set(k)
                boundKey     = k
                keyBtn.Text  = k.Name
            end
            function kbCtrl:Get() return boundKey end
            return kbCtrl
        end

        return Tab
    end -- CreateTab

    -- ── Notify (toast) ───────────────────────────────────────
    function Window:Notify(cfg)
        cfg = cfg or {}
        local notif = Create("Frame", {
            Size             = UDim2.new(0, 280, 0, 60),
            Position         = UDim2.new(1, 10, 1, -70),
            BackgroundColor3 = Theme.Surface,
            BorderSizePixel  = 0,
            ZIndex           = 50,
            Parent           = screenGui,
        })
        Corner(UDim.new(0, 8), notif)
        Stroke(Theme.Accent, 1, notif)

        Create("TextLabel", {
            Size             = UDim2.new(1, -16, 0, 20),
            Position         = UDim2.new(0, 12, 0, 8),
            BackgroundTransparency = 1,
            Text             = cfg.Title or "Notification",
            TextColor3       = Theme.Accent,
            TextSize         = 13,
            Font             = Enum.Font.GothamBold,
            TextXAlignment   = Enum.TextXAlignment.Left,
            ZIndex           = 51,
            Parent           = notif,
        })
        Create("TextLabel", {
            Size             = UDim2.new(1, -16, 0, 22),
            Position         = UDim2.new(0, 12, 0, 30),
            BackgroundTransparency = 1,
            Text             = cfg.Content or "",
            TextColor3       = Theme.TextSecond,
            TextSize         = 12,
            Font             = Enum.Font.Gotham,
            TextXAlignment   = Enum.TextXAlignment.Left,
            TextWrapped      = true,
            ZIndex           = 51,
            Parent           = notif,
        })

        -- Slide in
        Tween(notif, { Position = UDim2.new(1, -290, 1, -70) }, 0.3, Enum.EasingStyle.Back)
        task.delay(cfg.Duration or 3, function()
            Tween(notif, { Position = UDim2.new(1, 10, 1, -70) }, 0.25)
            task.delay(0.26, function() notif:Destroy() end)
        end)
    end

    -- ── Toggle visibility shortcut ───────────────────────────
    function Window:Toggle()
        windowFrame.Visible = not windowFrame.Visible
    end

    setmetatable(Window, Window)
    return Window
end -- CreateWindow

-- ══════════════════════════════════════════════════════════════
--  Return Library
-- ══════════════════════════════════════════════════════════════
setmetatable(Library, Library)
return Library
