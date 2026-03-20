local Fluxa = loadstring(game:HttpGet("https://raw.githubusercontent.com/bgsn523/Fluxa/refs/heads/main/Library.lua"))()

-- 전역 변수 설정 (Fluxa 버그 우회용)
getgenv().TitleText = "Fluxa Premium Hub v1.0"
getgenv().IsFlat = true
getgenv().titleText = "Settings"

local Window = Fluxa:Window({
    Name = "Fluxa Premium Hub v1.0",
    Flat = true
})

-- ==========================================
-- 1. COMBAT TAB
-- ==========================================
local CombatTab = Window:Tab("이것은 tab1이에요!")

-- [ Aimbot Section ]
local AimbotSection = CombatTab:Section("이것은 section1이에요!")

AimbotSection:Toggle("이것은 토글이에요!", false, function(state) print("Aimbot:", state) end)
AimbotSection:Dropdown("이것은 드롭다운이에요!", {"Head", "Torso", "Random"}, function(v) print("Target:", v) end)

AimbotSection:Keybind("이것은 키바인드에요!", Enum.KeyCode.F, function(key) print("Key pressed:", key.Name) end) 

-- [ 중첩된 1단계 Expandable Toggle ]
local AdvancedAimbot = AimbotSection:ExpandableToggle("이것은 확장토글이에요!", false, function(state) end)
AdvancedAimbot:Toggle("이것은 토글이에요!", true, function(state) print("Prediction:", state) end)
AdvancedAimbot:Slider("이것은 슬라이더에요!", 1, 10, 5, function(v) print("Power:", v) end)

-- [ 중첩된 2단계 Expandable Toggle ]
local SmoothnessOptions = AdvancedAimbot:ExpandableToggle("이것은 확장토글이에요!", true, function(state) end)
SmoothnessOptions:Toggle("이것은 토글이에요!", true, function(state) end)
SmoothnessOptions:Slider("이것은 슬라이더에요!", 1, 100, 50, function(v) end)

-- [ 중첩된 3단계 Expandable Toggle ]
local AdvancedSmoothness = SmoothnessOptions:ExpandableToggle("이것은 확장토글이에요!", false, function(state) end)
AdvancedSmoothness:Dropdown("이것은 드롭다운이에요!", {"Linear", "Exponential", "Bezier"}, function(v) end)
AdvancedSmoothness:Toggle("이것은 토글이에요!", true, function(state) end)

-- [ 중첩된 4단계 Expandable Toggle ]
local ExtremeSmoothness = AdvancedSmoothness:ExpandableToggle("이것은 확장토글이에요!", false, function(state) end)
ExtremeSmoothness:Slider("이것은 슬라이더에요!", 0, 1000, 100, function(v) end)
ExtremeSmoothness:TextBox("이것은 텍스트박스에요!", function(t) end)
ExtremeSmoothness:Button("이것은 버튼이에요!", function() print("Sync Applied") end)

-- [ 기타 Combat 기능 ]
local WeaponSection = CombatTab:Section("이것은 section2이에요!")
WeaponSection:Toggle("이것은 토글이에요!", true, function(state) end)
WeaponSection:Toggle("이것은 토글이에요!", true, function(state) end)
WeaponSection:Toggle("이것은 토글이에요!", false, function(state) end)

local AmmunitionOptions = WeaponSection:ExpandableToggle("이것은 확장토글이에요!", false, function(state) end)
AmmunitionOptions:Toggle("이것은 토글이에요!", true, function(state) end)
AmmunitionOptions:Toggle("이것은 토글이에요!", true, function(state) end)
AmmunitionOptions:Slider("이것은 슬라이더에요!", 1, 10, 2, function(v) end)

-- ==========================================
-- 2. VISUALS TAB
-- ==========================================
local VisualsTab = Window:Tab("이것은 tab2이에요!")

local PlayerESP = VisualsTab:Section("이것은 section1이에요!")
PlayerESP:Toggle("이것은 토글이에요!", true, function(state) end)
PlayerESP:MultiDropdown("이것은 멀티드롭다운이에요!", {"Box", "Name", "Distance", "Health Bar", "Weapon", "Tracer"}, {Box = true, Name = true}, function(v) end)

local ESPColors = PlayerESP:ExpandableToggle("이것은 확장토글이에요!", false, function(state) end)
ESPColors:ColorPicker("이것은 컬러피커에요!", Color3.fromRGB(0, 255, 0), function(c) end)
ESPColors:ColorPicker("이것은 컬러피커에요!", Color3.fromRGB(255, 0, 0), function(c) end)
ESPColors:ColorPicker("이것은 컬러피커에요!", Color3.fromRGB(255, 255, 0), function(c) end)

-- [ 중첩된 1단계: Box Settings ]
local BoxSettings = ESPColors:ExpandableToggle("이것은 확장토글이에요!", true, function(state) end)
BoxSettings:Dropdown("이것은 드롭다운이에요!", {"2D", "2D Corner", "3D Box"}, function(v) end)
BoxSettings:Slider("이것은 슬라이더에요!", 1, 5, 1, function(v) end)

-- [ 중첩된 2단계: 3D Box Settings ]
local ThreeDBoxSettings = BoxSettings:ExpandableToggle("이것은 확장토글이에요!", false, function(state) end)
ThreeDBoxSettings:Toggle("이것은 토글이에요!", true, function(v) end)
ThreeDBoxSettings:ColorPicker("이것은 컬러피커에요!", Color3.fromRGB(255, 0, 0), function(c) end)
ThreeDBoxSettings:Slider("이것은 슬라이더에요!", 0, 100, 50, function(v) end)

local WorldESP = VisualsTab:Section("이것은 section2이에요!")
WorldESP:Toggle("이것은 토글이에요!", false, function(state) end)
WorldESP:Toggle("이것은 토글이에요!", true, function(state) end)
WorldESP:MultiDropdown("이것은 멀티드롭다운이에요!", {"Cars", "Helicopters", "Boats", "Bicycles"}, {Cars = true, Helicopters = true}, function(v) end)

-- ==========================================
-- 3. MOVEMENT TAB
-- ==========================================
local MovementTab = Window:Tab("이것은 tab3이에요!")

local LocalPlayer = MovementTab:Section("이것은 section1이에요!")
LocalPlayer:Slider("이것은 슬라이더에요!", 16, 500, 16, function(v) end)
LocalPlayer:Slider("이것은 슬라이더에요!", 50, 500, 50, function(v) end)
LocalPlayer:Toggle("이것은 토글이에요!", false, function(state) end)
LocalPlayer:Toggle("이것은 토글이에요!", false, function(state) end)

local FlightMods = LocalPlayer:ExpandableToggle("이것은 확장토글이에요!", false, function(state) end)
FlightMods:Toggle("이것은 토글이에요!", false, function(state) end)
FlightMods:Slider("이것은 슬라이더에요!", 10, 500, 50, function(v) end)

local FlightAdvanced = FlightMods:ExpandableToggle("이것은 확장토글이에요!", false, function(state) end)
FlightAdvanced:Toggle("이것은 토글이에요!", false, function(state) end)
FlightAdvanced:Dropdown("이것은 드롭다운이에요!", {"F", "V", "LeftAlt", "Z"}, function(v) end)

local TeleportSection = MovementTab:Section("이것은 section2이에요!")
TeleportSection:Dropdown("이것은 드롭다운이에요!", {"Spawn", "Bank", "Gun Shop", "Safezone"}, function(v) end)
TeleportSection:Button("이것은 버튼이에요!", function() print("Teleporting") end)

local CustomTP = TeleportSection:ExpandableToggle("이것은 확장토글이에요!", false, function(state) end)
CustomTP:TextBox("이것은 텍스트박스에요!", function(t) end)
CustomTP:TextBox("이것은 텍스트박스에요!", function(t) end)
CustomTP:TextBox("이것은 텍스트박스에요!", function(t) end)
CustomTP:Button("이것은 버튼이에요!", function() end)

-- ==========================================
-- 4. UTILITY TAB
-- ==========================================
local UtilityTab = Window:Tab("이것은 tab4이에요!")

local ScriptsSection = UtilityTab:Section("이것은 section1이에요!")
ScriptsSection:Button("이것은 버튼이에요!", function() end)
ScriptsSection:Button("이것은 버튼이에요!", function() end)
ScriptsSection:Button("이것은 버튼이에요!", function() end)

local MiscSection = UtilityTab:Section("이것은 section2이에요!")
MiscSection:Toggle("이것은 토글이에요!", true, function(state) end)
MiscSection:Toggle("이것은 토글이에요!", true, function(state) end)
MiscSection:Toggle("이것은 토글이에요!", false, function(state) end)

local SpammerConfig = MiscSection:ExpandableToggle("이것은 확장토글이에요!", false, function(state) end)
SpammerConfig:TextBox("이것은 텍스트박스에요!", function(t) end)
SpammerConfig:Slider("이것은 슬라이더에요!", 1, 10, 1, function(v) end)

-- 주의: Settings 탭은 Library.lua 내부에서 자동으로 9999번째 레이아웃 오더로 생성됩니다.
