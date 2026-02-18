--[[ 
    FLUXA UI LIBRARY v4 (Sleek Minimalist)
    Style: No Borders, Soft Shadows, Smooth Animations, Modern Dark
]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

--// 1. Setup & Security
local Fluxa = {}
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Fluxa_v4"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false

if syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = CoreGui
elseif gethui then
    ScreenGui.Parent = gethui()
else
    ScreenGui.Parent = CoreGui
end

--// 2. Theme (Modern Slate Palette)
Fluxa.Theme = {
    Background  = Color3.fromRGB(20, 22, 26),      -- 메인 배경 (아주 어두운 남색 계열)
    Sidebar     = Color3.fromRGB(26, 29, 36),      -- 사이드바
    Element     = Color3.fromRGB(32, 35, 43),      -- 요소 배경 (버튼 등)
    Hover       = Color3.fromRGB(40, 44, 54),      -- 호버 시 색상
    Accent      = Color3.fromRGB(100, 130, 240),   -- 포인트 컬러 (Soft Slate Blue)
    Text        = Color3.fromRGB(240, 240, 245),   -- 메인 텍스트
    SubText     = Color3.fromRGB(140, 145, 155),   -- 보조 텍스트
}
Fluxa.Flags = {}
Fluxa.Folder = "FluxaConfigs"

--// 3. Utils
local function Create(class, props)
    local inst = Instance.new(class)
    for k,v in pairs(props) do inst[k] = v end
    return inst
end

local function AddCorner(parent, radius)
    Create("UICorner", {Parent = parent, CornerRadius = UDim.new(0, radius or 8)})
end

local function Tween(obj, props, time)
    TweenService:Create(obj, TweenInfo.new(time or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

-- Drag Function
local function MakeDraggable(trigger, object)
    local dragging, dragInput, dragStart, startPos
    trigger.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = object.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    trigger.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            Tween(object, {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}, 0.05)
        end
    end)
end

--// 4. Main Library
function Fluxa:Window(options)
    local TitleText = options.Name or "Fluxa"
    local WindowFuncs = {}
    
    -- Main Window
    local Main = Create("Frame", {
        Name = "Main", Parent = ScreenGui,
        BackgroundColor3 = Fluxa.Theme.Background,
        Position = UDim2.new(0.5, -300, 0.5, -200),
        Size = UDim2.new(0, 600, 0, 420),
        ClipsDescendants = true
    })
    AddCorner(Main, 10)
    -- Drop Shadow (Fake with UIStroke for cleanliness)
    local Shadow = Create("UIStroke", {
        Parent = Main, Thickness = 1, Color = Color3.fromRGB(45, 45, 50), ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Transparency = 0.5
    })

    -- Sidebar
    local Sidebar = Create("Frame", {
        Parent = Main, BackgroundColor3 = Fluxa.Theme.Sidebar,
        Size = UDim2.new(0, 160, 1, 0), Position = UDim2.new(0, 0, 0, 0)
    })
    AddCorner(Sidebar, 10)
    -- Hide right corners of sidebar
    Create("Frame", {
        Parent = Sidebar, BackgroundColor3 = Fluxa.Theme.Sidebar,
        Size = UDim2.new(0, 10, 1, 0), Position = UDim2.new(1, -10, 0, 0), BorderSizePixel = 0
    })

    -- Title Area
    local TitleLabel = Create("TextLabel", {
        Parent = Sidebar, BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 0, 50), Position = UDim2.new(0, 20, 0, 0),
        Font = Enum.Font.GothamBold, Text = TitleText,
        TextColor3 = Fluxa.Theme.Accent, TextSize = 20, TextXAlignment = Enum.TextXAlignment.Left
    })
    
    -- Tab Holder
    local TabContainer = Create("ScrollingFrame", {
        Parent = Sidebar, BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, -60), Position = UDim2.new(0, 0, 0, 60),
        ScrollBarThickness = 0, CanvasSize = UDim2.new(0,0,0,0)
    })
    local TabList = Create("UIListLayout", {
        Parent = TabContainer, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8)
    })
    Create("UIPadding", {Parent = TabContainer, PaddingLeft = UDim.new(0, 10)})

    -- Content Area
    local Content = Create("Frame", {
        Parent = Main, BackgroundTransparency = 1,
        Size = UDim2.new(1, -170, 1, -20), Position = UDim2.new(0, 170, 0, 10)
    })
    
    -- Draggable Area (Top of Main)
    local DragFrame = Create("Frame", {
        Parent = Main, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 50)
    })
    MakeDraggable(DragFrame, Main)

    local Tabs = {}
    local SelectedTab = nil

    function WindowFuncs:Tab(name)
        local TabFuncs = {}
        
        -- Tab Button
        local TabBtn = Create("TextButton", {
            Parent = TabContainer, BackgroundColor3 = Fluxa.Theme.Sidebar,
            Size = UDim2.new(1, -20, 0, 36), AutoButtonColor = false,
            Text = "", BackgroundTransparency = 1
        })
        AddCorner(TabBtn, 6)

        local TabText = Create("TextLabel", {
            Parent = TabBtn, BackgroundTransparency = 1,
            Size = UDim2.new(1, -20, 1, 0), Position = UDim2.new(0, 15, 0, 0),
            Font = Enum.Font.GothamMedium, Text = name,
            TextColor3 = Fluxa.Theme.SubText, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left
        })
        
        -- Selection Indicator
        local Indicator = Create("Frame", {
            Parent = TabBtn, BackgroundColor3 = Fluxa.Theme.Accent,
            Size = UDim2.new(0, 3, 0, 16), Position = UDim2.new(0, 0, 0.5, -8),
            Transparency = 1
        })
        AddCorner(Indicator, 2)

        -- Page
        local Page = Create("ScrollingFrame", {
            Parent = Content, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0), Visible = false,
            ScrollBarThickness = 2, ScrollBarImageColor3 = Fluxa.Theme.Element,
            CanvasSize = UDim2.new(0,0,0,0), BorderSizePixel = 0
        })
        local PageLayout = Create("UIListLayout", {
            Parent = Page, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10)
        })
        Create("UIPadding", {Parent = Page, PaddingRight = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10)})

        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0,0,0, PageLayout.AbsoluteContentSize.Y + 20)
        end)

        -- Tab Animation Logic
        local function Activate()
            if SelectedTab then
                Tween(SelectedTab.Text, {TextColor3 = Fluxa.Theme.SubText})
                Tween(SelectedTab.Indicator, {Transparency = 1})
                SelectedTab.Page.Visible = false
            end
            
            SelectedTab = {Btn = TabBtn, Text = TabText, Indicator = Indicator, Page = Page}
            Tween(TabText, {TextColor3 = Fluxa.Theme.Text})
            Tween(Indicator, {Transparency = 0})
            Page.Visible = true
        end

        TabBtn.MouseButton1Click:Connect(Activate)
        
        -- First Tab Auto Select
        if #Tabs == 0 then Activate() end
        table.insert(Tabs, {Btn = TabBtn})

        --// SECTIONS (Just titles, no boxes for clean look)
        function TabFuncs:Section(text)
            local SectionFuncs = {}
            
            -- Spacer if not first
            if #Page:GetChildren() > 2 then
                Create("Frame", {Parent = Page, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 10)})
            end

            local Label = Create("TextLabel", {
                Parent = Page, BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 24),
                Font = Enum.Font.GothamBold, Text = string.upper(text),
                TextColor3 = Fluxa.Theme.SubText, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left
            })
            Create("UIPadding", {Parent = Label, PaddingLeft = UDim.new(0, 4)})

            --// TOGGLE (Switch Style)
            function SectionFuncs:Toggle(text, default, callback)
                local Toggled = default or false
                Fluxa.Flags[text] = Toggled
                
                local ToggleBtn = Create("TextButton", {
                    Parent = Page, BackgroundColor3 = Fluxa.Theme.Element,
                    Size = UDim2.new(1, 0, 0, 40), AutoButtonColor = false, Text = ""
                })
                AddCorner(ToggleBtn, 8)
                
                local Title = Create("TextLabel", {
                    Parent = ToggleBtn, BackgroundTransparency = 1,
                    Position = UDim2.new(0, 15, 0, 0), Size = UDim2.new(1, -60, 1, 0),
                    Font = Enum.Font.GothamMedium, Text = text,
                    TextColor3 = Fluxa.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left
                })

                local Switch = Create("Frame", {
                    Parent = ToggleBtn, BackgroundColor3 = Fluxa.Theme.Sidebar,
                    Position = UDim2.new(1, -45, 0.5, -10), Size = UDim2.new(0, 32, 0, 20)
                })
                AddCorner(Switch, 10)
                
                local Knob = Create("Frame", {
                    Parent = Switch, BackgroundColor3 = Fluxa.Theme.SubText,
                    Position = UDim2.new(0, 3, 0.5, -7), Size = UDim2.new(0, 14, 0, 14)
                })
                AddCorner(Knob, 10)

                local function Update()
                    Fluxa.Flags[text] = Toggled
                    if Toggled then
                        Tween(Switch, {BackgroundColor3 = Fluxa.Theme.Accent})
                        Tween(Knob, {Position = UDim2.new(1, -17, 0.5, -7), BackgroundColor3 = Color3.new(1,1,1)})
                    else
                        Tween(Switch, {BackgroundColor3 = Fluxa.Theme.Sidebar})
                        Tween(Knob, {Position = UDim2.new(0, 3, 0.5, -7), BackgroundColor3 = Fluxa.Theme.SubText})
                    end
                    if callback then callback(Toggled) end
                end
                
                if default then Update() end

                ToggleBtn.MouseButton1Click:Connect(function()
                    Toggled = not Toggled
                    Update()
                end)
            end

            --// SLIDER
            function SectionFuncs:Slider(text, min, max, default, callback)
                Fluxa.Flags[text] = default or min
                local Value = default or min
                
                local SliderFrame = Create("Frame", {
                    Parent = Page, BackgroundColor3 = Fluxa.Theme.Element,
                    Size = UDim2.new(1, 0, 0, 55)
                })
                AddCorner(SliderFrame, 8)

                local Title = Create("TextLabel", {
                    Parent = SliderFrame, BackgroundTransparency = 1,
                    Position = UDim2.new(0, 15, 0, 10), Size = UDim2.new(1, -30, 0, 20),
                    Font = Enum.Font.GothamMedium, Text = text,
                    TextColor3 = Fluxa.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local ValueLabel = Create("TextLabel", {
                    Parent = SliderFrame, BackgroundTransparency = 1,
                    Position = UDim2.new(1, -50, 0, 10), Size = UDim2.new(0, 35, 0, 20),
                    Font = Enum.Font.Gotham, Text = tostring(Value),
                    TextColor3 = Fluxa.Theme.Accent, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Right
                })

                local Track = Create("Frame", {
                    Parent = SliderFrame, BackgroundColor3 = Fluxa.Theme.Sidebar,
                    Position = UDim2.new(0, 15, 0, 35), Size = UDim2.new(1, -30, 0, 6)
                })
                AddCorner(Track, 3)

                local Fill = Create("Frame", {
                    Parent = Track, BackgroundColor3 = Fluxa.Theme.Accent,
                    Size = UDim2.new((Value - min) / (max - min), 0, 1, 0)
                })
                AddCorner(Fill, 3)

                local Trigger = Create("TextButton", {
                    Parent = SliderFrame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Text = ""
                })

                local function Update(input)
                    local SizeX = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                    local NewVal = math.floor(min + ((max - min) * SizeX))
                    Value = NewVal
                    Fluxa.Flags[text] = Value
                    ValueLabel.Text = tostring(Value)
                    Tween(Fill, {Size = UDim2.new(SizeX, 0, 1, 0)}, 0.05)
                    if callback then callback(Value) end
                end

                Trigger.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Update(input)
                        local move = RunService.RenderStepped:Connect(function()
                            Update(UserInputService:GetMouseLocation())
                            if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                                move:Disconnect()
                            end
                        end)
                    end
                end)
            end

            --// BUTTON
            function SectionFuncs:Button(text, callback)
                local Btn = Create("TextButton", {
                    Parent = Page, BackgroundColor3 = Fluxa.Theme.Element,
                    Size = UDim2.new(1, 0, 0, 40), AutoButtonColor = false,
                    Font = Enum.Font.GothamMedium, Text = text,
                    TextColor3 = Fluxa.Theme.Text, TextSize = 13
                })
                AddCorner(Btn, 8)
                
                Btn.MouseEnter:Connect(function() Tween(Btn, {BackgroundColor3 = Fluxa.Theme.Hover}) end)
                Btn.MouseLeave:Connect(function() Tween(Btn, {BackgroundColor3 = Fluxa.Theme.Element}) end)
                Btn.MouseButton1Click:Connect(function()
                    Tween(Btn, {TextColor3 = Fluxa.Theme.Accent}, 0.1)
                    task.wait(0.1)
                    Tween(Btn, {TextColor3 = Fluxa.Theme.Text}, 0.1)
                    if callback then callback() end
                end)
            end
            
            --// DROPDOWN (Expandable)
            function SectionFuncs:Dropdown(text, items, callback)
                local Open = false
                
                local DropFrame = Create("Frame", {
                    Parent = Page, BackgroundColor3 = Fluxa.Theme.Element,
                    Size = UDim2.new(1, 0, 0, 40), ClipsDescendants = true
                })
                AddCorner(DropFrame, 8)
                
                local Title = Create("TextLabel", {
                    Parent = DropFrame, BackgroundTransparency = 1,
                    Position = UDim2.new(0, 15, 0, 0), Size = UDim2.new(1, -40, 0, 40),
                    Font = Enum.Font.GothamMedium, Text = text,
                    TextColor3 = Fluxa.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local Arrow = Create("TextLabel", {
                    Parent = DropFrame, BackgroundTransparency = 1,
                    Position = UDim2.new(1, -30, 0, 0), Size = UDim2.new(0, 20, 0, 40),
                    Font = Enum.Font.GothamBold, Text = "+",
                    TextColor3 = Fluxa.Theme.SubText, TextSize = 16
                })
                
                local Trigger = Create("TextButton", {
                    Parent = DropFrame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 40), Text = ""
                })
                
                local List = Create("Frame", {
                    Parent = DropFrame, BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 45), Size = UDim2.new(1, 0, 0, 0)
                })
                local ListLayout = Create("UIListLayout", {
                    Parent = List, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5)
                })
                Create("UIPadding", {Parent = List, PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10)})
                
                -- Refresh Items
                local function Refresh()
                    for _,v in pairs(List:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
                    
                    for _, item in pairs(items) do
                        local ItemBtn = Create("TextButton", {
                            Parent = List, BackgroundColor3 = Fluxa.Theme.Sidebar,
                            Size = UDim2.new(1, 0, 0, 30), AutoButtonColor = false,
                            Font = Enum.Font.Gotham, Text = item,
                            TextColor3 = Fluxa.Theme.SubText, TextSize = 12
                        })
                        AddCorner(ItemBtn, 6)
                        
                        ItemBtn.MouseButton1Click:Connect(function()
                            Title.Text = text .. ": " .. item
                            Title.TextColor3 = Fluxa.Theme.Accent
                            if callback then callback(item) end
                            -- Close
                            Open = false
                            Tween(DropFrame, {Size = UDim2.new(1, 0, 0, 40)})
                            Arrow.Text = "+"
                        end)
                    end
                end
                Refresh()

                Trigger.MouseButton1Click:Connect(function()
                    Open = not Open
                    if Open then
                        local contentHeight = ListLayout.AbsoluteContentSize.Y + 50
                        Tween(DropFrame, {Size = UDim2.new(1, 0, 0, contentHeight)})
                        Arrow.Text = "-"
                    else
                        Tween(DropFrame, {Size = UDim2.new(1, 0, 0, 40)})
                        Arrow.Text = "+"
                    end
                end)
            end

            return SectionFuncs
        end
        return TabFuncs
    end
    
    -- Configs (Simple)
    local SettingTab = WindowFuncs:Tab("Settings")
    local SettingSec = SettingTab:Section("Data")
    
    local CfgName = "default"
    SettingSec:Button("Save Config", function()
        if not isfolder(Fluxa.Folder) then makefolder(Fluxa.Folder) end
        writefile(Fluxa.Folder.."/"..CfgName..".json", HttpService:JSONEncode(Fluxa.Flags))
    end)

    return WindowFuncs
end

return Fluxa
