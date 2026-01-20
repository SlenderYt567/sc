--[[ 
    SlenderWind UI - Library Source
    Version: V5.1 (Production Build)
    Architect: SlenderHub Lead
    
    Features:
    - Secure Gateway (Key System)
    - Dynamic HUD (FPS/Ping/Time)
    - Search Engine
    - Rayfield-like Components
]]

local SlenderWind = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local Stats = game:GetService("Stats")

--// SlenderHub Standards: Singleton Check
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
        TweenService:Create(object, TweenInfo.new(0.15), {Position = Target}):Play()
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

    -- Theme Colors
    local Colors = {
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
        Error = Color3.fromRGB(255, 85, 85)
    }

    -- GUI Setup
    local ParentTarget = (RunService:IsStudio() and Players.LocalPlayer.PlayerGui or CoreGui)
    if ParentTarget:FindFirstChild("SlenderWind") then
        ParentTarget.SlenderWind:Destroy()
    end

    local ScreenGui = Create("ScreenGui", {Name = "SlenderWind", Parent = ParentTarget, ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling})

    -- Notification Container
    local NotifyContainer = Create("Frame", {
        Parent = ScreenGui, BackgroundTransparency = 1,
        Position = UDim2.new(1, -320, 1, -20), Size = UDim2.new(0, 300, 1, 0),
        AnchorPoint = Vector2.new(0, 1)
    })
    Create("UIListLayout", {Parent = NotifyContainer, SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Bottom, Padding = UDim.new(0, 5)})

    -- Main Container (Hidden initially if KeySystem is on)
    local Main = Create("Frame", {
        Name = "Main", Parent = ScreenGui, BackgroundColor3 = Colors.MainBg,
        Position = UDim2.new(0.5, -325, 0.5, -210), Size = UDim2.new(0, 650, 0, 420),
        ClipsDescendants = true, Visible = not Self.KeySystem
    })
    Create("UICorner", {Parent = Main, CornerRadius = UDim.new(0, 10)})
    Create("UIStroke", {Parent = Main, Color = Colors.Stroke, Thickness = 1})

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

        Create("TextLabel", {
            Parent = KeyFrame, Text = Self.KeySettings.Subtitle or "Enter your access key", 
            TextColor3 = Colors.SubText, Font = Enum.Font.Gotham, TextSize = 12,
            Position = UDim2.new(0, 0, 0, 35), Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1
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

        -- Key Logic
        CheckBtn.MouseButton1Click:Connect(function()
            if KeyInput.Text == Self.KeySettings.Key then
                -- Success
                TweenService:Create(KeyFrame, TweenInfo.new(0.5), {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}):Play()
                task.wait(0.5)
                KeyFrame:Destroy()
                Main.Visible = true
                TweenService:Create(Main, TweenInfo.new(0.5), {BackgroundTransparency = 0}):Play()
                
                -- Notify
                Self:Notify("Access Granted", "Welcome to SlenderHub.", 3)
            else
                -- Fail
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
            else
                Self:Notify("Error", "Your executor does not support setclipboard", 3)
            end
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

        -- Update Loop
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
    
    -- Sidebar (Left)
    local Sidebar = Create("Frame", {
        Parent = Main, BackgroundColor3 = Colors.Sidebar,
        Size = UDim2.new(0, 190, 1, 0), BorderSizePixel = 0
    })
    Create("UICorner", {Parent = Sidebar, CornerRadius = UDim.new(0, 10)})
    Create("Frame", {Parent = Sidebar, BackgroundColor3 = Colors.Sidebar, Size = UDim2.new(0, 10, 1, 0), Position = UDim2.new(1, -10, 0, 0), BorderSizePixel = 0})

    -- Vertical Separator Line
    local Separator = Create("Frame", {
        Parent = Main, BackgroundColor3 = Colors.Separator,
        Size = UDim2.new(0, 1, 1, 0), Position = UDim2.new(0, 190, 0, 0), BorderSizePixel = 0, ZIndex = 5
    })

    -- Controls
    local Controls = Create("Frame", {Parent = Sidebar, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 50)})
    local CloseBtn = Create("TextButton", {Parent = Controls, Text = "", BackgroundColor3 = Color3.fromRGB(255, 95, 87), Position = UDim2.new(0, 15, 0, 18), Size = UDim2.new(0, 12, 0, 12), AutoButtonColor = false})
    Create("UICorner", {Parent = CloseBtn, CornerRadius = UDim.new(1, 0)})
    local MinBtn = Create("TextButton", {Parent = Controls, Text = "", BackgroundColor3 = Color3.fromRGB(255, 189, 46), Position = UDim2.new(0, 35, 0, 18), Size = UDim2.new(0, 12, 0, 12), AutoButtonColor = false})
    Create("UICorner", {Parent = MinBtn, CornerRadius = UDim.new(1, 0)})
    local MaxBtn = Create("Frame", {Parent = Controls, BackgroundColor3 = Color3.fromRGB(39, 201, 63), Position = UDim2.new(0, 55, 0, 18), Size = UDim2.new(0, 12, 0, 12)})
    Create("UICorner", {Parent = MaxBtn, CornerRadius = UDim.new(1, 0)})

    -- Title
    Create("TextLabel", {
        Parent = Controls, Text = Self.Name, TextColor3 = Colors.Text,
        Font = Enum.Font.GothamBold, TextSize = 14, BackgroundTransparency = 1,
        Position = UDim2.new(0, 80, 0, 0), Size = UDim2.new(1, -85, 1, 0), 
        TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd
    })

    -- Search Bar
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

    -- Tab Container
    local TabHolder = Create("ScrollingFrame", {
        Parent = Sidebar, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 95), Size = UDim2.new(1, 0, 1, -100),
        ScrollBarThickness = 0, CanvasSize = UDim2.new(0,0,0,0)
    })
    Create("UIListLayout", {Parent = TabHolder, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5)})
    Create("UIPadding", {Parent = TabHolder, PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10)})

    -- Content Area
    local ContentArea = Create("Frame", {
        Parent = Main, BackgroundTransparency = 1,
        Position = UDim2.new(0, 205, 0, 15), Size = UDim2.new(1, -220, 1, -30)
    })

    -- Mobile/Minimize Icon
    local OpenBtn = Create("TextButton", {
        Parent = ScreenGui, Text = "SH", TextColor3 = Colors.Accent, BackgroundColor3 = Colors.Sidebar,
        Size = UDim2.new(0, 45, 0, 45), Position = UDim2.new(0, 20, 0.5, 0),
        Font = Enum.Font.GothamBlack, TextSize = 16, Visible = false
    })
    Create("UICorner", {Parent = OpenBtn, CornerRadius = UDim.new(0, 12)})
    Create("UIStroke", {Parent = OpenBtn, Color = Colors.Stroke, Thickness = 2})
    MakeDraggable(OpenBtn, OpenBtn)

    -- Logic
    MakeDraggable(Sidebar, Main)

    local function ToggleUI()
        Main.Visible = not Main.Visible
        OpenBtn.Visible = not Main.Visible
    end

    CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
    MinBtn.MouseButton1Click:Connect(ToggleUI)
    OpenBtn.MouseButton1Click:Connect(ToggleUI)

    UserInputService.InputBegan:Connect(function(input, gp)
        if not gp and input.KeyCode == Self.Keybind then ToggleUI() end
    end)

    -- Notification Function
    function Self:Notify(title, text, duration)
        local Notif = Create("Frame", {
            Parent = NotifyContainer, BackgroundColor3 = Colors.Sidebar,
            Size = UDim2.new(1, 0, 0, 60), BackgroundTransparency = 1
        })
        Create("UICorner", {Parent = Notif, CornerRadius = UDim.new(0, 8)})
        Create("UIStroke", {Parent = Notif, Color = Colors.Stroke, Thickness = 1, Transparency = 1})
        
        local NTitle = Create("TextLabel", {
            Parent = Notif, Text = title, TextColor3 = Colors.Accent, Font = Enum.Font.GothamBold,
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

    -- Tab System
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

        function TabObj:Button(text, callback)
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

            BtnFrame.MouseButton1Click:Connect(function()
                TweenService:Create(BtnFrame, TweenInfo.new(0.1), {BackgroundColor3 = Colors.Stroke}):Play()
                task.wait(0.1)
                TweenService:Create(BtnFrame, TweenInfo.new(0.3), {BackgroundColor3 = Colors.Element}):Play()
                pcall(callback)
            end)
        end

        function TabObj:Toggle(text, default, callback)
            local Enabled = default or false
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

            TogFrame.MouseButton1Click:Connect(function()
                Enabled = not Enabled
                local TargetPos = (Enabled and 18) or 2
                local TargetColor = (Enabled and Colors.Accent) or Color3.fromRGB(50, 50, 55)
                TweenService:Create(Knob, TweenInfo.new(0.2), {Position = UDim2.new(0, TargetPos, 0.5, -8)}):Play()
                TweenService:Create(Switch, TweenInfo.new(0.2), {BackgroundColor3 = TargetColor}):Play()
                pcall(callback, Enabled)
            end)
        end

        function TabObj:Slider(text, min, max, default, callback)
            local Value = default or min
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
            
            local ValueLabel = Create("TextLabel", {
                Parent = SliderFrame, Text = tostring(Value), TextColor3 = Colors.SubText, Font = Enum.Font.Gotham,
                TextSize = 12, BackgroundTransparency = 1, Position = UDim2.new(1, -40, 0, 8), Size = UDim2.new(0, 30, 0, 15), TextXAlignment = Enum.TextXAlignment.Right
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

            local Dragging = false
            local function Update(input)
                local SizeX = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                local NewValue = math.floor(min + ((max - min) * SizeX))
                ValueLabel.Text = tostring(NewValue)
                TweenService:Create(Fill, TweenInfo.new(0.05), {Size = UDim2.new(SizeX, 0, 1, 0)}):Play()
                pcall(callback, NewValue)
            end

            Track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    Dragging = true; Update(input)
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    Update(input)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then Dragging = false end
            end)
        end

        function TabObj:Dropdown(text, options, default, callback)
            local DropdownOpen = false
            local Selected = default or options[1]
            
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
            local ListLayout = Create("UIListLayout", {Parent = OptionList, SortOrder = Enum.SortOrder.LayoutOrder})

            local function RefreshOptions()
                for _, v in pairs(OptionList:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
                for _, opt in pairs(options) do
                    local OptBtn = Create("TextButton", {
                        Parent = OptionList, Text = opt, TextColor3 = Colors.SubText, Font = Enum.Font.Gotham,
                        TextSize = 12, BackgroundColor3 = Colors.Element, Size = UDim2.new(1, 0, 0, 30), AutoButtonColor = false
                    })
                    OptBtn.MouseButton1Click:Connect(function()
                        Selected = opt
                        SelectedLabel.Text = Selected
                        pcall(callback, Selected)
                        DropBtn.Fire()
                    end)
                end
            end

            DropBtn.MouseButton1Click:Connect(function()
                DropdownOpen = not DropdownOpen
                RefreshOptions()
                local ListSize = (#options * 30)
                local TargetSize = DropdownOpen and (36 + ListSize) or 36
                
                TweenService:Create(DropFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, TargetSize)}):Play()
                TweenService:Create(Arrow, TweenInfo.new(0.3), {Rotation = DropdownOpen and 180 or 0}):Play()
            end)
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

        return TabObj
    end

    return Self
end

return SlenderWind
