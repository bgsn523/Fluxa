local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

--// 1. 보안 및 초기화 (ProtectGui)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CyberTerminalUI"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

if syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = CoreGui
elseif gethui then
    ScreenGui.Parent = gethui()
else
    ScreenGui.Parent = CoreGui
end

--// 라이브러리 테이블
local Library = {
    Flags = {},
    Theme = {
        Background = Color3.fromRGB(15, 15, 20),
        Header = Color3.fromRGB(10, 10, 15),
        Accent = Color3.fromRGB(0, 255, 170), -- 사이버펑크 네온
        Text = Color3.fromRGB(240, 240, 240),
        DarkText = Color3.fromRGB(150, 150, 150),
        Outline = Color3.fromRGB(40, 40, 40)
    },
    Folder = "CyberLibConfigs"
}

-- 파일 시스템 체크 (Exploit 환경 확인)
local function is_file_exploit()
    return makefolder and writefile and readfile and isfile
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

-- 드래그 기능
local function MakeDraggable(topbarobject, object)
    local Dragging = nil
    local DragInput = nil
    local DragStart = nil
    local StartPosition = nil

    local function Update(input)
        local Delta = input.Position - DragStart
        object.Position = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y)
    end

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
            Update(input)
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
        Position = UDim2.new(0.5, -300, 0.5, -200),
        Size = UDim2.new(0, 600, 0, 450)
    })
    
    -- 테두리 장식 (사이버펑크 느낌)
    local Outline = Create("UIStroke", {
        Parent = MainFrame,
        Color = Library.Theme.Accent,
        Thickness = 1.5,
        Transparency = 0.5
    })

    local TopBar = Create("Frame", {
        Name = "TopBar",
        Parent = MainFrame,
        BackgroundColor3 = Library.Theme.Header,
        Size = UDim2.new(1, 0, 0, 30)
    })
    
    local TitleLabel = Create("TextLabel", {
        Parent = TopBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -20, 1, 0),
        Font = Enum.Font.Code, -- 터미널 폰트
        Text = title .. " // TERMINAL",
        TextColor3 = Library.Theme.Accent,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    MakeDraggable(TopBar, MainFrame)

    local TabContainer = Create("Frame", {
        Name = "TabContainer",
        Parent = MainFrame,
        BackgroundColor3 = Library.Theme.Header,
        Position = UDim2.new(0, 0, 0, 31),
        Size = UDim2.new(0, 120, 1, -31)
    })

    local PageContainer = Create("Frame", {
        Name = "PageContainer",
        Parent = MainFrame,
        BackgroundColor3 = Library.Theme.Background,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 125, 0, 35),
        Size = UDim2.new(1, -130, 1, -40)
    })
    
    local TabListLayout = Create("UIListLayout", {
        Parent = TabContainer,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2)
    })

    local Tabs = {}

    function WindowFunctions:Tab(name)
        local TabFunctions = {}
        
        -- 탭 버튼
        local TabButton = Create("TextButton", {
            Parent = TabContainer,
            BackgroundColor3 = Library.Theme.Background,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 30),
            Font = Enum.Font.Code,
            Text = "> " .. name,
            TextColor3 = Library.Theme.DarkText,
            TextSize = 14
        })

        -- 페이지 (스크롤 가능)
        local Page = Create("ScrollingFrame", {
            Parent = PageContainer,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0), -- 자동 조절 예정
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Library.Theme.Accent,
            Visible = false
        })
        
        local PageLayout = Create("UIListLayout", {
            Parent = Page,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10)
        })
        
        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 20)
        end)

        -- 탭 전환 로직
        TabButton.MouseButton1Click:Connect(function()
            for _, t in pairs(Tabs) do
                t.Page.Visible = false
                t.Button.TextColor3 = Library.Theme.DarkText
            end
            Page.Visible = true
            TabButton.TextColor3 = Library.Theme.Accent
        end)

        table.insert(Tabs, {Button = TabButton, Page = Page})
        
        -- 첫 번째 탭 자동 선택
        if #Tabs == 1 then
            Page.Visible = true
            TabButton.TextColor3 = Library.Theme.Accent
        end

        --// 그룹 박스 (섹션)
        function TabFunctions:Section(text)
            local SectionFrame = Create("Frame", {
                Parent = Page,
                BackgroundColor3 = Color3.fromRGB(20, 20, 25),
                BorderSizePixel = 0,
                Size = UDim2.new(1, -10, 0, 0) -- 자동 높이 조절
            })
            
            local SectionStroke = Create("UIStroke", {
                Parent = SectionFrame,
                Color = Library.Theme.Outline,
                Thickness = 1
            })
            
            local SectionLabel = Create("TextLabel", {
                Parent = SectionFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, -10),
                Size = UDim2.new(0, 100, 0, 20),
                BackgroundColor3 = Library.Theme.Background, -- 배경을 덮어서 라벨처럼 보이게
                Text = " [ " .. text .. " ] ",
                TextColor3 = Library.Theme.Accent,
                Font = Enum.Font.Code,
                TextSize = 12,
                ZIndex = 2
            })
            
            -- 라벨 뒤의 선을 가리기 위한 배경 패치
            local LabelBack = Create("Frame", {
                Parent = SectionFrame,
                BackgroundColor3 = Library.Theme.Background,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 8, 0, -2),
                Size = UDim2.new(0, SectionLabel.TextBounds.X + 4, 0, 4),
                ZIndex = 1
            })

            local SectionContent = Create("Frame", {
                Parent = SectionFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 15),
                Size = UDim2.new(1, -20, 0, 0)
            })

            local ContentLayout = Create("UIListLayout", {
                Parent = SectionContent,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 5)
            })
            
            ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                SectionContent.Size = UDim2.new(1, -20, 0, ContentLayout.AbsoluteContentSize.Y)
                SectionFrame.Size = UDim2.new(1, -10, 0, ContentLayout.AbsoluteContentSize.Y + 25)
            end)

            local SectionFunctions = {}

            --// 요소: 토글 (중첩 가능)
            function SectionFunctions:Toggle(text, default, callback)
                local ToggleParams = {
                    State = default or false
                }
                Library.Flags[text] = default or false

                local ToggleFrame = Create("TextButton", {
                    Parent = SectionContent,
                    BackgroundColor3 = Library.Theme.Header,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 25),
                    AutoButtonColor = false,
                    Text = ""
                })

                local ToggleText = Create("TextLabel", {
                    Parent = ToggleFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 30, 0, 0),
                    Size = UDim2.new(1, -30, 1, 0),
                    Font = Enum.Font.Code,
                    Text = text,
                    TextColor3 = Library.Theme.Text,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local Checkbox = Create("Frame", {
                    Parent = ToggleFrame,
                    BackgroundColor3 = Library.Theme.Background,
                    BorderSizePixel = 1,
                    BorderColor3 = Library.Theme.Outline,
                    Position = UDim2.new(0, 5, 0, 5),
                    Size = UDim2.new(0, 15, 0, 15)
                })

                local Indicator = Create("Frame", {
                    Parent = Checkbox,
                    BackgroundColor3 = Library.Theme.Accent,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 2, 0, 2),
                    Size = UDim2.new(0, 11, 0, 11),
                    Visible = default or false
                })

                -- 중첩 토글을 위한 컨테이너 (처음엔 숨김)
                local SubContainer = Create("Frame", {
                    Parent = SectionContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -10, 0, 0), -- 높이 자동
                    Visible = default or false,
                    ClipsDescendants = true
                })
                
                local SubLayout = Create("UIListLayout", {
                    Parent = SubContainer,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 5)
                })

                local function UpdateState()
                    ToggleParams.State = not ToggleParams.State
                    Library.Flags[text] = ToggleParams.State
                    Indicator.Visible = ToggleParams.State
                    
                    -- 중첩 컨테이너 보이기/숨기기
                    SubContainer.Visible = ToggleParams.State
                    
                    if callback then callback(ToggleParams.State) end
                end

                ToggleFrame.MouseButton1Click:Connect(UpdateState)

                -- 중첩 항목 추가 함수 (재귀적 구조 가능)
                local SubFunctions = {}
                function SubFunctions:AddOption(type, name, arg1, arg2)
                    -- 여기에 슬라이더, 버튼 등을 추가하여 SubContainer에 넣는 로직 구현
                    -- (예시로 텍스트 라벨만 추가)
                    local SubLabel = Create("TextLabel", {
                        Parent = SubContainer,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 20),
                        Font = Enum.Font.Code,
                        Text = "  -> " .. name, -- 들여쓰기 효과
                        TextColor3 = Library.Theme.DarkText,
                        TextSize = 12,
                        TextXAlignment = Enum.TextXAlignment.Left
                    })
                    -- 레이아웃 업데이트 트리거
                    SubContainer.Size = UDim2.new(1, -10, 0, SubLayout.AbsoluteContentSize.Y)
                end
                
                return SubFunctions
            end

            --// 요소: 슬라이더
            function SectionFunctions:Slider(text, min, max, default, callback)
                Library.Flags[text] = default or min
                local SliderFrame = Create("Frame", {
                    Parent = SectionContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 40)
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
                    Position = UDim2.new(1, -50, 0, 0),
                    Size = UDim2.new(0, 50, 0, 20),
                    Font = Enum.Font.Code,
                    Text = tostring(default),
                    TextColor3 = Library.Theme.Accent,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Right
                })

                local SliderBar = Create("Frame", {
                    Parent = SliderFrame,
                    BackgroundColor3 = Library.Theme.Outline,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 25),
                    Size = UDim2.new(1, 0, 0, 6)
                })

                local Fill = Create("Frame", {
                    Parent = SliderBar,
                    BackgroundColor3 = Library.Theme.Accent,
                    BorderSizePixel = 0,
                    Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
                })

                local Trigger = Create("TextButton", {
                    Parent = SliderBar,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = ""
                })

                local function UpdateSlide(input)
                    local SizeX = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
                    local Value = math.floor(min + ((max - min) * SizeX))
                    Fill.Size = UDim2.new(SizeX, 0, 1, 0)
                    ValueLabel.Text = tostring(Value)
                    Library.Flags[text] = Value
                    if callback then callback(Value) end
                end

                Trigger.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        local Connection
                        UpdateSlide(input)
                        Connection = RunService.RenderStepped:Connect(function()
                            if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                                UpdateSlide(UserInputService:GetMouseLocation()) -- 수정: MouseLocation 사용 권장
                            else
                                Connection:Disconnect()
                            end
                        end)
                    end
                end)
            end

            --// 요소: 검색 가능한 드롭다운
            function SectionFunctions:Dropdown(text, list, callback)
                local DropdownOpen = false
                
                local DropFrame = Create("Frame", {
                    Parent = SectionContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 45), -- 닫혔을 때 크기
                    ClipsDescendants = true
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

                local SearchBox = Create("TextBox", {
                    Parent = DropFrame,
                    BackgroundColor3 = Library.Theme.Header,
                    BorderSizePixel = 1,
                    BorderColor3 = Library.Theme.Outline,
                    Position = UDim2.new(0, 0, 0, 22),
                    Size = UDim2.new(1, 0, 0, 20),
                    Font = Enum.Font.Code,
                    PlaceholderText = "Select or Search...",
                    Text = "",
                    TextColor3 = Library.Theme.Accent,
                    TextSize = 12
                })

                local ListFrame = Create("ScrollingFrame", {
                    Parent = DropFrame,
                    BackgroundColor3 = Library.Theme.Header,
                    BorderSizePixel = 1,
                    BorderColor3 = Library.Theme.Outline,
                    Position = UDim2.new(0, 0, 0, 45),
                    Size = UDim2.new(1, 0, 0, 100),
                    CanvasSize = UDim2.new(0,0,0,0),
                    Visible = false
                })
                
                local ListLayout = Create("UIListLayout", {
                    Parent = ListFrame,
                    SortOrder = Enum.SortOrder.LayoutOrder
                })

                -- 리스트 갱신 함수
                local function RefreshList(filter)
                    for _, v in pairs(ListFrame:GetChildren()) do
                        if v:IsA("TextButton") then v:Destroy() end
                    end
                    
                    for _, item in pairs(list) do
                        if filter == nil or string.find(string.lower(item), string.lower(filter)) then
                            local ItemBtn = Create("TextButton", {
                                Parent = ListFrame,
                                BackgroundColor3 = Library.Theme.Background,
                                Size = UDim2.new(1, 0, 0, 20),
                                Font = Enum.Font.Code,
                                Text = item,
                                TextColor3 = Library.Theme.Text,
                                TextSize = 12
                            })
                            ItemBtn.MouseButton1Click:Connect(function()
                                SearchBox.Text = item
                                DropdownOpen = false
                                ListFrame.Visible = false
                                DropFrame.Size = UDim2.new(1, 0, 0, 45)
                                if callback then callback(item) end
                            end)
                        end
                    end
                    ListFrame.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y)
                end

                SearchBox.Focused:Connect(function()
                    DropdownOpen = true
                    ListFrame.Visible = true
                    DropFrame.Size = UDim2.new(1, 0, 0, 150) -- 열렸을 때 크기
                    RefreshList(SearchBox.Text)
                end)

                SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
                    RefreshList(SearchBox.Text)
                end)
            end

            return SectionFunctions
        end
        return TabFunctions
    end

    --// Settings 탭 (JSON 저장/로드)
    local SettingsTab = WindowFunctions:Tab("Settings")
    local ConfigSection = SettingsTab:Section("Configuration")

    local ConfigName = ""
    
    -- Config 이름 입력
    local NameBox = Create("TextBox", {
        Parent = ConfigSection.Parent.Parent, -- 조금 해키하지만 SectionContent에 직접 접근하기 위함 (여기서는 그냥 섹션 함수 사용 추천)
        -- (위의 섹션 구조상 직접 구현 대신 섹션 기능 사용)
    })
    
    -- UI 요소로 다시 구현
    ConfigSection:Toggle("Use Custom Config Name", false, function(v) end) -- 예시
    
    local NameInput = Create("TextBox", {
        Parent = ConfigSection.Parent:FindFirstChild("Frame"):FindFirstChild("Frame"), -- 구조체계 따라감
        BackgroundColor3 = Library.Theme.Header,
        Size = UDim2.new(1, 0, 0, 25),
        Font = Enum.Font.Code,
        PlaceholderText = "Config Name...",
        Text = "",
        TextColor3 = Library.Theme.Accent,
        TextSize = 13
    })
    NameInput.Parent = PageContainer:GetChildren()[#PageContainer:GetChildren()].Frame.Frame -- 마지막 페이지(Settings)의 섹션에 붙임
    NameInput.FocusLost:Connect(function()
        ConfigName = NameInput.Text
    end)

    ConfigSection:Dropdown("Select Config", {}, function(val)
        ConfigName = val
    end)

    -- 설정 저장 버튼
    local SaveBtn = Create("TextButton", {
        Parent = NameInput.Parent,
        BackgroundColor3 = Library.Theme.Accent,
        Size = UDim2.new(1, 0, 0, 25),
        Font = Enum.Font.Code,
        Text = "SAVE CONFIG (JSON)",
        TextColor3 = Color3.new(0,0,0)
    })
    
    SaveBtn.MouseButton1Click:Connect(function()
        if ConfigName == "" then return end
        if is_file_exploit() then
            local json = HttpService:JSONEncode(Library.Flags)
            writefile(Library.Folder .. "/" .. ConfigName .. ".json", json)
            print("Saved " .. ConfigName)
        end
    end)
    
    -- 새로고침 버튼
    local RefreshBtn = Create("TextButton", {
        Parent = NameInput.Parent,
        BackgroundColor3 = Library.Theme.Header,
        Size = UDim2.new(1, 0, 0, 25),
        Font = Enum.Font.Code,
        Text = "REFRESH LIST",
        TextColor3 = Library.Theme.Text
    })

    -- 키바인드 (UI 토글)
    local KeybindBtn = Create("TextButton", {
        Parent = NameInput.Parent,
        BackgroundColor3 = Library.Theme.Header,
        Size = UDim2.new(1, 0, 0, 25),
        Font = Enum.Font.Code,
        Text = "MENU BIND: RightShift",
        TextColor3 = Library.Theme.Accent
    })
    
    local binding = false
    local menuKey = Enum.KeyCode.RightShift
    
    KeybindBtn.MouseButton1Click:Connect(function()
        binding = true
        KeybindBtn.Text = "PRESS ANY KEY..."
    end)
    
    UserInputService.InputBegan:Connect(function(input)
        if binding and input.UserInputType == Enum.UserInputType.Keyboard then
            menuKey = input.KeyCode
            KeybindBtn.Text = "MENU BIND: " .. tostring(menuKey):gsub("Enum.KeyCode.", "")
            binding = false
        elseif input.KeyCode == menuKey then
            ScreenGui.Enabled = not ScreenGui.Enabled
        end
    end)

    return WindowFunctions
end

return Library
