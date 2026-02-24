--[[ 
    FLUXA UI LIBRARY v15 (TopBar & Flat Option)
    - Feature: Window Title is moved to a dedicated TopBar.
    - Feature: Added 'Flat' option to merge Sidebar and Content areas.
    - Usage: Fluxa:Window({ Name = "Title", Flat = true })
]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

--// 1. Setup & Security
local Fluxa = {}
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Fluxa_v15"
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

--// 2. Theme & Registry
Fluxa.Theme = {
    Background  = Color3.fromRGB(20, 22, 26),
    Sidebar     = Color3.fromRGB(25, 28, 33),
    Element     = Color3.fromRGB(32, 35, 40),
    Hover       = Color3.fromRGB(42, 45, 52),
    Accent      = Color3.fromRGB(100, 130, 240),
    Text        = Color3.fromRGB(240, 240, 245),
    SubText     = Color3.fromRGB(140, 145, 155),
    Outline     = Color3.fromRGB(50, 50, 55),
    TopBar      = Color3.fromRGB(25, 28, 33), -- New: TopBar Color
    
    FrameCorner = 6,
    BtnCorner   = 8
}

Fluxa.Registry = {
    Background = {}, Sidebar = {}, Element = {}, Hover = {}, Accent = {}, Text = {}, SubText = {}, Outline = {}, TopBar = {}
}

Fluxa.Flags = {}
Fluxa.Folder = "Fluxa"
Fluxa.ConfigFolder = Fluxa.Folder .. "/Configs"
Fluxa.ThemeFolder = Fluxa.Folder .. "/Themes"

if makefolder then
    if not isfolder(Fluxa.Folder) then makefolder(Fluxa.Folder) end
    if not isfolder(Fluxa.ConfigFolder) then makefolder(Fluxa.ConfigFolder) end
    if not isfolder(Fluxa.ThemeFolder) then makefolder(Fluxa.ThemeFolder) end
end

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
    local stroke = Create("UIStroke", {
        Parent = parent,
        Color = color or Fluxa.Theme.Outline,
        Thickness = thickness or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    })
    table.insert(Fluxa.Registry.Outline, stroke)
    return stroke
end

local function Tween(obj, props, time)
    TweenService:Create(obj, TweenInfo.new(time or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

function Fluxa:UpdateTheme()
    for key, instances in pairs(Fluxa.Registry) do
        local color = Fluxa.Theme[key]
        if color then
            for _, obj in pairs(instances) do
                if obj and obj.Parent then
                    if obj:IsA("UIStroke") then
                        Tween(obj, {Color = color})
                    elseif obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
                         if key == "Text" or key == "SubText" or key == "Accent" then
                             Tween(obj, {TextColor3 = color})
                         else
                             Tween(obj, {BackgroundColor3 = color})
                         end
                    else
                        Tween(obj, {BackgroundColor3 = color})
                    end
                end
            end
        end
    end
end

local function Register(obj, themeKey)
    if Fluxa.Registry[themeKey] then
        table.insert(Fluxa.Registry[themeKey], obj)
    end
    return obj
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
    -- [중요] 여기서 WindowFuncs 테이블을 먼저 생성해야 합니다.
    local WindowFuncs = {} 
    
    -- Main Window Container
    local Main = Register(Create("Frame", {
        Name = "Main", Parent = ScreenGui,
        BackgroundColor3 = Fluxa.Theme.Background,
        Position = UDim2.new(0.5, -325, 0.5, -225),
        Size = UDim2.new(0, 650, 0, 450),
        ClipsDescendants = true
    }), "Background")
    AddCorner(Main, Fluxa.Theme.FrameCorner)
    AddStroke(Main, Fluxa.Theme.Outline, 1)

    -- [[ TOP BAR ]] --
    local TopBar = Register(Create("Frame", {
        Name = "TopBar", Parent = Main,
        BackgroundColor3 = Fluxa.Theme.TopBar,
        Size = UDim2.new(1, 0, 0, 40),
        ZIndex = 2
    }), "Sidebar") -- Using Sidebar color for TopBar usually looks good, or use "TopBar" key
    
    -- Separator Line under TopBar
    Register(Create("Frame", {
        Parent = TopBar, BackgroundColor3 = Fluxa.Theme.Outline,
        Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, 0), BorderSizePixel = 0
    }), "Outline")

    Register(Create("TextLabel", {
        Parent = TopBar, BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 1, 0), Position = UDim2.new(0, 15, 0, 0),
        Font = Enum.Font.GothamBold, Text = TitleText,
        TextColor3 = Fluxa.Theme.Accent, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left
    }), "Accent")

    MakeDraggable(TopBar, Main)

    -- [[ SIDEBAR ]] --
    -- Positioned below TopBar
    local SidebarHeight = UDim2.new(1, -41, 1, -41) 
    local SidebarPos = UDim2.new(0, 0, 0, 41)
    
    local Sidebar = Register(Create("Frame", {
        Parent = Main, BackgroundColor3 = Fluxa.Theme.Sidebar,
        Size = UDim2.new(0, 180, 1, -41), 
        Position = SidebarPos
    }), "Sidebar")

    -- Sidebar Separator (Vertical)
    if not IsFlat then
        -- In separate mode, we might want visually distinct sidebar
        -- But v15 request implies merging. If IsFlat is true, we remove borders/gaps.
        -- If IsFlat is false, we keep the divider line.
         Register(Create("Frame", { Parent = Sidebar, BackgroundColor3 = Fluxa.Theme.Outline, Size = UDim2.new(0, 1, 1, 0), Position = UDim2.new(1, -1, 0, 0), BorderSizePixel = 0 }), "Outline")
    else
        -- In Flat mode, Sidebar and Content share styling more closely, often divided by line
         Register(Create("Frame", { Parent = Sidebar, BackgroundColor3 = Fluxa.Theme.Outline, Size = UDim2.new(0, 1, 1, 0), Position = UDim2.new(1, -1, 0, 0), BorderSizePixel = 0 }), "Outline")
    end
    
    local TabContainer = Create("ScrollingFrame", {
        Parent = Sidebar, BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, -20), Position = UDim2.new(0, 0, 0, 15), -- Slight top padding
        ScrollBarThickness = 0, CanvasSize = UDim2.new(0,0,0,0)
    })
    Create("UIListLayout", { Parent = TabContainer, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8) })
    Create("UIPadding", {Parent = TabContainer, PaddingLeft = UDim.new(0, 12)})

    -- [[ CONTENT AREA ]] --
    -- Layout logic based on Flat option
    local ContentPos, ContentSize
    
    if IsFlat then
        -- Attached mode: Content fills the rest of the frame exactly
        ContentPos = UDim2.new(0, 181, 0, 41)
        ContentSize = UDim2.new(1, -181, 1, -41)
    else
        -- Separated mode: Content floats with margins
        ContentPos = UDim2.new(0, 195, 0, 55)
        ContentSize = UDim2.new(1, -210, 1, -70)
        
        -- If separated, Content usually needs its own background container visual?
        -- In Fluxa v14 style, Content was transparent on Main background.
        -- We keep it transparent here to show Main background.
    end

    local Content = Create("Frame", {
        Parent = Main, BackgroundTransparency = 1,
        Position = ContentPos, Size = ContentSize
    })

    local Tabs = {}
    local SelectedTab = nil

    local function CreateTabBtn(name, container, layoutOrder)
        local TabBtn = Create("TextButton", {
            Parent = container, BackgroundColor3 = Fluxa.Theme.Sidebar,
            Size = UDim2.new(1, -16, 0, 38), AutoButtonColor = false,
            Text = "", BackgroundTransparency = 1,
            LayoutOrder = layoutOrder or 0
        })
        Register(TabBtn, "Sidebar")
        AddCorner(TabBtn, Fluxa.Theme.BtnCorner)

        local TabText = Register(Create("TextLabel", {
            Parent = TabBtn, BackgroundTransparency = 1,
            Size = UDim2.new(1, -20, 1, 0), Position = UDim2.new(0, 14, 0, 0),
            Font = Enum.Font.GothamMedium, Text = name,
            TextColor3 = Fluxa.Theme.SubText, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left
        }), "SubText")
        
        local Indicator = Register(Create("Frame", {
            Parent = TabBtn, BackgroundColor3 = Fluxa.Theme.Accent,
            Size = UDim2.new(0, 4, 0, 18), Position = UDim2.new(0, 0, 0.5, -9),
            Transparency = 1
        }), "Accent")
        AddCorner(Indicator, 4)

        local Page = Create("ScrollingFrame", {
            Parent = Content, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0), Visible = false,
            ScrollBarThickness = 3, ScrollBarImageColor3 = Fluxa.Theme.Outline,
            CanvasSize = UDim2.new(0,0,0,0), BorderSizePixel = 0
        })
        local PageLayout = Create("UIListLayout", { Parent = Page, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 12) })
        Create("UIPadding", {Parent = Page, PaddingTop = UDim.new(0, 5), PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 16), PaddingBottom = UDim.new(0, 20)})

        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0,0,0, PageLayout.AbsoluteContentSize.Y + 40)
        end)

        return TabBtn, TabText, Indicator, Page
    end

    local function ActivateTab(tab)
        if SelectedTab then
            Tween(SelectedTab.Text, {TextColor3 = Fluxa.Theme.SubText})
            Tween(SelectedTab.Indicator, {Transparency = 1})
            Tween(SelectedTab.Btn, {BackgroundTransparency = 1})
            SelectedTab.Page.Visible = false
        end
        SelectedTab = tab
        Tween(tab.Text, {TextColor3 = Fluxa.Theme.Text})
        Tween(tab.Indicator, {Transparency = 0})
        Tween(tab.Btn, {BackgroundTransparency = 0.95, BackgroundColor3 = Fluxa.Theme.Text})
        tab.Page.Visible = true
    end

    -- SECTION & ELEMENTS
    local function CreateSection(page)
        local SectionFuncs = {}
        
        local function AddHeader(text)
            -- Header Title (titleText가 있을 때만 생성하도록 수정)
            if titleText then
                if #page:GetChildren() > 2 then Create("Frame", {Parent = page, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 8)}) end
                local Label = Register(Create("TextLabel", { Parent = page, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 28), Font = Enum.Font.GothamBold, Text = string.upper(titleText), TextColor3 = Fluxa.Theme.Accent, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left }), "Accent")
                Create("UIPadding", {Parent = Label, PaddingLeft = UDim.new(0, 4)})
            end
            local Label = Register(Create("TextLabel", {
                Parent = page, BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 28),
                Font = Enum.Font.GothamBold, Text = string.upper(text),
                TextColor3 = Fluxa.Theme.Accent, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left
            }), "Accent")
            Create("UIPadding", {Parent = Label, PaddingLeft = UDim.new(0, 4)})
        end

        function SectionFuncs:Toggle(text, default, callback)
            local Toggled = default or false
            Fluxa.Flags[text] = Toggled
            local ToggleBtn = Register(Create("TextButton", { Parent = page, BackgroundColor3 = Fluxa.Theme.Element, Size = UDim2.new(1, 0, 0, 42), AutoButtonColor = false, Text = "" }), "Element")
            AddCorner(ToggleBtn, Fluxa.Theme.FrameCorner); AddStroke(ToggleBtn, Fluxa.Theme.Outline, 1)
            Register(Create("TextLabel", { Parent = ToggleBtn, BackgroundTransparency = 1, Position = UDim2.new(0, 16, 0, 0), Size = UDim2.new(1, -70, 1, 0), Font = Enum.Font.GothamMedium, Text = text, TextColor3 = Fluxa.Theme.Text, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left }), "Text")
            local Switch = Register(Create("Frame", { Parent = ToggleBtn, BackgroundColor3 = Fluxa.Theme.Sidebar, Position = UDim2.new(1, -54, 0.5, -11), Size = UDim2.new(0, 38, 0, 22) }), "Sidebar"); AddCorner(Switch, 16); local SwitchStroke = AddStroke(Switch, Fluxa.Theme.Outline, 1)
            local Knob = Register(Create("Frame", { Parent = Switch, BackgroundColor3 = Fluxa.Theme.SubText, Position = UDim2.new(0, 3, 0.5, -8), Size = UDim2.new(0, 16, 0, 16) }), "SubText"); AddCorner(Knob, 16)
            local function Update()
                Fluxa.Flags[text] = Toggled
                if Toggled then Tween(Switch, {BackgroundColor3 = Fluxa.Theme.Accent}); Tween(Switch.UIStroke, {Color = Fluxa.Theme.Accent}); Tween(Knob, {Position = UDim2.new(1, -19, 0.5, -8), BackgroundColor3 = Color3.new(1,1,1)})
                else Tween(Switch, {BackgroundColor3 = Fluxa.Theme.Sidebar}); Tween(Switch.UIStroke, {Color = Fluxa.Theme.Outline}); Tween(Knob, {Position = UDim2.new(0, 3, 0.5, -8), BackgroundColor3 = Fluxa.Theme.SubText}) end
                if callback then callback(Toggled) end
            end
            if default then Update() end
            ToggleBtn.MouseButton1Click:Connect(function() Toggled = not Toggled; Update() end)
        end

        function SectionFuncs:ExpandableToggle(text, default, callback)
            local Toggled = default or false
            Fluxa.Flags[text] = Toggled
            
            -- 1. 토글 UI 생성
            local ToggleBtn = Register(Create("TextButton", { Parent = page, BackgroundColor3 = Fluxa.Theme.Element, Size = UDim2.new(1, 0, 0, 42), AutoButtonColor = false, Text = "" }), "Element")
            AddCorner(ToggleBtn, Fluxa.Theme.FrameCorner)
            AddStroke(ToggleBtn, Fluxa.Theme.Outline, 1)
            
            Register(Create("TextLabel", { Parent = ToggleBtn, BackgroundTransparency = 1, Position = UDim2.new(0, 16, 0, 0), Size = UDim2.new(1, -70, 1, 0), Font = Enum.Font.GothamMedium, Text = text, TextColor3 = Fluxa.Theme.Text, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left }), "Text")
            local Switch = Register(Create("Frame", { Parent = ToggleBtn, BackgroundColor3 = Fluxa.Theme.Sidebar, Position = UDim2.new(1, -54, 0.5, -11), Size = UDim2.new(0, 38, 0, 22) }), "Sidebar"); AddCorner(Switch, 16); local SwitchStroke = AddStroke(Switch, Fluxa.Theme.Outline, 1)
            local Knob = Register(Create("Frame", { Parent = Switch, BackgroundColor3 = Fluxa.Theme.SubText, Position = UDim2.new(0, 3, 0.5, -8), Size = UDim2.new(0, 16, 0, 16) }), "SubText"); AddCorner(Knob, 16)
            
            -- 2. 트리 구조(Tree)를 위한 래퍼(Wrapper) 생성
            local SubPageWrapper = Create("Frame", { 
                Parent = page, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), 
                AutomaticSize = Enum.AutomaticSize.Y, Visible = Toggled 
            })
            
            -- [핵심 1] 파일 트리 수직선 (│)
            local TreeLine = Register(Create("Frame", {
                Parent = SubPageWrapper, BackgroundColor3 = Fluxa.Theme.Outline,
                Size = UDim2.new(0, 1, 1, -21), Position = UDim2.new(0, 16, 0, 0), BorderSizePixel = 0
            }), "Outline")

            local SubPage = Create("Frame", { 
                Parent = SubPageWrapper, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), 
                AutomaticSize = Enum.AutomaticSize.Y
            })
            Create("UIListLayout", { Parent = SubPage, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8) })
            
            -- 선을 그릴 공간 확보를 위해 들여쓰기 값을 16에서 32로 늘립니다.
            Create("UIPadding", { Parent = SubPage, PaddingLeft = UDim.new(0, 32) }) 

            -- [핵심 2] 하위 요소가 추가될 때마다 가로선(├──) 자동 생성
            SubPage.ChildAdded:Connect(function(child)
                if child:IsA("GuiObject") and not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
                    Register(Create("Frame", {
                        Parent = child, BackgroundColor3 = Fluxa.Theme.Outline,
                        Size = UDim2.new(0, 16, 0, 1), Position = UDim2.new(0, -16, 0.5, 0), BorderSizePixel = 0
                    }), "Outline")
                end
            end)

            local function Update()
                Fluxa.Flags[text] = Toggled
                if Toggled then 
                    Tween(Switch, {BackgroundColor3 = Fluxa.Theme.Accent}); Tween(Switch.UIStroke, {Color = Fluxa.Theme.Accent}); Tween(Knob, {Position = UDim2.new(1, -19, 0.5, -8), BackgroundColor3 = Color3.new(1,1,1)})
                    SubPageWrapper.Visible = true
                else 
                    Tween(Switch, {BackgroundColor3 = Fluxa.Theme.Sidebar}); Tween(Switch.UIStroke, {Color = Fluxa.Theme.Outline}); Tween(Knob, {Position = UDim2.new(0, 3, 0.5, -8), BackgroundColor3 = Fluxa.Theme.SubText})
                    SubPageWrapper.Visible = false
                end
                if callback then callback(Toggled) end
            end
            if default then Update() end
            ToggleBtn.MouseButton1Click:Connect(function() Toggled = not Toggled; Update() end)

            -- 3. 내부 SubPage에 아이템이 담기도록 섹션 반환
            return CreateSection(SubPage)
        end

        function SectionFuncs:Button(text, callback)
            local Btn = Register(Create("TextButton", { Parent = page, BackgroundColor3 = Fluxa.Theme.Element, Size = UDim2.new(1, 0, 0, 42), AutoButtonColor = false, Font = Enum.Font.GothamMedium, Text = text, TextColor3 = Fluxa.Theme.Text, TextSize = 14 }), "Element"); AddCorner(Btn, Fluxa.Theme.BtnCorner); AddStroke(Btn, Fluxa.Theme.Outline, 1)
            Btn.MouseEnter:Connect(function() Tween(Btn, {BackgroundColor3 = Fluxa.Theme.Hover}) end)
            Btn.MouseLeave:Connect(function() Tween(Btn, {BackgroundColor3 = Fluxa.Theme.Element}) end)
            Btn.MouseButton1Click:Connect(function() Tween(Btn, {TextColor3 = Fluxa.Theme.Accent}, 0.1); task.wait(0.1); Tween(Btn, {TextColor3 = Fluxa.Theme.Text}, 0.1); if callback then callback() end end)
        end
        function SectionFuncs:TextBox(text, callback)
             local Frame = Register(Create("Frame", { Parent = page, BackgroundColor3 = Fluxa.Theme.Element, Size = UDim2.new(1, 0, 0, 42) }), "Element"); AddCorner(Frame, 4); AddStroke(Frame, Fluxa.Theme.Outline, 1)
             Register(Create("TextLabel", { Parent = Frame, BackgroundTransparency = 1, Position = UDim2.new(0,14,0,0), Size = UDim2.new(0.5,0,1,0), Text = text, Font = Enum.Font.GothamMedium, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, TextColor3 = Fluxa.Theme.Text }), "Text")
             local Box = Register(Create("TextBox", { Parent = Frame, BackgroundTransparency = 1, Position = UDim2.new(0.5,0,0,0), Size = UDim2.new(0.5,-14,1,0), Text = "", Font = Enum.Font.Gotham, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Right, TextColor3 = Fluxa.Theme.Accent, PlaceholderText = "..." }), "Accent")
             Box.FocusLost:Connect(function() if callback then callback(Box.Text) end end)
        end
        function SectionFuncs:Dropdown(text, items, callback)
            local Open = false; local DropFrame = Register(Create("Frame", { Parent = page, BackgroundColor3 = Fluxa.Theme.Element, Size = UDim2.new(1, 0, 0, 42), ClipsDescendants = true }), "Element"); AddCorner(DropFrame, Fluxa.Theme.FrameCorner); AddStroke(DropFrame, Fluxa.Theme.Outline, 1)
            local Title = Register(Create("TextLabel", { Parent = DropFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 16, 0, 0), Size = UDim2.new(1, -65, 0, 42), Font = Enum.Font.GothamMedium, Text = text, TextColor3 = Fluxa.Theme.Text, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left }), "Text")
            local Trigger = Create("TextButton", { Parent = DropFrame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 42), Text = "" })
            local List = Create("Frame", { Parent = DropFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 46), Size = UDim2.new(1, 0, 0, 0) }); local ListLayout = Create("UIListLayout", { Parent = List, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4) }); Create("UIPadding", {Parent = List, PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8)})
            local function Refresh()
                for _,v in pairs(List:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
                for _, item in pairs(items) do
                    local ItemBtn = Register(Create("TextButton", { Parent = List, BackgroundColor3 = Fluxa.Theme.Sidebar, Size = UDim2.new(1, 0, 0, 34), AutoButtonColor = false, Font = Enum.Font.Gotham, Text = item, TextColor3 = Fluxa.Theme.SubText, TextSize = 13 }), "Sidebar"); AddCorner(ItemBtn, 6)
                    ItemBtn.MouseButton1Click:Connect(function() Title.Text = text .. ": " .. item; Register(Title, "Accent"); Title.TextColor3 = Fluxa.Theme.Accent; if callback then callback(item) end; Open = false; Tween(DropFrame, {Size = UDim2.new(1, 0, 0, 42)}) end)
                end
            end
            Refresh()
            Trigger.MouseButton1Click:Connect(function() Open = not Open; if Open then Tween(DropFrame, {Size = UDim2.new(1, 0, 0, ListLayout.AbsoluteContentSize.Y + 52)}) else Tween(DropFrame, {Size = UDim2.new(1, 0, 0, 42)}) end end)
            function SectionFuncs:RefreshDropdown(newItems) items = newItems; Refresh() end
        end
        function SectionFuncs:MultiDropdown(text, items, default, callback)
            local Open = false; local Selected = default or {}
            local DropFrame = Register(Create("Frame", { Parent = page, BackgroundColor3 = Fluxa.Theme.Element, Size = UDim2.new(1, 0, 0, 42), ClipsDescendants = true }), "Element"); AddCorner(DropFrame, Fluxa.Theme.FrameCorner); AddStroke(DropFrame, Fluxa.Theme.Outline, 1)
            local Title = Register(Create("TextLabel", { Parent = DropFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 16, 0, 0), Size = UDim2.new(1, -40, 0, 42), Font = Enum.Font.GothamMedium, Text = text, TextColor3 = Fluxa.Theme.Text, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left }), "Text")
            local Trigger = Create("TextButton", { Parent = DropFrame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 42), Text = "" })
            local List = Create("Frame", { Parent = DropFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 46), Size = UDim2.new(1, 0, 0, 0) }); local ListLayout = Create("UIListLayout", { Parent = List, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4) }); Create("UIPadding", {Parent = List, PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8)})
            local function UpdateText() local t = {}; for k, v in pairs(Selected) do if v then table.insert(t, k) end end; if #t == 0 then Title.Text = text; Title.TextColor3 = Fluxa.Theme.Text else Title.Text = text .. ": " .. table.concat(t, ", "); Title.TextColor3 = Fluxa.Theme.Accent end end; UpdateText()
            local function Refresh()
                for _,v in pairs(List:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
                for _, item in pairs(items) do
                    local ItemBtn = Register(Create("TextButton", { Parent = List, BackgroundColor3 = Fluxa.Theme.Sidebar, Size = UDim2.new(1, 0, 0, 34), AutoButtonColor = false, Font = Enum.Font.Gotham, Text = item, TextColor3 = Selected[item] and Fluxa.Theme.Accent or Fluxa.Theme.SubText, TextSize = 13 }), "Sidebar"); AddCorner(ItemBtn, 6)
                    ItemBtn.MouseButton1Click:Connect(function() Selected[item] = not Selected[item]; ItemBtn.TextColor3 = Selected[item] and Fluxa.Theme.Accent or Fluxa.Theme.SubText; UpdateText(); if callback then callback(Selected) end end)
                end
            end
            Refresh()
            Trigger.MouseButton1Click:Connect(function() Open = not Open; if Open then Tween(DropFrame, {Size = UDim2.new(1, 0, 0, ListLayout.AbsoluteContentSize.Y + 52)}) else Tween(DropFrame, {Size = UDim2.new(1, 0, 0, 42)}) end end)
        end
        function SectionFuncs:Slider(text, min, max, default, callback)
            Fluxa.Flags[text] = default or min
            local Value = default or min
            local SliderFrame = Register(Create("Frame", { Parent = page, BackgroundColor3 = Fluxa.Theme.Element, Size = UDim2.new(1, 0, 0, 56) }), "Element"); AddCorner(SliderFrame, Fluxa.Theme.FrameCorner); AddStroke(SliderFrame, Fluxa.Theme.Outline, 1)
            Register(Create("TextLabel", { Parent = SliderFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 16, 0, 10), Size = UDim2.new(1, -30, 0, 20), Font = Enum.Font.GothamMedium, Text = text, TextColor3 = Fluxa.Theme.Text, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left }), "Text")
            local ValueLabel = Register(Create("TextLabel", { Parent = SliderFrame, BackgroundTransparency = 1, Position = UDim2.new(1, -50, 0, 10), Size = UDim2.new(0, 38, 0, 20), Font = Enum.Font.Gotham, Text = tostring(Value), TextColor3 = Fluxa.Theme.Accent, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Right }), "Accent")
            local Track = Register(Create("Frame", { Parent = SliderFrame, BackgroundColor3 = Fluxa.Theme.Sidebar, Position = UDim2.new(0, 16, 0, 38), Size = UDim2.new(1, -32, 0, 6) }), "Sidebar"); AddCorner(Track, 8)
            local Fill = Register(Create("Frame", { Parent = Track, BackgroundColor3 = Fluxa.Theme.Accent, Size = UDim2.new((Value - min) / (max - min), 0, 1, 0) }), "Accent"); AddCorner(Fill, 8)
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
            Trigger.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then Update(input); local m,r; m=UserInputService.InputChanged:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseMovement then Update(i) end end); r=UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then m:Disconnect(); r:Disconnect() end end) end end)
        end
        function SectionFuncs:ColorPicker(text, default, callback)
            local Color = default or Color3.fromRGB(255, 255, 255)
            local h, s, v = Color:ToHSV()
            local Open = false
            local PickerFrame = Register(Create("Frame", { Parent = page, BackgroundColor3 = Fluxa.Theme.Element, Size = UDim2.new(1, 0, 0, 42), ClipsDescendants = true }), "Element"); AddCorner(PickerFrame, Fluxa.Theme.FrameCorner); AddStroke(PickerFrame, Fluxa.Theme.Outline, 1)
            Register(Create("TextLabel", { Parent = PickerFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 16, 0, 0), Size = UDim2.new(1, -60, 0, 42), Font = Enum.Font.GothamMedium, Text = text, TextColor3 = Fluxa.Theme.Text, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left }), "Text")
            local Preview = Create("Frame", { Parent = PickerFrame, BackgroundColor3 = Color, Position = UDim2.new(1, -45, 0.5, -10), Size = UDim2.new(0, 30, 0, 20) }); AddCorner(Preview, 6); AddStroke(Preview, Fluxa.Theme.Outline, 1)
            local Trigger = Create("TextButton", { Parent = PickerFrame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 42), Text = "" })
            local Palette = Create("Frame", { Parent = PickerFrame, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 48), Size = UDim2.new(1, 0, 0, 130) })
            local SVBox = Create("Frame", { Parent = Palette, Position = UDim2.new(0, 16, 0, 0), Size = UDim2.new(1, -32, 0, 100), BackgroundColor3 = Color3.fromHSV(h, 1, 1), ZIndex = 1 }); AddCorner(SVBox, 4)
            local SatLayer = Create("Frame", { Parent = SVBox, Size = UDim2.new(1,0,1,0), BackgroundColor3 = Color3.new(1,1,1), BackgroundTransparency = 0, ZIndex = 2 }); AddCorner(SatLayer, 4); Create("UIGradient", { Parent = SatLayer, Color = ColorSequence.new(Color3.new(1,1,1)), Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0,0), NumberSequenceKeypoint.new(1,1)} })
            local ValLayer = Create("Frame", { Parent = SVBox, Size = UDim2.new(1,0,1,0), BackgroundColor3 = Color3.new(0,0,0), BackgroundTransparency = 0, ZIndex = 3 }); AddCorner(ValLayer, 4); Create("UIGradient", { Parent = ValLayer, Rotation = 90, Color = ColorSequence.new(Color3.new(0,0,0)), Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0,1), NumberSequenceKeypoint.new(1,0)} })
            local PickerDot = Create("Frame", { Parent = SVBox, Size = UDim2.new(0, 4, 0, 4), Position = UDim2.new(s, -2, 1-v, -2), BackgroundColor3 = Color3.new(1,1,1), ZIndex = 10 }); AddCorner(PickerDot, 4); AddStroke(PickerDot, Color3.new(0,0,0), 1)
            local HueBar = Create("Frame", { Parent = Palette, Position = UDim2.new(0, 16, 0, 110), Size = UDim2.new(1, -32, 0, 10), BackgroundColor3 = Color3.new(1,1,1) }); AddCorner(HueBar, 4); Create("UIGradient", { Parent = HueBar, Color = ColorSequence.new{ ColorSequenceKeypoint.new(0, Color3.new(1,0,0)), ColorSequenceKeypoint.new(0.167, Color3.new(1,1,0)), ColorSequenceKeypoint.new(0.333, Color3.new(0,1,0)), ColorSequenceKeypoint.new(0.5, Color3.new(0,1,1)), ColorSequenceKeypoint.new(0.667, Color3.new(0,0,1)), ColorSequenceKeypoint.new(0.833, Color3.new(1,0,1)), ColorSequenceKeypoint.new(1, Color3.new(1,0,0)) } })
            local HueDot = Create("Frame", { Parent = HueBar, Size = UDim2.new(0, 4, 1, 0), Position = UDim2.new(h, -2, 0, 0), BackgroundColor3 = Color3.new(1,1,1) }); AddCorner(HueDot, 2); AddStroke(HueDot, Color3.new(0,0,0), 1)
            local function UpdateColor() local newColor = Color3.fromHSV(h, s, v); Preview.BackgroundColor3 = newColor; SVBox.BackgroundColor3 = Color3.fromHSV(h, 1, 1); PickerDot.Position = UDim2.new(s, -2, 1-v, -2); HueDot.Position = UDim2.new(h, -2, 0, 0); if callback then callback(newColor) end end
            local function UpdateHue() local m = UserInputService:GetMouseLocation(); local rx = math.clamp(m.X - HueBar.AbsolutePosition.X, 0, HueBar.AbsoluteSize.X); h = rx / HueBar.AbsoluteSize.X; UpdateColor() end
            local function UpdateSV() local m = UserInputService:GetMouseLocation(); local rx = math.clamp(m.X - SVBox.AbsolutePosition.X, 0, SVBox.AbsoluteSize.X); local ry = math.clamp(m.Y - SVBox.AbsolutePosition.Y - 36, 0, SVBox.AbsoluteSize.Y); s = rx / SVBox.AbsoluteSize.X; v = 1 - (ry / SVBox.AbsoluteSize.Y); UpdateColor() end
            HueBar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then local dragging = true; UpdateHue(); local c; c = RunService.RenderStepped:Connect(function() if not dragging then c:Disconnect() return end; UpdateHue(); if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then dragging = false; c:Disconnect() end end) end end)
            ValLayer.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then local dragging = true; UpdateSV(); local c; c = RunService.RenderStepped:Connect(function() if not dragging then c:Disconnect() return end; UpdateSV(); if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then dragging = false; c:Disconnect() end end) end end)
            Trigger.MouseButton1Click:Connect(function() Open = not Open; if Open then Tween(PickerFrame, {Size = UDim2.new(1, 0, 0, 180)}) else Tween(PickerFrame, {Size = UDim2.new(1, 0, 0, 42)}) end end)
            return SectionFuncs
        end
        return SectionFuncs
    end


    function WindowFuncs:Tab(name)
            local Btn, Text, Ind, Page = CreateTabBtn(name, TabContainer, 0)
            local TabObj = {Btn = Btn, Text = Text, Indicator = Ind, Page = Page}
            table.insert(Tabs, TabObj)
            
            Btn.MouseButton1Click:Connect(function() ActivateTab(TabObj) end)
            if #Tabs == 1 then ActivateTab(TabObj) end
            
            local TabFuncs = {}
            function TabFuncs:Section(text) 
                -- 섹션 제목(Header) 생성 로직
                if text then
                    if #Page:GetChildren() > 2 then Create("Frame", {Parent = Page, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 8)}) end
                    local Label = Register(Create("TextLabel", { Parent = Page, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 28), Font = Enum.Font.GothamBold, Text = string.upper(text), TextColor3 = Fluxa.Theme.Accent, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left }), "Accent")
                    Create("UIPadding", {Parent = Label, PaddingLeft = UDim.new(0, 4)})
                end
                return CreateSection(Page) 
            end
            return TabFuncs
        end



--// 5. SETTINGS TAB (마지막 탭 아래에 자동 추가)
    local SettingsBtn, SettingsText, SettingsInd, SettingsPage = CreateTabBtn("Settings", TabContainer, 9999)
    local SettingsTabObj = {Btn = SettingsBtn, Text = SettingsText, Indicator = SettingsInd, Page = SettingsPage}
    
    SettingsBtn.MouseButton1Click:Connect(function() 
        ActivateTab(SettingsTabObj) 
    end)

    local SetSec = CreateSection(SettingsPage)

    -- [[ CONFIG MANAGER ]]
    SetSec:Toggle("Config Manager", true)
    local CfgName = "default"
    SetSec:TextBox("Config Name", function(t) CfgName = t end)
    local function GetConfigs() if not listfiles then return {} end; local files = listfiles(Fluxa.ConfigFolder); local names = {}; for _, file in pairs(files) do local name = file:match("([^/]+)%.json$"); if name then table.insert(names, name) end end; return names end
    SetSec:Dropdown("Select Config", GetConfigs(), function(val) CfgName = val end)
    SetSec:Button("Save Config", function() if writefile then writefile(Fluxa.ConfigFolder .. "/" .. CfgName .. ".json", HttpService:JSONEncode(Fluxa.Flags)) end end)
    SetSec:Button("Load Config", function() if readfile and isfile(Fluxa.ConfigFolder .. "/" .. CfgName .. ".json") then local data = HttpService:JSONDecode(readfile(Fluxa.ConfigFolder .. "/" .. CfgName .. ".json")); Fluxa.Flags = data end end)

    -- [[ THEME MANAGER ]]
    SetSec:Toggle("Theme Manager", true)
    local function GetThemes() if not listfiles then return {} end; local files = listfiles(Fluxa.ThemeFolder); local names = {}; for _, file in pairs(files) do local name = file:match("([^/]+)%.json$"); if name then table.insert(names, name) end end; return names end
    local ThemeName = "default"
    SetSec:TextBox("Theme Name", function(t) ThemeName = t end)
    SetSec:Dropdown("Select Theme", GetThemes(), function(val) ThemeName = val end)
    SetSec:Button("Save Theme", function() if writefile then writefile(Fluxa.ThemeFolder .. "/" .. ThemeName .. ".json", HttpService:JSONEncode(Fluxa.Theme)) end end)

    -- [[ THEME CUSTOMIZER ]]
    SetSec:Toggle("Theme Customizer", true)
    local keys = {"Accent", "Background", "Sidebar", "Element", "Text", "SubText", "Outline"}
    for _, key in pairs(keys) do 
        SetSec:ColorPicker(key, Fluxa.Theme[key], function(color) 
            Fluxa.Theme[key] = color 
            Fluxa:UpdateTheme() 
        end) 
    end

    -- [핵심] 이 return WindowFuncs가 반드시 있어야 Window:Tab()이 작동합니다!
    return WindowFuncs
end -- Fluxa:Window 함수 종료

return Fluxa -- 라이브러리 메인 테이블 반환
