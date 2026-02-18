--[[ 
    FLUXA UI LIBRARY v9 (Full Feature)
    - Added: ColorPicker (HSV Support)
    - Added: MultiDropdown (Multi-select)
    - Style: Hybrid (Angular Frames + Round Buttons)
]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

--// 1. Setup & Security
local Fluxa = {}
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Fluxa_v9"
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

--// 2. Theme Settings
Fluxa.Theme = {
    Background  = Color3.fromRGB(20, 22, 26),
    Sidebar     = Color3.fromRGB(25, 28, 33),
    Element     = Color3.fromRGB(32, 35, 40),
    Hover       = Color3.fromRGB(42, 45, 52),
    Accent      = Color3.fromRGB(100, 130, 240),
    Text        = Color3.fromRGB(240, 240, 245),
    SubText     = Color3.fromRGB(140, 145, 155),
    Outline     = Color3.fromRGB(50, 50, 55),
    
    FrameCorner = 4,  -- [각짐] 프레임
    BtnCorner   = 8   -- [둥글] 버튼
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
    Create("UICorner", {Parent = parent, CornerRadius = UDim.new(0, radius)})
end

local function AddStroke(parent, color, thickness)
    Create("UIStroke", {
        Parent = parent,
        Color = color or Fluxa.Theme.Outline,
        Thickness = thickness or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    })
end

local function Tween(obj, props, time)
    TweenService:Create(obj, TweenInfo.new(time or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
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
            Tween(object, {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}, 0.05)
        end
    end)
end

--// 4. Main Library
function Fluxa:Window(options)
    local TitleText = options.Name or "FLUXA v9"
    local WindowFuncs = {}
    
    -- Main Window
    local Main = Create("Frame", {
        Name = "Main", Parent = ScreenGui,
        BackgroundColor3 = Fluxa.Theme.Background,
        Position = UDim2.new(0.5, -300, 0.5, -200),
        Size = UDim2.new(0, 600, 0, 420),
        ClipsDescendants = true
    })
    AddCorner(Main, Fluxa.Theme.FrameCorner)
    AddStroke(Main, Fluxa.Theme.Outline, 1)

    -- Sidebar
    local Sidebar = Create("Frame", {
        Parent = Main, BackgroundColor3 = Fluxa.Theme.Sidebar,
        Size = UDim2.new(0, 160, 1, 0), Position = UDim2.new(0, 0, 0, 0)
    })
    Create("Frame", { Parent = Sidebar, BackgroundColor3 = Fluxa.Theme.Outline, Size = UDim2.new(0, 1, 1, 0), Position = UDim2.new(1, -1, 0, 0), BorderSizePixel = 0 })

    -- Title
    Create("TextLabel", {
        Parent = Sidebar, BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 0, 50), Position = UDim2.new(0, 20, 0, 0),
        Font = Enum.Font.GothamBold, Text = TitleText,
        TextColor3 = Fluxa.Theme.Accent, TextSize = 18, TextXAlignment = Enum.TextXAlignment.Left
    })
    
    -- Tab Container
    local TabContainer = Create("ScrollingFrame", {
        Parent = Sidebar, BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, -60), Position = UDim2.new(0, 0, 0, 60),
        ScrollBarThickness = 0, CanvasSize = UDim2.new(0,0,0,0)
    })
    local TabList = Create("UIListLayout", {
        Parent = TabContainer, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6)
    })
    Create("UIPadding", {Parent = TabContainer, PaddingLeft = UDim.new(0, 10)})

    -- Content Area (With Margins)
    local Content = Create("Frame", {
        Parent = Main, BackgroundTransparency = 1,
        Position = UDim2.new(0, 180, 0, 10), 
        Size = UDim2.new(1, -190, 1, -20)
    })
    
    local DragFrame = Create("Frame", {
        Parent = Main, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 50)
    })
    MakeDraggable(DragFrame, Main)

    local Tabs = {}
    local SelectedTab = nil

    function WindowFuncs:Tab(name)
        local TabFuncs = {}
        
        local TabBtn = Create("TextButton", {
            Parent = TabContainer, BackgroundColor3 = Fluxa.Theme.Sidebar,
            Size = UDim2.new(1, -12, 0, 34), AutoButtonColor = false,
            Text = "", BackgroundTransparency = 1
        })
        AddCorner(TabBtn, Fluxa.Theme.BtnCorner)

        local TabText = Create("TextLabel", {
            Parent = TabBtn, BackgroundTransparency = 1,
            Size = UDim2.new(1, -20, 1, 0), Position = UDim2.new(0, 12, 0, 0),
            Font = Enum.Font.GothamMedium, Text = name,
            TextColor3 = Fluxa.Theme.SubText, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left
        })
        
        local Indicator = Create("Frame", {
            Parent = TabBtn, BackgroundColor3 = Fluxa.Theme.Accent,
            Size = UDim2.new(0, 4, 0, 16), Position = UDim2.new(0, 0, 0.5, -8),
            Transparency = 1
        })
        AddCorner(Indicator, 4)

        local Page = Create("ScrollingFrame", {
            Parent = Content, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0), Visible = false,
            ScrollBarThickness = 2, ScrollBarImageColor3 = Fluxa.Theme.Outline,
            CanvasSize = UDim2.new(0,0,0,0), BorderSizePixel = 0
        })
        local PageLayout = Create("UIListLayout", {
            Parent = Page, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10)
        })
        Create("UIPadding", {Parent = Page, PaddingTop = UDim.new(0, 5), PaddingLeft = UDim.new(0, 2), PaddingRight = UDim.new(0, 12), PaddingBottom = UDim.new(0, 10)})

        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0,0,0, PageLayout.AbsoluteContentSize.Y + 20)
        end)

        local function Activate()
            if SelectedTab then
                Tween(SelectedTab.Text, {TextColor3 = Fluxa.Theme.SubText})
                Tween(SelectedTab.Indicator, {Transparency = 1})
                Tween(SelectedTab.Btn, {BackgroundTransparency = 1})
                SelectedTab.Page.Visible = false
            end
            SelectedTab = {Btn = TabBtn, Text = TabText, Indicator = Indicator, Page = Page}
            Tween(TabText, {TextColor3 = Fluxa.Theme.Text})
            Tween(Indicator, {Transparency = 0})
            Tween(TabBtn, {BackgroundTransparency = 0.95, BackgroundColor3 = Fluxa.Theme.Text})
            Page.Visible = true
        end

        TabBtn.MouseButton1Click:Connect(Activate)
        if #Tabs == 0 then Activate() end
        table.insert(Tabs, {Btn = TabBtn})

        function TabFuncs:Section(text)
            local SectionFuncs = {}
            local Label = Create("TextLabel", {
                Parent = Page, BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 26),
                Font = Enum.Font.GothamBold, Text = string.upper(text),
                TextColor3 = Fluxa.Theme.Accent, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left
            })
            Create("UIPadding", {Parent = Label, PaddingLeft = UDim.new(0, 2), PaddingTop = UDim.new(0, 10)})

            --// TOGGLE
            function SectionFuncs:Toggle(text, default, callback)
                local Toggled = default or false
                Fluxa.Flags[text] = Toggled
                local ToggleBtn = Create("TextButton", {
                    Parent = Page, BackgroundColor3 = Fluxa.Theme.Element, Size = UDim2.new(1, 0, 0, 40), AutoButtonColor = false, Text = ""
                })
                AddCorner(ToggleBtn, Fluxa.Theme.FrameCorner); AddStroke(ToggleBtn, Fluxa.Theme.Outline, 1)
                Create("TextLabel", {
                    Parent = ToggleBtn, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(1, -60, 1, 0),
                    Font = Enum.Font.GothamMedium, Text = text, TextColor3 = Fluxa.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left
                })
                local Switch = Create("Frame", { Parent = ToggleBtn, BackgroundColor3 = Fluxa.Theme.Sidebar, Position = UDim2.new(1, -48, 0.5, -11), Size = UDim2.new(0, 36, 0, 22) })
                AddCorner(Switch, 16); AddStroke(Switch, Fluxa.Theme.Outline, 1)
                local Knob = Create("Frame", { Parent = Switch, BackgroundColor3 = Fluxa.Theme.SubText, Position = UDim2.new(0, 3, 0.5, -8), Size = UDim2.new(0, 16, 0, 16) })
                AddCorner(Knob, 16)
                local function Update()
                    Fluxa.Flags[text] = Toggled
                    if Toggled then
                        Tween(Switch, {BackgroundColor3 = Fluxa.Theme.Accent}); Tween(Switch.UIStroke, {Color = Fluxa.Theme.Accent}); Tween(Knob, {Position = UDim2.new(1, -19, 0.5, -8), BackgroundColor3 = Color3.new(1,1,1)})
                    else
                        Tween(Switch, {BackgroundColor3 = Fluxa.Theme.Sidebar}); Tween(Switch.UIStroke, {Color = Fluxa.Theme.Outline}); Tween(Knob, {Position = UDim2.new(0, 3, 0.5, -8), BackgroundColor3 = Fluxa.Theme.SubText})
                    end
                    if callback then callback(Toggled) end
                end
                if default then Update() end
                ToggleBtn.MouseButton1Click:Connect(function() Toggled = not Toggled; Update() end)
            end

            --// SLIDER
            function SectionFuncs:Slider(text, min, max, default, callback)
                Fluxa.Flags[text] = default or min
                local Value = default or min
                local SliderFrame = Create("Frame", { Parent = Page, BackgroundColor3 = Fluxa.Theme.Element, Size = UDim2.new(1, 0, 0, 50) })
                AddCorner(SliderFrame, Fluxa.Theme.FrameCorner); AddStroke(SliderFrame, Fluxa.Theme.Outline, 1)
                Create("TextLabel", { Parent = SliderFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 8), Size = UDim2.new(1, -30, 0, 20), Font = Enum.Font.GothamMedium, Text = text, TextColor3 = Fluxa.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left })
                local ValueLabel = Create("TextLabel", { Parent = SliderFrame, BackgroundTransparency = 1, Position = UDim2.new(1, -50, 0, 8), Size = UDim2.new(0, 38, 0, 20), Font = Enum.Font.Gotham, Text = tostring(Value), TextColor3 = Fluxa.Theme.Accent, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Right })
                local Track = Create("Frame", { Parent = SliderFrame, BackgroundColor3 = Fluxa.Theme.Sidebar, Position = UDim2.new(0, 12, 0, 34), Size = UDim2.new(1, -24, 0, 6) }); AddCorner(Track, 8)
                local Fill = Create("Frame", { Parent = Track, BackgroundColor3 = Fluxa.Theme.Accent, Size = UDim2.new((Value - min) / (max - min), 0, 1, 0) }); AddCorner(Fill, 8)
                local Trigger = Create("TextButton", { Parent = SliderFrame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Text = "", ZIndex = 10 })
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
                        local move, release
                        move = UserInputService.InputChanged:Connect(function(moveInput) if moveInput.UserInputType == Enum.UserInputType.MouseMovement then Update(moveInput) end end)
                        release = UserInputService.InputEnded:Connect(function(endInput) if endInput.UserInputType == Enum.UserInputType.MouseButton1 then move:Disconnect(); release:Disconnect() end end)
                    end
                end)
            end

            --// BUTTON
            function SectionFuncs:Button(text, callback)
                local Btn = Create("TextButton", { Parent = Page, BackgroundColor3 = Fluxa.Theme.Element, Size = UDim2.new(1, 0, 0, 38), AutoButtonColor = false, Font = Enum.Font.GothamMedium, Text = text, TextColor3 = Fluxa.Theme.Text, TextSize = 13 })
                AddCorner(Btn, Fluxa.Theme.BtnCorner); AddStroke(Btn, Fluxa.Theme.Outline, 1)
                Btn.MouseEnter:Connect(function() Tween(Btn, {BackgroundColor3 = Fluxa.Theme.Hover}); Tween(Btn.UIStroke, {Color = Fluxa.Theme.SubText}) end)
                Btn.MouseLeave:Connect(function() Tween(Btn, {BackgroundColor3 = Fluxa.Theme.Element}); Tween(Btn.UIStroke, {Color = Fluxa.Theme.Outline}) end)
                Btn.MouseButton1Click:Connect(function() Tween(Btn, {TextColor3 = Fluxa.Theme.Accent}, 0.1); task.wait(0.1); Tween(Btn, {TextColor3 = Fluxa.Theme.Text}, 0.1); if callback then callback() end end)
            end
            
            --// MULTI DROPDOWN (New Feature)
            function SectionFuncs:MultiDropdown(text, items, default, callback)
                local Open = false
                local Selected = default or {}
                local DropFrame = Create("Frame", { Parent = Page, BackgroundColor3 = Fluxa.Theme.Element, Size = UDim2.new(1, 0, 0, 38), ClipsDescendants = true })
                AddCorner(DropFrame, Fluxa.Theme.FrameCorner); AddStroke(DropFrame, Fluxa.Theme.Outline, 1)
                local Title = Create("TextLabel", { Parent = DropFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(1, -40, 0, 38), Font = Enum.Font.GothamMedium, Text = text, TextColor3 = Fluxa.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left })
                local Arrow = Create("TextLabel", { Parent = DropFrame, BackgroundTransparency = 1, Position = UDim2.new(1, -30, 0, 0), Size = UDim2.new(0, 20, 0, 38), Font = Enum.Font.GothamBold, Text = "+", TextColor3 = Fluxa.Theme.SubText, TextSize = 16 })
                local Trigger = Create("TextButton", { Parent = DropFrame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 38), Text = "" })
                local List = Create("Frame", { Parent = DropFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 42), Size = UDim2.new(1, 0, 0, 0) })
                local ListLayout = Create("UIListLayout", { Parent = List, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4) })
                Create("UIPadding", {Parent = List, PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8)})

                local function UpdateText()
                    local t = {}
                    for k, v in pairs(Selected) do if v then table.insert(t, k) end end
                    if #t == 0 then Title.Text = text; Title.TextColor3 = Fluxa.Theme.Text
                    else Title.Text = text .. ": " .. table.concat(t, ", "); Title.TextColor3 = Fluxa.Theme.Accent end
                end
                UpdateText()

                local function Refresh()
                    for _,v in pairs(List:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
                    for _, item in pairs(items) do
                        local ItemBtn = Create("TextButton", { Parent = List, BackgroundColor3 = Fluxa.Theme.Sidebar, Size = UDim2.new(1, 0, 0, 30), AutoButtonColor = false, Font = Enum.Font.Gotham, Text = item, TextColor3 = Selected[item] and Fluxa.Theme.Accent or Fluxa.Theme.SubText, TextSize = 12 })
                        AddCorner(ItemBtn, 6)
                        ItemBtn.MouseButton1Click:Connect(function()
                            Selected[item] = not Selected[item]
                            ItemBtn.TextColor3 = Selected[item] and Fluxa.Theme.Accent or Fluxa.Theme.SubText
                            UpdateText()
                            if callback then callback(Selected) end
                        end)
                    end
                end
                Refresh()
                Trigger.MouseButton1Click:Connect(function() Open = not Open
                    if Open then Tween(DropFrame, {Size = UDim2.new(1, 0, 0, ListLayout.AbsoluteContentSize.Y + 48)}); Arrow.Text = "-"
                    else Tween(DropFrame, {Size = UDim2.new(1, 0, 0, 38)}); Arrow.Text = "+" end
                end)
            end

            --// COLOR PICKER (New Feature)
            function SectionFuncs:ColorPicker(text, default, callback)
                local Color = default or Color3.fromRGB(255, 255, 255)
                local Open = false
                local PickerFrame = Create("Frame", { Parent = Page, BackgroundColor3 = Fluxa.Theme.Element, Size = UDim2.new(1, 0, 0, 40), ClipsDescendants = true })
                AddCorner(PickerFrame, Fluxa.Theme.FrameCorner); AddStroke(PickerFrame, Fluxa.Theme.Outline, 1)
                
                Create("TextLabel", { Parent = PickerFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(1, -60, 0, 40), Font = Enum.Font.GothamMedium, Text = text, TextColor3 = Fluxa.Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left })
                local Preview = Create("Frame", { Parent = PickerFrame, BackgroundColor3 = Color, Position = UDim2.new(1, -45, 0.5, -10), Size = UDim2.new(0, 30, 0, 20) })
                AddCorner(Preview, 6); AddStroke(Preview, Fluxa.Theme.Outline, 1)
                local Trigger = Create("TextButton", { Parent = PickerFrame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 40), Text = "" })
                
                -- Palette Area
                local Palette = Create("Frame", { Parent = PickerFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 45), Size = UDim2.new(1, 0, 0, 130) })
                
                -- SV Saturation/Value
                local SVBox = Create("Frame", { Parent = Palette, Position = UDim2.new(0, 12, 0, 0), Size = UDim2.new(1, -24, 0, 100), BackgroundColor3 = Color3.fromHSV(1, 1, 1) }); AddCorner(SVBox, 4)
                local SVG = Create("UIGradient", { Parent = SVBox, Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.new(1,1,1)), ColorSequenceKeypoint.new(1, Color3.new(1,0,0))} })
                local BlackG = Create("Frame", { Parent = SVBox, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 0, ZIndex = 2, BackgroundColor3 = Color3.new(1,1,1) }); AddCorner(BlackG, 4)
                Create("UIGradient", { Parent = BlackG, Rotation = 90, Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.new(0,0,0)), ColorSequenceKeypoint.new(1, Color3.new(0,0,0))}, Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0)} })

                -- Hue Slider
                local HueBar = Create("Frame", { Parent = Palette, Position = UDim2.new(0, 12, 0, 110), Size = UDim2.new(1, -24, 0, 12), BackgroundColor3 = Color3.new(1,1,1) }); AddCorner(HueBar, 4)
                Create("UIGradient", { Parent = HueBar, Color = ColorSequence.new{ ColorSequenceKeypoint.new(0, Color3.new(1,0,0)), ColorSequenceKeypoint.new(0.167, Color3.new(1,1,0)), ColorSequenceKeypoint.new(0.333, Color3.new(0,1,0)), ColorSequenceKeypoint.new(0.5, Color3.new(0,1,1)), ColorSequenceKeypoint.new(0.667, Color3.new(0,0,1)), ColorSequenceKeypoint.new(0.833, Color3.new(1,0,1)), ColorSequenceKeypoint.new(1, Color3.new(1,0,0)) } })

                local h, s, v = Color:ToHSV()
                local colorInput = Color
                
                local function UpdateColor()
                    colorInput = Color3.fromHSV(h, s, v)
                    Preview.BackgroundColor3 = colorInput
                    SVG.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.new(1,1,1)), ColorSequenceKeypoint.new(1, Color3.fromHSV(h, 1, 1))}
                    if callback then callback(colorInput) end
                end

                local function UpdateHue(input)
                    local x = math.clamp((input.Position.X - HueBar.AbsolutePosition.X) / HueBar.AbsoluteSize.X, 0, 1)
                    h = x
                    UpdateColor()
                end
                
                local function UpdateSV(input)
                    local x = math.clamp((input.Position.X - SVBox.AbsolutePosition.X) / SVBox.AbsoluteSize.X, 0, 1)
                    local y = math.clamp((input.Position.Y - SVBox.AbsolutePosition.Y) / SVBox.AbsoluteSize.Y, 0, 1)
                    s = x
                    v = 1 - y
                    UpdateColor()
                end

                -- Input Handling
                HueBar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then local m,r; m=UserInputService.InputChanged:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseMovement then UpdateHue(i) end end); r=UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then m:Disconnect(); r:Disconnect() end end); UpdateHue(input) end end)
                BlackG.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then local m,r; m=UserInputService.InputChanged:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseMovement then UpdateSV(i) end end); r=UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then m:Disconnect(); r:Disconnect() end end); UpdateSV(input) end end)

                Trigger.MouseButton1Click:Connect(function() Open = not Open
                    if Open then Tween(PickerFrame, {Size = UDim2.new(1, 0, 0, 180)}) else Tween(PickerFrame, {Size = UDim2.new(1, 0, 0, 40)}) end
                end)
            end

            return SectionFuncs
        end
        return TabFuncs
    end
    local SettingTab = WindowFuncs:Tab("Settings"); local SettingSec = SettingTab:Section("Data"); SettingSec:Button("Save Config", function() end)
    return WindowFuncs
end
return Fluxa
