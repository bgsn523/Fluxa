--[[ 
    FLUXA UI LIBRARY v3 (Red/Dark Style)
    Based on image_1.png style: Dark background, red accents, left sidebar tabs.
]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

--// 1. Root & Security
local Fluxa = {}
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FluxaUI_v3"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false

-- ProtectGui Logic
if syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = CoreGui
elseif gethui then
    ScreenGui.Parent = gethui()
else
    ScreenGui.Parent = CoreGui
end

--// 2. Theming (Red/Dark Palette)
Fluxa.Theme = {
    Main        = Color3.fromRGB(15, 15, 15),      -- 메인 배경 (진한 검정)
    Sidebar     = Color3.fromRGB(15, 15, 15),      -- 사이드바 (동일한 검정)
    Content     = Color3.fromRGB(20, 20, 20),      -- 컨텐츠 영역 (약간 밝은 검정)
    Element     = Color3.fromRGB(25, 25, 25),      -- 요소 배경
    ElementHover= Color3.fromRGB(35, 35, 35),      -- 요소 호버
    Accent      = Color3.fromRGB(255, 50, 50),     -- 강렬한 붉은색 악센트
    Text        = Color3.fromRGB(240, 240, 240),   -- 흰색 텍스트
    SubText     = Color3.fromRGB(180, 180, 180),   -- 보조 텍스트
    Outline     = Color3.fromRGB(40, 40, 40),      -- 외곽선
    Divider     = Color3.fromRGB(30, 30, 30)       -- 구분선
}

Fluxa.Flags = {}
Fluxa.Folder = "FluxaConfigs"

--// 3. Utility Functions
local function Create(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props) do inst[k] = v end
    return inst
end

local function AddStroke(parent, color, thickness, transparency)
    Create("UIStroke", {
        Parent = parent, 
        Color = color or Fluxa.Theme.Outline, 
        Thickness = thickness or 1, 
        Transparency = transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    })
end

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
            TweenService:Create(object, TweenInfo.new(0.05, Enum.EasingStyle.Linear), {
                Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            }):Play()
        end
    end)
end

--// 4. Main Window Function
function Fluxa:Window(options)
    local Title = options.Name or "Fluxa"
    local ConfigName = options.Config or "default"
    
    local WindowFuncs = {}
    
    -- Main Container
    local MainFrame = Create("Frame", {
        Name = "MainFrame", Parent = ScreenGui,
        BackgroundColor3 = Fluxa.Theme.Main,
        Position = UDim2.new(0.5, -300, 0.5, -200),
        Size = UDim2.new(0, 600, 0, 400),
        ClipsDescendants = true,
        BorderSizePixel = 0
    })
    -- Top Red Accent Line
    Create("Frame", {
        Parent = MainFrame, BackgroundColor3 = Fluxa.Theme.Accent,
        Size = UDim2.new(1, 0, 0, 2), Position = UDim2.new(0, 0, 0, 0), BorderSizePixel = 0
    })
    AddStroke(MainFrame, Fluxa.Theme.Accent, 1, 0.5) -- 전체 붉은 테두리

    -- Title Bar (Draggable)
    local TitleBar = Create("Frame", {
        Parent = MainFrame, BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 30), Position = UDim2.new(0, 0, 0, 2)
    })
    local TitleLabel = Create("TextLabel", {
        Parent = TitleBar, BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 1, 0), Position = UDim2.new(0, 10, 0, 0),
        Font = Enum.Font.GothamBold, Text = Title,
        TextColor3 = Fluxa.Theme.Text, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left
    })
    MakeDraggable(TitleBar, MainFrame)

    -- Sidebar
    local Sidebar = Create("Frame", {
        Parent = MainFrame, BackgroundColor3 = Fluxa.Theme.Sidebar,
        Size = UDim2.new(0, 150, 1, -32), Position = UDim2.new(0, 0, 0, 32), BorderSizePixel = 0
    })
    -- Sidebar Divider
    Create("Frame", {
        Parent = Sidebar, BackgroundColor3 = Fluxa.Theme.Divider,
        Size = UDim2.new(0, 1, 1, 0), Position = UDim2.new(1, -1, 0, 0), BorderSizePixel = 0
    })

    -- Tab Container
    local TabHolder = Create("ScrollingFrame", {
        Parent = Sidebar, BackgroundTransparency = 1,
        Size = UDim2.new(1, -1, 1, 0), Position = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 0, CanvasSize = UDim2.new(0,0,0,0)
    })
    local TabLayout = Create("UIListLayout", {
        Parent = TabHolder, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 0)
    })

    -- Content Area
    local ContentArea = Create("Frame", {
        Parent = MainFrame, BackgroundColor3 = Fluxa.Theme.Content,
        Size = UDim2.new(1, -150, 1, -32), Position = UDim2.new(0, 150, 0, 32), BorderSizePixel = 0
    })

    local Tabs = {}
    local FirstTab = true

    --// Tab Function
    function WindowFuncs:Tab(name)
        local TabFuncs = {}
        
        -- Tab Button
        local TabBtn = Create("TextButton", {
            Parent = TabHolder, BackgroundColor3 = Fluxa.Theme.Sidebar,
            Size = UDim2.new(1, 0, 0, 30), AutoButtonColor = false,
            Font = Enum.Font.GothamBold, Text = name,
            TextColor3 = Fluxa.Theme.SubText, TextSize = 13, BorderSizePixel = 0
        })
        
        -- Active Tab Indicator (Red Line at bottom)
        local TabIndicator = Create("Frame", {
            Parent = TabBtn, BackgroundColor3 = Fluxa.Theme.Accent,
            Size = UDim2.new(1, 0, 0, 2), Position = UDim2.new(0, 0, 1, -2),
            BorderSizePixel = 0, Visible = false
        })

        -- Page Frame
        local Page = Create("ScrollingFrame", {
            Parent = ContentArea, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0), Visible = false,
            ScrollBarThickness = 3, ScrollBarImageColor3 = Fluxa.Theme.Accent,
            CanvasSize = UDim2.new(0,0,0,0), BorderSizePixel = 0
        })
        local PageLayout = Create("UIListLayout", {
            Parent = Page, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10)
        })
        Create("UIPadding", {Parent = Page, PaddingTop = UDim.new(0, 15), PaddingLeft = UDim.new(0, 15), PaddingRight = UDim.new(0, 15), PaddingBottom = UDim.new(0, 15)})

        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0,0,0, PageLayout.AbsoluteContentSize.Y + 30)
        end)

        -- Activate Logic
        TabBtn.MouseButton1Click:Connect(function()
            for _, t in pairs(Tabs) do
                TweenService:Create(t.Btn, TweenInfo.new(0.2), {TextColor3 = Fluxa.Theme.SubText}):Play()
                t.Indicator.Visible = false
                t.Page.Visible = false
            end
            TweenService:Create(TabBtn, TweenInfo.new(0.2), {TextColor3 = Fluxa.Theme.Accent}):Play()
            TabIndicator.Visible = true
            Page.Visible = true
        end)

        if FirstTab then
            TabBtn.TextColor3 = Fluxa.Theme.Accent
            TabIndicator.Visible = true
            Page.Visible = true
            FirstTab = false
        end
        table.insert(Tabs, {Btn = TabBtn, Indicator = TabIndicator, Page = Page})

        --// Section (GroupBox - Red Accent Style)
        function TabFuncs:Section(title)
            local SectionFuncs = {}
            
            local SectionFrame = Create("Frame", {
                Parent = Page, BackgroundColor3 = Fluxa.Theme.Element,
                Size = UDim2.new(1, 0, 0, 0), BorderSizePixel = 0
            })
            -- Section Top Red Accent
            Create("Frame", {
                Parent = SectionFrame, BackgroundColor3 = Fluxa.Theme.Accent,
                Size = UDim2.new(1, 0, 0, 2), Position = UDim2.new(0, 0, 0, 0), BorderSizePixel = 0
            })
            AddStroke(SectionFrame, Fluxa.Theme.Outline, 1)

            local SectionTitle = Create("TextLabel", {
                Parent = SectionFrame, BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 5), Size = UDim2.new(1, -20, 0, 20),
                Font = Enum.Font.GothamBold, Text = title,
                TextColor3 = Fluxa.Theme.Text, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left
            })

            local Container = Create("Frame", {
                Parent = SectionFrame, BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 30), Size = UDim2.new(1, -20, 0, 0)
            })
            local ContainerLayout = Create("UIListLayout", {
                Parent = Container, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5)
            })
            Create("UIPadding", {Parent = Container, PaddingBottom = UDim.new(0, 10)})

            ContainerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                Container.Size = UDim2.new(1, -20, 0, ContainerLayout.AbsoluteContentSize.Y)
                SectionFrame.Size = UDim2.new(1, 0, 0, ContainerLayout.AbsoluteContentSize.Y + 40)
            end)

            --// Toggle (Checkbox Style)
            function SectionFuncs:Toggle(text, default, callback)
                local Toggled = default or false
                Fluxa.Flags[text] = Toggled

                local ToggleBtn = Create("TextButton", {
                    Parent = Container, BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 25), AutoButtonColor = false, Text = ""
                })

                local Label = Create("TextLabel", {
                    Parent = ToggleBtn, BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 0), Size = UDim2.new(1, -30, 1, 0),
                    Font = Enum.Font.Gotham, Text = text,
                    TextColor3 = Fluxa.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left
                })

                local Checkbox = Create("Frame", {
                    Parent = ToggleBtn, BackgroundColor3 = Fluxa.Theme.Element,
                    Position = UDim2.new(1, -20, 0.5, -10), Size = UDim2.new(0, 20, 0, 20),
                    BorderSizePixel = 0
                })
                AddStroke(Checkbox, Fluxa.Theme.Outline, 1)

                local CheckMark = Create("Frame", {
                    Parent = Checkbox, BackgroundColor3 = Fluxa.Theme.Accent,
                    Size = UDim2.new(1, -4, 1, -4), Position = UDim2.new(0, 2, 0, 2),
                    Visible = Toggled, BorderSizePixel = 0
                })

                local function Update()
                    Fluxa.Flags[text] = Toggled
                    CheckMark.Visible = Toggled
                    if callback then callback(Toggled) end
                end
                
                ToggleBtn.MouseButton1Click:Connect(function()
                    Toggled = not Toggled
                    Update()
                end)
            end

            --// Slider (Red Fill Style)
            function SectionFuncs:Slider(text, min, max, default, callback)
                Fluxa.Flags[text] = default or min
                local SliderVal = default or min
                
                local SliderFrame = Create("Frame", {
                    Parent = Container, BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 40)
                })

                local Label = Create("TextLabel", {
                    Parent = SliderFrame, BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 0), Size = UDim2.new(1, -50, 0, 20),
                    Font = Enum.Font.Gotham, Text = text,
                    TextColor3 = Fluxa.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left
                })

                local ValLabel = Create("TextLabel", {
                    Parent = SliderFrame, BackgroundTransparency = 1,
                    Position = UDim2.new(1, -45, 0, 0), Size = UDim2.new(0, 45, 0, 20),
                    Font = Enum.Font.Gotham, Text = string.format("%.2f", SliderVal),
                    TextColor3 = Fluxa.Theme.Accent, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Right
                })

                local BarBG = Create("Frame", {
                    Parent = SliderFrame, BackgroundColor3 = Fluxa.Theme.Element,
                    Position = UDim2.new(0, 0, 0, 25), Size = UDim2.new(1, 0, 0, 8),
                    BorderSizePixel = 0
                })
                AddStroke(BarBG, Fluxa.Theme.Outline, 1)

                local Fill = Create("Frame", {
                    Parent = BarBG, BackgroundColor3 = Fluxa.Theme.Accent,
                    Size = UDim2.new((SliderVal - min) / (max - min), 0, 1, 0),
                    BorderSizePixel = 0
                })

                local Trigger = Create("TextButton", {
                    Parent = BarBG, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Text = ""
                })

                local function Update(input)
                    local SizeX = math.clamp((input.Position.X - BarBG.AbsolutePosition.X) / BarBG.AbsoluteSize.X, 0, 1)
                    local NewVal = min + ((max - min) * SizeX)
                    SliderVal = NewVal
                    Fluxa.Flags[text] = SliderVal
                    ValLabel.Text = string.format("%.2f", SliderVal)
                    Fill.Size = UDim2.new(SizeX, 0, 1, 0)
                    if callback then callback(SliderVal) end
                end

                Trigger.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Update(input)
                        local moveC; moveC = RunService.RenderStepped:Connect(function()
                            Update(UserInputService:GetMouseLocation())
                            if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                                moveC:Disconnect()
                            end
                        end)
                    end
                end)
            end

            --// Dropdown (Red Accent Style)
            function SectionFuncs:Dropdown(text, items, callback)
                local DropdownOpen = false
                
                local DropFrame = Create("Frame", {
                    Parent = Container, BackgroundColor3 = Fluxa.Theme.Element,
                    Size = UDim2.new(1, 0, 0, 30), ClipsDescendants = true, ZIndex = 2,
                    BorderSizePixel = 0
                })
                AddStroke(DropFrame, Fluxa.Theme.Outline, 1)
                
                local Label = Create("TextLabel", {
                    Parent = DropFrame, BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(0.6, 0, 0, 30),
                    Font = Enum.Font.Gotham, Text = text,
                    TextColor3 = Fluxa.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left
                })

                local SelectedText = Create("TextLabel", {
                    Parent = DropFrame, BackgroundTransparency = 1,
                    Position = UDim2.new(0.6, 0, 0, 0), Size = UDim2.new(0.4, -25, 0, 30),
                    Font = Enum.Font.Gotham, Text = "Select...",
                    TextColor3 = Fluxa.Theme.Accent, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Right
                })

                local Arrow = Create("TextLabel", {
                    Parent = DropFrame, BackgroundTransparency = 1,
                    Position = UDim2.new(1, -25, 0, 0), Size = UDim2.new(0, 25, 0, 30),
                    Font = Enum.Font.GothamBold, Text = "v",
                    TextColor3 = Fluxa.Theme.SubText, TextSize = 12
                })

                local DropBtn = Create("TextButton", {
                    Parent = DropFrame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30), Text = ""
                })

                local ListFrame = Create("ScrollingFrame", {
                    Parent = DropFrame, BackgroundColor3 = Fluxa.Theme.Element,
                    Position = UDim2.new(0, 0, 0, 32), Size = UDim2.new(1, 0, 0, 0),
                    BorderSizePixel = 0, CanvasSize = UDim2.new(0,0,0,0), ScrollBarThickness = 2, ScrollBarImageColor3 = Fluxa.Theme.Accent
                })
                local ListLayout = Create("UIListLayout", {Parent = ListFrame, SortOrder = Enum.SortOrder.LayoutOrder})

                DropBtn.MouseButton1Click:Connect(function()
                    DropdownOpen = not DropdownOpen
                    if DropdownOpen then
                        TweenService:Create(DropFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 150)}):Play()
                        TweenService:Create(ListFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 1, -32)}):Play()
                        Arrow.Rotation = 180
                    else
                        TweenService:Create(DropFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 30)}):Play()
                        TweenService:Create(ListFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 0)}):Play()
                        Arrow.Rotation = 0
                    end
                end)

                for _, item in pairs(items) do
                    local ItemBtn = Create("TextButton", {
                        Parent = ListFrame, BackgroundColor3 = Fluxa.Theme.Element,
                        Size = UDim2.new(1, 0, 0, 25), Font = Enum.Font.Gotham,
                        Text = item, TextColor3 = Fluxa.Theme.SubText, TextSize = 13, AutoButtonColor = false, BorderSizePixel = 0
                    })
                    ItemBtn.MouseEnter:Connect(function() ItemBtn.TextColor3 = Fluxa.Theme.Accent end)
                    ItemBtn.MouseLeave:Connect(function() ItemBtn.TextColor3 = Fluxa.Theme.SubText end)
                    ItemBtn.MouseButton1Click:Connect(function()
                        SelectedText.Text = item
                        DropdownOpen = false
                        TweenService:Create(DropFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 30)}):Play()
                        Arrow.Rotation = 0
                        if callback then callback(item) end
                    end)
                end
                ListFrame.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y)
            end
            
            --// Button (Red Accent Style)
            function SectionFuncs:Button(text, callback)
                local Btn = Create("TextButton", {
                    Parent = Container, BackgroundColor3 = Fluxa.Theme.Element,
                    Size = UDim2.new(1, 0, 0, 30), AutoButtonColor = false,
                    Font = Enum.Font.Gotham, Text = text,
                    TextColor3 = Fluxa.Theme.Text, TextSize = 13, BorderSizePixel = 0
                })
                AddStroke(Btn, Fluxa.Theme.Outline, 1)
                
                Btn.MouseEnter:Connect(function() TweenService:Create(Btn, TweenInfo.new(0.1), {TextColor3 = Fluxa.Theme.Accent}):Play() end)
                Btn.MouseLeave:Connect(function() TweenService:Create(Btn, TweenInfo.new(0.1), {TextColor3 = Fluxa.Theme.Text}):Play() end)
                Btn.MouseButton1Click:Connect(function()
                    if callback then callback() end
                end)
            end
            
            --// TextBox (Red Accent Style)
            function SectionFuncs:TextBox(text, placeholder, callback)
                local BoxFrame = Create("Frame", {
                    Parent = Container, BackgroundColor3 = Fluxa.Theme.Element,
                    Size = UDim2.new(1, 0, 0, 30), BorderSizePixel = 0
                })
                AddStroke(BoxFrame, Fluxa.Theme.Outline, 1)

                local Label = Create("TextLabel", {
                    Parent = BoxFrame, BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0), Size = UDim2.new(0.4, 0, 1, 0),
                    Font = Enum.Font.Gotham, Text = text,
                    TextColor3 = Fluxa.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left
                })

                local Input = Create("TextBox", {
                    Parent = BoxFrame, BackgroundTransparency = 1,
                    Position = UDim2.new(0.4, 10, 0, 0), Size = UDim2.new(0.6, -20, 1, 0),
                    Font = Enum.Font.Gotham, PlaceholderText = placeholder or "", Text = "",
                    TextColor3 = Fluxa.Theme.Accent, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Right,
                    ClearTextOnFocus = false
                })

                Input.FocusLost:Connect(function()
                    if callback then callback(Input.Text) end
                end)
            end

            return SectionFuncs
        end
        return TabFuncs
    end
    
    --// Config System Implementation (Manual for style)
    local SettingsTab = WindowFuncs:Tab("Settings")
    local ConfigSection = SettingsTab:Section("Configuration")
    
    local ConfigNameInput = "default"
    ConfigSection:TextBox("Config Name", "default", function(text) ConfigNameInput = text end)

    ConfigSection:Button("Save Config", function()
        if not isfolder(Fluxa.Folder) then makefolder(Fluxa.Folder) end
        writefile(Fluxa.Folder .. "/" .. ConfigNameInput .. ".json", HttpService:JSONEncode(Fluxa.Flags))
        print("Saved Config: " .. ConfigNameInput)
    end)
    
    ConfigSection:Button("Load Config", function()
        if isfile(Fluxa.Folder .. "/" .. ConfigNameInput .. ".json") then
            local data = HttpService:JSONDecode(readfile(Fluxa.Folder .. "/" .. ConfigNameInput .. ".json"))
            print("Loaded Config: " .. ConfigNameInput)
            -- (값 적용 로직은 각 요소 구현에 따라 추가 필요)
        end
    end)

    return WindowFuncs
end

return Fluxa
