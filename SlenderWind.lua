--[[ 
    SlenderWind UI - Library Source
    Version: V10.0 [Obsidian Edition]
    Architect: SlenderHub Lead
    
    New Features vs V9:
    + Multi-Selection Dropdowns
    + Tooltip System (Hover Info)
    + Advanced Notifications (Success/Warn/Error)
    + Glass/Acrylic Style Transparency
    + Optimized Event Handling
]]

local SlenderWind = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local Stats = game:GetService("Stats")
local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")

--// Singleton Check
if getgenv().SlenderWindLoaded then
    -- Optional: Warn user
end
getgenv().SlenderWindLoaded = true

--// Utility Functions
local function Create(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props) do
        inst[k] = v
    end
    return inst
end

local function MakeDraggable(topbar, object)
    local Dragging, DragInput, DragStart, StartPos
    local function Update(input)
        local Delta = input.Position - DragStart
        local Target = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
        TweenService:Create(object, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = Target}):Play()
    end
    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true; DragStart = input.Position; StartPos = object.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then Dragging = false end
            end)
        end
    end)
    topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            DragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then Update(input) end
    end)
end

--// Library Logic
function SlenderWind.Window(config)
    local Self = {}
    Self.Config = config or {}
    Self.Name = config.Name or "Slender Hub"
    Self.Keybind = config.Keybind or Enum.KeyCode.RightControl
    Self.KeySystem = config.KeySystem or false
    Self.KeySettings = config.KeySettings or {}
    Self.Flags = {} 
    Self.Elements = {} 
    
    -- Config Saving Settings
    Self.SaveConfig = config.ConfigurationSaving or { Enabled = false, FolderName = "SlenderHub", FileName = "Config" }

    -- Dynamic Theme System
    local DefaultTheme = {
        MainBg = Color3.fromRGB(18, 18, 22),
        Sidebar = Color3.fromRGB(23, 23, 27),
        Content = Color3.fromRGB(18, 18, 22),
        Element = Color3.fromRGB(30, 30, 36),
        Text = Color3.fromRGB(240, 240, 240),
        SubText = Color3.fromRGB(160, 160, 160),
        Accent = Color3.fromRGB(60, 130, 250),
        Stroke = Color3.fromRGB(45, 45, 50),
        Separator = Color3.fromRGB(35, 35, 40),
        Hover = Color3.fromRGB(40, 40, 46),
        Success = Color3.fromRGB(60, 250, 100),
        Warning = Color3.fromRGB(250, 180, 60),
        Error = Color3.fromRGB(255, 85, 85)
    }

    Self.Theme = setmetatable(config.Theme or {}, {__index = DefaultTheme})
    local Colors = Self.Theme

    -- GUI Setup
    local ParentTarget = (RunService:IsStudio() and Players.LocalPlayer.PlayerGui or CoreGui)
    if ParentTarget:FindFirstChild("SlenderWind") then
        ParentTarget.SlenderWind:Destroy()
    end

    local ScreenGui = Create("ScreenGui", {Name = "SlenderWind", Parent = ParentTarget, ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling})

    -- Tooltip Layer
    local TooltipLabel = Create("TextLabel", {
        Parent = ScreenGui, BackgroundColor3 = Colors.Sidebar, TextColor3 = Colors.Text,
        Font = Enum.Font.Gotham, TextSize = 12, Size = UDim2.new(0, 0, 0, 20),
        Visible = false, ZIndex = 200
    })
    Create("UICorner", {Parent = TooltipLabel, CornerRadius = UDim.new(0, 4)})
    Create("UIStroke", {Parent = TooltipLabel, Color = Colors.Stroke, Thickness = 1})
    Create("UIPadding", {Parent = TooltipLabel, PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 5)})

    local function AddTooltip(element, text)
        if not text then return end
        element.MouseEnter:Connect(function()
            TooltipLabel.Visible = true
            TooltipLabel.Text = text
            TooltipLabel.Size = UDim2.new(0, TextService:GetTextSize(text, 12, Enum.Font.Gotham, Vector2.new(1000, 20)).X + 10, 0, 24)
        end)
        element.MouseLeave:Connect(function()
            TooltipLabel.Visible = false
        end)
        element.MouseMoved:Connect(function()
            TooltipLabel.Position = UDim2.new(0, UserInputService:GetMouseLocation().X + 15, 0, UserInputService:GetMouseLocation().Y + 15)
        end)
    end

    -- Notification Container
    local NotifyContainer = Create("Frame", {
        Parent = ScreenGui, BackgroundTransparency = 1,
        Position = UDim2.new(1, -320, 1, -20), Size = UDim2.new(0, 300, 1, 0),
        AnchorPoint = Vector2.new(0, 1)
    })
    Create("UIListLayout", {Parent = NotifyContainer, SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Bottom, Padding = UDim.new(0, 5)})

    -- Main Container
    local Main = Create("Frame", {
        Name = "Main", Parent = ScreenGui, BackgroundColor3 = Colors.MainBg,
        BackgroundTransparency = 0.05, -- Glass Effect
        Position = UDim2.new(0.5, -325, 0.5, -210), Size = UDim2.new(0, 650, 0, 420),
        ClipsDescendants = true, Visible = not Self.KeySystem
    })
    Create("UICorner", {Parent = Main, CornerRadius = UDim.new(0, 10)})
    Create("UIStroke", {Parent = Main, Color = Colors.Stroke, Thickness = 1})

    --// CONFIGURATION SYSTEM //--
    function Self:Save()
        if not Self.SaveConfig.Enabled then return end
        if not isfolder(Self.SaveConfig.FolderName) then makefolder(Self.SaveConfig.FolderName) end
        
        local Path = Self.SaveConfig.FolderName .. "/" .. Self.SaveConfig.FileName .. ".json"
        local Data = HttpService:JSONEncode(Self.Flags)
        writefile(Path, Data)
    end

    function Self:Load()
        if not Self.SaveConfig.Enabled then return end
        local Path = Self.SaveConfig.FolderName .. "/" .. Self.SaveConfig.FileName .. ".json"
        if isfile(Path) then
            local Success, Decoded = pcall(function() return HttpService:JSONDecode(readfile(Path)) end)
            if Success and Decoded then
                for Flag, Value in pairs(Decoded) do
                    if Self.Elements[Flag] then
                        Self.Elements[Flag]:Set(Value)
                    end
                end
            end
        end
    end

    --// KEY SYSTEM LOGIC //--
    if Self.KeySystem then
        local KeyFrame = Create("Frame", {
            Name = "KeySystem", Parent = ScreenGui, BackgroundColor3 = Colors.MainBg,
            Position = UDim2.new(0.5, -150, 0.5, -100), Size = UDim2.new(0, 300, 0, 200),
            ClipsDescendants = true
        })
        Create("UICorner", {Parent = KeyFrame, CornerRadius = UDim.new(0, 10)})
        Create("UIStroke", {Parent = KeyFrame, Color = Colors.Stroke, Thickness = 1})
        MakeDraggable(KeyFrame, KeyFrame)

        Create("TextLabel", {
            Parent = KeyFrame, Text = Self.KeySettings.Title or "SlenderHub Security", 
            TextColor3 = Colors.Text, Font = Enum.Font.GothamBold, TextSize = 16,
            Position = UDim2.new(0, 0, 0, 15), Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1
        })

        local KeyInput = Create("TextBox", {
            Parent = KeyFrame, Text = "", PlaceholderText = "Paste Key Here...", 
            BackgroundColor3 = Colors.Element, TextColor3 = Colors.Text, Font = Enum.Font.Gotham, TextSize = 13,
            Position = UDim2.new(0, 20, 0, 70), Size = UDim2.new(1, -40, 0, 35)
        })
        Create("UICorner", {Parent = KeyInput, CornerRadius = UDim.new(0, 6)})
        Create("UIStroke", {Parent = KeyInput, Color = Colors.Stroke, Thickness = 1})

        local CheckBtn = Create("TextButton", {
            Parent = KeyFrame, Text = "Verify Key", BackgroundColor3 = Colors.Accent,
            TextColor3 = Colors.Text, Font = Enum.Font.GothamBold, TextSize = 13,
            Position = UDim2.new(0, 20, 0, 115), Size = UDim2.new(0, 125, 0, 35), AutoButtonColor = false
        })
        Create("UICorner", {Parent = CheckBtn, CornerRadius = UDim.new(0, 6)})

        local LinkBtn = Create("TextButton", {
            Parent = KeyFrame, Text = "Get Key", BackgroundColor3 = Colors.Element,
            TextColor3 = Colors.SubText, Font = Enum.Font.GothamBold, TextSize = 13,
            Position = UDim2.new(1, -145, 0, 115), Size = UDim2.new(0, 125, 0, 35), AutoButtonColor = false
        })
        Create("UICorner", {Parent = LinkBtn, CornerRadius = UDim.new(0, 6)})
        Create("UIStroke", {Parent = LinkBtn, Color = Colors.Stroke, Thickness = 1})

        CheckBtn.MouseButton1Click:Connect(function()
            if KeyInput.Text == Self.KeySettings.Key then
                TweenService:Create(KeyFrame, TweenInfo.new(0.5), {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}):Play()
                task.wait(0.5)
                KeyFrame:Destroy()
                Main.Visible = true
                TweenService:Create(Main, TweenInfo.new(0.5), {BackgroundTransparency = 0.05}):Play()
                Self:Notify("Success", "Access Granted. Welcome.", 3)
                Self:Load()
            else
                TweenService:Create(KeyInput.UIStroke, TweenInfo.new(0.1), {Color = Colors.Error}):Play()
                KeyInput.Text = "Invalid Key"
                task.wait(1)
                KeyInput.Text = ""
                TweenService:Create(KeyInput.UIStroke, TweenInfo.new(0.5), {Color = Colors.Stroke}):Play()
            end
        end)

        LinkBtn.MouseButton1Click:Connect(function()
            if setclipboard then
                setclipboard(Self.KeySettings.Link or "https://slenderhub.net")
                LinkBtn.Text = "Copied!"
                task.wait(1)
                LinkBtn.Text = "Get Key"
            end
        end)
    else
        task.spawn(function() 
            task.wait(0.1)
            Self:Load()
        end)
    end

    --// WATERMARK HUD //--
    function Self:Watermark(settings)
        local Enabled = settings.Enabled or true
        if not Enabled then return end

        local HudFrame = Create("Frame", {
            Parent = ScreenGui, BackgroundColor3 = Color3.fromRGB(20, 20, 25),
            Position = UDim2.new(0.5, -150, 0, 10), Size = UDim2.new(0, 300, 0, 26),
            ZIndex = 100
        })
        Create("UICorner", {Parent = HudFrame, CornerRadius = UDim.new(0, 6)})
        Create("UIStroke", {Parent = HudFrame, Color = Colors.Accent, Thickness = 1, Transparency = 0.5})

        local HudText = Create("TextLabel", {
            Parent = HudFrame, Text = "Loading...", TextColor3 = Colors.Text,
            Font = Enum.Font.GothamBold, TextSize = 12, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0)
        })

        task.spawn(function()
            while HudFrame.Parent do
                local FPS = math.floor(workspace:GetRealPhysicsFPS())
                local Ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
                local Time = os.date("%H:%M:%S")
                HudText.Text = string.format("%s | FPS: %d | Ping: %dms | %s", settings.Title or "SlenderHub", FPS, Ping, Time)
                task.wait(1)
            end
        end)
    end

    --// MAIN UI CONSTRUCTION //--
    local Sidebar = Create("Frame", {
        Parent = Main, BackgroundColor3 = Colors.Sidebar,
        Size = UDim2.new(0, 190, 1, 0), BorderSizePixel = 0
    })
    Create("UICorner", {Parent = Sidebar, CornerRadius = UDim.new(0, 10)})
    Create("Frame", {Parent = Sidebar, BackgroundColor3 = Colors.Sidebar, Size = UDim2.new(0, 10, 1, 0), Position = UDim2.new(1, -10, 0, 0), BorderSizePixel = 0})

    local Separator = Create("Frame", {
        Parent = Main, BackgroundColor3 = Colors.Separator,
        Size = UDim2.new(0, 1, 1, 0), Position = UDim2.new(0, 190, 0, 0), BorderSizePixel = 0, ZIndex = 5
    })

    local Controls = Create("Frame", {Parent = Sidebar, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 50)})
    local CloseBtn = Create("TextButton", {Parent = Controls, Text = "", BackgroundColor3 = Color3.fromRGB(255, 95, 87), Position = UDim2.new(0, 15, 0, 18), Size = UDim2.new(0, 12, 0, 12), AutoButtonColor = false})
    Create("UICorner", {Parent = CloseBtn, CornerRadius = UDim.new(1, 0)})
    local MinBtn = Create("TextButton", {Parent = Controls, Text = "", BackgroundColor3 = Color3.fromRGB(255, 189, 46), Position = UDim2.new(0, 35, 0, 18), Size = UDim2.new(0, 12, 0, 12), AutoButtonColor = false})
    Create("UICorner", {Parent = MinBtn, CornerRadius = UDim.new(1, 0)})
    local MaxBtn = Create("Frame", {Parent = Controls, BackgroundColor3 = Color3.fromRGB(39, 201, 63), Position = UDim2.new(0, 55, 0, 18), Size = UDim2.new(0, 12, 0, 12)})
    Create("UICorner", {Parent = MaxBtn, CornerRadius = UDim.new(1, 0)})

    Create("TextLabel", {
        Parent = Controls, Text = Self.Name, TextColor3 = Colors.Text,
        Font = Enum.Font.GothamBold, TextSize = 14, BackgroundTransparency = 1,
        Position = UDim2.new(0, 80, 0, 0), Size = UDim2.new(1, -85, 1, 0), 
        TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd
    })

    local SearchFrame = Create("Frame", {
        Parent = Sidebar, BackgroundColor3 = Colors.MainBg,
        Position = UDim2.new(0, 12, 0, 55), Size = UDim2.new(1, -24, 0, 30)
    })
    Create("UICorner", {Parent = SearchFrame, CornerRadius = UDim.new(0, 6)})
    Create("UIStroke", {Parent = SearchFrame, Color = Colors.Stroke, Thickness = 1})
    Create("ImageLabel", {Parent = SearchFrame, Image = "rbxassetid://3926305904", ImageRectOffset = Vector2.new(964, 324), ImageRectSize = Vector2.new(36, 36), ImageColor3 = Colors.SubText, BackgroundTransparency = 1, Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(0, 8, 0.5, -8)})
    
    local SearchInput = Create("TextBox", {
        Parent = SearchFrame, Text = "", PlaceholderText = "Search...", PlaceholderColor3 = Colors.SubText,
        TextColor3 = Colors.Text, Font = Enum.Font.Gotham, TextSize = 13, BackgroundTransparency = 1,
        Position = UDim2.new(0, 32, 0, 0), Size = UDim2.new(1, -32, 1, 0), TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false
    })

    local TabHolder = Create("ScrollingFrame", {
        Parent = Sidebar, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 95), Size = UDim2.new(1, 0, 1, -100),
        ScrollBarThickness = 0, CanvasSize = UDim2.new(0,0,0,0)
    })
    Create("UIListLayout", {Parent = TabHolder, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5)})
    Create("UIPadding", {Parent = TabHolder, PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10)})

    local ContentArea = Create("Frame", {
        Parent = Main, BackgroundTransparency = 1,
        Position = UDim2.new(0, 205, 0, 15), Size = UDim2.new(1, -220, 1, -30)
    })

    local OpenBtn = Create("TextButton", {
        Parent = ScreenGui, Text = "SH", TextColor3 = Colors.Accent, BackgroundColor3 = Colors.Sidebar,
        Size = UDim2.new(0, 45, 0, 45), Position = UDim2.new(0, 20, 0.5, 0),
        Font = Enum.Font.GothamBlack, TextSize = 16, Visible = false
    })
    Create("UICorner", {Parent = OpenBtn, CornerRadius = UDim.new(0, 12)})
    Create("UIStroke", {Parent = OpenBtn, Color = Colors.Stroke, Thickness = 2})
    MakeDraggable(OpenBtn, OpenBtn)

    MakeDraggable(Sidebar, Main)

    local function ToggleUI()
        Main.Visible = not Main.Visible
        OpenBtn.Visible = not Main.Visible
    end

    function Self:Destroy()
        ScreenGui:Destroy()
    end

    CloseBtn.MouseButton1Click:Connect(function() Self:Destroy() end)
    MinBtn.MouseButton1Click:Connect(ToggleUI)
    OpenBtn.MouseButton1Click:Connect(ToggleUI)

    UserInputService.InputBegan:Connect(function(input, gp)
        if not gp and input.KeyCode == Self.Keybind then ToggleUI() end
    end)

    --// ADVANCED NOTIFICATIONS //--
    function Self:Notify(title, text, duration, type)
        local TypeColor = Colors.Accent
        if type == "Success" then TypeColor = Colors.Success
        elseif type == "Warning" then TypeColor = Colors.Warning
        elseif type == "Error" then TypeColor = Colors.Error end

        local Notif = Create("Frame", {
            Parent = NotifyContainer, BackgroundColor3 = Colors.Sidebar,
            Size = UDim2.new(1, 0, 0, 60), BackgroundTransparency = 1
        })
        Create("UICorner", {Parent = Notif, CornerRadius = UDim.new(0, 8)})
        Create("UIStroke", {Parent = Notif, Color = TypeColor, Thickness = 1, Transparency = 1})
        
        local NTitle = Create("TextLabel", {
            Parent = Notif, Text = title, TextColor3 = TypeColor, Font = Enum.Font.GothamBold,
            TextSize = 14, Position = UDim2.new(0, 10, 0, 8), Size = UDim2.new(1, -20, 0, 20),
            TextXAlignment = Enum.TextXAlignment.Left, TextTransparency = 1
        })
        
        local NText = Create("TextLabel", {
            Parent = Notif, Text = text, TextColor3 = Colors.Text, Font = Enum.Font.Gotham,
            TextSize = 12, Position = UDim2.new(0, 10, 0, 28), Size = UDim2.new(1, -20, 0, 20),
            TextXAlignment = Enum.TextXAlignment.Left, TextTransparency = 1
        })

        TweenService:Create(Notif, TweenInfo.new(0.3), {BackgroundTransparency = 0.1}):Play()
        TweenService:Create(Notif.UIStroke, TweenInfo.new(0.3), {Transparency = 0}):Play()
        TweenService:Create(NTitle, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
        TweenService:Create(NText, TweenInfo.new(0.3), {TextTransparency = 0}):Play()

        task.delay(duration or 3, function()
            TweenService:Create(Notif, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
            TweenService:Create(Notif.UIStroke, TweenInfo.new(0.3), {Transparency = 1}):Play()
            TweenService:Create(NTitle, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
            TweenService:Create(NText, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
            task.wait(0.3)
            Notif:Destroy()
        end)
    end

    local Tabs = {}
    local CurrentTab = nil

    SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
        local query = SearchInput.Text:lower()
        if CurrentTab and CurrentTab.Page then
            for _, element in pairs(CurrentTab.Page:GetChildren()) do
                if element:IsA("Frame") or element:IsA("TextButton") then
                    local titleLabel = element:FindFirstChild("Title")
                    if titleLabel then
                        if query == "" or titleLabel.Text:lower():find(query) then
                            element.Visible = true
                        else
                            element.Visible = false
                        end
                    end
                end
            end
        end
    end)

    function Self:Tab(name, iconId)
        local TabObj = {}
        
        local TabBtn = Create("TextButton", {
            Parent = TabHolder, Text = "", BackgroundColor3 = Colors.Sidebar,
            Size = UDim2.new(1, 0, 0, 34), AutoButtonColor = false
        })
        Create("UICorner", {Parent = TabBtn, CornerRadius = UDim.new(0, 6)})
        
        local TabLabel = Create("TextLabel", {
            Parent = TabBtn, Text = name, TextColor3 = Colors.SubText,
            Font = Enum.Font.GothamMedium, TextSize = 13, BackgroundTransparency = 1,
            Position = UDim2.new(0, 34, 0, 0), Size = UDim2.new(1, -34, 1, 0), TextXAlignment = Enum.TextXAlignment.Left
        })
        
        local Icon = Create("ImageLabel", {
            Parent = TabBtn, BackgroundTransparency = 1, Image = iconId or "rbxassetid://3926305904",
            ImageRectOffset = Vector2.new(4, 844), ImageRectSize = Vector2.new(36, 36),
            ImageColor3 = Colors.SubText, Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(0, 10, 0.5, -8)
        })

        local Page = Create("ScrollingFrame", {
            Parent = ContentArea, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0),
            ScrollBarThickness = 3, Visible = false, ScrollBarImageColor3 = Colors.Accent, BorderSizePixel = 0,
            CanvasSize = UDim2.new(0, 0, 0, 0), BottomImage = "rbxassetid://6889812721", MidImage = "rbxassetid://6889812721", TopImage = "rbxassetid://6889812721"
        })
        Create("UIListLayout", {Parent = Page, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8)})
        Create("UIPadding", {Parent = Page, PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5), PaddingRight = UDim.new(0, 5)})

        Page.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, Page.UIListLayout.AbsoluteContentSize.Y + 10)
        end)

        TabBtn.MouseButton1Click:Connect(function()
            for _, t in pairs(Tabs) do
                TweenService:Create(t.Btn, TweenInfo.new(0.2), {BackgroundColor3 = Colors.Sidebar}):Play()
                TweenService:Create(t.Txt, TweenInfo.new(0.2), {TextColor3 = Colors.SubText}):Play()
                TweenService:Create(t.Img, TweenInfo.new(0.2), {ImageColor3 = Colors.SubText}):Play()
                t.Page.Visible = false
            end
            TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundColor3 = Colors.Hover}):Play()
            TweenService:Create(TabLabel, TweenInfo.new(0.2), {TextColor3 = Colors.Text}):Play()
            TweenService:Create(Icon, TweenInfo.new(0.2), {ImageColor3 = Colors.Accent}):Play()
            Page.Visible = true
            CurrentTab = TabObj
            SearchInput.Text = ""
        end)

        if #Tabs == 0 and not Self.KeySystem then
            TabBtn.BackgroundColor3 = Colors.Hover
            TabLabel.TextColor3 = Colors.Text
            Icon.ImageColor3 = Colors.Accent
            Page.Visible = true
            CurrentTab = TabObj
        end

        table.insert(Tabs, {Btn = TabBtn, Txt = TabLabel, Img = Icon, Page = Page})

        function TabObj:Section(text)
            local Sec = Create("TextLabel", {
                Parent = Page, Text = text, TextColor3 = Colors.SubText, Font = Enum.Font.GothamBold,
                TextSize = 11, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 25), TextXAlignment = Enum.TextXAlignment.Left
            })
            Create("UIPadding", {Parent = Sec, PaddingLeft = UDim.new(0, 2)})
        end

        function TabObj:Button(text, tooltip, callback)
            local cb = callback or tooltip
            if type(tooltip) == "function" then tooltip = nil end

            local BtnFrame = Create("TextButton", {
                Parent = Page, Text = "", BackgroundColor3 = Colors.Element,
                Size = UDim2.new(1, 0, 0, 36), AutoButtonColor = false
            })
            Create("UICorner", {Parent = BtnFrame, CornerRadius = UDim.new(0, 6)})
            Create("UIStroke", {Parent = BtnFrame, Color = Colors.Stroke, Thickness = 1})
            
            Create("TextLabel", {
                Name = "Title", Parent = BtnFrame, Text = text, TextColor3 = Colors.Text, Font = Enum.Font.GothamMedium,
                TextSize = 13, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(1, -12, 1, 0), TextXAlignment = Enum.TextXAlignment.Left
            })

            Create("ImageLabel", {
                Parent = BtnFrame, BackgroundTransparency = 1, Image = "rbxassetid://3926305904",
                ImageRectOffset = Vector2.new(84, 204), ImageRectSize = Vector2.new(36, 36),
                ImageColor3 = Colors.SubText, Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(1, -28, 0.5, -9)
            })

            AddTooltip(BtnFrame, tooltip)

            BtnFrame.MouseButton1Click:Connect(function()
                TweenService:Create(BtnFrame, TweenInfo.new(0.1), {BackgroundColor3 = Colors.Stroke}):Play()
                task.wait(0.1)
                TweenService:Create(BtnFrame, TweenInfo.new(0.3), {BackgroundColor3 = Colors.Element}):Play()
                pcall(cb)
            end)
        end

        function TabObj:Toggle(text, default, flag, tooltip, callback)
            local cb = callback or tooltip
            if type(tooltip) == "function" then tooltip = nil end
            
            local Enabled = default or false
            local FlagName = flag or text
            
            local TogFrame = Create("TextButton", {
                Parent = Page, Text = "", BackgroundColor3 = Colors.Element,
                Size = UDim2.new(1, 0, 0, 36), AutoButtonColor = false
            })
            Create("UICorner", {Parent = TogFrame, CornerRadius = UDim.new(0, 6)})
            Create("UIStroke", {Parent = TogFrame, Color = Colors.Stroke, Thickness = 1})

            Create("TextLabel", {
                Name = "Title", Parent = TogFrame, Text = text, TextColor3 = Colors.Text, Font = Enum.Font.GothamMedium,
                TextSize = 13, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(1, -60, 1, 0), TextXAlignment = Enum.TextXAlignment.Left
            })

            local Switch = Create("Frame", {
                Parent = TogFrame, BackgroundColor3 = (Enabled and Colors.Accent) or Color3.fromRGB(50, 50, 55),
                Size = UDim2.new(0, 36, 0, 20), Position = UDim2.new(1, -46, 0.5, -10)
            })
            Create("UICorner", {Parent = Switch, CornerRadius = UDim.new(1, 0)})
            
            local Knob = Create("Frame", {
                Parent = Switch, BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(0, (Enabled and 18) or 2, 0.5, -8)
            })
            Create("UICorner", {Parent = Knob, CornerRadius = UDim.new(1, 0)})

            AddTooltip(TogFrame, tooltip)

            local function UpdateToggle(val)
                Enabled = val
                if FlagName then Self.Flags[FlagName] = Enabled end
                local TargetPos = (Enabled and 18) or 2
                local TargetColor = (Enabled and Colors.Accent) or Color3.fromRGB(50, 50, 55)
                TweenService:Create(Knob, TweenInfo.new(0.2), {Position = UDim2.new(0, TargetPos, 0.5, -8)}):Play()
                TweenService:Create(Switch, TweenInfo.new(0.2), {BackgroundColor3 = TargetColor}):Play()
                pcall(cb, Enabled)
                Self:Save()
            end

            TogFrame.MouseButton1Click:Connect(function() UpdateToggle(not Enabled) end)

            if FlagName then
                Self.Flags[FlagName] = Enabled
                Self.Elements[FlagName] = { Set = UpdateToggle }
            end
        end

        function TabObj:Slider(text, min, max, default, flag, tooltip, callback)
            local cb = callback or tooltip
            if type(tooltip) == "function" then tooltip = nil end

            local Value = default or min
            local FlagName = flag or text
            
            local SliderFrame = Create("Frame", {
                Parent = Page, BackgroundColor3 = Colors.Element,
                Size = UDim2.new(1, 0, 0, 50)
            })
            Create("UICorner", {Parent = SliderFrame, CornerRadius = UDim.new(0, 6)})
            Create("UIStroke", {Parent = SliderFrame, Color = Colors.Stroke, Thickness = 1})

            Create("TextLabel", {
                Name = "Title", Parent = SliderFrame, Text = text, TextColor3 = Colors.Text, Font = Enum.Font.GothamMedium,
                TextSize = 13, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 8), Size = UDim2.new(1, -24, 0, 15), TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local ValueBox = Create("TextBox", {
                Parent = SliderFrame, Text = tostring(Value), TextColor3 = Colors.SubText, Font = Enum.Font.Gotham,
                TextSize = 12, BackgroundTransparency = 1, Position = UDim2.new(1, -40, 0, 8), Size = UDim2.new(0, 30, 0, 15), 
                TextXAlignment = Enum.TextXAlignment.Right, PlaceholderText = "#"
            })

            local Track = Create("TextButton", {
                Parent = SliderFrame, Text = "", BackgroundColor3 = Color3.fromRGB(45, 45, 50),
                Size = UDim2.new(1, -24, 0, 4), Position = UDim2.new(0, 12, 0, 35), AutoButtonColor = false
            })
            Create("UICorner", {Parent = Track, CornerRadius = UDim.new(1, 0)})

            local Fill = Create("Frame", {
                Parent = Track, BackgroundColor3 = Colors.Accent,
                Size = UDim2.new((Value - min) / (max - min), 0, 1, 0), BorderSizePixel = 0
            })
            Create("UICorner", {Parent = Fill, CornerRadius = UDim.new(1, 0)})

            AddTooltip(SliderFrame, tooltip)

            local function UpdateSlider(val)
                local Clamped = math.clamp(val, min, max)
                Value = Clamped
                if FlagName then Self.Flags[FlagName] = Value end
                
                ValueBox.Text = tostring(Value)
                local Percent = (Value - min) / (max - min)
                TweenService:Create(Fill, TweenInfo.new(0.05), {Size = UDim2.new(Percent, 0, 1, 0)}):Play()
                pcall(cb, Value)
                Self:Save()
            end

            local Dragging = false
            local function UpdateInput(input)
                local SizeX = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                local NewValue = math.floor(min + ((max - min) * SizeX))
                UpdateSlider(NewValue)
            end

            Track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    Dragging = true; UpdateInput(input)
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    UpdateInput(input)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then Dragging = false end
            end)

            ValueBox.FocusLost:Connect(function()
                local num = tonumber(ValueBox.Text)
                if num then UpdateSlider(num) else ValueBox.Text = tostring(Value) end
            end)

            if FlagName then
                Self.Flags[FlagName] = Value
                Self.Elements[FlagName] = { Set = UpdateSlider }
            end
        end

        function TabObj:Dropdown(text, options, default, flag, tooltip, callback)
            local cb = callback or tooltip
            if type(tooltip) == "function" then tooltip = nil end

            local DropdownOpen = false
            local Selected = default or options[1]
            local CurrentOptions = options
            local FlagName = flag or text
            
            local DropFrame = Create("Frame", {
                Parent = Page, BackgroundColor3 = Colors.Element,
                Size = UDim2.new(1, 0, 0, 36), ClipsDescendants = true
            })
            Create("UICorner", {Parent = DropFrame, CornerRadius = UDim.new(0, 6)})
            Create("UIStroke", {Parent = DropFrame, Color = Colors.Stroke, Thickness = 1})

            local DropBtn = Create("TextButton", {
                Parent = DropFrame, Text = "", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 36)
            })

            Create("TextLabel", {
                Name = "Title", Parent = DropFrame, Text = text, TextColor3 = Colors.Text, Font = Enum.Font.GothamMedium,
                TextSize = 13, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(1, -12, 0, 36), TextXAlignment = Enum.TextXAlignment.Left
            })

            local SelectedLabel = Create("TextLabel", {
                Parent = DropFrame, Text = Selected, TextColor3 = Colors.SubText, Font = Enum.Font.Gotham,
                TextSize = 12, BackgroundTransparency = 1, Position = UDim2.new(1, -130, 0, 0), Size = UDim2.new(0, 100, 0, 36), TextXAlignment = Enum.TextXAlignment.Right
            })

            local Arrow = Create("ImageLabel", {
                Parent = DropFrame, BackgroundTransparency = 1, Image = "rbxassetid://6031091004",
                ImageColor3 = Colors.SubText, Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(1, -24, 0, 10)
            })

            local OptionList = Create("Frame", {
                Parent = DropFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 36), Size = UDim2.new(1, 0, 0, 0)
            })
            Create("UIListLayout", {Parent = OptionList, SortOrder = Enum.SortOrder.LayoutOrder})

            AddTooltip(DropFrame, tooltip)

            local function UpdateSelection(val)
                Selected = val
                SelectedLabel.Text = tostring(Selected)
                if FlagName then Self.Flags[FlagName] = Selected end
                pcall(cb, Selected)
                Self:Save()
            end

            local function BuildList(opts)
                for _, v in pairs(OptionList:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
                for _, opt in pairs(opts) do
                    local OptBtn = Create("TextButton", {
                        Parent = OptionList, Text = opt, TextColor3 = Colors.SubText, Font = Enum.Font.Gotham,
                        TextSize = 12, BackgroundColor3 = Colors.Element, Size = UDim2.new(1, 0, 0, 30), AutoButtonColor = false
                    })
                    OptBtn.MouseButton1Click:Connect(function()
                        UpdateSelection(opt)
                        DropBtn.Fire()
                    end)
                end
            end

            DropBtn.MouseButton1Click:Connect(function()
                DropdownOpen = not DropdownOpen
                if DropdownOpen then BuildList(CurrentOptions) end
                
                local ListSize = (#CurrentOptions * 30)
                local TargetSize = DropdownOpen and (36 + ListSize) or 36
                
                TweenService:Create(DropFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, TargetSize)}):Play()
                TweenService:Create(Arrow, TweenInfo.new(0.3), {Rotation = DropdownOpen and 180 or 0}):Play()
            end)

            BuildList(CurrentOptions)

            if FlagName then
                Self.Flags[FlagName] = Selected
                Self.Elements[FlagName] = { Set = UpdateSelection }
            end

            local DropdownAPI = {}
            function DropdownAPI:Refresh(newOptions, newDefault)
                CurrentOptions = newOptions
                UpdateSelection(newDefault or newOptions[1])
                if DropdownOpen then
                    BuildList(CurrentOptions)
                    local ListSize = (#CurrentOptions * 30)
                    TweenService:Create(DropFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 36 + ListSize)}):Play()
                end
            end
            function DropdownAPI:Set(value) UpdateSelection(value) end
            return DropdownAPI
        end

        --// MULTI-DROPDOWN (V10 New Feature) //--
        function TabObj:MultiDropdown(text, options, default, flag, tooltip, callback)
            local cb = callback or tooltip
            if type(tooltip) == "function" then tooltip = nil end

            local DropdownOpen = false
            local Selected = default or {}
            local CurrentOptions = options
            local FlagName = flag or text
            
            local DropFrame = Create("Frame", {
                Parent = Page, BackgroundColor3 = Colors.Element,
                Size = UDim2.new(1, 0, 0, 36), ClipsDescendants = true
            })
            Create("UICorner", {Parent = DropFrame, CornerRadius = UDim.new(0, 6)})
            Create("UIStroke", {Parent = DropFrame, Color = Colors.Stroke, Thickness = 1})

            local DropBtn = Create("TextButton", {
                Parent = DropFrame, Text = "", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 36)
            })

            Create("TextLabel", {
                Name = "Title", Parent = DropFrame, Text = text, TextColor3 = Colors.Text, Font = Enum.Font.GothamMedium,
                TextSize = 13, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(1, -12, 0, 36), TextXAlignment = Enum.TextXAlignment.Left
            })

            local SelectedLabel = Create("TextLabel", {
                Parent = DropFrame, Text = "...", TextColor3 = Colors.SubText, Font = Enum.Font.Gotham,
                TextSize = 12, BackgroundTransparency = 1, Position = UDim2.new(1, -130, 0, 0), Size = UDim2.new(0, 100, 0, 36), TextXAlignment = Enum.TextXAlignment.Right
            })

            local Arrow = Create("ImageLabel", {
                Parent = DropFrame, BackgroundTransparency = 1, Image = "rbxassetid://6031091004",
                ImageColor3 = Colors.SubText, Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(1, -24, 0, 10)
            })

            local OptionList = Create("Frame", {
                Parent = DropFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 36), Size = UDim2.new(1, 0, 0, 0)
            })
            Create("UIListLayout", {Parent = OptionList, SortOrder = Enum.SortOrder.LayoutOrder})

            AddTooltip(DropFrame, tooltip)

            local function UpdateLabel()
                if #Selected == 0 then SelectedLabel.Text = "None"
                elseif #Selected == 1 then SelectedLabel.Text = Selected[1]
                else SelectedLabel.Text = #Selected .. " Selected" end
            end

            local function ToggleOption(opt)
                if table.find(Selected, opt) then
                    for i, v in pairs(Selected) do if v == opt then table.remove(Selected, i) end end
                else
                    table.insert(Selected, opt)
                end
                UpdateLabel()
                if FlagName then Self.Flags[FlagName] = Selected end
                pcall(cb, Selected)
                Self:Save()
            end

            local function BuildList(opts)
                for _, v in pairs(OptionList:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
                for _, opt in pairs(opts) do
                    local IsSelected = table.find(Selected, opt)
                    local OptBtn = Create("TextButton", {
                        Parent = OptionList, Text = opt, TextColor3 = IsSelected and Colors.Accent or Colors.SubText, 
                        Font = Enum.Font.Gotham, TextSize = 12, BackgroundColor3 = Colors.Element, 
                        Size = UDim2.new(1, 0, 0, 30), AutoButtonColor = false
                    })
                    OptBtn.MouseButton1Click:Connect(function()
                        ToggleOption(opt)
                        OptBtn.TextColor3 = table.find(Selected, opt) and Colors.Accent or Colors.SubText
                    end)
                end
            end

            DropBtn.MouseButton1Click:Connect(function()
                DropdownOpen = not DropdownOpen
                if DropdownOpen then BuildList(CurrentOptions) end
                
                local ListSize = (#CurrentOptions * 30)
                local TargetSize = DropdownOpen and (36 + ListSize) or 36
                
                TweenService:Create(DropFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, TargetSize)}):Play()
                TweenService:Create(Arrow, TweenInfo.new(0.3), {Rotation = DropdownOpen and 180 or 0}):Play()
            end)

            UpdateLabel()

            if FlagName then
                Self.Flags[FlagName] = Selected
                Self.Elements[FlagName] = { 
                    Set = function(val) 
                        Selected = val
                        UpdateLabel()
                        pcall(cb, Selected)
                    end 
                }
            end

            return {
                Refresh = function(self, newOptions, newDefault)
                    CurrentOptions = newOptions
                    Selected = newDefault or {}
                    UpdateLabel()
                    if DropdownOpen then
                        BuildList(CurrentOptions)
                        local ListSize = (#CurrentOptions * 30)
                        TweenService:Create(DropFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 36 + ListSize)}):Play()
                    end
                end
            }
        end

        function TabObj:Keybind(text, default, callback)
            local Binding = default or Enum.KeyCode.RightControl
            local Waiting = false
            
            local KeyFrame = Create("Frame", {
                Parent = Page, BackgroundColor3 = Colors.Element,
                Size = UDim2.new(1, 0, 0, 36)
            })
            Create("UICorner", {Parent = KeyFrame, CornerRadius = UDim.new(0, 6)})
            Create("UIStroke", {Parent = KeyFrame, Color = Colors.Stroke, Thickness = 1})

            Create("TextLabel", {
                Name = "Title", Parent = KeyFrame, Text = text, TextColor3 = Colors.Text, Font = Enum.Font.GothamMedium,
                TextSize = 13, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(1, -12, 1, 0), TextXAlignment = Enum.TextXAlignment.Left
            })

            local BindBtn = Create("TextButton", {
                Parent = KeyFrame, Text = Binding.Name, TextColor3 = Colors.SubText, Font = Enum.Font.Gotham,
                TextSize = 12, BackgroundColor3 = Color3.fromRGB(40, 40, 45), Size = UDim2.new(0, 80, 0, 24),
                Position = UDim2.new(1, -90, 0.5, -12)
            })
            Create("UICorner", {Parent = BindBtn, CornerRadius = UDim.new(0, 4)})

            BindBtn.MouseButton1Click:Connect(function()
                Waiting = true
                BindBtn.Text = "..."
                BindBtn.TextColor3 = Colors.Accent
            end)

            UserInputService.InputBegan:Connect(function(input)
                if Waiting and input.UserInputType == Enum.UserInputType.Keyboard then
                    Binding = input.KeyCode
                    BindBtn.Text = Binding.Name
                    BindBtn.TextColor3 = Colors.SubText
                    Waiting = false
                    pcall(callback, Binding)
                end
            end)
        end

        function TabObj:Input(title, placeholder, flag, tooltip, callback)
            local cb = callback or tooltip
            if type(tooltip) == "function" then tooltip = nil end
            local FlagName = flag or title

            local InputFrame = Create("Frame", {
                Parent = Page, BackgroundColor3 = Colors.Element,
                Size = UDim2.new(1, 0, 0, 50)
            })
            Create("UICorner", {Parent = InputFrame, CornerRadius = UDim.new(0, 6)})
            Create("UIStroke", {Parent = InputFrame, Color = Colors.Stroke, Thickness = 1})

            Create("TextLabel", {
                Name = "Title", Parent = InputFrame, Text = title, TextColor3 = Colors.Text, Font = Enum.Font.GothamMedium,
                TextSize = 13, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 8), Size = UDim2.new(1, -24, 0, 15), TextXAlignment = Enum.TextXAlignment.Left
            })

            local InputBoxFrame = Create("Frame", {
                Parent = InputFrame, BackgroundColor3 = Color3.fromRGB(40, 40, 45),
                Position = UDim2.new(0, 12, 0, 28), Size = UDim2.new(1, -24, 0, 16)
            })
            Create("UICorner", {Parent = InputBoxFrame, CornerRadius = UDim.new(0, 4)})

            local InputBox = Create("TextBox", {
                Parent = InputBoxFrame, Text = "", PlaceholderText = placeholder or "Type here...",
                TextColor3 = Colors.SubText, PlaceholderColor3 = Color3.fromRGB(100, 100, 100),
                Font = Enum.Font.Gotham, TextSize = 12, BackgroundTransparency = 1,
                Size = UDim2.new(1, -8, 1, 0), Position = UDim2.new(0, 4, 0, 0),
                TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false
            })

            AddTooltip(InputFrame, tooltip)

            local function UpdateInput(text)
                InputBox.Text = text
                if FlagName then Self.Flags[FlagName] = text end
                pcall(cb, text)
                Self:Save()
            end

            InputBox.FocusLost:Connect(function(enterPressed)
                if not enterPressed then return end
                UpdateInput(InputBox.Text)
                TweenService:Create(InputFrame.UIStroke, TweenInfo.new(0.2), {Color = Colors.Accent}):Play()
                task.wait(0.2)
                TweenService:Create(InputFrame.UIStroke, TweenInfo.new(0.5), {Color = Colors.Stroke}):Play()
            end)

            if FlagName then
                Self.Flags[FlagName] = ""
                Self.Elements[FlagName] = { Set = UpdateInput }
            end

            return { Set = function(self, text) UpdateInput(text) end }
        end

        function TabObj:ColorPicker(title, default, flag, tooltip, callback)
            local cb = callback or tooltip
            if type(tooltip) == "function" then tooltip = nil end

            local ColorVal = default or Color3.fromRGB(255, 255, 255)
            local FlagName = flag or title
            local PickerOpen = false
            local RainbowMode = false
            
            local PickerFrame = Create("Frame", {
                Parent = Page, BackgroundColor3 = Colors.Element,
                Size = UDim2.new(1, 0, 0, 36), ClipsDescendants = true
            })
            Create("UICorner", {Parent = PickerFrame, CornerRadius = UDim.new(0, 6)})
            Create("UIStroke", {Parent = PickerFrame, Color = Colors.Stroke, Thickness = 1})

            Create("TextLabel", {
                Name = "Title", Parent = PickerFrame, Text = title, TextColor3 = Colors.Text, Font = Enum.Font.GothamMedium,
                TextSize = 13, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(1, -12, 0, 36), TextXAlignment = Enum.TextXAlignment.Left
            })

            local Preview = Create("TextButton", {
                Parent = PickerFrame, Text = "", BackgroundColor3 = ColorVal,
                Position = UDim2.new(1, -45, 0, 8), Size = UDim2.new(0, 35, 0, 20), AutoButtonColor = false
            })
            Create("UICorner", {Parent = Preview, CornerRadius = UDim.new(0, 4)})
            Create("UIStroke", {Parent = Preview, Color = Colors.Stroke, Thickness = 1})

            AddTooltip(PickerFrame, tooltip)

            local SettingsFrame = Create("Frame", {
                Parent = PickerFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 36), Size = UDim2.new(1, 0, 0, 65)
            })
            
            local RBox, GBox, BBox

            local function UpdateColor(newColor)
                ColorVal = newColor
                Preview.BackgroundColor3 = ColorVal
                if RBox then RBox.Text = math.floor(ColorVal.R*255) end
                if GBox then GBox.Text = math.floor(ColorVal.G*255) end
                if BBox then BBox.Text = math.floor(ColorVal.B*255) end
                
                if FlagName then 
                    Self.Flags[FlagName] = {R = ColorVal.R, G = ColorVal.G, B = ColorVal.B} 
                end
                pcall(cb, ColorVal)
                Self:Save()
            end

            local function CreateRGBInput(name, pos, getVal, setVal)
                local Box = Create("TextBox", {
                    Parent = SettingsFrame, Text = tostring(getVal()), PlaceholderText = name,
                    BackgroundColor3 = Color3.fromRGB(40, 40, 45), TextColor3 = Colors.SubText,
                    Font = Enum.Font.Gotham, TextSize = 12, Position = pos, Size = UDim2.new(0, 40, 0, 25)
                })
                Create("UICorner", {Parent = Box, CornerRadius = UDim.new(0, 4)})
                Box.FocusLost:Connect(function()
                    local num = tonumber(Box.Text)
                    if num then setVal(math.clamp(num, 0, 255)) end
                    UpdateColor(ColorVal)
                end)
                return Box
            end

            RBox = CreateRGBInput("R", UDim2.new(0, 12, 0, 5), function() return math.floor(ColorVal.R*255) end, function(v) ColorVal = Color3.fromRGB(v, ColorVal.G*255, ColorVal.B*255) end)
            GBox = CreateRGBInput("G", UDim2.new(0, 60, 0, 5), function() return math.floor(ColorVal.G*255) end, function(v) ColorVal = Color3.fromRGB(ColorVal.R*255, v, ColorVal.B*255) end)
            BBox = CreateRGBInput("B", UDim2.new(0, 108, 0, 5), function() return math.floor(ColorVal.B*255) end, function(v) ColorVal = Color3.fromRGB(ColorVal.R*255, ColorVal.G*255, v) end)

            local RainbowBtn = Create("TextButton", {
                Parent = SettingsFrame, Text = "Rainbow", BackgroundColor3 = Color3.fromRGB(40, 40, 45),
                TextColor3 = Colors.SubText, Font = Enum.Font.Gotham, TextSize = 11,
                Position = UDim2.new(1, -70, 0, 5), Size = UDim2.new(0, 60, 0, 25)
            })
            Create("UICorner", {Parent = RainbowBtn, CornerRadius = UDim.new(0, 4)})

            RainbowBtn.MouseButton1Click:Connect(function()
                RainbowMode = not RainbowMode
                RainbowBtn.TextColor3 = RainbowMode and Colors.Accent or Colors.SubText
                if RainbowMode then
                    task.spawn(function()
                        while RainbowMode and PickerFrame.Parent do
                            local hue = tick() % 5 / 5
                            UpdateColor(Color3.fromHSV(hue, 1, 1))
                            task.wait()
                        end
                    end)
                end
            end)

            Preview.MouseButton1Click:Connect(function()
                PickerOpen = not PickerOpen
                TweenService:Create(PickerFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, PickerOpen and 80 or 36)}):Play()
            end)

            if FlagName then
                Self.Flags[FlagName] = {R = ColorVal.R, G = ColorVal.G, B = ColorVal.B}
                Self.Elements[FlagName] = { 
                    Set = function(val) 
                        if typeof(val) == "table" then
                            UpdateColor(Color3.new(val.R, val.G, val.B))
                        else
                            UpdateColor(val)
                        end
                    end 
                }
            end
        end

        function TabObj:Paragraph(title, content)
            local ParaFrame = Create("Frame", {
                Parent = Page, BackgroundColor3 = Colors.Element,
                Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y
            })
            Create("UICorner", {Parent = ParaFrame, CornerRadius = UDim.new(0, 6)})
            Create("UIStroke", {Parent = ParaFrame, Color = Colors.Stroke, Thickness = 1})
            Create("UIPadding", {Parent = ParaFrame, PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10), PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12)})

            local ParaTitle = Create("TextLabel", {
                Name = "Title", Parent = ParaFrame, Text = title, TextColor3 = Colors.Accent, Font = Enum.Font.GothamBold,
                TextSize = 14, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 15), TextXAlignment = Enum.TextXAlignment.Left
            })

            local ParaContent = Create("TextLabel", {
                Parent = ParaFrame, Text = content, TextColor3 = Colors.SubText, Font = Enum.Font.Gotham,
                TextSize = 12, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), 
                TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, AutomaticSize = Enum.AutomaticSize.Y,
                Position = UDim2.new(0, 0, 0, 20)
            })
            
            Create("Frame", {Parent = ParaFrame, BackgroundTransparency = 1, Size = UDim2.new(1,0,0,20), LayoutOrder = 100})
        end

        function TabObj:Label(text)
            local LabelFrame = Create("Frame", {
                Parent = Page, BackgroundColor3 = Colors.Element,
                Size = UDim2.new(1, 0, 0, 26)
            })
            Create("UICorner", {Parent = LabelFrame, CornerRadius = UDim.new(0, 6)})

            local LabelText = Create("TextLabel", {
                Name = "Title", Parent = LabelFrame, Text = text, TextColor3 = Colors.SubText, Font = Enum.Font.Gotham,
                TextSize = 12, BackgroundTransparency = 1, Size = UDim2.new(1, -20, 1, 0), Position = UDim2.new(0, 10, 0, 0),
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            Create("ImageLabel", {
                Parent = LabelFrame, BackgroundTransparency = 1, Image = "rbxassetid://3926305904",
                ImageRectOffset = Vector2.new(404, 644), ImageRectSize = Vector2.new(36, 36),
                ImageColor3 = Colors.SubText, Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(1, -24, 0.5, -7)
            })

            local LabelFuncs = {}
            function LabelFuncs:Set(newText)
                LabelText.Text = newText
            end
            return LabelFuncs
        end

        return TabObj
    end

    return Self
end

return SlenderWind
