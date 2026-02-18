--[[ 
    CYBERPUNK TERMINAL LIBRARY v2 (Enhanced Style & Fixes)
    Designed for: Synapse X, Krnl, etc.
]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

--// 1. 보안 및 초기화 (ProtectGui)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CyberTerminalUI_v2"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false -- 리스폰 시 초기화 방지

if syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = CoreGui
elseif gethui then
    ScreenGui.Parent = gethui()
else
    ScreenGui.Parent = CoreGui
end

--// 라이브러리 테이블 & 테마 (세련된 팔레트 적용)
local Library = {
    Flags = {},
    Theme = {
        Background = Color3.fromRGB(10, 12, 16), -- 더 깊고 어두운 배경
        Header = Color3.fromRGB(16, 20, 28),     -- 헤더 및 탭 배경
        Accent = Color3.fromRGB(0, 200, 255),    -- 사이버펑크 시안 (세련된 네온)
        AccentHover = Color3.fromRGB(0, 230, 255), -- 호버 시 더 밝게
        Text = Color3.fromRGB(245, 245, 245),
        DarkText = Color3.fromRGB(120, 130, 140),
        Outline = Color3.fromRGB(30, 35, 45),    -- 미묘한 테두리
        Divider = Color3.fromRGB(22, 26, 34)     -- 구분선
    },
    Folder = "CyberLibConfigs"
}

-- 파일 시스템 체크
local function is_file_exploit()
    return makefolder and writefile and readfile and isfile and listfiles
end

if is_file_exploit() then
    if not isfolder(Library.Folder) then
        makefolder(Library.Folder)
    end
end

--// 유틸리티 함수
local function Create(class, properties)
    local instance = Instance.new(class)
    for k, v in pairs(properties) do
        instance[k] = v
    end
    return instance
end

local function AddStroke(parent, color, thickness, transparency)
    local stroke = Create("UIStroke", {
        Parent = parent,
        Color = color or Library.Theme.Outline,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    })
    return stroke
end

local function AddCorner(parent, radius)
    local corner = Create("UICorner", {
        Parent = parent,
        CornerRadius = UDim.new(0, radius or 4)
    })
    return corner
end

-- 드래그 기능 수정 (TopBar에만 적용, 입력 막힘 방지)
local function MakeDraggable(topbarobject, object)
    local Dragging = nil
    local DragInput = nil
    local DragStart = nil
    local StartPosition = nil

    topbarobject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = input.Position
            StartPosition = object.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end)

    topbarobject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            DragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            local Delta = input.Position - DragStart
            object.Position = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y)
        end
    end)
end

--// 윈도우 생성 함수
function Library:Window(title)
    local WindowFunctions = {}
    
    local MainFrame = Create("Frame", {
        Name = "MainFrame",
        Parent = ScreenGui,
        BackgroundColor3 = Library.Theme.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -325, 0.5, -225),
        Size = UDim2.new(0, 650, 0, 450),
        ClipsDescendants = true -- 내용 잘림 방지
    })
    AddCorner(MainFrame, 6)
    AddStroke(MainFrame, Library.Theme.Accent, 1.5, 0.3) -- 메인 빛나는 테두리

    local TopBar = Create("Frame", {
        Name = "TopBar",
        Parent = MainFrame,
        BackgroundColor3 = Library.Theme.Header,
        Size = UDim2.new(1, 0, 0, 34)
    })
    AddCorner(TopBar, 6)
    
    -- TopBar 하단 직선 코너 처리
    local TopBarCover = Create("Frame", {
        Parent = TopBar,
        BackgroundColor3 = Library.Theme.Header,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -6),
        Size = UDim2.new(1, 0, 0, 6)
    })

    local TitleLabel = Create("TextLabel", {
        Parent = TopBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(1, -24, 1, 0),
        Font = Enum.Font.Code,
        Text = title .. "  //  TERMINAL",
        TextColor3 = Library.Theme.Accent,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    MakeDraggable(TopBar, MainFrame)

    local TabContainer = Create("Frame", {
        Name = "TabContainer",
        Parent = MainFrame,
        BackgroundColor3 = Library.Theme.Header,
        Position = UDim2.new(0, 0, 0, 34),
        Size = UDim2.new(0, 140, 1, -34),
        BorderSizePixel = 0
    })
    
    -- 탭 컨테이너 구분선
    local TabDivider = Create("Frame", {
        Parent = TabContainer,
        BackgroundColor3 = Library.Theme.Divider,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -1, 0, 0),
        Size = UDim2.new(0, 1, 1, 0)
    })

    local PageContainer = Create("Frame", {
        Name = "PageContainer",
        Parent = MainFrame,
        BackgroundColor3 = Library.Theme.Background,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 145, 0, 38), -- 위치 및 간격 조정
        Size = UDim2.new(1, -150, 1, -42), -- 크기 조정으로 잘림 방지
        ClipsDescendants = true
    })
    
    local TabListLayout = Create("UIListLayout", {
        Parent = TabContainer,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4)
    })
    
    local TabPadding = Create("UIPadding", {
        Parent = TabContainer,
        PaddingTop = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 8)
    })

    local Tabs = {}
    local FirstTab = true

    function WindowFunctions:Tab(name)
        local TabFunctions = {}
        
        local TabButton = Create("TextButton", {
            Parent = TabContainer,
            BackgroundColor3 = Library.Theme.Background,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -12, 0, 28),
            Font = Enum.Font.Code,
            Text = " > " .. name,
            TextColor3 = Library.Theme.DarkText,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            AutoButtonColor = false
        })
        AddCorner(TabButton, 4)

        local Page = Create("ScrollingFrame", {
            Parent = PageContainer,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Library.Theme.Accent,
            BorderSizePixel = 0,
            Visible = false
        })
        
        local PageLayout = Create("UIListLayout", {
            Parent = Page,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 12)
        })
        
        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 20)
        end)

        -- 탭 호버 및 클릭 효과
        TabButton.MouseEnter:Connect(function()
            if Page.Visible == false then
                TweenService:Create(TabButton, TweenInfo.new(0.2), {TextColor3 = Library.Theme.Text}):Play()
            end
        end)
        TabButton.MouseLeave:Connect(function()
            if Page.Visible == false then
                TweenService:Create(TabButton, TweenInfo.new(0.2), {TextColor3 = Library.Theme.DarkText}):Play()
            end
        end)

        TabButton.MouseButton1Click:Connect(function()
            for _, t in pairs(Tabs) do
                t.Page.Visible = false
                TweenService:Create(t.Button, TweenInfo.new(0.2), {TextColor3 = Library.Theme.DarkText, BackgroundTransparency = 1}):Play()
            end
            Page.Visible = true
            TweenService:Create(TabButton, TweenInfo.new(0.2), {TextColor3 = Library.Theme.Accent, BackgroundTransparency = 0.8}):Play() -- 활성 탭 배경 미묘하게
        end)

        table.insert(Tabs, {Button = TabButton, Page = Page})
        
        if FirstTab then
            Page.Visible = true
            TabButton.TextColor3 = Library.Theme.Accent
            TabButton.BackgroundTransparency = 0.8
            FirstTab = false
        end

        --// 그룹 박스 (세련된 스타일)
        function TabFunctions:Section(text)
            local SectionFrame = Create("Frame", {
                Parent = Page,
                BackgroundColor3 = Library.Theme.Header,
                BorderSizePixel = 0,
                Size = UDim2.new(1, -8, 0, 0)
            })
            AddCorner(SectionFrame, 5)
            AddStroke(SectionFrame, Library.Theme.Outline, 1)
            
            local SectionLabel = Create("TextLabel", {
                Parent = SectionFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 12, 0, -11),
                Size = UDim2.new(0, 0, 0, 20), -- 너비 자동 계산
                BackgroundColor3 = Library.Theme.Header,
                Text = " " .. text .. " ",
                TextColor3 = Library.Theme.Accent,
                Font = Enum.Font.Code,
                TextSize = 13,
                ZIndex = 2,
                AutomaticSize = Enum.AutomaticSize.X
            })
            
            local LabelBack = Create("Frame", {
                Parent = SectionFrame,
                BackgroundColor3 = Library.Theme.Header,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 10, 0, -2),
                Size = UDim2.new(0, 0, 0, 4),
                ZIndex = 1,
                AutomaticSize = Enum.AutomaticSize.X
            })
            
            -- 라벨 크기에 맞춰 배경 크기 조절
            SectionLabel:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                LabelBack.Size = UDim2.new(0, SectionLabel.AbsoluteSize.X - 4, 0, 4)
            end)

            local SectionContent = Create("Frame", {
                Parent = SectionFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 18),
                Size = UDim2.new(1, -20, 0, 0)
            })

            local ContentLayout = Create("UIListLayout", {
                Parent = SectionContent,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 8)
            })
            
            ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                SectionContent.Size = UDim2.new(1, -20, 0, ContentLayout.AbsoluteContentSize.Y)
                SectionFrame.Size = UDim2.new(1, -8, 0, ContentLayout.AbsoluteContentSize.Y + 28)
            end)

            local SectionFunctions = {}

            --// 요소: 토글 (스타일 개선 및 클릭 수정)
            function SectionFunctions:Toggle(text, default, callback)
                local ToggleParams = { State = default or false }
                Library.Flags[text] = default or false

                local ToggleFrame = Create("TextButton", {
                    Parent = SectionContent,
                    BackgroundColor3 = Library.Theme.Background,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 28),
                    AutoButtonColor = false,
                    Text = ""
                })
                AddCorner(ToggleFrame, 4)
                local ToggleStroke = AddStroke(ToggleFrame, Library.Theme.Outline, 1)

                local ToggleText = Create("TextLabel", {
                    Parent = ToggleFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 34, 0, 0),
                    Size = UDim2.new(1, -34, 1, 0),
                    Font = Enum.Font.Code,
                    Text = text,
                    TextColor3 = Library.Theme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local Checkbox = Create("Frame", {
                    Parent = ToggleFrame,
                    BackgroundColor3 = Library.Theme.Header,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 6, 0, 6),
                    Size = UDim2.new(0, 16, 0, 16)
                })
                AddCorner(Checkbox, 3)
                AddStroke(Checkbox, Library.Theme.Outline, 1)

                local Indicator = Create("Frame", {
                    Parent = Checkbox,
                    BackgroundColor3 = Library.Theme.Accent,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 3, 0, 3),
                    Size = UDim2.new(0, 10, 0, 10),
                    Visible = default or false
                })
                AddCorner(Indicator, 2)

                local SubContainer = Create("Frame", {
                    Parent = SectionContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 0),
                    Visible = default or false,
                    ClipsDescendants = true
                })
                
                local SubLayout = Create("UIListLayout", {
                    Parent = SubContainer,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 8)
                })
                
                local SubPadding = Create("UIPadding", {
                    Parent = SubContainer,
                    PaddingLeft = UDim.new(0, 12),
                    PaddingTop = UDim.new(0, 4)
                })

                local function UpdateState()
                    ToggleParams.State = not ToggleParams.State
                    Library.Flags[text] = ToggleParams.State
                    
                    if ToggleParams.State then
                        TweenService:Create(Indicator, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
                        TweenService:Create(ToggleStroke, TweenInfo.new(0.15), {Color = Library.Theme.Accent}):Play()
                    else
                        TweenService:Create(Indicator, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
                        TweenService:Create(ToggleStroke, TweenInfo.new(0.15), {Color = Library.Theme.Outline}):Play()
                    end
                    Indicator.Visible = true -- 항상 보이게 하고 투명도로 조절

                    SubContainer.Visible = ToggleParams.State
                    if callback then callback(ToggleParams.State) end
                end
                
                -- 초기 상태 설정
                if default then
                     ToggleStroke.Color = Library.Theme.Accent
                     Indicator.BackgroundTransparency = 0
                else
                     Indicator.BackgroundTransparency = 1
                end

                ToggleFrame.MouseButton1Click:Connect(UpdateState)
                
                -- 호버 효과
                ToggleFrame.MouseEnter:Connect(function()
                    if not ToggleParams.State then
                        TweenService:Create(ToggleStroke, TweenInfo.new(0.15), {Color = Library.Theme.Text}):Play()
                    end
                end)
                ToggleFrame.MouseLeave:Connect(function()
                    if not ToggleParams.State then
                        TweenService:Create(ToggleStroke, TweenInfo.new(0.15), {Color = Library.Theme.Outline}):Play()
                    end
                end)

                local SubFunctions = {}
                -- 중첩 요소 추가 기능 (예시: 라벨)
                function SubFunctions:AddLabel(name)
                    local SubLabel = Create("TextLabel", {
                        Parent = SubContainer,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 20),
                        Font = Enum.Font.Code,
                        Text = "-> " .. name,
                        TextColor3 = Library.Theme.DarkText,
                        TextSize = 12,
                        TextXAlignment = Enum.TextXAlignment.Left
                    })
                    SubContainer.Size = UDim2.new(1, 0, 0, SubLayout.AbsoluteContentSize.Y + 8)
                end
                
                return SubFunctions
            end

            --// 요소: 버튼 (새로 추가)
            function SectionFunctions:Button(text, callback)
                local ButtonFrame = Create("TextButton", {
                    Parent = SectionContent,
                    BackgroundColor3 = Library.Theme.Background,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 28),
                    AutoButtonColor = false,
                    Font = Enum.Font.Code,
                    Text = text,
                    TextColor3 = Library.Theme.Text,
                    TextSize = 13
                })
                AddCorner(ButtonFrame, 4)
                local ButtonStroke = AddStroke(ButtonFrame, Library.Theme.Outline, 1)
                
                ButtonFrame.MouseButton1Click:Connect(function()
                    TweenService:Create(ButtonFrame, TweenInfo.new(0.1), {BackgroundColor3 = Library.Theme.Accent, TextColor3 = Library.Theme.Header}):Play()
                    task.wait(0.1)
                    TweenService:Create(ButtonFrame, TweenInfo.new(0.1), {BackgroundColor3 = Library.Theme.Background, TextColor3 = Library.Theme.Text}):Play()
                    if callback then callback() end
                end)
                
                ButtonFrame.MouseEnter:Connect(function()
                    TweenService:Create(ButtonStroke, TweenInfo.new(0.15), {Color = Library.Theme.Accent}):Play()
                end)
                ButtonFrame.MouseLeave:Connect(function()
                    TweenService:Create(ButtonStroke, TweenInfo.new(0.15), {Color = Library.Theme.Outline}):Play()
                end)
            end

            --// 요소: 슬라이더 (스타일 개선)
            function SectionFunctions:Slider(text, min, max, default, callback)
                Library.Flags[text] = default or min
                local SliderFrame = Create("Frame", {
                    Parent = SectionContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 42)
                })

                local SliderLabel = Create("TextLabel", {
                    Parent = SliderFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 20),
                    Font = Enum.Font.Code,
                    Text = text,
                    TextColor3 = Library.Theme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local ValueLabel = Create("TextLabel", {
                    Parent = SliderFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -60, 0, 0),
                    Size = UDim2.new(0, 60, 0, 20),
                    Font = Enum.Font.Code,
                    Text = tostring(default) .. " / " .. tostring(max),
                    TextColor3 = Library.Theme.Accent,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Right
                })

                local SliderBar = Create("Frame", {
                    Parent = SliderFrame,
                    BackgroundColor3 = Library.Theme.Background,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 26),
                    Size = UDim2.new(1, 0, 0, 8)
                })
                AddCorner(SliderBar, 4)
                AddStroke(SliderBar, Library.Theme.Outline, 1)

                local Fill = Create("Frame", {
                    Parent = SliderBar,
                    BackgroundColor3 = Library.Theme.Accent,
                    BorderSizePixel = 0,
                    Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
                })
                AddCorner(Fill, 4)

                local Trigger = Create("TextButton", {
                    Parent = SliderBar,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = ""
                })

                local function UpdateSlide(input)
                    local SizeX = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
                    local Value = math.floor(min + ((max - min) * SizeX))
                    TweenService:Create(Fill, TweenInfo.new(0.1), {Size = UDim2.new(SizeX, 0, 1, 0)}):Play()
                    ValueLabel.Text = tostring(Value) .. " / " .. tostring(max)
                    Library.Flags[text] = Value
                    if callback then callback(Value) end
                end

                Trigger.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        local Connection
                        UpdateSlide(input)
                        Connection = RunService.RenderStepped:Connect(function()
                            if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                                UpdateSlide(UserInputService:GetMouseLocation())
                            else
                                Connection:Disconnect()
                            end
                        end)
                    end
                end)
            end

            --// 요소: 검색 가능한 드롭다운 (스타일 및 기능 개선)
            function SectionFunctions:Dropdown(text, list, callback)
                local DropdownOpen = false
                
                local DropFrame = Create("Frame", {
                    Parent = SectionContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 50),
                    ClipsDescendants = true,
                    ZIndex = 10 -- 다른 요소 위에 표시
                })
                
                local Label = Create("TextLabel", {
                    Parent = DropFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 20),
                    Font = Enum.Font.Code,
                    Text = text,
                    TextColor3 = Library.Theme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local SearchBoxOutline = Create("Frame", {
                    Parent = DropFrame,
                    BackgroundColor3 = Library.Theme.Background,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 22),
                    Size = UDim2.new(1, 0, 0, 26)
                })
                AddCorner(SearchBoxOutline, 4)
                local SearchStroke = AddStroke(SearchBoxOutline, Library.Theme.Outline, 1)

                local SearchBox = Create("TextBox", {
                    Parent = SearchBoxOutline,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 8, 0, 0),
                    Size = UDim2.new(1, -26, 1, 0),
                    Font = Enum.Font.Code,
                    PlaceholderText = "Select or Search...",
                    Text = "",
                    TextColor3 = Library.Theme.Accent,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local Icon = Create("TextLabel", {
                    Parent = SearchBoxOutline,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -24, 0, 0),
                    Size = UDim2.new(0, 24, 1, 0),
                    Font = Enum.Font.Code,
                    Text = "v",
                    TextColor3 = Library.Theme.DarkText,
                    TextSize = 14
                })

                local ListFrame = Create("ScrollingFrame", {
                    Parent = DropFrame,
                    BackgroundColor3 = Library.Theme.Header,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 52),
                    Size = UDim2.new(1, 0, 0, 0), -- 초기 높이 0
                    CanvasSize = UDim2.new(0,0,0,0),
                    ScrollBarThickness = 3,
                    ScrollBarImageColor3 = Library.Theme.Accent,
                    Visible = false,
                    ZIndex = 11
                })
                AddCorner(ListFrame, 4)
                AddStroke(ListFrame, Library.Theme.Outline, 1)
                
                local ListLayout = Create("UIListLayout", {
                    Parent = ListFrame,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 2)
                })
                local ListPadding = Create("UIPadding", {
                    Parent = ListFrame,
                    PaddingTop = UDim.new(0, 4),
                    PaddingBottom = UDim.new(0, 4),
                    PaddingLeft = UDim.new(0, 4),
                    PaddingRight = UDim.new(0, 4)
                })

                local function RefreshList(filter)
                    for _, v in pairs(ListFrame:GetChildren()) do
                        if v:IsA("TextButton") then v:Destroy() end
                    end
                    
                    local count = 0
                    for _, item in pairs(list) do
                        if filter == nil or filter == "" or string.find(string.lower(item), string.lower(filter)) then
                            local ItemBtn = Create("TextButton", {
                                Parent = ListFrame,
                                BackgroundColor3 = Library.Theme.Background,
                                BackgroundTransparency = 1,
                                Size = UDim2.new(1, 0, 0, 24),
                                Font = Enum.Font.Code,
                                Text = item,
                                TextColor3 = Library.Theme.Text,
                                TextSize = 13,
                                AutoButtonColor = false
                            })
                            AddCorner(ItemBtn, 3)
                            
                            ItemBtn.MouseEnter:Connect(function()
                                TweenService:Create(ItemBtn, TweenInfo.new(0.1), {BackgroundTransparency = 0.8, TextColor3 = Library.Theme.Accent}):Play()
                            end)
                            ItemBtn.MouseLeave:Connect(function()
                                TweenService:Create(ItemBtn, TweenInfo.new(0.1), {BackgroundTransparency = 1, TextColor3 = Library.Theme.Text}):Play()
                            end)

                            ItemBtn.MouseButton1Click:Connect(function()
                                SearchBox.Text = item
                                DropdownOpen = false
                                TweenService:Create(DropFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 50)}):Play()
                                TweenService:Create(ListFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 0)}):Play()
                                TweenService:Create(Icon, TweenInfo.new(0.2), {Rotation = 0}):Play()
                                task.wait(0.2)
                                ListFrame.Visible = false
                                if callback then callback(item) end
                            end)
                            count = count + 1
                        end
                    end
                    ListFrame.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 8)
                    local newHeight = math.min(count * 26 + 10, 150) -- 최대 높이 제한
                    if DropdownOpen then
                         TweenService:Create(ListFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, newHeight)}):Play()
                         TweenService:Create(DropFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 52 + newHeight)}):Play()
                    end
                end

                SearchBox.Focused:Connect(function()
                    if not DropdownOpen then
                        DropdownOpen = true
                        ListFrame.Visible = true
                        TweenService:Create(Icon, TweenInfo.new(0.2), {Rotation = 180}):Play()
                        TweenService:Create(SearchStroke, TweenInfo.new(0.2), {Color = Library.Theme.Accent}):Play()
                        RefreshList(SearchBox.Text)
                    end
                end)
                
                SearchBox.FocusLost:Connect(function()
                     TweenService:Create(SearchStroke, TweenInfo.new(0.2), {Color = Library.Theme.Outline}):Play()
                     -- 약간의 딜레이 후 닫기 (버튼 클릭 허용)
                     task.delay(0.2, function()
                         if DropdownOpen and not ListFrame.IsMouseOver then -- 마우스가 리스트 위에 없으면 닫기
                             DropdownOpen = false
                             TweenService:Create(DropFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 50)}):Play()
                             TweenService:Create(ListFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 0)}):Play()
                             TweenService:Create(Icon, TweenInfo.new(0.2), {Rotation = 0}):Play()
                             task.wait(0.2)
                             ListFrame.Visible = false
                         end
                     end)
                end)

                SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
                    if DropdownOpen then
                        RefreshList(SearchBox.Text)
                    end
                end)
            end

            return SectionFunctions
        end
        return TabFunctions
    end
end

return Library
