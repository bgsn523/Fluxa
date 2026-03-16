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
	Background = Color3.fromRGB(20, 22, 26),
	Sidebar = Color3.fromRGB(25, 28, 33),
	Element = Color3.fromRGB(32, 35, 40),
	Hover = Color3.fromRGB(42, 45, 52),
	Accent = Color3.fromRGB(100, 130, 240),
	Text = Color3.fromRGB(240, 240, 245),
	SubText = Color3.fromRGB(140, 145, 155),
	Outline = Color3.fromRGB(50, 50, 55),
	TopBar = Color3.fromRGB(25, 28, 33), -- New: TopBar Color

	FrameCorner = 6,
	BtnCorner = 8,
}

Fluxa.Registry = {
	Background = {},
	Sidebar = {},
	Element = {},
	Hover = {},
	Accent = {},
	Text = {},
	SubText = {},
	Outline = {},
	TopBar = {},
}

Fluxa.Flags = {}
Fluxa.Folder = "Fluxa"
Fluxa.ConfigFolder = Fluxa.Folder .. "/Configs"
Fluxa.ThemeFolder = Fluxa.Folder .. "/Themes"

if makefolder then
	if not isfolder(Fluxa.Folder) then
		makefolder(Fluxa.Folder)
	end
	if not isfolder(Fluxa.ConfigFolder) then
		makefolder(Fluxa.ConfigFolder)
	end
	if not isfolder(Fluxa.ThemeFolder) then
		makefolder(Fluxa.ThemeFolder)
	end
end

--// 3. Utils
local function Create(class, props)
	local inst = Instance.new(class)
	for k, v in pairs(props) do
		inst[k] = v
	end
	return inst
end

local function AddCorner(parent, radius)
	Create("UICorner", { Parent = parent, CornerRadius = UDim.new(0, radius) })
end

local function AddStroke(parent, color, thickness)
	local stroke = Create("UIStroke", {
		Parent = parent,
		Color = color or Fluxa.Theme.Outline,
		Thickness = thickness or 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
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
						Tween(obj, { Color = color })
					elseif obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
						if key == "Text" or key == "SubText" or key == "Accent" then
							Tween(obj, { TextColor3 = color })
						else
							Tween(obj, { BackgroundColor3 = color })
						end
					else
						Tween(obj, { BackgroundColor3 = color })
					end
				end
			end
		end
	end
end

Fluxa.UpdateMap = {} -- 불러오기 시 UI를 갱신할 함수 저장소

-- JSON 저장 시 Color3 호환을 위한 변환 함수
local function EncodeData(data)
	local t = {}
	for k, v in pairs(data) do
		if typeof(v) == "Color3" then
			t[k] = "RGB:" .. v.R .. "," .. v.G .. "," .. v.B
		else
			t[k] = v
		end
	end
	return HttpService:JSONEncode(t)
end

local function DecodeData(str)
	local t = HttpService:JSONDecode(str)
	local res = {}
	for k, v in pairs(t) do
		if type(v) == "string" and v:sub(1, 4) == "RGB:" then
			local s = v:sub(5):split(",")
			res[k] = Color3.new(tonumber(s[1]), tonumber(s[2]), tonumber(s[3]))
		else
			res[k] = v
		end
	end
	return res
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
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	trigger.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			dragInput = input
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			Tween(
				object,
				{
					Position = UDim2.new(
						startPos.X.Scale,
						startPos.X.Offset + delta.X,
						startPos.Y.Scale,
						startPos.Y.Offset + delta.Y
					),
				},
				0.05
			)
		end
	end)
end

--// 4. Main Library
function Fluxa:Window(options)
	-- [중요] 여기서 WindowFuncs 테이블을 먼저 생성해야 합니다.
	local WindowFuncs = {}

	-- Main Window Container
	local Main = Register(
		Create("Frame", {
			Name = "Main",
			Parent = ScreenGui,
			BackgroundColor3 = Fluxa.Theme.Background,
			Position = UDim2.new(0.5, -325, 0.5, -225),
			Size = UDim2.new(0, 650, 0, 450),
			ClipsDescendants = true,
		}),
		"Background"
	)
	AddCorner(Main, Fluxa.Theme.FrameCorner)
	AddStroke(Main, Fluxa.Theme.Outline, 1)

	-- [[ TOP BAR ]] --
	local TopBar = Register(
		Create("Frame", {
			Name = "TopBar",
			Parent = Main,
			BackgroundColor3 = Fluxa.Theme.TopBar,
			Size = UDim2.new(1, 0, 0, 40),
			ZIndex = 2,
		}),
		"Sidebar"
	) -- Using Sidebar color for TopBar usually looks good, or use "TopBar" key

	-- Separator Line under TopBar
	Register(
		Create("Frame", {
			Parent = TopBar,
			BackgroundColor3 = Fluxa.Theme.Outline,
			Size = UDim2.new(1, 0, 0, 1),
			Position = UDim2.new(0, 0, 1, 0),
			BorderSizePixel = 0,
		}),
		"Outline"
	)

	Register(
		Create("TextLabel", {
			Parent = TopBar,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -20, 1, 0),
			Position = UDim2.new(0, 15, 0, 0),
			Font = Enum.Font.GothamBold,
			Text = TitleText,
			TextColor3 = Fluxa.Theme.Accent,
			TextSize = 16,
			TextXAlignment = Enum.TextXAlignment.Left,
		}),
		"Accent"
	)

	MakeDraggable(TopBar, Main)

	-- [[ SIDEBAR ]] --
	-- Positioned below TopBar
	local SidebarHeight = UDim2.new(1, -41, 1, -41)
	local SidebarPos = UDim2.new(0, 0, 0, 41)

	local Sidebar = Register(
		Create("Frame", {
			Parent = Main,
			BackgroundColor3 = Fluxa.Theme.Sidebar,
			Size = UDim2.new(0, 180, 1, -41),
			Position = SidebarPos,
		}),
		"Sidebar"
	)

	-- Sidebar Separator (Vertical)
	if not IsFlat then
		-- In separate mode, we might want visually distinct sidebar
		-- But v15 request implies merging. If IsFlat is true, we remove borders/gaps.
		-- If IsFlat is false, we keep the divider line.
		Register(
			Create(
				"Frame",
				{
					Parent = Sidebar,
					BackgroundColor3 = Fluxa.Theme.Outline,
					Size = UDim2.new(0, 1, 1, 0),
					Position = UDim2.new(1, -1, 0, 0),
					BorderSizePixel = 0,
				}
			),
			"Outline"
		)
	else
		-- In Flat mode, Sidebar and Content share styling more closely, often divided by line
		Register(
			Create(
				"Frame",
				{
					Parent = Sidebar,
					BackgroundColor3 = Fluxa.Theme.Outline,
					Size = UDim2.new(0, 1, 1, 0),
					Position = UDim2.new(1, -1, 0, 0),
					BorderSizePixel = 0,
				}
			),
			"Outline"
		)
	end

	local TabContainer = Create("ScrollingFrame", {
		Parent = Sidebar,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, -20),
		Position = UDim2.new(0, 0, 0, 15), -- Slight top padding
		ScrollBarThickness = 0,
		CanvasSize = UDim2.new(0, 0, 0, 0),
	})
	Create("UIListLayout", { Parent = TabContainer, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8) })
	Create("UIPadding", { Parent = TabContainer, PaddingLeft = UDim.new(0, 12) })

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
		Parent = Main,
		BackgroundTransparency = 1,
		Position = ContentPos,
		Size = ContentSize,
	})

	local Tabs = {}
	local SelectedTab = nil

	local function CreateTabBtn(name, container, layoutOrder)
		local TabBtn = Create("TextButton", {
			Parent = container,
			BackgroundColor3 = Fluxa.Theme.Sidebar,
			Size = UDim2.new(1, -16, 0, 38),
			AutoButtonColor = false,
			Text = "",
			BackgroundTransparency = 1,
			LayoutOrder = layoutOrder or 0,
		})
		Register(TabBtn, "Sidebar")
		AddCorner(TabBtn, Fluxa.Theme.BtnCorner)

		local TabText = Register(
			Create("TextLabel", {
				Parent = TabBtn,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, -20, 1, 0),
				Position = UDim2.new(0, 14, 0, 0),
				Font = Enum.Font.GothamMedium,
				Text = name,
				TextColor3 = Fluxa.Theme.SubText,
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left,
			}),
			"SubText"
		)

		local Indicator = Register(
			Create("Frame", {
				Parent = TabBtn,
				BackgroundColor3 = Fluxa.Theme.Accent,
				Size = UDim2.new(0, 4, 0, 18),
				Position = UDim2.new(0, 0, 0.5, -9),
				Transparency = 1,
			}),
			"Accent"
		)
		AddCorner(Indicator, 4)

		local Page = Create("ScrollingFrame", {
			Parent = Content,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			Visible = false,
			ScrollBarThickness = 3,
			ScrollBarImageColor3 = Fluxa.Theme.Outline,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			BorderSizePixel = 0,
		})
		local PageLayout =
			Create("UIListLayout", { Parent = Page, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 12) })
		Create(
			"UIPadding",
			{
				Parent = Page,
				PaddingTop = UDim.new(0, 5),
				PaddingLeft = UDim.new(0, 4),
				PaddingRight = UDim.new(0, 16),
				PaddingBottom = UDim.new(0, 20),
			}
		)

		PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 40)
		end)

		return TabBtn, TabText, Indicator, Page
	end

	local function ActivateTab(tab)
		if SelectedTab then
			Tween(SelectedTab.Text, { TextColor3 = Fluxa.Theme.SubText })
			Tween(SelectedTab.Indicator, { Transparency = 1 })
			Tween(SelectedTab.Btn, { BackgroundTransparency = 1 })
			SelectedTab.Page.Visible = false
		end
		SelectedTab = tab
		Tween(tab.Text, { TextColor3 = Fluxa.Theme.Text })
		Tween(tab.Indicator, { Transparency = 0 })
		Tween(tab.Btn, { BackgroundTransparency = 0.95, BackgroundColor3 = Fluxa.Theme.Text })
		tab.Page.Visible = true
	end

	-- SECTION & ELEMENTS
	local function CreateSection(page, groupTitle)
		local SectionFuncs = {}

		-- groupTitle이 있으면 그룹 박스 래퍼를 생성하고 내부 page로 교체
		if groupTitle then
			-- 그룹 전체 컨테이너 (AutomaticSize Y로 내용에 맞게 늘어남)
			local GroupBox = Register(Create("Frame", {
				Parent = page,
				BackgroundColor3 = Fluxa.Theme.Sidebar,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BorderSizePixel = 0,
			}), "Sidebar")
			AddCorner(GroupBox, Fluxa.Theme.FrameCorner)
			AddStroke(GroupBox, Fluxa.Theme.Outline, 1)

			-- 그룹 제목 헤더 바 (상단 스트립)
			local Header = Register(Create("Frame", {
				Parent = GroupBox,
				BackgroundColor3 = Fluxa.Theme.Element,
				Size = UDim2.new(1, 0, 0, 32),
				BorderSizePixel = 0,
				ZIndex = 2,
			}), "Element")
			AddCorner(Header, Fluxa.Theme.FrameCorner)
			-- 헤더 하단 코너만 직각으로 만들기 위해 채우기 프레임 추가
			Create("Frame", {
				Parent = Header,
				BackgroundColor3 = Fluxa.Theme.Element,
				Size = UDim2.new(1, 0, 0, Fluxa.Theme.FrameCorner),
				Position = UDim2.new(0, 0, 1, -Fluxa.Theme.FrameCorner),
				BorderSizePixel = 0,
				ZIndex = 2,
			})
			-- Accent 컬러 포인트 선 (왼쪽)
			local AccentBar = Register(Create("Frame", {
				Parent = Header,
				BackgroundColor3 = Fluxa.Theme.Accent,
				Size = UDim2.new(0, 2, 1, -10),
				Position = UDim2.new(0, 6, 0, 5),
				BorderSizePixel = 0,
				ZIndex = 3,
			}), "Accent")
			AddCorner(AccentBar, 2)
			-- 그룹 제목 텍스트
			Register(Create("TextLabel", {
				Parent = Header,
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 16, 0, 0),
				Size = UDim2.new(1, -16, 1, 0),
				Font = Enum.Font.GothamBold,
				Text = string.upper(groupTitle),
				TextColor3 = Fluxa.Theme.Text,
				TextSize = 11,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 3,
			}), "Text")

			-- 내부 요소들이 들어갈 스크롤 없는 frame
			local InnerPage = Create("Frame", {
				Parent = GroupBox,
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 0, 0, 32),
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
			})
			Create("UIListLayout", {
				Parent = InnerPage,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 8),
			})
			Create("UIPadding", {
				Parent = InnerPage,
				PaddingTop = UDim.new(0, 10),
				PaddingLeft = UDim.new(0, 10),
				PaddingRight = UDim.new(0, 10),
				PaddingBottom = UDim.new(0, 10),
			})
			-- 이후 모든 요소는 InnerPage 안에 넣음
			page = InnerPage
		end

		local function AddHeader(text)
			-- Header Title (titleText가 있을 때만 생성하도록 수정)
			if titleText then
				if #page:GetChildren() > 2 then
					Create("Frame", { Parent = page, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 8) })
				end
				local Label = Register(
					Create(
						"TextLabel",
						{
							Parent = page,
							BackgroundTransparency = 1,
							Size = UDim2.new(1, 0, 0, 28),
							Font = Enum.Font.GothamBold,
							Text = string.upper(titleText),
							TextColor3 = Fluxa.Theme.Accent,
							TextSize = 12,
							TextXAlignment = Enum.TextXAlignment.Left,
						}
					),
					"Accent"
				)
				Create("UIPadding", { Parent = Label, PaddingLeft = UDim.new(0, 4) })
			end
			local Label = Register(
				Create("TextLabel", {
					Parent = page,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 28),
					Font = Enum.Font.GothamBold,
					Text = string.upper(text),
					TextColor3 = Fluxa.Theme.Accent,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Left,
				}),
				"Accent"
			)
			Create("UIPadding", { Parent = Label, PaddingLeft = UDim.new(0, 4) })
		end

		function SectionFuncs:Toggle(text, default, callback)
			local Toggled = default or false
			Fluxa.Flags[text] = Toggled
			local ToggleBtn = Register(
				Create(
					"TextButton",
					{
						Parent = page,
						BackgroundColor3 = Fluxa.Theme.Element,
						Size = UDim2.new(1, 0, 0, 42),
						AutoButtonColor = false,
						Text = "",
					}
				),
				"Element"
			)
			AddCorner(ToggleBtn, Fluxa.Theme.FrameCorner)
			AddStroke(ToggleBtn, Fluxa.Theme.Outline, 1)
			Register(
				Create(
					"TextLabel",
					{
						Parent = ToggleBtn,
						BackgroundTransparency = 1,
						Position = UDim2.new(0, 16, 0, 0),
						Size = UDim2.new(1, -70, 1, 0),
						Font = Enum.Font.GothamMedium,
						Text = text,
						TextColor3 = Fluxa.Theme.Text,
						TextSize = 14,
						TextXAlignment = Enum.TextXAlignment.Left,
					}
				),
				"Text"
			)
			local Switch = Register(
				Create(
					"Frame",
					{
						Parent = ToggleBtn,
						BackgroundColor3 = Fluxa.Theme.Sidebar,
						Position = UDim2.new(1, -54, 0.5, -11),
						Size = UDim2.new(0, 38, 0, 22),
					}
				),
				"Sidebar"
			)
			AddCorner(Switch, 16)
			local SwitchStroke = AddStroke(Switch, Fluxa.Theme.Outline, 1)
			local Knob = Register(
				Create(
					"Frame",
					{
						Parent = Switch,
						BackgroundColor3 = Fluxa.Theme.SubText,
						Position = UDim2.new(0, 3, 0.5, -8),
						Size = UDim2.new(0, 16, 0, 16),
					}
				),
				"SubText"
			)
			AddCorner(Knob, 16)
			local function Update()
				Fluxa.Flags[text] = Toggled
				if Toggled then
					Tween(Switch, { BackgroundColor3 = Fluxa.Theme.Accent })
					Tween(Switch.UIStroke, { Color = Fluxa.Theme.Accent })
					Tween(Knob, { Position = UDim2.new(1, -19, 0.5, -8), BackgroundColor3 = Color3.new(1, 1, 1) })
				else
					Tween(Switch, { BackgroundColor3 = Fluxa.Theme.Sidebar })
					Tween(Switch.UIStroke, { Color = Fluxa.Theme.Outline })
					Tween(Knob, { Position = UDim2.new(0, 3, 0.5, -8), BackgroundColor3 = Fluxa.Theme.SubText })
				end
				if callback then
					callback(Toggled)
				end
			end
			if default then
				Update()
			end
			ToggleBtn.MouseButton1Click:Connect(function()
				Toggled = not Toggled
				Update()
			end)
		end

		function SectionFuncs:ExpandableToggle(text, default, callback)
			local Toggled = default or false
			Fluxa.Flags[text] = Toggled

			-- [핵심 1] 토글 버튼과 하위 요소를 하나로 묶는 최상위 컨테이너
			local Container = Create("Frame", {
				Parent = page,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
			})
			Create(
				"UIListLayout",
				{ Parent = Container, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8) }
			)

			-- 1. 토글 UI 생성 (Parent를 Container로 설정)
			local ToggleBtn = Register(
				Create(
					"TextButton",
					{
						Parent = Container,
						BackgroundColor3 = Fluxa.Theme.Element,
						Size = UDim2.new(1, 0, 0, 42),
						AutoButtonColor = false,
						Text = "",
					}
				),
				"Element"
			)
			AddCorner(ToggleBtn, Fluxa.Theme.FrameCorner)
			AddStroke(ToggleBtn, Fluxa.Theme.Outline, 1)

			Register(
				Create(
					"TextLabel",
					{
						Parent = ToggleBtn,
						BackgroundTransparency = 1,
						Position = UDim2.new(0, 16, 0, 0),
						Size = UDim2.new(1, -70, 1, 0),
						Font = Enum.Font.GothamMedium,
						Text = text,
						TextColor3 = Fluxa.Theme.Text,
						TextSize = 14,
						TextXAlignment = Enum.TextXAlignment.Left,
					}
				),
				"Text"
			)
			local Switch = Register(
				Create(
					"Frame",
					{
						Parent = ToggleBtn,
						BackgroundColor3 = Fluxa.Theme.Sidebar,
						Position = UDim2.new(1, -54, 0.5, -11),
						Size = UDim2.new(0, 38, 0, 22),
					}
				),
				"Sidebar"
			)
			AddCorner(Switch, 16)
			local SwitchStroke = AddStroke(Switch, Fluxa.Theme.Outline, 1)
			local Knob = Register(
				Create(
					"Frame",
					{
						Parent = Switch,
						BackgroundColor3 = Fluxa.Theme.SubText,
						Position = UDim2.new(0, 3, 0.5, -8),
						Size = UDim2.new(0, 16, 0, 16),
					}
				),
				"SubText"
			)
			AddCorner(Knob, 16)

			-- 2. 트리 구조(Tree) 래퍼 (Parent를 Container로 설정)
			local SubPageWrapper = Create("Frame", {
				Parent = Container,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				Visible = Toggled,
			})

			-- 수직선 (│)
			local TreeLine = Register(
				Create("Frame", {
					Parent = SubPageWrapper,
					BackgroundColor3 = Fluxa.Theme.Outline,
					Size = UDim2.new(0, 1, 1, -21),
					Position = UDim2.new(0, 16, 0, 0),
					BorderSizePixel = 0,
				}),
				"Outline"
			)

			local SubPage = Create("Frame", {
				Parent = SubPageWrapper,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
			})
			Create(
				"UIListLayout",
				{ Parent = SubPage, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8) }
			)
			Create("UIPadding", { Parent = SubPage, PaddingLeft = UDim.new(0, 32) })

			-- [핵심 2] 하위 요소가 추가될 때마다 가로선(├──) 자동 생성
			SubPage.ChildAdded:Connect(function(child)
				if child:IsA("GuiObject") and not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
					Register(
						Create("Frame", {
							Parent = child,
							BackgroundColor3 = Fluxa.Theme.Outline,
							-- Scale 0.5 대신 Offset 21로 고정하여, 컨테이너가 커져도 선이 항상 버튼 중앙에 오도록 고정!
							Size = UDim2.new(0, 16, 0, 1),
							Position = UDim2.new(0, -16, 0, 21),
							BorderSizePixel = 0,
						}),
						"Outline"
					)
				end
			end)

			local function Update()
				Fluxa.Flags[text] = Toggled
				if Toggled then
					Tween(Switch, { BackgroundColor3 = Fluxa.Theme.Accent })
					Tween(Switch.UIStroke, { Color = Fluxa.Theme.Accent })
					Tween(Knob, { Position = UDim2.new(1, -19, 0.5, -8), BackgroundColor3 = Color3.new(1, 1, 1) })
					SubPageWrapper.Visible = true
				else
					Tween(Switch, { BackgroundColor3 = Fluxa.Theme.Sidebar })
					Tween(Switch.UIStroke, { Color = Fluxa.Theme.Outline })
					Tween(Knob, { Position = UDim2.new(0, 3, 0.5, -8), BackgroundColor3 = Fluxa.Theme.SubText })
					SubPageWrapper.Visible = false
				end
				if callback then
					callback(Toggled)
				end
			end
			if default then
				Update()
			end
			ToggleBtn.MouseButton1Click:Connect(function()
				Toggled = not Toggled
				Update()
			end)

			-- 3. 새로운 섹션 반환
			return CreateSection(SubPage)
		end

		function SectionFuncs:Button(text, callback)
			local Btn = Register(
				Create(
					"TextButton",
					{
						Parent = page,
						BackgroundColor3 = Fluxa.Theme.Element,
						Size = UDim2.new(1, 0, 0, 42),
						AutoButtonColor = false,
						Font = Enum.Font.GothamMedium,
						Text = text,
						TextColor3 = Fluxa.Theme.Text,
						TextSize = 14,
					}
				),
				"Element"
			)
			AddCorner(Btn, Fluxa.Theme.BtnCorner)
			AddStroke(Btn, Fluxa.Theme.Outline, 1)
			Btn.MouseEnter:Connect(function()
				Tween(Btn, { BackgroundColor3 = Fluxa.Theme.Hover })
			end)
			Btn.MouseLeave:Connect(function()
				Tween(Btn, { BackgroundColor3 = Fluxa.Theme.Element })
			end)
			Btn.MouseButton1Click:Connect(function()
				Tween(Btn, { TextColor3 = Fluxa.Theme.Accent }, 0.1)
				task.wait(0.1)
				Tween(Btn, { TextColor3 = Fluxa.Theme.Text }, 0.1)
				if callback then
					callback()
				end
			end)
		end
		function SectionFuncs:TextBox(text, callback)
			local Frame = Register(
				Create(
					"Frame",
					{ Parent = page, BackgroundColor3 = Fluxa.Theme.Element, Size = UDim2.new(1, 0, 0, 42) }
				),
				"Element"
			)
			AddCorner(Frame, 4)
			AddStroke(Frame, Fluxa.Theme.Outline, 1)
			Register(
				Create(
					"TextLabel",
					{
						Parent = Frame,
						BackgroundTransparency = 1,
						Position = UDim2.new(0, 14, 0, 0),
						Size = UDim2.new(0.5, 0, 1, 0),
						Text = text,
						Font = Enum.Font.GothamMedium,
						TextSize = 14,
						TextXAlignment = Enum.TextXAlignment.Left,
						TextColor3 = Fluxa.Theme.Text,
					}
				),
				"Text"
			)
			local Box = Register(
				Create(
					"TextBox",
					{
						Parent = Frame,
						BackgroundTransparency = 1,
						Position = UDim2.new(0.5, 0, 0, 0),
						Size = UDim2.new(0.5, -14, 1, 0),
						Text = "",
						Font = Enum.Font.Gotham,
						TextSize = 13,
						TextXAlignment = Enum.TextXAlignment.Right,
						TextColor3 = Fluxa.Theme.Accent,
						PlaceholderText = "...",
					}
				),
				"Accent"
			)
			Box.FocusLost:Connect(function()
				if callback then
					callback(Box.Text)
				end
			end)
		end
		function SectionFuncs:Dropdown(text, items, callback)
			local Open = false
			local DropFrame = Register(
				Create(
					"Frame",
					{
						Parent = page,
						BackgroundColor3 = Fluxa.Theme.Element,
						Size = UDim2.new(1, 0, 0, 42),
						ClipsDescendants = true,
					}
				),
				"Element"
			)
			AddCorner(DropFrame, Fluxa.Theme.FrameCorner)
			AddStroke(DropFrame, Fluxa.Theme.Outline, 1)
			local Title = Register(
				Create(
					"TextLabel",
					{
						Parent = DropFrame,
						BackgroundTransparency = 1,
						Position = UDim2.new(0, 16, 0, 0),
						Size = UDim2.new(1, -65, 0, 42),
						Font = Enum.Font.GothamMedium,
						Text = text,
						TextColor3 = Fluxa.Theme.Text,
						TextSize = 14,
						TextXAlignment = Enum.TextXAlignment.Left,
					}
				),
				"Text"
			)
			local Trigger = Create(
				"TextButton",
				{ Parent = DropFrame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 42), Text = "" }
			)
			local List = Create(
				"Frame",
				{
					Parent = DropFrame,
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 0, 0, 46),
					Size = UDim2.new(1, 0, 0, 0),
				}
			)
			local ListLayout = Create(
				"UIListLayout",
				{ Parent = List, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4) }
			)
			Create("UIPadding", { Parent = List, PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) })
			local function Refresh()
				for _, v in pairs(List:GetChildren()) do
					if v:IsA("TextButton") then
						v:Destroy()
					end
				end
				for _, item in pairs(items) do
					local ItemBtn = Register(
						Create(
							"TextButton",
							{
								Parent = List,
								BackgroundColor3 = Fluxa.Theme.Sidebar,
								Size = UDim2.new(1, 0, 0, 34),
								AutoButtonColor = false,
								Font = Enum.Font.Gotham,
								Text = item,
								TextColor3 = Fluxa.Theme.SubText,
								TextSize = 13,
							}
						),
						"Sidebar"
					)
					AddCorner(ItemBtn, 6)
					ItemBtn.MouseButton1Click:Connect(function()
						Title.Text = text .. ": " .. item
						Register(Title, "Accent")
						Title.TextColor3 = Fluxa.Theme.Accent
						if callback then
							callback(item)
						end
						Open = false
						Tween(DropFrame, { Size = UDim2.new(1, 0, 0, 42) })
					end)
				end
			end
			Refresh()
			Trigger.MouseButton1Click:Connect(function()
				Open = not Open
				if Open then
					Tween(DropFrame, { Size = UDim2.new(1, 0, 0, ListLayout.AbsoluteContentSize.Y + 52) })
				else
					Tween(DropFrame, { Size = UDim2.new(1, 0, 0, 42) })
				end
			end)
			function SectionFuncs:RefreshDropdown(newItems)
				items = newItems
				Refresh()
			end
		end
		function SectionFuncs:MultiDropdown(text, items, default, callback)
			local Open = false
			local Selected = default or {}
			local DropFrame = Register(
				Create(
					"Frame",
					{
						Parent = page,
						BackgroundColor3 = Fluxa.Theme.Element,
						Size = UDim2.new(1, 0, 0, 42),
						ClipsDescendants = true,
					}
				),
				"Element"
			)
			AddCorner(DropFrame, Fluxa.Theme.FrameCorner)
			AddStroke(DropFrame, Fluxa.Theme.Outline, 1)
			local Title = Register(
				Create(
					"TextLabel",
					{
						Parent = DropFrame,
						BackgroundTransparency = 1,
						Position = UDim2.new(0, 16, 0, 0),
						Size = UDim2.new(1, -40, 0, 42),
						Font = Enum.Font.GothamMedium,
						Text = text,
						TextColor3 = Fluxa.Theme.Text,
						TextSize = 14,
						TextXAlignment = Enum.TextXAlignment.Left,
					}
				),
				"Text"
			)
			local Trigger = Create(
				"TextButton",
				{ Parent = DropFrame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 42), Text = "" }
			)
			local List = Create(
				"Frame",
				{
					Parent = DropFrame,
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 0, 0, 46),
					Size = UDim2.new(1, 0, 0, 0),
				}
			)
			local ListLayout = Create(
				"UIListLayout",
				{ Parent = List, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4) }
			)
			Create("UIPadding", { Parent = List, PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) })
			local function UpdateText()
				local t = {}
				for k, v in pairs(Selected) do
					if v then
						table.insert(t, k)
					end
				end
				if #t == 0 then
					Title.Text = text
					Title.TextColor3 = Fluxa.Theme.Text
				else
					Title.Text = text .. ": " .. table.concat(t, ", ")
					Title.TextColor3 = Fluxa.Theme.Accent
				end
			end
			UpdateText()
			local function Refresh()
				for _, v in pairs(List:GetChildren()) do
					if v:IsA("TextButton") then
						v:Destroy()
					end
				end
				for _, item in pairs(items) do
					local ItemBtn = Register(
						Create(
							"TextButton",
							{
								Parent = List,
								BackgroundColor3 = Fluxa.Theme.Sidebar,
								Size = UDim2.new(1, 0, 0, 34),
								AutoButtonColor = false,
								Font = Enum.Font.Gotham,
								Text = item,
								TextColor3 = Selected[item] and Fluxa.Theme.Accent or Fluxa.Theme.SubText,
								TextSize = 13,
							}
						),
						"Sidebar"
					)
					AddCorner(ItemBtn, 6)
					ItemBtn.MouseButton1Click:Connect(function()
						Selected[item] = not Selected[item]
						ItemBtn.TextColor3 = Selected[item] and Fluxa.Theme.Accent or Fluxa.Theme.SubText
						UpdateText()
						if callback then
							callback(Selected)
						end
					end)
				end
			end
			Refresh()
			Trigger.MouseButton1Click:Connect(function()
				Open = not Open
				if Open then
					Tween(DropFrame, { Size = UDim2.new(1, 0, 0, ListLayout.AbsoluteContentSize.Y + 52) })
				else
					Tween(DropFrame, { Size = UDim2.new(1, 0, 0, 42) })
				end
			end)
		end
		function SectionFuncs:Slider(text, min, max, default, callback)
			Fluxa.Flags[text] = default or min
			local Value = default or min
			local SliderFrame = Register(
				Create(
					"Frame",
					{ Parent = page, BackgroundColor3 = Fluxa.Theme.Element, Size = UDim2.new(1, 0, 0, 56) }
				),
				"Element"
			)
			AddCorner(SliderFrame, Fluxa.Theme.FrameCorner)
			AddStroke(SliderFrame, Fluxa.Theme.Outline, 1)
			Register(
				Create(
					"TextLabel",
					{
						Parent = SliderFrame,
						BackgroundTransparency = 1,
						Position = UDim2.new(0, 16, 0, 10),
						Size = UDim2.new(1, -30, 0, 20),
						Font = Enum.Font.GothamMedium,
						Text = text,
						TextColor3 = Fluxa.Theme.Text,
						TextSize = 14,
						TextXAlignment = Enum.TextXAlignment.Left,
					}
				),
				"Text"
			)
			local ValueLabel = Register(
				Create(
					"TextLabel",
					{
						Parent = SliderFrame,
						BackgroundTransparency = 1,
						Position = UDim2.new(1, -50, 0, 10),
						Size = UDim2.new(0, 38, 0, 20),
						Font = Enum.Font.Gotham,
						Text = tostring(Value),
						TextColor3 = Fluxa.Theme.Accent,
						TextSize = 14,
						TextXAlignment = Enum.TextXAlignment.Right,
					}
				),
				"Accent"
			)
			local Track = Register(
				Create(
					"Frame",
					{
						Parent = SliderFrame,
						BackgroundColor3 = Fluxa.Theme.Sidebar,
						Position = UDim2.new(0, 16, 0, 38),
						Size = UDim2.new(1, -32, 0, 6),
					}
				),
				"Sidebar"
			)
			AddCorner(Track, 8)
			local Fill = Register(
				Create(
					"Frame",
					{
						Parent = Track,
						BackgroundColor3 = Fluxa.Theme.Accent,
						Size = UDim2.new((Value - min) / (max - min), 0, 1, 0),
					}
				),
				"Accent"
			)
			AddCorner(Fill, 8)
			local Trigger = Create(
				"TextButton",
				{
					Parent = SliderFrame,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 1, 0),
					Text = "",
					ZIndex = 10,
				}
			)
			local function Update(input)
				local SizeX = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
				local NewVal = math.floor(min + ((max - min) * SizeX))
				Value = NewVal
				Fluxa.Flags[text] = Value
				ValueLabel.Text = tostring(Value)
				Tween(Fill, { Size = UDim2.new(SizeX, 0, 1, 0) }, 0.05)
				if callback then
					callback(Value)
				end
			end
			Trigger.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					Update(input)
					local m, r
					m = UserInputService.InputChanged:Connect(function(i)
						if i.UserInputType == Enum.UserInputType.MouseMovement then
							Update(i)
						end
					end)
					r = UserInputService.InputEnded:Connect(function(i)
						if i.UserInputType == Enum.UserInputType.MouseButton1 then
							m:Disconnect()
							r:Disconnect()
						end
					end)
				end
			end)
		end
		function SectionFuncs:ColorPicker(text, default, callback)
			local Color = default or Color3.fromRGB(255, 255, 255)
			local h, s, v = Color:ToHSV()
			local Open = false
			local PickerFrame = Register(
				Create(
					"Frame",
					{
						Parent = page,
						BackgroundColor3 = Fluxa.Theme.Element,
						Size = UDim2.new(1, 0, 0, 42),
						ClipsDescendants = true,
					}
				),
				"Element"
			)
			AddCorner(PickerFrame, Fluxa.Theme.FrameCorner)
			AddStroke(PickerFrame, Fluxa.Theme.Outline, 1)
			Register(
				Create(
					"TextLabel",
					{
						Parent = PickerFrame,
						BackgroundTransparency = 1,
						Position = UDim2.new(0, 16, 0, 0),
						Size = UDim2.new(1, -60, 0, 42),
						Font = Enum.Font.GothamMedium,
						Text = text,
						TextColor3 = Fluxa.Theme.Text,
						TextSize = 14,
						TextXAlignment = Enum.TextXAlignment.Left,
					}
				),
				"Text"
			)
			local Preview = Create(
				"Frame",
				{
					Parent = PickerFrame,
					BackgroundColor3 = Color,
					Position = UDim2.new(1, -45, 0.5, -10),
					Size = UDim2.new(0, 30, 0, 20),
				}
			)
			AddCorner(Preview, 6)
			AddStroke(Preview, Fluxa.Theme.Outline, 1)
			local Trigger = Create(
				"TextButton",
				{ Parent = PickerFrame, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 42), Text = "" }
			)
			local Palette = Create(
				"Frame",
				{
					Parent = PickerFrame,
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 0, 0, 48),
					Size = UDim2.new(1, 0, 0, 130),
				}
			)
			local SVBox = Create(
				"Frame",
				{
					Parent = Palette,
					Position = UDim2.new(0, 16, 0, 0),
					Size = UDim2.new(1, -32, 0, 100),
					BackgroundColor3 = Color3.fromHSV(h, 1, 1),
					ZIndex = 1,
				}
			)
			AddCorner(SVBox, 4)
			local SatLayer = Create(
				"Frame",
				{
					Parent = SVBox,
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundColor3 = Color3.new(1, 1, 1),
					BackgroundTransparency = 0,
					ZIndex = 2,
				}
			)
			AddCorner(SatLayer, 4)
			Create(
				"UIGradient",
				{
					Parent = SatLayer,
					Color = ColorSequence.new(Color3.new(1, 1, 1)),
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0),
						NumberSequenceKeypoint.new(1, 1),
					}),
				}
			)
			local ValLayer = Create(
				"Frame",
				{
					Parent = SVBox,
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundColor3 = Color3.new(0, 0, 0),
					BackgroundTransparency = 0,
					ZIndex = 3,
				}
			)
			AddCorner(ValLayer, 4)
			Create(
				"UIGradient",
				{
					Parent = ValLayer,
					Rotation = 90,
					Color = ColorSequence.new(Color3.new(0, 0, 0)),
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 1),
						NumberSequenceKeypoint.new(1, 0),
					}),
				}
			)
			local PickerDot = Create(
				"Frame",
				{
					Parent = SVBox,
					Size = UDim2.new(0, 4, 0, 4),
					Position = UDim2.new(s, -2, 1 - v, -2),
					BackgroundColor3 = Color3.new(1, 1, 1),
					ZIndex = 10,
				}
			)
			AddCorner(PickerDot, 4)
			AddStroke(PickerDot, Color3.new(0, 0, 0), 1)
			local HueBar = Create(
				"Frame",
				{
					Parent = Palette,
					Position = UDim2.new(0, 16, 0, 110),
					Size = UDim2.new(1, -32, 0, 10),
					BackgroundColor3 = Color3.new(1, 1, 1),
				}
			)
			AddCorner(HueBar, 4)
			Create(
				"UIGradient",
				{
					Parent = HueBar,
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.new(1, 0, 0)),
						ColorSequenceKeypoint.new(0.167, Color3.new(1, 1, 0)),
						ColorSequenceKeypoint.new(0.333, Color3.new(0, 1, 0)),
						ColorSequenceKeypoint.new(0.5, Color3.new(0, 1, 1)),
						ColorSequenceKeypoint.new(0.667, Color3.new(0, 0, 1)),
						ColorSequenceKeypoint.new(0.833, Color3.new(1, 0, 1)),
						ColorSequenceKeypoint.new(1, Color3.new(1, 0, 0)),
					}),
				}
			)
			local HueDot = Create(
				"Frame",
				{
					Parent = HueBar,
					Size = UDim2.new(0, 4, 1, 0),
					Position = UDim2.new(h, -2, 0, 0),
					BackgroundColor3 = Color3.new(1, 1, 1),
				}
			)
			AddCorner(HueDot, 2)
			AddStroke(HueDot, Color3.new(0, 0, 0), 1)
			local function UpdateColor()
				local newColor = Color3.fromHSV(h, s, v)
				Preview.BackgroundColor3 = newColor
				SVBox.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
				PickerDot.Position = UDim2.new(s, -2, 1 - v, -2)
				HueDot.Position = UDim2.new(h, -2, 0, 0)
				if callback then
					callback(newColor)
				end
			end
			local function UpdateHue()
				local m = UserInputService:GetMouseLocation()
				local rx = math.clamp(m.X - HueBar.AbsolutePosition.X, 0, HueBar.AbsoluteSize.X)
				h = rx / HueBar.AbsoluteSize.X
				UpdateColor()
			end
			local function UpdateSV()
				local m = UserInputService:GetMouseLocation()
				local rx = math.clamp(m.X - SVBox.AbsolutePosition.X, 0, SVBox.AbsoluteSize.X)
				local ry = math.clamp(m.Y - SVBox.AbsolutePosition.Y - 36, 0, SVBox.AbsoluteSize.Y)
				s = rx / SVBox.AbsoluteSize.X
				v = 1 - (ry / SVBox.AbsoluteSize.Y)
				UpdateColor()
			end
			HueBar.InputBegan:Connect(function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1 then
					local dragging = true
					UpdateHue()
					local c
					c = RunService.RenderStepped:Connect(function()
						if not dragging then
							c:Disconnect()
							return
						end
						UpdateHue()
						if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
							dragging = false
							c:Disconnect()
						end
					end)
				end
			end)
			ValLayer.InputBegan:Connect(function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1 then
					local dragging = true
					UpdateSV()
					local c
					c = RunService.RenderStepped:Connect(function()
						if not dragging then
							c:Disconnect()
							return
						end
						UpdateSV()
						if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
							dragging = false
							c:Disconnect()
						end
					end)
				end
			end)
			Trigger.MouseButton1Click:Connect(function()
				Open = not Open
				if Open then
					Tween(PickerFrame, { Size = UDim2.new(1, 0, 0, 180) })
				else
					Tween(PickerFrame, { Size = UDim2.new(1, 0, 0, 42) })
				end
			end)
			return SectionFuncs
		end
		return SectionFuncs
	end

	function WindowFuncs:Tab(name)
		local Btn, Text, Ind, Page = CreateTabBtn(name, TabContainer, 0)
		local TabObj = { Btn = Btn, Text = Text, Indicator = Ind, Page = Page }
		table.insert(Tabs, TabObj)

		Btn.MouseButton1Click:Connect(function()
			ActivateTab(TabObj)
		end)
		if #Tabs == 1 then
			ActivateTab(TabObj)
		end

		local TabFuncs = {}
		function TabFuncs:Section(text)
			-- 섹션 제목(Header) 생성 로직
			if text then
				if #Page:GetChildren() > 2 then
					Create("Frame", { Parent = Page, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 8) })
				end
				local Label = Register(
					Create(
						"TextLabel",
						{
							Parent = Page,
							BackgroundTransparency = 1,
							Size = UDim2.new(1, 0, 0, 28),
							Font = Enum.Font.GothamBold,
							Text = string.upper(text),
							TextColor3 = Fluxa.Theme.Accent,
							TextSize = 12,
							TextXAlignment = Enum.TextXAlignment.Left,
						}
					),
					"Accent"
				)
				Create("UIPadding", { Parent = Label, PaddingLeft = UDim.new(0, 4) })
			end
			return CreateSection(Page)
		end
		return TabFuncs
	end

	--// 5. SETTINGS TAB (Auto Added)
	local SettingsBtn, SettingsText, SettingsInd, SettingsPage = CreateTabBtn("Settings", TabContainer, 9999)
	local SettingsTabObj = { Btn = SettingsBtn, Text = SettingsText, Indicator = SettingsInd, Page = SettingsPage }
	SettingsBtn.MouseButton1Click:Connect(function()
		ActivateTab(SettingsTabObj)
	end)

	-- [[ SETTINGS TAB 정리된 그룹 구조 ]]

	-- ─── GROUP 1: Config Manager ───────────────────
	local ConfigSec = CreateSection(SettingsPage, "Config Manager")

	local CfgName = "default"
	ConfigSec:TextBox("Config Name", function(t)
		CfgName = t ~= "" and t or "default"
	end)

	local function GetConfigs()
		if not listfiles then return {} end
		local names = {}
		for _, file in pairs(listfiles(Fluxa.ConfigFolder)) do
			local name = file:match("([^/]+)%.json$")
			if name then table.insert(names, name) end
		end
		return names
	end

	ConfigSec:Dropdown("Load Config", GetConfigs(), function(val)
		CfgName = val
		if readfile and isfile(Fluxa.ConfigFolder .. "/" .. val .. ".json") then
			Fluxa.Flags = HttpService:JSONDecode(readfile(Fluxa.ConfigFolder .. "/" .. val .. ".json"))
		end
	end)

	ConfigSec:Button("Refresh List", function()
		ConfigSec:RefreshDropdown(GetConfigs())
	end)

	ConfigSec:Button("Save Config", function()
		if writefile then
			writefile(Fluxa.ConfigFolder .. "/" .. CfgName .. ".json", HttpService:JSONEncode(Fluxa.Flags))
		end
	end)

	-- ─── GROUP 2: Theme Editor ─────────────────────
	local ThemeSec = CreateSection(SettingsPage, "Theme Editor")

	local ThemeName = "default"
	ThemeSec:TextBox("Theme Name", function(t)
		ThemeName = t ~= "" and t or "default"
	end)

	local function GetThemes()
		if not listfiles then return {} end
		local names = {}
		for _, file in pairs(listfiles(Fluxa.ThemeFolder)) do
			local name = file:match("([^/]+)%.json$")
			if name then table.insert(names, name) end
		end
		return names
	end

	ThemeSec:Dropdown("Load Theme", GetThemes(), function(val)
		ThemeName = val
		if readfile and isfile(Fluxa.ThemeFolder .. "/" .. val .. ".json") then
			local t = HttpService:JSONDecode(readfile(Fluxa.ThemeFolder .. "/" .. val .. ".json"))
			for k, v in pairs(t) do Fluxa.Theme[k] = v end
			Fluxa:UpdateTheme()
		end
	end)

	ThemeSec:Button("Refresh List", function()
		ThemeSec:RefreshDropdown(GetThemes())
	end)

	ThemeSec:Button("Save Theme", function()
		if writefile then
			writefile(Fluxa.ThemeFolder .. "/" .. ThemeName .. ".json", HttpService:JSONEncode(Fluxa.Theme))
		end
	end)

	-- ─── GROUP 3: Color Customizer ─────────────────
	local ColorSec = CreateSection(SettingsPage, "Color Customizer")

	local colorKeys = { "Accent", "Background", "Sidebar", "Element", "Text", "SubText", "Outline" }
	for _, key in pairs(colorKeys) do
		ColorSec:ColorPicker(key, Fluxa.Theme[key], function(color)
			Fluxa.Theme[key] = color
			Fluxa:UpdateTheme()
		end)
	end

	-- [핵심] 이 부분은 절대 지우지 마세요!
	return WindowFuncs
end

--// 5. Notification System (Toast)
--[[
    Fluxa:Notify({
        Title    = "Hello",          -- 알림 제목 (필수)
        Content  = "This is a msg.", -- 알림 내용 (선택)
        Duration = 4,                -- 표시 시간(초), 기본값 4
        Type     = "info",           -- "info" | "success" | "warning" | "error"
    })
]]

do
	local NotifyContainer = Create("Frame", {
		Parent = ScreenGui,
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -20, 1, -20),
		Size = UDim2.new(0, 320, 1, 0),
		AnchorPoint = Vector2.new(1, 1),
		ZIndex = 100,
	})
	Create("UIListLayout", {
		Parent = NotifyContainer,
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		Padding = UDim.new(0, 10),
	})

	local notifyCount = 0

	local TypeColors = {
		info    = Color3.fromRGB(100, 130, 240), -- Accent blue
		success = Color3.fromRGB(85,  210, 130),
		warning = Color3.fromRGB(250, 200, 80),
		error   = Color3.fromRGB(245, 80,  80),
	}

	local TypeIcons = {
		info    = "i", -- 폰트 기반 디자인을 위해 알파벳 사용
		success = "✓",
		warning = "!",
		error   = "✕",
	}

	function Fluxa:Notify(options)
		options = options or {}
		local title    = options.Title    or "Notification"
		local content  = options.Content  or ""
		local duration = options.Duration or 4
		local ntype    = options.Type     or "info"

		local accentColor = TypeColors[ntype] or TypeColors.info
		local iconChar    = TypeIcons[ntype]  or TypeIcons.info

		notifyCount = notifyCount + 1
		local thisOrder = notifyCount

		-- 동적으로 높이 계산
		local titleHeight = 16
		local contentHeight = (content ~= "") and 16 or 0
		local gap = (content ~= "") and 4 or 0
		local paddingTop = 14
		local paddingBottom = 16
		local cardH = paddingTop + titleHeight + contentHeight + gap + paddingBottom

		-- Outer wrapper (리스트 레이아웃용 및 사라질 때 애니메이션 유지)
		local Wrapper = Create("Frame", {
			Parent = NotifyContainer,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, cardH),
			ClipsDescendants = false,
			LayoutOrder = thisOrder,
		})

		-- 그림자 대신 가벼운 하이라이트를 주는 카드 본체
		local Card = Create("Frame", {
			Parent = Wrapper,
			BackgroundColor3 = Fluxa.Theme.Element, -- 기존 다크 배경 유지
			Size = UDim2.new(1, 0, 0, cardH),
			Position = UDim2.new(1, 40, 0, 0), -- 시작: 조금 더 오른쪽 바깥
			ClipsDescendants = true, -- 게이지바나 내부 요소가 모서리를 넘지 않도록
			ZIndex = 100,
		})
		AddCorner(Card, 8) -- 조금 더 둥글고 부드러운 코너
		
		-- 내부 빛반사 효과 (가짜 글래스모피즘 강조)
		Create("UIStroke", {
			Parent = Card,
			Color = Color3.fromRGB(255, 255, 255),
			Transparency = 0.92,
			Thickness = 1,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		})

		-- 왼쪽 컬러 바 (얇은 필 형태 + UIStroke 글로우)
		local GlowBar = Create("Frame", {
			Parent = Card,
			BackgroundColor3 = accentColor,
			Size = UDim2.new(0, 2, 1, -20), -- 얇게(2px), 위아래 마진
			Position = UDim2.new(0, 8, 0, 10),
			ZIndex = 101,
			BorderSizePixel = 0,
		})
		AddCorner(GlowBar, 4)
		-- UIStroke를 이용한 빛 번짐 효과
		Create("UIStroke", {
			Parent = GlowBar,
			Color = accentColor,
			Transparency = 0.5,
			Thickness = 2,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		})

		-- 아이콘 배경 (원형)
		local IconBG = Create("Frame", {
			Parent = Card,
			BackgroundColor3 = accentColor,
			BackgroundTransparency = 0.85, -- 은은한 글로우 느낌
			Position = UDim2.new(0, 14, 0.5, -16),
			Size = UDim2.new(0, 32, 0, 32),
			ZIndex = 101,
		})
		AddCorner(IconBG, 16) -- 원형
		
		-- 아이콘 텍스트
		Create("TextLabel", {
			Parent = IconBG,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			Font = Enum.Font.GothamBlack,
			Text = iconChar,
			TextColor3 = accentColor,
			TextSize = 15,
			TextXAlignment = Enum.TextXAlignment.Center,
			ZIndex = 102,
		})

		-- 텍스트 컨테이너
		local TextContainer = Create("Frame", {
			Parent = Card,
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 60, 0, paddingTop),
			Size = UDim2.new(1, -74, 1, -(paddingTop + paddingBottom)),
			ZIndex = 101,
		})
		Create("UIListLayout", {
			Parent = TextContainer,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, gap),
		})

		-- 제목
		Create("TextLabel", {
			Parent = TextContainer,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, titleHeight),
			Font = Enum.Font.GothamBold,
			Text = title,
			TextColor3 = Color3.fromRGB(245, 245, 250), -- Theme.Text 보다 살짝 더 밝고 선명하게
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 101,
			LayoutOrder = 1,
		})

		-- 내용 (있을 때만)
		if content ~= "" then
			Create("TextLabel", {
				Parent = TextContainer,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, contentHeight),
				Font = Enum.Font.GothamMedium,
				Text = content,
				TextColor3 = Fluxa.Theme.SubText,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
				ZIndex = 101,
				LayoutOrder = 2,
			})
		end

		-- 진행 바 래퍼 (카드 모서리와 동일한 ClipsDescendants 적용)
		-- ProgressBG를 카드 내부 좌표로 배치해야 ClipsDescendants가 정상 동작함
		local ProgressBG = Create("Frame", {
			Parent = Card,
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
			BackgroundTransparency = 0.75,
			Position = UDim2.new(0, 0, 1, -3), -- 카드 내부 기준. 하단 3px 위
			Size = UDim2.new(1, 0, 0, 3),     -- 두께 3px
			ZIndex = 102,
			ClipsDescendants = true,          -- Progress 바가 여기서 잘림
			BorderSizePixel = 0,
		})
		-- 카드와 동일한 radius로 모서리 처리 → Card의 ClipsDescendants가 이걸 카드 곡률로 자름
		AddCorner(ProgressBG, 8)
		
		-- 실제 진행 바
		local Progress = Create("Frame", {
			Parent = ProgressBG,
			BackgroundColor3 = accentColor,
			Size = UDim2.new(1, 0, 1, 0),
			Position = UDim2.new(0, 0, 0, 0),
			ZIndex = 103,
			BorderSizePixel = 0,
		})
		AddCorner(Progress, 8)
		
		-- 진행 바 그라데이션 (왼쪽 밝게 -> 오른쪽 살짝 투명하게)
		local UIGrad = Instance.new("UIGradient")
		UIGrad.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
			ColorSequenceKeypoint.new(1, accentColor)
		})
		UIGrad.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.4),
			NumberSequenceKeypoint.new(0.5, 0),
			NumberSequenceKeypoint.new(1, 0)
		})
		UIGrad.Parent = Progress

		-- [애니메이션 설정]
		-- 등장: 살짝 튕기는 Back Easing + 위치 이동
		TweenService:Create(
			Card,
			TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{ Position = UDim2.new(0, 0, 0, 0) }
		):Play()

		-- 진행 바 감소 (우측에서 좌측으로)
		TweenService:Create(
			Progress,
			TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
			{ Size = UDim2.new(0, 0, 1, 0) }
		):Play()

		-- duration 후 사라지기 애니메이션
		task.delay(duration, function()
			-- 카드가 오른쪽으로 약간 가속하며 빠짐 (Back.In)
			TweenService:Create(
				Card,
				TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In),
				{ Position = UDim2.new(1, 60, 0, 0) }
			):Play()
			
			task.wait(0.35)
			-- Wrapper 높이를 줄여 다른 알림이 부드럽게 올라가게 양보
			TweenService:Create(
				Wrapper,
				TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{ Size = UDim2.new(1, 0, 0, 0) }
			):Play()
			
			task.wait(0.35)
			Wrapper:Destroy()
		end)
	end
end

return Fluxa
