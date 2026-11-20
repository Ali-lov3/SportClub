local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local TextService = game:GetService("TextService")
local StatsService = game:GetService("Stats")
local TeleportService = game:GetService("TeleportService")
local MarketplaceService = game:GetService("MarketplaceService")
local LocalPlayer = Players.LocalPlayer

local Lucide
pcall(function()
	Lucide = loadstring(game:HttpGet("https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/icons.lua"))()
end)

local function ResolveIcon(Icon)
	if type(Icon) == "number" then return "rbxassetid://" .. Icon end
	if type(Icon) == "string" then
		if string.match(Icon, "^rbxassetid://") then return Icon end
		if string.match(Icon, "^%d+$") then return "rbxassetid://" .. Icon end
		local Name = string.lower(Icon)
		if type(Lucide) == "function" then
			local ok, Data = pcall(Lucide, Name)
			if ok and type(Data) == "table" then
				local Id = Data.id or Data.Id or Data[1]
				local Size = Data.imageRectSize or Data.ImageRectSize or Data[2]
				local Offset = Data.imageRectOffset or Data.imageRectPosition or Data.ImageRectOffset or Data[3]
				if Id then return "rbxassetid://" .. tostring(Id), Offset, Size end
			end
		elseif type(Lucide) == "table" then
			for _, Set in { Lucide["48px"], Lucide["256px"], Lucide } do
				if type(Set) == "table" then
					local Data = Set[Name]
					if type(Data) == "table" and Data[1] then
						return "rbxassetid://" .. tostring(Data[1]), Data[3], Data[2]
					end
				end
			end
		end
	end
	return "rbxassetid://0"
end

local function ToVector2(Value)
	if typeof(Value) == "Vector2" then return Value end
	if type(Value) == "table" then return Vector2.new(Value[1] or Value.X or 0, Value[2] or Value.Y or 0) end
	return Vector2.new(0, 0)
end

local function ApplyIcon(Object, Icon)
	if not Icon then return end
	local Image, Offset, Size = ResolveIcon(Icon)
	Object.Image = Image
	if Offset then Object.ImageRectOffset = ToVector2(Offset) end
	if Size then Object.ImageRectSize = ToVector2(Size) end
end

local Theme = {
	Window = Color3.fromRGB(10, 10, 10),
	Sidebar = Color3.fromRGB(14, 14, 14),
	PanelBody = Color3.fromRGB(19, 19, 19),
	PanelHeader = Color3.fromRGB(22, 22, 22),
	Item = Color3.fromRGB(23, 23, 23),
	Stroke = Color3.fromRGB(32, 32, 32),
	Accent = Color3.fromRGB(0, 119, 255),
	AccentLine = Color3.fromRGB(10, 62, 120),
	DropStroke = Color3.fromRGB(27, 27, 27),
	Fill = Color3.fromRGB(0, 74, 161),
	Thumb = Color3.fromRGB(214, 224, 240),
	Text = Color3.fromRGB(236, 236, 236),
	Dim = Color3.fromRGB(94, 94, 94),
	Off = Color3.fromRGB(43, 43, 43),
	Knob = Color3.fromRGB(78, 78, 78),
	Divider = Color3.fromRGB(20, 20, 20),
	ListBody = Color3.fromRGB(23, 23, 23),
	Risky = Color3.fromRGB(240, 196, 52),
	Warning = Color3.fromRGB(235, 64, 52),
	Notice = Color3.fromRGB(15, 15, 15),
}

local function StyleColor(Opts)
	local Style = Opts.Style and string.lower(tostring(Opts.Style))
	if Opts.Risky == true or Style == "risky" then return Theme.Risky end
	if Opts.Warning == true or Style == "warning" then return Theme.Warning end
	return nil
end

local function RichColor(Color)
	return string.format("rgb(%d,%d,%d)", math.floor(Color.R * 255 + 0.5), math.floor(Color.G * 255 + 0.5), math.floor(Color.B * 255 + 0.5))
end

local MouseNames = {
	[Enum.UserInputType.MouseButton2] = "RMB",
	[Enum.UserInputType.MouseButton3] = "MMB",
}

local function KeyText(Key)
	if not Key then return "None" end
	return MouseNames[Key] or Key.Name
end

local CurrentScale = 1
local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local Left = Enum.TextXAlignment.Left
local Right = Enum.TextXAlignment.Right
local Center = Enum.TextXAlignment.Center
local FontMain = Enum.Font.GothamMedium
local FontBold = Enum.Font.GothamBold

local function New(Class, Props, Parent)
	local Obj = Instance.new(Class)
	for Key, Value in pairs(Props) do Obj[Key] = Value end
	if Parent then Obj.Parent = Parent end
	return Obj
end

local Round = {
	Window = 5,
	Sidebar = 5,
	Section = 3,
	Header = 3,
	Dropdown = 2,
	Menu = 2,
	Button = 3,
	Search = 5,
	Folder = 5,
	Pill = 4,
	Footer = 4,
	Thumb = 2,
	Full = "Full",
}

local function Corner(Obj, Radius)
	local Value = Radius == "Full" and UDim.new(1, 0) or UDim.new(0, Radius)
	return New("UICorner", { CornerRadius = Value }, Obj)
end

local function Stroke(Obj, Color, Thickness)
	return New("UIStroke", { Color = Color, Thickness = Thickness or 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, Obj)
end

local function Pad(Obj, L, T, R, B)
	return New("UIPadding", {
		PaddingLeft = UDim.new(0, L),
		PaddingTop = UDim.new(0, T),
		PaddingRight = UDim.new(0, R),
		PaddingBottom = UDim.new(0, B),
	}, Obj)
end

local function List(Obj, Gap)
	return New("UIListLayout", { Padding = UDim.new(0, Gap or 0), SortOrder = Enum.SortOrder.LayoutOrder }, Obj)
end

local function Label(Parent, Text, Size, Color, Font, Align)
	return New("TextLabel", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Text = Text,
		TextSize = Size,
		TextColor3 = Color,
		Font = Font or FontMain,
		TextXAlignment = Align or Left,
		TextYAlignment = Enum.TextYAlignment.Center,
	}, Parent)
end

local function Icon(Parent, Name, Size, Color)
	local Img = New("ImageLabel", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(Size, Size),
		ImageColor3 = Color,
	}, Parent)
	ApplyIcon(Img, Name)
	return Img
end

local function Ease(Obj, Props, Time, Style, Direction)
	local Motion = TweenService:Create(Obj, TweenInfo.new(Time, Style or Enum.EasingStyle.Quint, Direction or Enum.EasingDirection.Out), Props)
	Motion:Play()
	return Motion
end

local function Tween(Obj, Props, Time)
	return Ease(Obj, Props, Time or 0.22, Enum.EasingStyle.Quart)
end

local FadeOrig = setmetatable({}, { __mode = "k" })

local function FadeProps(Obj)
	if Obj:IsA("UIStroke") then return { "Transparency" } end
	if Obj:IsA("TextLabel") or Obj:IsA("TextButton") or Obj:IsA("TextBox") then return { "BackgroundTransparency", "TextTransparency" } end
	if Obj:IsA("ImageLabel") or Obj:IsA("ImageButton") then return { "BackgroundTransparency", "ImageTransparency" } end
	if Obj:IsA("ScrollingFrame") then return { "BackgroundTransparency", "ScrollBarImageTransparency" } end
	if Obj:IsA("Frame") then return { "BackgroundTransparency" } end
	return nil
end

local function FadeSnap(Root)
	local function Take(Obj)
		if FadeOrig[Obj] then return end
		local Names = FadeProps(Obj)
		if not Names then return end
		local Record = {}
		for _, Name in ipairs(Names) do
			Record[Name] = Obj[Name]
		end
		FadeOrig[Obj] = Record
	end
	Take(Root)
	for _, Obj in ipairs(Root:GetDescendants()) do
		Take(Obj)
	end
end

local function Fade(Root, Amount, Time, Style)
	FadeSnap(Root)
	local function Apply(Obj)
		local Record = FadeOrig[Obj]
		if not Record then return end
		local Goal = {}
		for Name, Value in pairs(Record) do
			Goal[Name] = Value + (1 - Value) * Amount
		end
		Ease(Obj, Goal, math.max(Time or 0, 0.001), Style or Enum.EasingStyle.Quint)
	end
	Apply(Root)
	for _, Obj in ipairs(Root:GetDescendants()) do
		Apply(Obj)
	end
end

local function HoverStroke(Button, StrokeObject, IdleColor, HoverColor, Locked)
	Button.MouseEnter:Connect(function()
		if Locked and Locked() then return end
		Tween(StrokeObject, { Color = HoverColor }, 0.18)
	end)
	Button.MouseLeave:Connect(function()
		if Locked and Locked() then return end
		Tween(StrokeObject, { Color = IdleColor }, 0.18)
	end)
end

local function RevealController(Wrap, Content)
	local Token = 0
	return function(Open, Instant)
		Token = Token + 1
		local Mine = Token
		if Instant then
			Wrap.ClipsDescendants = false
			Wrap.AutomaticSize = Enum.AutomaticSize.Y
			Wrap.Size = UDim2.new(1, 0, 0, 0)
			Wrap.Visible = Open
			return
		end
		Wrap.ClipsDescendants = true
		if Open then
			Wrap.AutomaticSize = Enum.AutomaticSize.None
			Wrap.Size = UDim2.new(1, 0, 0, 0)
			Wrap.Visible = true
			task.spawn(function()
				RunService.RenderStepped:Wait()
				if Mine ~= Token then return end
				local Goal = Content.AbsoluteSize.Y / math.max(CurrentScale, 0.01) + 1
				local Motion = Ease(Wrap, { Size = UDim2.new(1, 0, 0, Goal) }, 0.38, Enum.EasingStyle.Quint)
				Motion.Completed:Connect(function(State)
					if Mine ~= Token or State ~= Enum.PlaybackState.Completed then return end
					Wrap.ClipsDescendants = false
					Wrap.AutomaticSize = Enum.AutomaticSize.Y
					Wrap.Size = UDim2.new(1, 0, 0, 0)
				end)
			end)
		else
			local Height = Wrap.AbsoluteSize.Y / math.max(CurrentScale, 0.01)
			Wrap.AutomaticSize = Enum.AutomaticSize.None
			Wrap.Size = UDim2.new(1, 0, 0, Height)
			local Motion = Ease(Wrap, { Size = UDim2.new(1, 0, 0, 0) }, 0.3, Enum.EasingStyle.Quint)
			Motion.Completed:Connect(function(State)
				if Mine ~= Token or State ~= Enum.PlaybackState.Completed then return end
				Wrap.Visible = false
				Wrap.AutomaticSize = Enum.AutomaticSize.Y
			end)
		end
	end
end

local PointerOffset = Vector2.zero

local function Pointer(Input)
	if Input.UserInputType == Enum.UserInputType.Touch then
		return Vector2.new(Input.Position.X, Input.Position.Y) + PointerOffset
	end
	return UserInputService:GetMouseLocation()
end

local function Calibrate(Input, Object)
	if Input.UserInputType ~= Enum.UserInputType.Touch then return end
	local Raw = Vector2.new(Input.Position.X, Input.Position.Y)
	local Inset = GuiService:GetGuiInset()
	local Min = Object.AbsolutePosition
	local Max = Min + Object.AbsoluteSize
	local function Inside(Point)
		return Point.X >= Min.X and Point.X <= Max.X and Point.Y >= Min.Y and Point.Y <= Max.Y
	end
	local Plain = Inside(Raw)
	local Shifted = Inside(Raw + Inset)
	if Plain and not Shifted then
		PointerOffset = Vector2.zero
	elseif Shifted and not Plain then
		PointerOffset = Inset
	end
end

local function Drag(Handle, Target)
	local Dragging, Start, Origin
	Handle.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
			Dragging = true
			Start = Pointer(Input)
			Origin = Target.Position
			Input.Changed:Connect(function()
				if Input.UserInputState == Enum.UserInputState.End then Dragging = false end
			end)
		end
	end)
	UserInputService.InputChanged:Connect(function(Input)
		if Dragging and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
			local Delta = Pointer(Input) - Start
			Target.Position = UDim2.new(Origin.X.Scale, Origin.X.Offset + Delta.X, Origin.Y.Scale, Origin.Y.Offset + Delta.Y)
		end
	end)
end

local function Roots()
	local Result = {}
	if gethui then
		local ok, Root = pcall(gethui)
		if ok and Root then table.insert(Result, Root) end
	end
	pcall(function() table.insert(Result, game:GetService("CoreGui")) end)
	table.insert(Result, LocalPlayer:WaitForChild("PlayerGui"))
	return Result
end

local Library = {}

function Library:CreateWindow(Config)
	Config = Config or {}
	local WindowTitle = tostring(Config.Title or "Example")
	local GameInfo = tostring(Config.GameInfo or Config.Gameinfo or "Example")
	local ConfigFolder = tostring(Config.ConfigFolder or WindowTitle)
	local LicenseKey = Config.Key
	local IsLifetime = Config.LifeTime == true
	local Anonymous = Config.Anonymous == true
	local GuiName = string.gsub(WindowTitle, "[^%w]", "") .. "UI"
	local NotifyName = string.gsub(WindowTitle, "[^%w]", "") .. "Notify"
	local LogoImage = ""
	if Config.Logo ~= nil then LogoImage = (ResolveIcon(Config.Logo)) end
	local FooterName = IsLifetime and "Lifetime" or "Standard"
	local FooterState = IsLifetime and "Premium: Yes" or "Premium: No"

	local Flags = {}
	local Setters = {}
	local SearchIndex = {}
	local SectionTitles = {}
	local Tabs = {}
	local Binding = nil
	local Window = { Flags = Flags }
	local PanelExpand = setmetatable({}, { __mode = "k" })
	local TitleAccent = Config.TitleAccent and tostring(Config.TitleAccent) or ""
	local LinkText = tostring(Config.Link or WindowTitle)
	local BrandMarkup = WindowTitle
	if TitleAccent ~= "" and string.sub(WindowTitle, 1, #TitleAccent) == TitleAccent then
		BrandMarkup = string.format('<font color="%s">%s</font>%s', RichColor(Theme.Accent), TitleAccent, string.sub(WindowTitle, #TitleAccent + 1))
	end

	local function Register(Obj, Name, Kind)
		if type(Name) ~= "string" or Name == "" then return end
		table.insert(SearchIndex, { Obj = Obj, Name = Name, Kind = Kind })
		if Kind == "Section" then SectionTitles[Obj] = Name end
	end

	local function Panel(Parent, Order, Title, IconName, Collapsed, Fixed)
		local Frame = New("Frame", {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = Theme.PanelBody,
			BorderSizePixel = 0,
			LayoutOrder = Order,
		}, Parent)
		Corner(Frame, Round.Section)
		List(Frame, 0)
		Register(Frame, Title, "Section")
		local Header = New("TextButton", {
			Size = UDim2.new(1, 0, 0, 21),
			BackgroundColor3 = Theme.PanelHeader,
			BorderSizePixel = 0,
			Text = "",
			AutoButtonColor = false,
			LayoutOrder = 1,
		}, Frame)
		Corner(Header, Round.Header)
		New("Frame", {
			Position = UDim2.new(0, 0, 0.5, 0),
			Size = UDim2.new(1, 0, 0.5, 0),
			BackgroundColor3 = Theme.PanelHeader,
			BorderSizePixel = 0,
		}, Header)
		local HeaderIcon = Icon(Header, IconName, 10, Theme.Accent)
		HeaderIcon.AnchorPoint = Vector2.new(0, 0.5)
		HeaderIcon.Position = UDim2.new(0, 8, 0.5, 0)
		local HeaderText = Label(Header, Title, 10, Theme.Text, FontMain)
		HeaderText.Position = UDim2.new(0, 24, 0, 0)
		HeaderText.Size = UDim2.new(1, -44, 1, 0)
		local Chevron = Icon(Header, "chevron-down", 9, Theme.Dim)
		Chevron.AnchorPoint = Vector2.new(1, 0.5)
		Chevron.Position = UDim2.new(1, -8, 0.5, 0)
		Chevron.Rotation = Collapsed and 180 or 0
		Chevron.Visible = not Fixed
		local Wrap = New("Frame", {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			LayoutOrder = 2,
		}, Frame)
		local Body = New("Frame", {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
		}, Wrap)
		List(Body, 5)
		Pad(Body, 6, 6, 6, 8)
		local Reveal = RevealController(Wrap, Body)
		local Open = not Collapsed
		Reveal(Open, true)
		local function SetOpen(Value)
			Open = Value
			Reveal(Value)
			Tween(Chevron, { Rotation = Value and 0 or 180 }, 0.25)
			Tween(HeaderText, { TextColor3 = Theme.Text }, 0.2)
		end
		if not Fixed then
			Header.MouseButton1Click:Connect(function()
				SetOpen(not Open)
			end)
			Header.MouseEnter:Connect(function()
				Tween(Chevron, { ImageColor3 = Theme.Text }, 0.2)
			end)
			Header.MouseLeave:Connect(function()
				Tween(Chevron, { ImageColor3 = Theme.Dim }, 0.25)
			end)
		end
		PanelExpand[Frame] = function()
			if Open then return false end
			SetOpen(true)
			return true
		end
		return Body
	end

	local function Toggle(Parent, Order, Opts)
		local State = Opts.Default == true
		local Tone = StyleColor(Opts)
		local Holder = New("Frame", {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			LayoutOrder = Order,
		}, Parent)
		List(Holder, 5)
		local Row = New("TextButton", {
			Size = UDim2.new(1, 0, 0, 12),
			BackgroundTransparency = 1,
			Text = "",
			AutoButtonColor = false,
			LayoutOrder = 1,
		}, Holder)
		Register(Row, Opts.Name, "Toggle")
		local Text = Label(Row, Opts.Name, 9, Tone or (State and Theme.Text or Theme.Dim))
		Text.Size = UDim2.new(1, -24, 1, 0)
		Text.TextTruncate = Enum.TextTruncate.AtEnd
		local Extras = New("Frame", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -25, 0.5, 0),
			Size = UDim2.fromOffset(0, 12),
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundTransparency = 1,
		}, Row)
		local ExtraLayout = List(Extras, 6)
		ExtraLayout.FillDirection = Enum.FillDirection.Horizontal
		ExtraLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
		ExtraLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		local Track = New("Frame", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, 0, 0.5, 0),
			Size = UDim2.fromOffset(18, 11),
			BackgroundColor3 = State and Theme.Accent or Theme.Off,
			BorderSizePixel = 0,
		}, Row)
		Corner(Track, Round.Full)
		local Knob = New("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = State and UDim2.new(1, -9, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
			Size = UDim2.fromOffset(7, 7),
			BackgroundColor3 = State and Color3.new(1, 1, 1) or Theme.Knob,
			BorderSizePixel = 0,
		}, Track)
		Corner(Knob, Round.Full)
		Flags[Opts.Flag] = State
		local function Render()
			Tween(Track, { BackgroundColor3 = State and Theme.Accent or Theme.Off })
			Tween(Knob, {
				Position = State and UDim2.new(1, -9, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
				BackgroundColor3 = State and Color3.new(1, 1, 1) or Theme.Knob,
			})
			Tween(Text, { TextColor3 = Tone or (State and Theme.Text or Theme.Dim) })
		end
		local function Set(Value, Silent)
			State = Value == true
			Flags[Opts.Flag] = State
			Render()
			if not Silent and Opts.Callback then Opts.Callback(State) end
		end
		Row.MouseButton1Click:Connect(function()
			Set(not State)
		end)
		Setters[Opts.Flag] = Set
		return Set, Holder, Extras
	end

	local function OptionToggle(Parent, Order, Opts)
		local Holder = New("Frame", {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			LayoutOrder = Order,
		}, Parent)
		List(Holder, 5)
		local BodyWrap = New("Frame", {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			Visible = Opts.Default == true,
			LayoutOrder = 2,
		}, Holder)
		Pad(BodyWrap, 0, 1, 0, 0)
		New("Frame", {
			Position = UDim2.new(0, 2, 0, 0),
			Size = UDim2.new(0, 1, 1, 0),
			BackgroundColor3 = Theme.Stroke,
			BorderSizePixel = 0,
		}, BodyWrap)
		local Inner = New("Frame", {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
		}, BodyWrap)
		List(Inner, 5)
		Pad(Inner, 10, 0, 0, 1)
		local Reveal = RevealController(BodyWrap, Inner)
		local UserCallback = Opts.Callback
		local Set = Toggle(Holder, 1, {
			Name = Opts.Name,
			Flag = Opts.Flag,
			Default = Opts.Default,
			Callback = function(State)
				Reveal(State)
				if UserCallback then UserCallback(State) end
			end,
		})
		Reveal(Opts.Default == true, true)
		return Set, Inner
	end

	local function Slider(Parent, Order, Opts)
		local Min, Max = Opts.Min, Opts.Max
		local Step = 10 ^ (Opts.Decimals or 2)
		local Holder = New("Frame", {
			Size = UDim2.new(1, 0, 0, 20),
			BackgroundTransparency = 1,
			LayoutOrder = Order,
		}, Parent)
		Register(Holder, Opts.Name, "Slider")
		local Title = Label(Holder, Opts.Name, 9, StyleColor(Opts) or Theme.Text)
		Title.Size = UDim2.new(0.65, 0, 0, 12)
		local ValueLabel = Label(Holder, "", 9, Theme.Dim, FontMain, Right)
		ValueLabel.AnchorPoint = Vector2.new(1, 0)
		ValueLabel.Position = UDim2.new(1, 0, 0, 0)
		ValueLabel.Size = UDim2.new(0.35, 0, 0, 12)
		local Track = New("Frame", {
			Position = UDim2.new(0, 0, 0, 16),
			Size = UDim2.new(1, 0, 0, 4),
			BackgroundColor3 = Theme.Item,
			BorderSizePixel = 0,
		}, Holder)
		Corner(Track, Round.Full)
		local Fill = New("Frame", {
			Size = UDim2.fromScale(0, 1),
			BackgroundColor3 = Theme.Fill,
			BorderSizePixel = 0,
		}, Track)
		Corner(Fill, Round.Full)
		local Thumb = New("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0, 0.5),
			Size = UDim2.fromOffset(11, 8),
			BackgroundColor3 = Theme.Off,
			BorderSizePixel = 0,
			ZIndex = 2,
		}, Track)
		Corner(Thumb, Round.Thumb)
		local Hit = New("TextButton", {
			Position = UDim2.new(0, -3, 0, 10),
			Size = UDim2.new(1, 6, 0, 10),
			BackgroundTransparency = 1,
			Text = "",
			ZIndex = 3,
		}, Holder)
		local FillMotion, ThumbMotion
		local function Apply(Value, Silent, Smooth)
			Value = math.clamp(math.floor(Value * Step + 0.5) / Step, Min, Max)
			local Fraction = (Value - Min) / (Max - Min)
			if FillMotion then FillMotion:Cancel() end
			if ThumbMotion then ThumbMotion:Cancel() end
			if Smooth then
				FillMotion = Ease(Fill, { Size = UDim2.fromScale(Fraction, 1) }, 0.45, Enum.EasingStyle.Quint)
				ThumbMotion = Ease(Thumb, { AnchorPoint = Vector2.new(Fraction, 0.5), Position = UDim2.fromScale(Fraction, 0.5) }, 0.45, Enum.EasingStyle.Quint)
			else
				Fill.Size = UDim2.fromScale(Fraction, 1)
				Thumb.AnchorPoint = Vector2.new(Fraction, 0.5)
				Thumb.Position = UDim2.fromScale(Fraction, 0.5)
			end
			ValueLabel.Text = tostring(Value) .. (Opts.Suffix and tostring(Opts.Suffix) or "")
			Flags[Opts.Flag] = Value
			if not Silent and Opts.Callback then Opts.Callback(Value) end
		end
		local Dragging = false
		local function FromInput(Input)
			local Fraction = (Input.Position.X - Track.AbsolutePosition.X) / math.max(Track.AbsoluteSize.X, 1)
			Apply(Min + (Max - Min) * math.clamp(Fraction, 0, 1))
		end
		Hit.InputBegan:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
				Dragging = true
				Tween(Thumb, { BackgroundColor3 = Theme.Thumb }, 0.18)
				FromInput(Input)
			end
		end)
		UserInputService.InputChanged:Connect(function(Input)
			if Dragging and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
				FromInput(Input)
			end
		end)
		UserInputService.InputEnded:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
				if Dragging then Tween(Thumb, { BackgroundColor3 = Theme.Off }, 0.3) end
				Dragging = false
			end
		end)
		Apply(Opts.Default, true)
		Setters[Opts.Flag] = function(Value)
			if type(Value) == "number" then Apply(Value, nil, true) end
		end
	end

	local function Dropdown(Parent, Order, Opts)
		local Selected = Opts.Default
		local Holder = New("Frame", {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			LayoutOrder = Order,
		}, Parent)
		Register(Holder, Opts.Name, "Dropdown")
		List(Holder, 4)
		local Title = Label(Holder, Opts.Name, 9, Theme.Text)
		Title.Size = UDim2.new(1, 0, 0, 12)
		Title.LayoutOrder = 1
		local Box = New("TextButton", {
			Size = UDim2.new(1, 0, 0, 19),
			BackgroundColor3 = Theme.Item,
			BorderSizePixel = 0,
			Text = "",
			AutoButtonColor = false,
			LayoutOrder = 2,
		}, Holder)
		Corner(Box, Round.Dropdown)
		local BoxStroke = Stroke(Box, Theme.DropStroke, 1)
		local Current = Label(Box, Selected, 9, Theme.Text)
		Current.Position = UDim2.new(0, 6, 0, 0)
		Current.Size = UDim2.new(1, -24, 1, 0)
		local Chevron = Icon(Box, "chevron-down", 9, Theme.Dim)
		Chevron.AnchorPoint = Vector2.new(1, 0.5)
		Chevron.Position = UDim2.new(1, -5, 0.5, 0)
		local MenuWrap = New("Frame", {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			Visible = false,
			LayoutOrder = 3,
		}, Holder)
		Pad(MenuWrap, 0, 1, 0, 0)
		local Menu = New("Frame", {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = Theme.ListBody,
			BorderSizePixel = 0,
		}, MenuWrap)
		Corner(Menu, Round.Menu)
		Stroke(Menu, Theme.DropStroke, 1)
		List(Menu, 1)
		Pad(Menu, 0, 4, 0, 10)
		local Buttons = {}
		local function Refresh()
			Current.Text = Selected
			for Name, Button in pairs(Buttons) do
				Button.TextColor3 = Name == Selected and Theme.Accent or Theme.Dim
			end
		end
		local Controller = RevealController(MenuWrap, Menu)
		local IsOpen = false
		local function SetOpen(Value, Instant)
			IsOpen = Value
			Controller(Value, Instant)
			local Rotation = Value and 180 or 0
			local Color = Value and Theme.AccentLine or Theme.DropStroke
			if Instant then
				Chevron.Rotation = Rotation
				BoxStroke.Color = Color
			else
				Tween(Chevron, { Rotation = Rotation }, 0.35)
				Tween(BoxStroke, { Color = Color })
			end
		end
		for Index, Name in ipairs(Opts.Options) do
			local Button = New("TextButton", {
				Size = UDim2.new(1, 0, 0, 12),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Text = Name,
				TextSize = 9,
				Font = FontMain,
				TextColor3 = Theme.Dim,
				TextXAlignment = Left,
				AutoButtonColor = false,
				LayoutOrder = Index,
			}, Menu)
			Pad(Button, 6, 0, 0, 0)
			Buttons[Name] = Button
			Button.MouseButton1Click:Connect(function()
				Selected = Name
				Flags[Opts.Flag] = Name
				Refresh()
				SetOpen(false)
				if Opts.Callback then Opts.Callback(Name) end
			end)
		end
		HoverStroke(Box, BoxStroke, Theme.DropStroke, Color3.fromRGB(46, 46, 46), function() return IsOpen end)
		Box.MouseButton1Click:Connect(function()
			SetOpen(not IsOpen)
		end)
		Setters[Opts.Flag] = function(Value)
			if Buttons[Value] then
				Selected = Value
				Flags[Opts.Flag] = Value
				Refresh()
				if Opts.Callback then Opts.Callback(Value) end
			end
		end
		Flags[Opts.Flag] = Selected
		Refresh()
		SetOpen(Opts.Open == true, true)
	end

	local function SearchDropdown(Parent, Order, Opts)
		local Selected = Opts.Default or Opts.Options[1]
		local MaxHeight = 91
		local Holder = New("Frame", {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			LayoutOrder = Order,
		}, Parent)
		Register(Holder, Opts.Name, "Dropdown")
		List(Holder, 4)
		local Title = Label(Holder, Opts.Name, 9, Theme.Text)
		Title.Size = UDim2.new(1, 0, 0, 12)
		Title.LayoutOrder = 1
		local Box = New("TextButton", {
			Size = UDim2.new(1, 0, 0, 19),
			BackgroundColor3 = Theme.Item,
			BorderSizePixel = 0,
			Text = "",
			AutoButtonColor = false,
			LayoutOrder = 2,
		}, Holder)
		Corner(Box, Round.Dropdown)
		local BoxStroke = Stroke(Box, Theme.DropStroke, 1)
		local Current = Label(Box, Selected, 9, Theme.Text)
		Current.TextTruncate = Enum.TextTruncate.AtEnd
		Current.Position = UDim2.new(0, 6, 0, 0)
		Current.Size = UDim2.new(1, -24, 1, 0)
		local Chevron = Icon(Box, "chevron-down", 9, Theme.Dim)
		Chevron.AnchorPoint = Vector2.new(1, 0.5)
		Chevron.Position = UDim2.new(1, -5, 0.5, 0)
		local MenuWrap = New("Frame", {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			Visible = false,
			LayoutOrder = 3,
		}, Holder)
		Pad(MenuWrap, 0, 1, 0, 0)
		local Menu = New("Frame", {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = Theme.ListBody,
			BorderSizePixel = 0,
		}, MenuWrap)
		Corner(Menu, Round.Menu)
		Stroke(Menu, Theme.DropStroke, 1)
		List(Menu, 3)
		Pad(Menu, 4, 4, 4, 4)
		local SearchBox = New("TextBox", {
			Size = UDim2.new(1, 0, 0, 17),
			BackgroundColor3 = Theme.Item,
			BorderSizePixel = 0,
			Text = "",
			PlaceholderText = "Search...",
			PlaceholderColor3 = Theme.Dim,
			TextColor3 = Theme.Text,
			TextSize = 9,
			Font = FontMain,
			TextXAlignment = Left,
			ClearTextOnFocus = false,
			LayoutOrder = 1,
		}, Menu)
		Corner(SearchBox, Round.Dropdown)
		Stroke(SearchBox, Theme.DropStroke, 1)
		Pad(SearchBox, 6, 0, 6, 0)
		local Scroller = New("ScrollingFrame", {
			Size = UDim2.new(1, 0, 0, 12),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 2,
			ScrollBarImageColor3 = Theme.Off,
			CanvasSize = UDim2.new(),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollingDirection = Enum.ScrollingDirection.Y,
			LayoutOrder = 2,
		}, Menu)
		List(Scroller, 1)
		local Empty = Label(Scroller, "No results", 9, Theme.Dim)
		Empty.Size = UDim2.new(1, 0, 0, 12)
		Empty.Visible = false
		Pad(Empty, 6, 0, 0, 0)
		local Buttons = {}
		local function Refresh()
			Current.Text = Selected
			for Name, Button in pairs(Buttons) do
				Button.TextColor3 = Name == Selected and Theme.Accent or Theme.Dim
			end
		end
		local function Filter()
			local Query = string.lower(SearchBox.Text)
			local Count = 0
			for _, Name in ipairs(Opts.Options) do
				local Show = Query == "" or string.find(string.lower(Name), Query, 1, true) ~= nil
				Buttons[Name].Visible = Show
				if Show then Count = Count + 1 end
			end
			Empty.Visible = Count == 0
			Ease(Scroller, { Size = UDim2.new(1, 0, 0, math.clamp(Count * 13, 12, MaxHeight)) }, 0.3, Enum.EasingStyle.Quint)
		end
		local Controller = RevealController(MenuWrap, Menu)
		local IsOpen = false
		local function SetOpen(Value, Instant)
			IsOpen = Value
			Controller(Value, Instant)
			local Rotation = Value and 180 or 0
			local Color = Value and Theme.AccentLine or Theme.DropStroke
			if Instant then
				Chevron.Rotation = Rotation
				BoxStroke.Color = Color
			else
				Tween(Chevron, { Rotation = Rotation }, 0.35)
				Tween(BoxStroke, { Color = Color })
			end
			if not Value then SearchBox.Text = "" end
		end
		for Index, Name in ipairs(Opts.Options) do
			local Button = New("TextButton", {
				Size = UDim2.new(1, 0, 0, 12),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Text = Name,
				TextSize = 9,
				Font = FontMain,
				TextColor3 = Theme.Dim,
				TextXAlignment = Left,
				AutoButtonColor = false,
				LayoutOrder = Index,
			}, Scroller)
			Pad(Button, 6, 0, 0, 0)
			Buttons[Name] = Button
			Button.MouseButton1Click:Connect(function()
				Selected = Name
				Flags[Opts.Flag] = Name
				Refresh()
				SetOpen(false)
				if Opts.Callback then Opts.Callback(Name) end
			end)
		end
		SearchBox:GetPropertyChangedSignal("Text"):Connect(Filter)
		HoverStroke(Box, BoxStroke, Theme.DropStroke, Color3.fromRGB(46, 46, 46), function() return IsOpen end)
		Box.MouseButton1Click:Connect(function()
			SetOpen(not IsOpen)
		end)
		Setters[Opts.Flag] = function(Value)
			if Buttons[Value] then
				Selected = Value
				Flags[Opts.Flag] = Value
				Refresh()
				if Opts.Callback then Opts.Callback(Value) end
			end
		end
		Flags[Opts.Flag] = Selected
		Refresh()
		Filter()
		SetOpen(Opts.Open == true, true)
	end

	local function MultiDropdown(Parent, Order, Opts)
		local Selected = {}
		for _, Name in ipairs(Opts.Default or {}) do Selected[Name] = true end
		local Holder = New("Frame", {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			LayoutOrder = Order,
		}, Parent)
		Register(Holder, Opts.Name, "Dropdown")
		List(Holder, 4)
		local Title = Label(Holder, Opts.Name, 9, Theme.Text)
		Title.Size = UDim2.new(1, 0, 0, 12)
		Title.LayoutOrder = 1
		local Box = New("TextButton", {
			Size = UDim2.new(1, 0, 0, 19),
			BackgroundColor3 = Theme.Item,
			BorderSizePixel = 0,
			Text = "",
			AutoButtonColor = false,
			LayoutOrder = 2,
		}, Holder)
		Corner(Box, Round.Dropdown)
		local BoxStroke = Stroke(Box, Theme.DropStroke, 1)
		local Current = Label(Box, "None", 9, Theme.Dim)
		Current.TextTruncate = Enum.TextTruncate.AtEnd
		Current.Position = UDim2.new(0, 6, 0, 0)
		Current.Size = UDim2.new(1, -24, 1, 0)
		local Chevron = Icon(Box, "chevron-down", 9, Theme.Dim)
		Chevron.AnchorPoint = Vector2.new(1, 0.5)
		Chevron.Position = UDim2.new(1, -5, 0.5, 0)
		local MenuWrap = New("Frame", {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			Visible = false,
			LayoutOrder = 3,
		}, Holder)
		Pad(MenuWrap, 0, 1, 0, 0)
		local Menu = New("Frame", {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = Theme.ListBody,
			BorderSizePixel = 0,
		}, MenuWrap)
		Corner(Menu, Round.Menu)
		Stroke(Menu, Theme.DropStroke, 1)
		List(Menu, 1)
		Pad(Menu, 0, 4, 0, 4)
		local Buttons = {}
		local Checks = {}
		local function Refresh()
			local Chosen = {}
			for _, Name in ipairs(Opts.Options) do
				if Selected[Name] then table.insert(Chosen, Name) end
			end
			Current.Text = #Chosen == 0 and "None" or table.concat(Chosen, ", ")
			Current.TextColor3 = #Chosen == 0 and Theme.Dim or Theme.Text
			for Name, Button in pairs(Buttons) do
				local On = Selected[Name] == true
				Button.TextColor3 = On and Theme.Accent or Theme.Dim
				Checks[Name].Visible = On
			end
			Flags[Opts.Flag] = Chosen
			return Chosen
		end
		local Controller = RevealController(MenuWrap, Menu)
		local IsOpen = false
		local function SetOpen(Value, Instant)
			IsOpen = Value
			Controller(Value, Instant)
			local Rotation = Value and 180 or 0
			local Color = Value and Theme.AccentLine or Theme.DropStroke
			if Instant then
				Chevron.Rotation = Rotation
				BoxStroke.Color = Color
			else
				Tween(Chevron, { Rotation = Rotation }, 0.35)
				Tween(BoxStroke, { Color = Color })
			end
		end
		for Index, Name in ipairs(Opts.Options) do
			local Button = New("TextButton", {
				Size = UDim2.new(1, 0, 0, 12),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Text = Name,
				TextSize = 9,
				Font = FontMain,
				TextColor3 = Theme.Dim,
				TextXAlignment = Left,
				AutoButtonColor = false,
				LayoutOrder = Index,
			}, Menu)
			Pad(Button, 6, 0, 18, 0)
			local Check = Icon(Button, "check", 9, Theme.Accent)
			Check.AnchorPoint = Vector2.new(1, 0.5)
			Check.Position = UDim2.new(1, -5, 0.5, 0)
			Check.Visible = false
			Buttons[Name] = Button
			Checks[Name] = Check
			Button.MouseButton1Click:Connect(function()
				Selected[Name] = not Selected[Name] or nil
				local Chosen = Refresh()
				if Opts.Callback then Opts.Callback(Chosen) end
			end)
		end
		HoverStroke(Box, BoxStroke, Theme.DropStroke, Color3.fromRGB(46, 46, 46), function() return IsOpen end)
		Box.MouseButton1Click:Connect(function()
			SetOpen(not IsOpen)
		end)
		Setters[Opts.Flag] = function(Value)
			if type(Value) ~= "table" then return end
			Selected = {}
			for _, Name in ipairs(Value) do
				if Buttons[Name] then Selected[Name] = true end
			end
			local Chosen = Refresh()
			if Opts.Callback then Opts.Callback(Chosen) end
		end
		Refresh()
		SetOpen(Opts.Open == true, true)
	end

	local function ToHex(Color)
		return string.format("%02X%02X%02X", math.floor(Color.R * 255 + 0.5), math.floor(Color.G * 255 + 0.5), math.floor(Color.B * 255 + 0.5))
	end

	local function Keybind(Parent, Order, Opts, Extras)
		local Key = Opts.Default
		local Listening = false
		local Box
		if Extras then
			Box = New("TextButton", {
				Size = UDim2.fromOffset(0, 12),
				AutomaticSize = Enum.AutomaticSize.X,
				BackgroundTransparency = 1,
				Text = "",
				TextSize = 9,
				Font = FontMain,
				TextColor3 = Theme.Dim,
				AutoButtonColor = false,
				LayoutOrder = 1,
			}, Extras)
		else
			local Row = New("Frame", {
				Size = UDim2.new(1, 0, 0, 12),
				BackgroundTransparency = 1,
				LayoutOrder = Order,
			}, Parent)
			Register(Row, Opts.Name, "Keybind")
			local Title = Label(Row, Opts.Name, 9, Theme.Text)
			Title.Size = UDim2.new(1, -50, 1, 0)
			Title.TextTruncate = Enum.TextTruncate.AtEnd
			Box = New("TextButton", {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, 0, 0.5, 0),
				Size = UDim2.fromOffset(0, 12),
				AutomaticSize = Enum.AutomaticSize.X,
				BackgroundTransparency = 1,
				Text = "",
				TextSize = 9,
				Font = FontMain,
				TextColor3 = Theme.Dim,
				AutoButtonColor = false,
			}, Row)
		end
		local Inside = false
		local function Render()
			Box.Text = Listening and "[...]" or ("[" .. KeyText(Key) .. "]")
			Tween(Box, { TextColor3 = Listening and Theme.Accent or (Inside and Theme.Text or Theme.Dim) }, 0.2)
		end
		Flags[Opts.Flag] = Key
		Render()
		Box.MouseEnter:Connect(function()
			Inside = true
			if not Listening then Tween(Box, { TextColor3 = Theme.Text }, 0.2) end
		end)
		Box.MouseLeave:Connect(function()
			Inside = false
			if not Listening then Tween(Box, { TextColor3 = Theme.Dim }, 0.25) end
		end)
		Box.MouseButton1Click:Connect(function()
			if Binding then Binding() end
			Listening = true
			Binding = function()
				Listening = false
				Render()
			end
			Render()
		end)
		UserInputService.InputBegan:Connect(function(Input, Processed)
			if Listening then
				local Picked
				local Valid = false
				if Input.UserInputType == Enum.UserInputType.Keyboard then
					Valid = true
					if Input.KeyCode ~= Enum.KeyCode.Escape then Picked = Input.KeyCode end
				elseif MouseNames[Input.UserInputType] then
					Valid = true
					Picked = Input.UserInputType
				elseif Input.UserInputType == Enum.UserInputType.MouseButton1 then
					Listening = false
					Render()
					task.defer(function()
						Binding = nil
					end)
					return
				end
				if Valid then
					Key = Picked
					Listening = false
					Flags[Opts.Flag] = Key
					Render()
					task.defer(function()
						Binding = nil
					end)
					if Opts.Callback then Opts.Callback(Key) end
				end
				return
			end
			if not Processed and Key and (Input.KeyCode == Key or Input.UserInputType == Key) and Opts.Pressed then
				Opts.Pressed()
			end
		end)
		local function Set(Value)
			Key = Value
			Flags[Opts.Flag] = Key
			Render()
		end
		Setters[Opts.Flag] = Set
		return Set
	end

	local function ColorPicker(Parent, Order, Opts, Extras)
		local Value = Opts.Default or Color3.new(1, 1, 1)
		local Hue, Sat, Val = Value:ToHSV()
		local Holder, Row, Swatch
		if Extras then
			Holder = Parent
			Swatch = New("TextButton", {
				Size = UDim2.fromOffset(16, 9),
				BackgroundColor3 = Value,
				BorderSizePixel = 0,
				Text = "",
				AutoButtonColor = false,
				LayoutOrder = 2,
			}, Extras)
			Row = Swatch
		else
			Holder = New("Frame", {
				Size = UDim2.new(1, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				LayoutOrder = Order,
			}, Parent)
			Register(Holder, Opts.Name, "Color")
			List(Holder, 4)
			Row = New("TextButton", {
				Size = UDim2.new(1, 0, 0, 12),
				BackgroundTransparency = 1,
				Text = "",
				AutoButtonColor = false,
				LayoutOrder = 1,
			}, Holder)
			local Title = Label(Row, Opts.Name, 9, Theme.Text)
			Title.Size = UDim2.new(1, -28, 1, 0)
			Swatch = New("Frame", {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, 0, 0.5, 0),
				Size = UDim2.fromOffset(20, 10),
				BackgroundColor3 = Value,
				BorderSizePixel = 0,
			}, Row)
		end
		Corner(Swatch, Round.Thumb)
		local SwatchStroke = Stroke(Swatch, Theme.DropStroke, 1)
		local BodyWrap = New("Frame", {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			Visible = Opts.Open == true,
			LayoutOrder = 2,
		}, Holder)
		local Body = New("Frame", {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = Theme.ListBody,
			BorderSizePixel = 0,
		}, BodyWrap)
		Corner(Body, Round.Menu)
		Stroke(Body, Theme.DropStroke, 1)
		List(Body, 5)
		Pad(Body, 5, 5, 5, 5)
		local SV = New("Frame", {
			Size = UDim2.new(1, 0, 0, 64),
			BackgroundColor3 = Color3.fromHSV(Hue, 1, 1),
			BorderSizePixel = 0,
			LayoutOrder = 1,
		}, Body)
		Corner(SV, Round.Thumb)
		local White = New("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
		}, SV)
		Corner(White, Round.Thumb)
		New("UIGradient", { Transparency = NumberSequence.new(0, 1) }, White)
		local Black = New("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = Color3.new(0, 0, 0),
			BorderSizePixel = 0,
		}, SV)
		Corner(Black, Round.Thumb)
		New("UIGradient", { Rotation = 90, Transparency = NumberSequence.new(1, 0) }, Black)
		local SVCursor = New("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.fromOffset(7, 7),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ZIndex = 4,
		}, SV)
		Corner(SVCursor, Round.Full)
		Stroke(SVCursor, Color3.new(1, 1, 1), 1)
		local SVHit = New("TextButton", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Text = "",
			ZIndex = 5,
		}, SV)
		local HueBar = New("Frame", {
			Size = UDim2.new(1, 0, 0, 8),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
			LayoutOrder = 2,
		}, Body)
		Corner(HueBar, Round.Full)
		New("UIGradient", {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
				ColorSequenceKeypoint.new(1 / 6, Color3.fromHSV(1 / 6, 1, 1)),
				ColorSequenceKeypoint.new(2 / 6, Color3.fromHSV(2 / 6, 1, 1)),
				ColorSequenceKeypoint.new(3 / 6, Color3.fromHSV(3 / 6, 1, 1)),
				ColorSequenceKeypoint.new(4 / 6, Color3.fromHSV(4 / 6, 1, 1)),
				ColorSequenceKeypoint.new(5 / 6, Color3.fromHSV(5 / 6, 1, 1)),
				ColorSequenceKeypoint.new(1, Color3.fromHSV(0, 1, 1)),
			}),
		}, HueBar)
		local HueCursor = New("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.fromOffset(3, 12),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
			ZIndex = 4,
		}, HueBar)
		Corner(HueCursor, Round.Thumb)
		Stroke(HueCursor, Color3.new(0, 0, 0), 1)
		local HueHit = New("TextButton", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Text = "",
			ZIndex = 5,
		}, HueBar)
		local Hex = New("TextBox", {
			Size = UDim2.new(1, 0, 0, 17),
			BackgroundColor3 = Theme.Item,
			BorderSizePixel = 0,
			Text = "",
			PlaceholderText = "HEX",
			PlaceholderColor3 = Theme.Dim,
			TextColor3 = Theme.Text,
			TextSize = 9,
			Font = FontMain,
			TextXAlignment = Center,
			ClearTextOnFocus = false,
			LayoutOrder = 3,
		}, Body)
		Corner(Hex, Round.Dropdown)
		Stroke(Hex, Theme.DropStroke, 1)
		local function Apply(Silent)
			Value = Color3.fromHSV(Hue, Sat, Val)
			Swatch.BackgroundColor3 = Value
			SV.BackgroundColor3 = Color3.fromHSV(Hue, 1, 1)
			SVCursor.Position = UDim2.fromScale(Sat, 1 - Val)
			HueCursor.Position = UDim2.fromScale(Hue, 0.5)
			Hex.Text = ToHex(Value)
			Flags[Opts.Flag] = Value
			if not Silent and Opts.Callback then Opts.Callback(Value) end
		end
		local Mode
		local function FromInput(Input)
			local Pos = Pointer(Input)
			if Mode == "SV" then
				Sat = math.clamp((Pos.X - SV.AbsolutePosition.X) / math.max(SV.AbsoluteSize.X, 1), 0, 1)
				Val = 1 - math.clamp((Pos.Y - SV.AbsolutePosition.Y) / math.max(SV.AbsoluteSize.Y, 1), 0, 1)
				Apply()
			elseif Mode == "Hue" then
				Hue = math.clamp((Pos.X - HueBar.AbsolutePosition.X) / math.max(HueBar.AbsoluteSize.X, 1), 0, 1)
				Apply()
			end
		end
		SVHit.InputBegan:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
				Mode = "SV"
				Calibrate(Input, SVHit)
				FromInput(Input)
			end
		end)
		HueHit.InputBegan:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
				Mode = "Hue"
				Calibrate(Input, HueHit)
				FromInput(Input)
			end
		end)
		UserInputService.InputChanged:Connect(function(Input)
			if Mode and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
				FromInput(Input)
			end
		end)
		UserInputService.InputEnded:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
				Mode = nil
			end
		end)
		Hex.FocusLost:Connect(function()
			local R, G, B = string.match(Hex.Text, "^#?(%x%x)(%x%x)(%x%x)$")
			if R then
				Hue, Sat, Val = Color3.fromRGB(tonumber(R, 16), tonumber(G, 16), tonumber(B, 16)):ToHSV()
				Apply()
			else
				Hex.Text = ToHex(Value)
			end
		end)
		local PickerOpen = Opts.Open == true
		local SetPicker = RevealController(BodyWrap, Body)
		HoverStroke(Row, SwatchStroke, Theme.DropStroke, Color3.fromRGB(46, 46, 46), function() return PickerOpen end)
		Row.MouseButton1Click:Connect(function()
			PickerOpen = not PickerOpen
			SetPicker(PickerOpen)
			Tween(SwatchStroke, { Color = PickerOpen and Theme.AccentLine or Theme.DropStroke })
		end)
		Apply(true)
		local function Set(Color, Silent)
			Hue, Sat, Val = Color:ToHSV()
			Apply(Silent)
		end
		Setters[Opts.Flag] = function(Color)
			if typeof(Color) == "Color3" then Set(Color) end
		end
		return Set
	end

	local function ActionButton(Parent, Order, Text, Callback)
		local Idle = Theme.Item
		local Hover = Color3.fromRGB(28, 28, 28)
		local Button = New("TextButton", {
			Size = UDim2.new(1, 0, 0, 19),
			BackgroundColor3 = Idle,
			BorderSizePixel = 0,
			Text = Text,
			TextSize = 9,
			Font = FontMain,
			TextColor3 = Theme.Dim,
			AutoButtonColor = false,
			LayoutOrder = Order,
		}, Parent)
		Register(Button, Text, "Button")
		Corner(Button, Round.Button)
		local ButtonStroke = Stroke(Button, Theme.Stroke, 1)
		local Inside = false
		Button.MouseEnter:Connect(function()
			Inside = true
			Tween(Button, { TextColor3 = Theme.Text, BackgroundColor3 = Hover }, 0.2)
			Tween(ButtonStroke, { Color = Color3.fromRGB(46, 46, 46) }, 0.2)
		end)
		Button.MouseLeave:Connect(function()
			Inside = false
			Tween(Button, { TextColor3 = Theme.Dim, BackgroundColor3 = Idle }, 0.25)
			Tween(ButtonStroke, { Color = Theme.Stroke }, 0.25)
		end)
		Button.MouseButton1Down:Connect(function()
			Tween(Button, { BackgroundColor3 = Color3.fromRGB(17, 17, 17) }, 0.1)
		end)
		Button.MouseButton1Click:Connect(function()
			Tween(Button, { BackgroundColor3 = Inside and Hover or Idle }, 0.3)
			if Callback then Callback() end
		end)
	end

	local function Input(Parent, Order, Opts)
		local Value = tostring(Opts.Default or "")
		local Holder = New("Frame", {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			LayoutOrder = Order,
		}, Parent)
		Register(Holder, Opts.Name, "Input")
		List(Holder, 4)
		local Title = Label(Holder, Opts.Name, 9, StyleColor(Opts) or Theme.Text)
		Title.Size = UDim2.new(1, 0, 0, 12)
		Title.LayoutOrder = 1
		local Box = New("Frame", {
			Size = UDim2.new(1, 0, 0, 19),
			BackgroundColor3 = Theme.Item,
			BorderSizePixel = 0,
			ClipsDescendants = true,
			LayoutOrder = 2,
		}, Holder)
		Corner(Box, Round.Dropdown)
		local BoxStroke = Stroke(Box, Theme.DropStroke, 1)
		local Field = New("TextBox", {
			Position = UDim2.new(0, 6, 0, 0),
			Size = UDim2.new(1, -12, 1, 0),
			BackgroundTransparency = 1,
			Text = Value,
			PlaceholderText = tostring(Opts.Placeholder or ""),
			PlaceholderColor3 = Theme.Dim,
			TextColor3 = Theme.Text,
			TextSize = 9,
			Font = FontMain,
			TextXAlignment = Left,
			ClearTextOnFocus = false,
			ClipsDescendants = true,
		}, Box)
		Flags[Opts.Flag] = Value
		local function Clean(Text)
			Text = tostring(Text or "")
			if Opts.Numeric then Text = string.gsub(Text, "[^%d%.%-]", "") end
			return Text
		end
		local function Set(Text, Silent)
			Value = Clean(Text)
			Field.Text = Value
			Flags[Opts.Flag] = Value
			if not Silent and Opts.Callback then Opts.Callback(Value) end
		end
		Field.Focused:Connect(function()
			Tween(BoxStroke, { Color = Theme.AccentLine }, 0.2)
		end)
		Field.FocusLost:Connect(function()
			Tween(BoxStroke, { Color = Theme.DropStroke }, 0.25)
			Set(Field.Text)
		end)
		Setters[Opts.Flag] = function(Text)
			Set(Text)
		end
		return Set
	end

	local function LabelElement(Parent, Order, Opts)
		local Holder = New("Frame", {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			LayoutOrder = Order,
		}, Parent)
		List(Holder, 2)
		local Title = Label(Holder, tostring(Opts.Name or ""), 9, StyleColor(Opts) or Theme.Text)
		Title.Size = UDim2.new(1, 0, 0, 12)
		Title.RichText = true
		Title.LayoutOrder = 1
		local Description
		if Opts.Description and Opts.Description ~= "" then
			Description = Label(Holder, tostring(Opts.Description), 8, Theme.Dim)
			Description.Size = UDim2.new(1, 0, 0, 0)
			Description.AutomaticSize = Enum.AutomaticSize.Y
			Description.TextWrapped = true
			Description.RichText = true
			Description.TextYAlignment = Enum.TextYAlignment.Top
			Description.LayoutOrder = 2
		end
		if Opts.Separator then
			New("Frame", {
				Size = UDim2.new(1, 0, 0, 4),
				BackgroundTransparency = 1,
				LayoutOrder = 3,
			}, Holder)
			New("Frame", {
				Size = UDim2.new(1, 0, 0, 1),
				BackgroundColor3 = Theme.Stroke,
				BorderSizePixel = 0,
				LayoutOrder = 4,
			}, Holder)
		end
		return Title, Description, Holder
	end

	local function Divider(Parent, Order, Opts)
		local Name = Opts.Name and tostring(Opts.Name) or ""
		local Holder = New("Frame", {
			Size = UDim2.new(1, 0, 0, Name ~= "" and 12 or 5),
			BackgroundTransparency = 1,
			LayoutOrder = Order,
		}, Parent)
		if Name == "" then
			local Line = New("Frame", {
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, 0, 0.5, 0),
				Size = UDim2.new(1, 0, 0, 1),
				BackgroundColor3 = Theme.Stroke,
				BorderSizePixel = 0,
			}, Holder)
			return Holder
		end
		local Width = TextService:GetTextSize(Name, 9, FontMain, Vector2.new(1000, 100)).X
		local Title = Label(Holder, Name, 9, Theme.Text)
		Title.Size = UDim2.fromOffset(Width + 2, 12)
		local Centered = Opts.Centered == true or string.lower(tostring(Opts.Align or "")) == "center"
		if Centered then
			Title.AnchorPoint = Vector2.new(0.5, 0.5)
			Title.Position = UDim2.new(0.5, 0, 0.5, 0)
			Title.TextXAlignment = Center
			New("Frame", {
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, 0, 0.5, 0),
				Size = UDim2.new(0.5, -(Width / 2 + 7), 0, 1),
				BackgroundColor3 = Theme.Stroke,
				BorderSizePixel = 0,
			}, Holder)
			New("Frame", {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, 0, 0.5, 0),
				Size = UDim2.new(0.5, -(Width / 2 + 7), 0, 1),
				BackgroundColor3 = Theme.Stroke,
				BorderSizePixel = 0,
			}, Holder)
		else
			Title.AnchorPoint = Vector2.new(0, 0.5)
			Title.Position = UDim2.new(0, 13, 0.5, 0)
			New("Frame", {
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, 0, 0.5, 0),
				Size = UDim2.fromOffset(7, 1),
				BackgroundColor3 = Theme.Stroke,
				BorderSizePixel = 0,
			}, Holder)
			New("Frame", {
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, Width + 22, 0.5, 0),
				Size = UDim2.new(1, -(Width + 22), 0, 1),
				BackgroundColor3 = Theme.Stroke,
				BorderSizePixel = 0,
			}, Holder)
		end
		return Holder
	end

	local function Column(Parent, X, HasSub)
		local Top = HasSub and 33 or 7
		local Scroll = New("ScrollingFrame", {
			Position = UDim2.new(0, X - 1, 0, Top),
			Size = UDim2.new(0, 141, 1, -Top),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 0,
			CanvasSize = UDim2.new(),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollingDirection = Enum.ScrollingDirection.Y,
		}, Parent)
		Scroll:SetAttribute("Column", true)
		List(Scroll, 7)
		Pad(Scroll, 1, 1, 1, 1)
		return Scroll
	end

	local FlagCount = 0
	local SectionMethods = {}
	SectionMethods.__index = SectionMethods

	local function MakeSection(Body)
		return setmetatable({ Body = Body, Count = 0 }, SectionMethods)
	end

	local function Prepare(Section, Opts)
		Opts = Opts or {}
		Section.Count = Section.Count + 1
		if Opts.Flag == nil then
			FlagCount = FlagCount + 1
			Opts.Flag = "Element" .. FlagCount
		end
		return Opts
	end

	local function Control(Flag)
		return {
			Flag = Flag,
			Set = function(_, Value)
				local Setter = Setters[Flag]
				if Setter then Setter(Value) end
			end,
			Get = function()
				return Flags[Flag]
			end,
		}
	end

	function SectionMethods:Toggle(Opts)
		Opts = Prepare(self, Opts)
		Opts.Name = Opts.Name or "Example"
		local _, Holder, Extras = Toggle(self.Body, self.Count, Opts)
		local Handle = Control(Opts.Flag)
		local function SubFlag(Sub)
			Sub = Sub or {}
			if Sub.Flag == nil then
				FlagCount = FlagCount + 1
				Sub.Flag = "Element" .. FlagCount
			end
			Sub.Name = Sub.Name or Opts.Name
			return Sub
		end
		function Handle:ColorPicker(Sub)
			Sub = SubFlag(Sub)
			ColorPicker(Holder, 2, Sub, Extras)
			return Control(Sub.Flag)
		end
		function Handle:Keybind(Sub)
			Sub = SubFlag(Sub)
			Keybind(Holder, 2, Sub, Extras)
			return Control(Sub.Flag)
		end
		if Opts.ColorPicker then Handle:ColorPicker(Opts.ColorPicker) end
		if Opts.Keybind then Handle:Keybind(Opts.Keybind) end
		return Handle
	end

	function SectionMethods:OptionToggle(Opts)
		Opts = Prepare(self, Opts)
		Opts.Name = Opts.Name or "Example"
		local _, Inner = OptionToggle(self.Body, self.Count, Opts)
		local Child = MakeSection(Inner)
		local Handle = Control(Opts.Flag)
		Child.Flag = Handle.Flag
		Child.Set = Handle.Set
		Child.Get = Handle.Get
		return Child
	end

	function SectionMethods:Slider(Opts)
		Opts = Prepare(self, Opts)
		Opts.Name = Opts.Name or "Example"
		Opts.Min = Opts.Min or 0
		Opts.Max = Opts.Max or 100
		Opts.Default = Opts.Default or Opts.Min
		Slider(self.Body, self.Count, Opts)
		return Control(Opts.Flag)
	end

	function SectionMethods:Dropdown(Opts)
		Opts = Prepare(self, Opts)
		Opts.Name = Opts.Name or "Example"
		Opts.Options = Opts.Options or {}
		Opts.Default = Opts.Default or Opts.Options[1] or ""
		Dropdown(self.Body, self.Count, Opts)
		return Control(Opts.Flag)
	end

	function SectionMethods:SearchDropdown(Opts)
		Opts = Prepare(self, Opts)
		Opts.Name = Opts.Name or "Example"
		Opts.Options = Opts.Options or {}
		Opts.Default = Opts.Default or Opts.Options[1] or ""
		SearchDropdown(self.Body, self.Count, Opts)
		return Control(Opts.Flag)
	end

	function SectionMethods:MultiDropdown(Opts)
		Opts = Prepare(self, Opts)
		Opts.Name = Opts.Name or "Example"
		Opts.Options = Opts.Options or {}
		Opts.Default = Opts.Default or {}
		MultiDropdown(self.Body, self.Count, Opts)
		return Control(Opts.Flag)
	end

	function SectionMethods:Keybind(Opts)
		Opts = Prepare(self, Opts)
		Opts.Name = Opts.Name or "Example"
		Keybind(self.Body, self.Count, Opts)
		return Control(Opts.Flag)
	end

	function SectionMethods:ColorPicker(Opts)
		Opts = Prepare(self, Opts)
		Opts.Name = Opts.Name or "Example"
		ColorPicker(self.Body, self.Count, Opts)
		return Control(Opts.Flag)
	end

	function SectionMethods:Button(Opts)
		Opts = Opts or {}
		self.Count = self.Count + 1
		ActionButton(self.Body, self.Count, Opts.Name or "Example", Opts.Callback)
		return {}
	end

	function SectionMethods:Input(Opts)
		Opts = Prepare(self, Opts)
		Opts.Name = Opts.Name or "Example"
		Input(self.Body, self.Count, Opts)
		return Control(Opts.Flag)
	end

	function SectionMethods:Label(Opts)
		if type(Opts) == "string" then Opts = { Name = Opts } end
		Opts = Opts or {}
		self.Count = self.Count + 1
		local Title, Description = LabelElement(self.Body, self.Count, Opts)
		local Handle = {}
		function Handle:SetTitle(Text)
			Title.Text = tostring(Text)
		end
		function Handle:SetDescription(Text)
			if Description then Description.Text = tostring(Text) end
		end
		return Handle
	end

	function SectionMethods:Divider(Opts)
		if type(Opts) == "string" then Opts = { Name = Opts } end
		Opts = Opts or {}
		self.Count = self.Count + 1
		Divider(self.Body, self.Count, Opts)
		return {}
	end

	function SectionMethods:Split()
		self.Count = self.Count + 1
		local Holder = New("Frame", {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			LayoutOrder = self.Count,
		}, self.Body)
		local Layout = List(Holder, 8)
		Layout.FillDirection = Enum.FillDirection.Horizontal
		Layout.VerticalAlignment = Enum.VerticalAlignment.Top
		local function Half(Order)
			local Side = New("Frame", {
				Size = UDim2.new(0.5, -4, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				LayoutOrder = Order,
			}, Holder)
			List(Side, 5)
			return MakeSection(Side)
		end
		return Half(1), Half(2)
	end

	local function AddSection(Holder, HasSub, Opts)
		Opts = Opts or {}
		if not Holder.Columns then
			Holder.Columns = {
				Left = Column(Holder.Frame, 0, HasSub),
				Right = Column(Holder.Frame, 148, HasSub),
				Order = { Left = 0, Right = 0 },
			}
		end
		local Columns = Holder.Columns
		local Side = string.lower(tostring(Opts.Side or "left")) == "right" and "Right" or "Left"
		Columns.Order[Side] = Columns.Order[Side] + 1
		local Body = Panel(Columns[Side], Columns.Order[Side], Opts.Name or "Example", Opts.Icon or "layers", Opts.Collapsed == true)
		return MakeSection(Body)
	end

	for _, Root in ipairs(Roots()) do
		local Old = Root:FindFirstChild(GuiName)
		if Old then Old:Destroy() end
		local OldNotify = Root:FindFirstChild(NotifyName)
		if OldNotify then OldNotify:Destroy() end
	end

	local Gui = New("ScreenGui", {
		Name = GuiName,
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = 999,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	})

	local NotifyGui = New("ScreenGui", {
		Name = NotifyName,
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = 1000,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	})

	local NotifyHolder = New("Frame", {
		Position = UDim2.new(0, 10, 0, GuiService:GetGuiInset().Y + 8),
		Size = UDim2.fromOffset(190, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
	}, NotifyGui)
	local NotifyScale = New("UIScale", {}, NotifyHolder)
	New("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		VerticalAlignment = Enum.VerticalAlignment.Top,
	}, NotifyHolder)

	local function Glow(Parent, Color, Transparency)
		return New("ImageLabel", {
			Position = UDim2.new(0, -16, 0, -16),
			Size = UDim2.new(1, 32, 1, 32),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Image = "rbxassetid://5028857084",
			ImageColor3 = Color,
			ImageTransparency = Transparency,
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(24, 24, 276, 276),
			ZIndex = 1,
		}, Parent)
	end

	local WatermarkWrap = New("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = 0,
		Visible = Config.Watermark ~= false,
	}, NotifyHolder)
	Pad(WatermarkWrap, 0, 0, 0, 8)
	local WatermarkCard = New("Frame", {
		Size = UDim2.fromOffset(0, 0),
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundTransparency = 1,
	}, WatermarkWrap)
	Glow(WatermarkCard, Theme.Accent, 0.88)
	local WatermarkBg = New("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Theme.Notice,
		BorderSizePixel = 0,
		ZIndex = 2,
	}, WatermarkCard)
	Corner(WatermarkBg, Round.Section)
	Stroke(WatermarkBg, Theme.Stroke, 1)
	local WatermarkBody = New("Frame", {
		Size = UDim2.fromOffset(0, 0),
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundTransparency = 1,
		ZIndex = 3,
	}, WatermarkCard)
	Pad(WatermarkBody, 8, 5, 8, 5)
	local WatermarkLayout = List(WatermarkBody, 6)
	WatermarkLayout.FillDirection = Enum.FillDirection.Horizontal
	WatermarkLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	local WatermarkOrder = 0

	local function WatermarkPart(Text, Color)
		WatermarkOrder = WatermarkOrder + 1
		local Part = Label(WatermarkBody, Text, 9, Color or Theme.Text)
		Part.AutomaticSize = Enum.AutomaticSize.X
		Part.Size = UDim2.fromOffset(0, 14)
		Part.LayoutOrder = WatermarkOrder
		return Part
	end

	local function WatermarkSeparator()
		WatermarkOrder = WatermarkOrder + 1
		New("Frame", {
			Size = UDim2.fromOffset(1, 9),
			BackgroundColor3 = Color3.fromRGB(46, 46, 46),
			BorderSizePixel = 0,
			LayoutOrder = WatermarkOrder,
		}, WatermarkBody)
	end

	if LogoImage ~= "" then
		WatermarkOrder = WatermarkOrder + 1
		New("ImageLabel", {
			Size = UDim2.fromOffset(15, 15),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Image = LogoImage,
			ScaleType = Enum.ScaleType.Fit,
			LayoutOrder = WatermarkOrder,
		}, WatermarkBody)
	end
	WatermarkPart(LinkText, Theme.Accent)
	WatermarkSeparator()
	local WatermarkFps = WatermarkPart("0 FPS")
	WatermarkSeparator()
	local WatermarkPing = WatermarkPart("0 Ping")
	WatermarkSeparator()
	local WatermarkClock = WatermarkPart(os.date("%A, %H:%M"))

	local FpsFrames = 0
	local FpsTime = 0
	local WatermarkLoop = RunService.RenderStepped:Connect(function(Delta)
		FpsFrames = FpsFrames + 1
		FpsTime = FpsTime + Delta
		if FpsTime < 0.5 then return end
		local Fps = math.floor(FpsFrames / FpsTime + 0.5)
		FpsFrames = 0
		FpsTime = 0
		if not WatermarkWrap.Visible then return end
		local Ping = 0
		pcall(function()
			Ping = math.floor(StatsService.Network.ServerStatsItem["Data Ping"]:GetValue() + 0.5)
		end)
		WatermarkFps.Text = Fps .. " FPS"
		WatermarkPing.Text = Ping .. " Ping"
		WatermarkClock.Text = os.date("%A, %H:%M")
	end)
	NotifyGui.Destroying:Connect(function()
		WatermarkLoop:Disconnect()
	end)

	local NotifyOrder = 0
	local NotifyActive = {}

	local function Notify(Opts)
		NotifyOrder = NotifyOrder + 1
		local Duration = Opts.Duration or 4
		local Closed = false
		local Tint = Opts.Color or Theme.Accent
		local Slot = New("Frame", {
			Size = UDim2.new(1, 0, 0, 0),
			BackgroundTransparency = 1,
			LayoutOrder = NotifyOrder,
		}, NotifyHolder)
		Pad(Slot, 0, 0, 0, 6)
		local Card = New("Frame", {
			Position = UDim2.new(0, -28, 0, 0),
			Size = UDim2.fromOffset(0, 0),
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundTransparency = 1,
		}, Slot)
		Glow(Card, Tint, 0.88)
		local Bg = New("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = Theme.Notice,
			BorderSizePixel = 0,
			ZIndex = 2,
		}, Card)
		Corner(Bg, Round.Section)
		Stroke(Bg, Theme.Stroke, 1)
		local Body = New("Frame", {
			Size = UDim2.fromOffset(0, 0),
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundTransparency = 1,
			ZIndex = 3,
		}, Card)
		Pad(Body, 9, 6, 9, 7)
		local BodyLayout = List(Body, 6)
		BodyLayout.FillDirection = Enum.FillDirection.Horizontal
		BodyLayout.VerticalAlignment = Enum.VerticalAlignment.Top
		if Opts.Icon then
			local NotifyIcon = Icon(Body, Opts.Icon, 11, Tint)
			NotifyIcon.LayoutOrder = 1
		end
		local Content = New("Frame", {
			Size = UDim2.fromOffset(0, 0),
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundTransparency = 1,
			LayoutOrder = 2,
		}, Body)
		List(Content, 2)
		local TitleLabel = Label(Content, tostring(Opts.Title or ""), 10, Theme.Text)
		TitleLabel.RichText = true
		TitleLabel.TextWrapped = true
		TitleLabel.AutomaticSize = Enum.AutomaticSize.XY
		TitleLabel.Size = UDim2.fromOffset(0, 0)
		TitleLabel.LayoutOrder = 1
		New("UISizeConstraint", { MaxSize = Vector2.new(170, math.huge) }, TitleLabel)
		if Opts.Text and Opts.Text ~= "" then
			local TextLabel = Label(Content, tostring(Opts.Text), 9, Theme.Dim)
			TextLabel.RichText = true
			TextLabel.TextWrapped = true
			TextLabel.AutomaticSize = Enum.AutomaticSize.XY
			TextLabel.Size = UDim2.fromOffset(0, 0)
			TextLabel.TextYAlignment = Enum.TextYAlignment.Top
			TextLabel.LayoutOrder = 2
			New("UISizeConstraint", { MaxSize = Vector2.new(170, math.huge) }, TextLabel)
		end
		local Hit = New("TextButton", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Text = "",
			ZIndex = 5,
		}, Card)
		Fade(Card, 1, 0)

		local function Close()
			if Closed then return end
			Closed = true
			local At = table.find(NotifyActive, Close)
			if At then table.remove(NotifyActive, At) end
			local Height = Slot.AbsoluteSize.Y / math.max(NotifyScale.Scale, 0.01)
			Slot.AutomaticSize = Enum.AutomaticSize.None
			Slot.Size = UDim2.new(1, 0, 0, Height)
			Fade(Card, 1, 0.35)
			Ease(Card, { Position = UDim2.new(0, -28, 0, 0) }, 0.35, Enum.EasingStyle.Quint)
			task.delay(0.2, function()
				local Motion = Ease(Slot, { Size = UDim2.new(1, 0, 0, 0) }, 0.4, Enum.EasingStyle.Quint)
				Motion.Completed:Connect(function()
					Slot:Destroy()
				end)
			end)
		end

		Hit.MouseButton1Click:Connect(Close)
		table.insert(NotifyActive, Close)
		while #NotifyActive > 8 do
			NotifyActive[1]()
		end

		task.spawn(function()
			RunService.RenderStepped:Wait()
			if Closed then return end
			local Height = Card.AbsoluteSize.Y / math.max(NotifyScale.Scale, 0.01) + 6
			Fade(Card, 0, 0.55)
			Ease(Card, { Position = UDim2.new(0, 0, 0, 0) }, 0.55, Enum.EasingStyle.Quint)
			local Motion = Ease(Slot, { Size = UDim2.new(1, 0, 0, Height) }, 0.45, Enum.EasingStyle.Quint)
			Motion.Completed:Connect(function(State)
				if Closed or State ~= Enum.PlaybackState.Completed then return end
				Slot.AutomaticSize = Enum.AutomaticSize.Y
				Slot.Size = UDim2.new(1, 0, 0, 0)
			end)
			task.delay(Duration, Close)
		end)

		return Close
	end

	local Main = New("Frame", {
		Name = "Main",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(434, 420),
		BackgroundColor3 = Theme.Window,
		BorderSizePixel = 0,
		ClipsDescendants = true,
	}, Gui)
	Corner(Main, Round.Window)
	Stroke(Main, Color3.fromRGB(22, 22, 22), 1)
	local Scale = New("UIScale", {}, Main)
	local MainCover = New("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Theme.Window,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		ZIndex = 100,
	}, Main)
	Corner(MainCover, Round.Window)

	local OpenFactor = New("NumberValue", { Value = 0.94 }, Gui)
	local ScaleBase = 1

	local function ApplyScale()
		CurrentScale = ScaleBase * OpenFactor.Value
		Scale.Scale = CurrentScale
	end
	OpenFactor.Changed:Connect(ApplyScale)

	local function UpdateScale()
		local View = Gui.AbsoluteSize
		local HeightFraction = IsMobile and 0.9 or 0.64
		local Value = math.min(View.X * 0.94 / 434, View.Y * HeightFraction / 420)
		ScaleBase = math.clamp(Value, 0.35, 4)
		NotifyScale.Scale = math.clamp(ScaleBase, 0.7, 1.3)
		ApplyScale()
	end
	Gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateScale)

	local WindowVisible = false
	local WindowToken = 0
	local ToggleHook = function() end

	local function SetVisible(Value)
		if WindowVisible == Value then return end
		WindowVisible = Value
		ToggleHook(Value)
		WindowToken = WindowToken + 1
		local Mine = WindowToken
		if Value then
			Gui.Enabled = true
			MainCover.Visible = true
			local Reveal = Ease(MainCover, { BackgroundTransparency = 1 }, 0.5, Enum.EasingStyle.Quint)
			Reveal.Completed:Connect(function(State)
				if Mine == WindowToken and State == Enum.PlaybackState.Completed then MainCover.Visible = false end
			end)
			Ease(OpenFactor, { Value = 1 }, 0.65, Enum.EasingStyle.Quint)
		else
			MainCover.Visible = true
			Ease(MainCover, { BackgroundTransparency = 0 }, 0.28, Enum.EasingStyle.Quad)
			local Motion = Ease(OpenFactor, { Value = 0.96 }, 0.32, Enum.EasingStyle.Quint)
			Motion.Completed:Connect(function(State)
				if Mine == WindowToken and State == Enum.PlaybackState.Completed then Gui.Enabled = false end
			end)
		end
	end

	local ToggleButton = New("TextButton", {
		Position = UDim2.new(1, -122, 1, -58),
		Size = UDim2.fromOffset(108, 38),
		BackgroundColor3 = Theme.Notice,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
		Visible = UserInputService.TouchEnabled,
	}, NotifyGui)
	Corner(ToggleButton, Round.Section)
	local ToggleStroke = Stroke(ToggleButton, Theme.Stroke, 1)
	local PressScale = New("UIScale", {}, ToggleButton)
	local ToggleLogo = New("ImageLabel", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 7, 0.5, 0),
		Size = UDim2.fromOffset(24, 24),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Image = LogoImage,
		ScaleType = Enum.ScaleType.Fit,
		ImageTransparency = 0.35,
	}, ToggleButton)
	local ToggleTitle = Label(ToggleButton, BrandMarkup, 10, Theme.Text, FontBold)
	ToggleTitle.RichText = true
	ToggleTitle.TextTruncate = Enum.TextTruncate.AtEnd
	ToggleTitle.Position = UDim2.new(0, 37, 0, 6)
	ToggleTitle.Size = UDim2.new(1, -41, 0, 13)
	local ToggleSub = Label(ToggleButton, GameInfo, 8, Theme.Dim)
	ToggleSub.TextTruncate = Enum.TextTruncate.AtEnd
	ToggleSub.Position = UDim2.new(0, 37, 0, 20)
	ToggleSub.Size = UDim2.new(1, -41, 0, 11)

	ToggleHook = function(Value)
		Tween(ToggleStroke, { Color = Value and Theme.AccentLine or Theme.Stroke }, 0.35)
		Tween(ToggleLogo, { ImageTransparency = Value and 0 or 0.35 }, 0.35)
	end

	local TogglePressing = false
	local ToggleDragged = false
	local ToggleStart
	local TogglePosition

	ToggleButton.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
			TogglePressing = true
			ToggleDragged = false
			ToggleStart = Pointer(Input)
			TogglePosition = ToggleButton.Position
			Ease(PressScale, { Scale = 0.92 }, 0.18, Enum.EasingStyle.Quart)
		end
	end)

	UserInputService.InputChanged:Connect(function(Input)
		if not TogglePressing then return end
		if Input.UserInputType ~= Enum.UserInputType.MouseMovement and Input.UserInputType ~= Enum.UserInputType.Touch then return end
		local Delta = Pointer(Input) - ToggleStart
		if not ToggleDragged and Delta.Magnitude > 8 then ToggleDragged = true end
		if ToggleDragged then
			ToggleButton.Position = UDim2.new(TogglePosition.X.Scale, TogglePosition.X.Offset + Delta.X, TogglePosition.Y.Scale, TogglePosition.Y.Offset + Delta.Y)
		end
	end)

	UserInputService.InputEnded:Connect(function(Input)
		if not TogglePressing then return end
		if Input.UserInputType ~= Enum.UserInputType.MouseButton1 and Input.UserInputType ~= Enum.UserInputType.Touch then return end
		TogglePressing = false
		Ease(PressScale, { Scale = 1 }, 0.35, Enum.EasingStyle.Quint)
		if ToggleDragged then
			local View = NotifyGui.AbsoluteSize
			local Position = ToggleButton.AbsolutePosition
			local Size = ToggleButton.AbsoluteSize
			local X = math.clamp(Position.X, 8, math.max(View.X - Size.X - 8, 8))
			local Y = math.clamp(Position.Y, 8, math.max(View.Y - Size.Y - 8, 8))
			Ease(ToggleButton, { Position = UDim2.fromOffset(X, Y) }, 0.4, Enum.EasingStyle.Quint)
		else
			SetVisible(not WindowVisible)
		end
	end)

	local Sidebar = New("Frame", {
		Size = UDim2.new(0, 128, 1, 0),
		BackgroundColor3 = Theme.Sidebar,
		BorderSizePixel = 0,
	}, Main)
	Corner(Sidebar, Round.Sidebar)
	New("Frame", {
		Position = UDim2.new(1, -10, 0, 0),
		Size = UDim2.new(0, 10, 1, 0),
		BackgroundColor3 = Theme.Sidebar,
		BorderSizePixel = 0,
	}, Sidebar)
	New("Frame", {
		Position = UDim2.new(1, -1, 0, 0),
		Size = UDim2.new(0, 1, 1, 0),
		BackgroundColor3 = Theme.Stroke,
		BorderSizePixel = 0,
	}, Sidebar)

	local Brand = New("Frame", {
		Size = UDim2.new(1, 0, 0, 40),
		BackgroundTransparency = 1,
	}, Sidebar)
	local Logo = New("ImageLabel", {
		Position = UDim2.new(0, 7, 0, 10),
		Size = UDim2.fromOffset(25, 25),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Image = LogoImage,
		ScaleType = Enum.ScaleType.Fit,
	}, Brand)
	local BrandTitle = Label(Brand, BrandMarkup, 10, Theme.Text, FontBold)
	BrandTitle.RichText = true
	BrandTitle.Position = UDim2.new(0, 35, 0, 13)
	BrandTitle.Size = UDim2.new(1, -40, 0, 13)
	local BrandSub = Label(Brand, GameInfo, 8, Theme.Dim)
	BrandSub.Position = UDim2.new(0, 35, 0, 27)
	BrandSub.Size = UDim2.new(1, -40, 0, 10)
	New("Frame", {
		Position = UDim2.new(0, 10, 0, 40),
		Size = UDim2.new(1, -21, 0, 1),
		BackgroundColor3 = Theme.Divider,
		BorderSizePixel = 0,
	}, Sidebar)

	local TabList = New("ScrollingFrame", {
		Position = UDim2.new(0, 0, 0, 41),
		Size = UDim2.new(1, -1, 1, Config.Footer == true and -82 or -46),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 0,
		CanvasSize = UDim2.new(),
		ScrollingDirection = Enum.ScrollingDirection.Y,
	}, Sidebar)

	local Footer = New("Frame", {
		Visible = Config.Footer == true,
		Position = UDim2.new(0, 8, 1, -37),
		Size = UDim2.new(1, -17, 0, 31),
		BackgroundColor3 = Color3.fromRGB(19, 19, 19),
		BorderSizePixel = 0,
	}, Sidebar)
	Corner(Footer, Round.Footer)
	local Avatar = New("ImageLabel", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 6, 0.5, 0),
		Size = UDim2.fromOffset(17, 17),
		BackgroundColor3 = Theme.Item,
		BorderSizePixel = 0,
	}, Footer)
	Corner(Avatar, Round.Full)
	if Anonymous then
		local Mask = Icon(Avatar, "user", 10, Theme.Dim)
		Mask.AnchorPoint = Vector2.new(0.5, 0.5)
		Mask.Position = UDim2.fromScale(0.5, 0.5)
	else
		task.spawn(function()
			local ok, Image = pcall(function()
				return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
			end)
			if ok then Avatar.Image = Image end
		end)
	end
	local FooterTitle = Label(Footer, FooterName, 9, Theme.Text)
	FooterTitle.Position = UDim2.new(0, 29, 0, 3)
	FooterTitle.Size = UDim2.new(1, -32, 0, 12)
	local FooterSub = Label(Footer, FooterState, 7, Theme.Dim)
	FooterSub.Position = UDim2.new(0, 29, 0, 15)
	FooterSub.Size = UDim2.new(1, -32, 0, 10)

	local TopDrag = New("Frame", {
		Position = UDim2.new(0, 128, 0, 0),
		Size = UDim2.new(1, -128, 0, 36),
		BackgroundTransparency = 1,
	}, Main)
	Drag(TopDrag, Main)
	Drag(Brand, Main)

	local HeaderIcon = Icon(Main, "layers", 11, Theme.Accent)
	HeaderIcon.AnchorPoint = Vector2.new(0, 0.5)
	HeaderIcon.Position = UDim2.new(0, 140, 0, 17)
	local HeaderTitle = Label(Main, "", 10, Theme.Text)
	HeaderTitle.Position = UDim2.new(0, 160, 0, 8)
	HeaderTitle.Size = UDim2.fromOffset(110, 18)
	local HeaderSub = Label(Main, "", 8, Theme.Dim)
	HeaderSub.Position = UDim2.new(0, 160, 0, 19)
	HeaderSub.Size = UDim2.fromOffset(134, 11)
	HeaderSub.TextTruncate = Enum.TextTruncate.AtEnd

	local function ApplyHeader(Tab)
		ApplyIcon(HeaderIcon, Tab.Icon)
		HeaderTitle.Text = Tab.Name
		local Has = type(Tab.Description) == "string" and Tab.Description ~= ""
		HeaderSub.Text = Has and Tab.Description or ""
		HeaderTitle.Position = Has and UDim2.new(0, 160, 0, 6) or UDim2.new(0, 160, 0, 8)
		HeaderTitle.Size = Has and UDim2.fromOffset(134, 12) or UDim2.fromOffset(110, 18)
	end

	local SearchHolder = New("Frame", {
		Position = UDim2.new(0, 300, 0, 7),
		Size = UDim2.fromOffset(98, 21),
		BackgroundColor3 = Color3.fromRGB(18, 18, 18),
		BorderSizePixel = 0,
	}, Main)
	Corner(SearchHolder, Round.Search)
	Stroke(SearchHolder, Theme.Stroke, 1)
	local SearchIcon = Icon(SearchHolder, "search", 9, Theme.Dim)
	SearchIcon.AnchorPoint = Vector2.new(0, 0.5)
	SearchIcon.Position = UDim2.new(0, 6, 0.5, 0)
	local SearchBox = New("TextBox", {
		Position = UDim2.new(0, 19, 0, 0),
		Size = UDim2.new(1, -22, 1, 0),
		BackgroundTransparency = 1,
		Text = "",
		PlaceholderText = "Search...",
		PlaceholderColor3 = Theme.Dim,
		TextColor3 = Theme.Text,
		TextSize = 9,
		Font = FontMain,
		TextXAlignment = Left,
		ClearTextOnFocus = false,
	}, SearchHolder)

	local FolderButton = New("TextButton", {
		Visible = false,
		Position = UDim2.new(0, 407, 0, 7),
		Size = UDim2.fromOffset(21, 21),
		BackgroundColor3 = Color3.fromRGB(18, 18, 18),
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
	}, Main)
	Corner(FolderButton, Round.Folder)
	Stroke(FolderButton, Theme.Stroke, 1)
	local FolderIcon = Icon(FolderButton, "folder", 10, Theme.Dim)
	FolderIcon.AnchorPoint = Vector2.new(0.5, 0.5)
	FolderIcon.Position = UDim2.fromScale(0.5, 0.5)
	local AutoLoadStart = function() end
	local ConfigBuilt = false

	local function BuildConfigManager()
		FolderButton.Visible = true
		local HasFileSystem = type(writefile) == "function" and type(readfile) == "function" and type(isfolder) == "function" and type(makefolder) == "function" and type(listfiles) == "function"
		local ConfigOpen = false
		local SelectedConfig = nil

		local function ConfigPath(Name)
			return ConfigFolder .. "/" .. Name .. ".json"
		end

		local function CleanName(Text)
			local Name = string.gsub(Text or "", "[^%w%-_ ]", "")
			Name = string.match(Name, "^%s*(.-)%s*$")
			return Name
		end

		local function EncodeValue(Value)
			if Value == nil then return { __t = "None" } end
			if typeof(Value) == "Color3" then return { __t = "Color3", R = Value.R, G = Value.G, B = Value.B } end
			if typeof(Value) == "EnumItem" then return { __t = "Enum", Name = Value.Name, Kind = tostring(Value.EnumType) } end
			if type(Value) == "table" then return { __t = "List", Items = Value } end
			return Value
		end

		local function DecodeValue(Value)
			if type(Value) ~= "table" then return Value, true end
			if Value.__t == "Color3" then return Color3.new(Value.R, Value.G, Value.B), true end
			if Value.__t == "Enum" then
				local ok, Key = pcall(function() return Enum[Value.Kind or "KeyCode"][Value.Name] end)
				if ok then return Key, true end
				return nil, false
			end
			if Value.__t == "None" then return nil, true end
			if Value.__t == "List" and type(Value.Items) == "table" then return Value.Items, true end
			return nil, false
		end

		local AutoLoadFile = ConfigFolder .. "/autoload.txt"

		local function GetAutoLoad()
			if not HasFileSystem or type(isfile) ~= "function" then return nil end
			local ok, Name = pcall(function()
				if not isfile(AutoLoadFile) then return nil end
				return readfile(AutoLoadFile)
			end)
			if not ok or type(Name) ~= "string" then return nil end
			Name = CleanName(Name)
			if Name == "" then return nil end
			return Name
		end

		local function ListConfigs()
			local Result = {}
			if not HasFileSystem then return Result end
			pcall(function()
				if not isfolder(ConfigFolder) then makefolder(ConfigFolder) end
				for _, Path in ipairs(listfiles(ConfigFolder)) do
					local Name = string.match(Path, "([^/\\]+)%.json$")
					if Name then table.insert(Result, Name) end
				end
			end)
			table.sort(Result)
			return Result
		end

		local ConfigPopup = New("Frame", {
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -8, 0, 27),
			Size = UDim2.fromOffset(176, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = Theme.PanelBody,
			BorderSizePixel = 0,
			Visible = false,
			ZIndex = 20,
		}, Main)
		Corner(ConfigPopup, Round.Section)
		Stroke(ConfigPopup, Theme.Stroke, 1)
		List(ConfigPopup, 0)

		local ConfigBody = Panel(ConfigPopup, 1, "Config Manager", "folder", nil, true)

		local ConfigName = New("TextBox", {
			Size = UDim2.new(1, 0, 0, 19),
			BackgroundColor3 = Theme.Item,
			BorderSizePixel = 0,
			Text = "",
			PlaceholderText = "Config name",
			PlaceholderColor3 = Theme.Dim,
			TextColor3 = Theme.Text,
			TextSize = 9,
			Font = FontMain,
			TextXAlignment = Left,
			ClearTextOnFocus = false,
			LayoutOrder = 1,
		}, ConfigBody)
		Corner(ConfigName, Round.Dropdown)
		Stroke(ConfigName, Theme.DropStroke, 1)
		Pad(ConfigName, 6, 0, 6, 0)

		local ConfigList = New("ScrollingFrame", {
			Size = UDim2.new(1, 0, 0, 72),
			BackgroundColor3 = Theme.Item,
			BorderSizePixel = 0,
			ScrollBarThickness = 2,
			ScrollBarImageColor3 = Theme.Off,
			CanvasSize = UDim2.new(),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollingDirection = Enum.ScrollingDirection.Y,
			LayoutOrder = 2,
		}, ConfigBody)
		Corner(ConfigList, Round.Dropdown)
		Stroke(ConfigList, Theme.DropStroke, 1)
		List(ConfigList, 1)
		Pad(ConfigList, 0, 2, 0, 2)

		local ConfigStatus = Label(ConfigBody, "", 8, Theme.Dim)
		ConfigStatus.Size = UDim2.new(1, 0, 0, 10)
		ConfigStatus.LayoutOrder = 8

		local function SetStatus(Text, Color)
			ConfigStatus.Text = Text
			ConfigStatus.TextColor3 = Color or Theme.Dim
		end

		local RefreshConfigs

		local function Resolve()
			local Name = CleanName(ConfigName.Text)
			if Name == "" then Name = SelectedConfig end
			return Name
		end

		local function SaveConfig()
			if not HasFileSystem then SetStatus("No file access", Theme.Dim) return end
			local Name = CleanName(ConfigName.Text)
			if Name == "" then SetStatus("Enter a name", Theme.Dim) return end
			local Data = {}
			for Flag in pairs(Setters) do
				Data[Flag] = EncodeValue(Flags[Flag])
			end
			local ok = pcall(function()
				if not isfolder(ConfigFolder) then makefolder(ConfigFolder) end
				writefile(ConfigPath(Name), HttpService:JSONEncode(Data))
			end)
			SelectedConfig = Name
			SetStatus(ok and ("Saved " .. Name) or "Save failed", ok and Theme.Accent or Theme.Dim)
			if ok then Notify({ Title = "Config saved", Text = Name }) end
			RefreshConfigs()
		end

		local function LoadConfig()
			if not HasFileSystem then SetStatus("No file access", Theme.Dim) return end
			local Name = Resolve()
			if not Name then SetStatus("Select a config", Theme.Dim) return end
			local ok, Data = pcall(function()
				return HttpService:JSONDecode(readfile(ConfigPath(Name)))
			end)
			if not ok or type(Data) ~= "table" then SetStatus("Load failed", Theme.Dim) return end
			for Flag, Raw in pairs(Data) do
				local Setter = Setters[Flag]
				if Setter then
					local Value, Valid = DecodeValue(Raw)
					if Valid then pcall(Setter, Value) end
				end
			end
			SelectedConfig = Name
			SetStatus("Loaded " .. Name, Theme.Accent)
			Notify({ Title = "Config loaded", Text = Name })
			RefreshConfigs()
		end

		local function DeleteConfig()
			if not HasFileSystem or type(delfile) ~= "function" then SetStatus("No file access", Theme.Dim) return end
			local Name = Resolve()
			if not Name then SetStatus("Select a config", Theme.Dim) return end
			local ok = pcall(function() delfile(ConfigPath(Name)) end)
			if SelectedConfig == Name then SelectedConfig = nil end
			ConfigName.Text = ""
			SetStatus(ok and ("Deleted " .. Name) or "Delete failed", ok and Theme.Accent or Theme.Dim)
			if ok then Notify({ Title = "Config deleted", Text = Name }) end
			RefreshConfigs()
		end

		ActionButton(ConfigBody, 3, "Save", SaveConfig)
		ActionButton(ConfigBody, 4, "Load", LoadConfig)
		ActionButton(ConfigBody, 5, "Delete", DeleteConfig)

		local function SetAutoLoad()
			if not HasFileSystem then SetStatus("No file access", Theme.Dim) return end
			local Name = Resolve()
			if not Name then SetStatus("Select a config", Theme.Dim) return end
			if type(isfile) == "function" and not isfile(ConfigPath(Name)) then SetStatus("Save it first", Theme.Dim) return end
			local ok = pcall(function()
				if not isfolder(ConfigFolder) then makefolder(ConfigFolder) end
				writefile(AutoLoadFile, Name)
			end)
			SelectedConfig = Name
			SetStatus(ok and ("Auto load " .. Name) or "Auto load failed", ok and Theme.Accent or Theme.Dim)
			if ok then Notify({ Title = "Auto load set", Text = Name }) end
			RefreshConfigs()
		end

		local function RemoveAutoLoad()
			if not HasFileSystem or type(delfile) ~= "function" then SetStatus("No file access", Theme.Dim) return end
			local Current = GetAutoLoad()
			if not Current then SetStatus("No auto load set", Theme.Dim) return end
			local ok = pcall(function() delfile(AutoLoadFile) end)
			SetStatus(ok and "Auto load removed" or "Remove failed", ok and Theme.Accent or Theme.Dim)
			if ok then Notify({ Title = "Auto load removed", Text = Current }) end
			RefreshConfigs()
		end

		ActionButton(ConfigBody, 6, "Auto Load", SetAutoLoad)
		ActionButton(ConfigBody, 7, "Remove Auto Load", RemoveAutoLoad)

		function RefreshConfigs()
			for _, Child in ipairs(ConfigList:GetChildren()) do
				if Child:IsA("TextButton") then Child:Destroy() end
			end
			local AutoName = GetAutoLoad()
			for Index, Name in ipairs(ListConfigs()) do
				local Item = New("TextButton", {
					Size = UDim2.new(1, 0, 0, 14),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Text = Name == AutoName and (Name .. "  (auto)") or Name,
					TextSize = 9,
					Font = FontMain,
					TextColor3 = Name == SelectedConfig and Theme.Accent or Theme.Dim,
					TextXAlignment = Left,
					AutoButtonColor = false,
					LayoutOrder = Index,
				}, ConfigList)
				Pad(Item, 6, 0, 0, 0)
				Item.MouseButton1Click:Connect(function()
					SelectedConfig = Name
					ConfigName.Text = Name
					RefreshConfigs()
				end)
			end
		end

		local PopupRest = UDim2.new(1, -8, 0, 33)
		local PopupHidden = UDim2.new(1, -8, 0, 27)
		local PopupToken = 0

		local function SetConfigOpen(Value)
			ConfigOpen = Value
			PopupToken = PopupToken + 1
			local Mine = PopupToken
			Tween(FolderIcon, { ImageColor3 = Value and Theme.Accent or Theme.Dim }, 0.3)
			if Value then
				if not HasFileSystem then SetStatus("No file access", Theme.Dim) else SetStatus("") end
				RefreshConfigs()
				if not ConfigPopup.Visible then
					Fade(ConfigPopup, 1, 0)
					ConfigPopup.Position = PopupHidden
					ConfigPopup.Visible = true
				end
				Fade(ConfigPopup, 0, 0.45)
				Ease(ConfigPopup, { Position = PopupRest }, 0.45, Enum.EasingStyle.Quint)
			else
				Fade(ConfigPopup, 1, 0.28)
				local Motion = Ease(ConfigPopup, { Position = PopupHidden }, 0.28, Enum.EasingStyle.Quint)
				Motion.Completed:Connect(function(State)
					if Mine == PopupToken and State == Enum.PlaybackState.Completed then ConfigPopup.Visible = false end
				end)
			end
		end

		FolderButton.MouseButton1Click:Connect(function()
			SetConfigOpen(not ConfigOpen)
		end)
		FolderButton.MouseEnter:Connect(function()
			if not ConfigOpen then Tween(FolderIcon, { ImageColor3 = Theme.Text }) end
		end)
		FolderButton.MouseLeave:Connect(function()
			if not ConfigOpen then Tween(FolderIcon, { ImageColor3 = Theme.Dim }) end
		end)

		AutoLoadStart = function()
			local AutoConfig = GetAutoLoad()
			if AutoConfig then
				SelectedConfig = AutoConfig
				task.delay(0.6, function()
					LoadConfig()
				end)
			end
		end
	end

	local TabIndicator = New("Frame", {
		Position = UDim2.new(0, 10, 0, 4),
		Size = UDim2.new(1, -20, 0, 25),
		BackgroundColor3 = Theme.Item,
		BorderSizePixel = 0,
		Visible = false,
	}, TabList)
	Corner(TabIndicator, Round.Button)

	local CurrentTab
	local PageRest = UDim2.new(0, 140, 0, 36)
	local PageShift = UDim2.new(0, 140, 0, 44)
	local PageToken = 0
	local PageCover = New("Frame", {
		Position = UDim2.new(0, 140, 0, 36),
		Size = UDim2.new(0, 287, 1, -36),
		BackgroundColor3 = Theme.Window,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Visible = false,
		ZIndex = 10,
	}, Main)

	local function Select(Tab, Instant)
		if Tab == CurrentTab and not Instant then return end
		CurrentTab = Tab
		for _, Other in ipairs(Tabs) do
			local On = Other == Tab
			Other.Active = On
			Tween(Other.Text, { TextColor3 = On and Theme.Text or Theme.Dim }, 0.3)
			Tween(Other.IconObject, { ImageColor3 = On and Theme.Accent or Theme.Dim }, 0.3)
		end
		local Goal = UDim2.new(0, 10, 0, Tab.Top)
		if Instant then
			TabIndicator.Position = Goal
			TabIndicator.Visible = true
			PageToken = PageToken + 1
			PageCover.Visible = false
			for _, Other in ipairs(Tabs) do
				Other.Page.Visible = Other == Tab
				Other.Page.Position = PageRest
			end
			ApplyHeader(Tab)
			return
		end
		Ease(TabIndicator, { Position = Goal }, 0.5, Enum.EasingStyle.Quint)
		PageToken = PageToken + 1
		local Mine = PageToken
		PageCover.Visible = true
		Ease(PageCover, { BackgroundTransparency = 0 }, 0.12, Enum.EasingStyle.Quad)
		task.delay(0.12, function()
			if Mine ~= PageToken then return end
			for _, Other in ipairs(Tabs) do
				Other.Page.Visible = false
			end
			local Page = Tab.Page
			Page.Position = PageShift
			Page.Visible = true
			Ease(Page, { Position = PageRest }, 0.5, Enum.EasingStyle.Quint)
			local Reveal = Ease(PageCover, { BackgroundTransparency = 1 }, 0.4, Enum.EasingStyle.Quad)
			Reveal.Completed:Connect(function(State)
				if Mine == PageToken and State == Enum.PlaybackState.Completed then PageCover.Visible = false end
			end)
		end)
		Ease(HeaderTitle, { TextTransparency = 1 }, 0.12, Enum.EasingStyle.Quad)
		Ease(HeaderSub, { TextTransparency = 1 }, 0.12, Enum.EasingStyle.Quad)
		Ease(HeaderIcon, { ImageTransparency = 1 }, 0.12, Enum.EasingStyle.Quad)
		task.delay(0.12, function()
			if CurrentTab ~= Tab then return end
			ApplyHeader(Tab)
			Ease(HeaderTitle, { TextTransparency = 0 }, 0.3, Enum.EasingStyle.Quint)
			Ease(HeaderSub, { TextTransparency = 0 }, 0.3, Enum.EasingStyle.Quint)
			Ease(HeaderIcon, { ImageTransparency = 0 }, 0.3, Enum.EasingStyle.Quint)
		end)
	end

	local TabMethods = {}
	TabMethods.__index = TabMethods

	local SubMethods = {}
	SubMethods.__index = SubMethods

	function SubMethods:Section(Opts)
		return AddSection(self, true, Opts)
	end

	function TabMethods:Section(Opts)
		if #self.Subs > 0 then error("This tab uses sub tabs, add sections to a sub tab", 2) end
		return AddSection(self, false, Opts)
	end

	local function PaintSub(Sub, On, Instant)
		local Goals = {
			{ Sub.Pill, { BackgroundTransparency = On and 0 or 1 } },
			{ Sub.Text, { TextColor3 = On and Theme.Text or Theme.Dim } },
		}
		if Sub.IconObject then
			table.insert(Goals, { Sub.IconObject, { ImageColor3 = On and Theme.Accent or Theme.Dim } })
		end
		for _, Entry in ipairs(Goals) do
			if Instant then
				for Key, Value in pairs(Entry[2]) do Entry[1][Key] = Value end
			else
				Tween(Entry[1], Entry[2], 0.3)
			end
		end
	end

	function TabMethods:SelectSub(Sub, Instant)
		if self.CurrentSub == Sub and not Instant then return end
		self.CurrentSub = Sub
		self.SubToken = (self.SubToken or 0) + 1
		local Mine = self.SubToken
		local Cover = self.SubCover
		for _, Other in ipairs(self.Subs) do
			PaintSub(Other, Other == Sub, Instant)
		end
		if Instant then
			Cover.Visible = false
			for _, Other in ipairs(self.Subs) do
				Other.Frame.Position = UDim2.fromScale(0, 0)
				Other.Frame.Visible = Other == Sub
			end
			return
		end
		Cover.Visible = true
		Ease(Cover, { BackgroundTransparency = 0 }, 0.1, Enum.EasingStyle.Quad)
		task.delay(0.1, function()
			if Mine ~= self.SubToken then return end
			for _, Other in ipairs(self.Subs) do
				Other.Frame.Visible = false
			end
			Sub.Frame.Position = UDim2.new(0, 0, 0, 8)
			Sub.Frame.Visible = true
			Ease(Sub.Frame, { Position = UDim2.new(0, 0, 0, 0) }, 0.45, Enum.EasingStyle.Quint)
			local Reveal = Ease(Cover, { BackgroundTransparency = 1 }, 0.35, Enum.EasingStyle.Quad)
			Reveal.Completed:Connect(function(State)
				if Mine == self.SubToken and State == Enum.PlaybackState.Completed then Cover.Visible = false end
			end)
		end)
	end

	function TabMethods:SubTab(Opts)
		Opts = Opts or {}
		local Tab = self
		if Tab.Columns then error("This tab already holds sections, use either sections or sub tabs", 2) end
		if not Tab.SubBar then
			Tab.SubBar = New("Frame", {
				Size = UDim2.new(1, 0, 0, 22),
				BackgroundTransparency = 1,
				ZIndex = 2,
			}, Tab.Page)
			local Row = List(Tab.SubBar, 5)
			Row.FillDirection = Enum.FillDirection.Horizontal
			Tab.SubCover = New("Frame", {
				Position = UDim2.new(0, 0, 0, 28),
				Size = UDim2.new(1, 0, 1, -28),
				BackgroundColor3 = Theme.Window,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Visible = false,
				ZIndex = 10,
			}, Tab.Page)
		end
		local Index = #Tab.Subs + 1
		local Pill = New("TextButton", {
			Size = UDim2.fromOffset(0, 22),
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundColor3 = Theme.PanelBody,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Text = "",
			AutoButtonColor = false,
			LayoutOrder = Index,
		}, Tab.SubBar)
		Corner(Pill, Round.Pill)
		Pad(Pill, 8, 0, 9, 0)
		local Inner = New("Frame", {
			Size = UDim2.fromOffset(0, 22),
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundTransparency = 1,
		}, Pill)
		local Layout = List(Inner, 5)
		Layout.FillDirection = Enum.FillDirection.Horizontal
		Layout.VerticalAlignment = Enum.VerticalAlignment.Center
		local PillIcon
		if Opts.Icon then
			PillIcon = Icon(Inner, Opts.Icon, 10, Theme.Dim)
			PillIcon.LayoutOrder = 1
		end
		local PillText = Label(Inner, tostring(Opts.Name or "Example"), 9, Theme.Dim)
		PillText.AutomaticSize = Enum.AutomaticSize.X
		PillText.Size = UDim2.fromOffset(0, 22)
		PillText.LayoutOrder = 2
		local Frame = New("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Visible = false,
		}, Tab.Page)
		local Sub = setmetatable({
			Name = tostring(Opts.Name or "Example"),
			Frame = Frame,
			Pill = Pill,
			Text = PillText,
			IconObject = PillIcon,
		}, SubMethods)
		table.insert(Tab.Subs, Sub)
		local Hover = Color3.fromRGB(150, 150, 150)
		Pill.MouseEnter:Connect(function()
			if Tab.CurrentSub == Sub then return end
			Tween(PillText, { TextColor3 = Hover }, 0.2)
			if PillIcon then Tween(PillIcon, { ImageColor3 = Hover }, 0.2) end
		end)
		Pill.MouseLeave:Connect(function()
			if Tab.CurrentSub == Sub then return end
			Tween(PillText, { TextColor3 = Theme.Dim }, 0.25)
			if PillIcon then Tween(PillIcon, { ImageColor3 = Theme.Dim }, 0.25) end
		end)
		Pill.MouseButton1Click:Connect(function()
			Tab:SelectSub(Sub)
		end)
		if Index == 1 then Tab:SelectSub(Sub, true) end
		return Sub
	end

	local TabCursor = 4
	local TabCategory

	local function CreateTab(Name, IconName, Category, Description)
		local Index = #Tabs + 1
		if Category ~= nil and Category ~= TabCategory then
			if TabCategory ~= nil or Index > 1 then
				TabCursor = TabCursor + 2
				New("Frame", {
					Position = UDim2.new(0, 10, 0, TabCursor),
					Size = UDim2.new(1, -21, 0, 1),
					BackgroundColor3 = Theme.Divider,
					BorderSizePixel = 0,
				}, TabList)
				TabCursor = TabCursor + 8
			end
			TabCategory = Category
			local Head = Label(TabList, tostring(Category), 9, Theme.Dim)
			Head.Position = UDim2.new(0, 14, 0, TabCursor)
			Head.Size = UDim2.new(1, -28, 0, 12)
			TabCursor = TabCursor + 17
		end
		local Top = TabCursor
		TabCursor = TabCursor + 32
		TabList.CanvasSize = UDim2.fromOffset(0, TabCursor)
		local Button = New("TextButton", {
			Position = UDim2.new(0, 10, 0, Top),
			Size = UDim2.new(1, -20, 0, 25),
			BackgroundTransparency = 1,
			Text = "",
			AutoButtonColor = false,
			LayoutOrder = Index,
		}, TabList)
		local TabIcon = Icon(Button, IconName, 11, Theme.Dim)
		TabIcon.AnchorPoint = Vector2.new(0, 0.5)
		TabIcon.Position = UDim2.new(0, 4, 0.5, 0)
		local TabText = Label(Button, Name, 10, Theme.Dim)
		TabText.Position = UDim2.new(0, 19, 0, 0)
		TabText.Size = UDim2.new(1, -19, 1, 0)
		local Page = New("Frame", {
			Position = UDim2.new(0, 140, 0, 36),
			Size = UDim2.new(0, 287, 1, -36),
			BackgroundTransparency = 1,
			ClipsDescendants = true,
			Visible = false,
		}, Main)
		local Tab = setmetatable({
			Name = Name,
			Icon = IconName,
			Description = Description,
			Category = Category,
			Index = Index,
			Top = Top,
			Button = Button,
			Text = TabText,
			IconObject = TabIcon,
			Page = Page,
			Frame = Page,
			Subs = {},
		}, TabMethods)
		table.insert(Tabs, Tab)
		local HoverTint = Color3.fromRGB(150, 150, 150)
		Button.MouseEnter:Connect(function()
			if Tab.Active then return end
			Tween(TabText, { TextColor3 = HoverTint }, 0.2)
			Tween(TabIcon, { ImageColor3 = HoverTint }, 0.2)
		end)
		Button.MouseLeave:Connect(function()
			if Tab.Active then return end
			Tween(TabText, { TextColor3 = Theme.Dim }, 0.25)
			Tween(TabIcon, { ImageColor3 = Theme.Dim }, 0.25)
		end)
		Button.MouseButton1Click:Connect(function()
			Select(Tab)
		end)
		if Index == 1 then Select(Tab, true) end
		return Tab
	end

	function Window:Tab(Opts)
		Opts = Opts or {}
		return CreateTab(tostring(Opts.Name or "Example"), Opts.Icon or "layers", Opts.Category, Opts.Description)
	end

	local HomeBuilt = false

	function Window:HomeManager()
		if HomeBuilt then return end
		HomeBuilt = true
		local HomeTab = CreateTab("Home", "home", nil, "Player and game information")
		local HomePage = HomeTab.Page
		local HomeLeft = Column(HomePage, 0)
		local HomeRight = Column(HomePage, 148)

		local function InfoRow(Parent, Order, Name, Value, Split)
			local Row = New("Frame", {
				Size = UDim2.new(1, 0, 0, 12),
				BackgroundTransparency = 1,
				LayoutOrder = Order,
			}, Parent)
			local Key = Label(Row, Name, 9, Theme.Dim)
			Key.Size = UDim2.new(Split or 0.4, 0, 1, 0)
			local Val = Label(Row, Value, 9, Theme.Text, FontMain, Right)
			Val.AnchorPoint = Vector2.new(1, 0)
			Val.Position = UDim2.new(1, 0, 0, 0)
			Val.Size = UDim2.new(1 - (Split or 0.4), 0, 1, 0)
			Val.TextTruncate = Enum.TextTruncate.AtEnd
			return Val
		end

		local PlayerPanel = Panel(HomeLeft, 1, "Player", "user", nil, true)
		local PlayerCard = New("Frame", {
			Size = UDim2.new(1, 0, 0, 52),
			BackgroundTransparency = 1,
			LayoutOrder = 1,
		}, PlayerPanel)
		local PlayerAvatar = New("ImageLabel", {
			Size = UDim2.fromOffset(52, 52),
			BackgroundColor3 = Theme.Item,
			BorderSizePixel = 0,
			ScaleType = Enum.ScaleType.Crop,
		}, PlayerCard)
		Corner(PlayerAvatar, Round.Button)
		Stroke(PlayerAvatar, Theme.Stroke, 1)
		if Anonymous then
			local Mask = Icon(PlayerAvatar, "user", 22, Theme.Dim)
			Mask.AnchorPoint = Vector2.new(0.5, 0.5)
			Mask.Position = UDim2.fromScale(0.5, 0.5)
		else
			task.spawn(function()
				local ok, Image = pcall(function()
					return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
				end)
				if ok then PlayerAvatar.Image = Image end
			end)
		end
		local PlayerName = Label(PlayerCard, Anonymous and "Anonymous" or LocalPlayer.DisplayName, 10, Theme.Text, FontBold)
		PlayerName.Position = UDim2.new(0, 60, 0, 6)
		PlayerName.Size = UDim2.new(1, -60, 0, 13)
		PlayerName.TextTruncate = Enum.TextTruncate.AtEnd
		local PlayerUser = Label(PlayerCard, Anonymous and "@hidden" or ("@" .. LocalPlayer.Name), 9, Theme.Dim)
		PlayerUser.Position = UDim2.new(0, 60, 0, 21)
		PlayerUser.Size = UDim2.new(1, -60, 0, 12)
		PlayerUser.TextTruncate = Enum.TextTruncate.AtEnd
		local PlayerId = Label(PlayerCard, Anonymous and "ID hidden" or ("ID " .. LocalPlayer.UserId), 8, Theme.Dim)
		PlayerId.Position = UDim2.new(0, 60, 0, 34)
		PlayerId.Size = UDim2.new(1, -60, 0, 10)
		PlayerId.TextTruncate = Enum.TextTruncate.AtEnd
		InfoRow(PlayerPanel, 2, "Account Age", LocalPlayer.AccountAge .. " days")
		if LicenseKey ~= nil and tostring(LicenseKey) ~= "" then
			InfoRow(PlayerPanel, 3, "Key", tostring(LicenseKey), 0.18)
		end

		local GamePanel = Panel(HomeRight, 1, "Game", "gamepad-2", nil, true)
		local GameImage = New("ImageLabel", {
			Size = UDim2.new(1, 0, 0, 72),
			BackgroundColor3 = Theme.Item,
			BorderSizePixel = 0,
			ScaleType = Enum.ScaleType.Crop,
			Image = "rbxthumb://type=GameIcon&id=" .. game.GameId .. "&w=150&h=150",
			LayoutOrder = 1,
		}, GamePanel)
		Corner(GameImage, Round.Button)
		Stroke(GameImage, Theme.Stroke, 1)
		local GameName = Label(GamePanel, "Loading...", 10, Theme.Text, FontBold)
		GameName.Size = UDim2.new(1, 0, 0, 0)
		GameName.AutomaticSize = Enum.AutomaticSize.Y
		GameName.TextWrapped = true
		GameName.TextYAlignment = Enum.TextYAlignment.Top
		GameName.LayoutOrder = 2
		local CreatorValue = InfoRow(GamePanel, 3, "Creator", "...")
		InfoRow(GamePanel, 4, "Place ID", tostring(game.PlaceId))
		task.spawn(function()
			local ok, Info = pcall(function()
				return MarketplaceService:GetProductInfo(game.PlaceId)
			end)
			if ok and type(Info) == "table" then
				GameName.Text = Info.Name or "Unknown"
				if type(Info.Creator) == "table" and Info.Creator.Name then CreatorValue.Text = Info.Creator.Name end
				if Info.IconImageAssetId and Info.IconImageAssetId ~= 0 then
					GameImage.Image = "rbxassetid://" .. tostring(Info.IconImageAssetId)
				end
			else
				GameName.Text = "Unknown"
				CreatorValue.Text = "Unknown"
			end
		end)

		local Teleporting = false

		local function Rejoin()
			if Teleporting then return end
			Teleporting = true
			Notify({ Title = "Rejoin", Text = "Rejoining this server" })
			local ok = pcall(function()
				if #Players:GetPlayers() <= 1 then
					LocalPlayer:Kick("\nRejoining...")
					task.wait()
					TeleportService:Teleport(game.PlaceId, LocalPlayer)
				else
					TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
				end
			end)
			if not ok then
				Teleporting = false
				Notify({ Title = "Rejoin", Text = "Teleport failed" })
				return
			end
			task.delay(10, function()
				Teleporting = false
			end)
		end

		local function ServerHop()
			if Teleporting then return end
			Teleporting = true
			Notify({ Title = "Server Hop", Text = "Searching for a server" })
			task.spawn(function()
				local Target
				local Cursor = ""
				for _ = 1, 5 do
					local Url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&excludeFullGames=true&limit=100"
					if Cursor ~= "" then Url = Url .. "&cursor=" .. Cursor end
					local ok, Data = pcall(function()
						return HttpService:JSONDecode(game:HttpGet(Url))
					end)
					if not ok or type(Data) ~= "table" or type(Data.data) ~= "table" then break end
					local Pool = {}
					for _, Server in ipairs(Data.data) do
						if Server.id ~= game.JobId and type(Server.playing) == "number" and type(Server.maxPlayers) == "number" and Server.playing < Server.maxPlayers - 1 then
							table.insert(Pool, Server)
						end
					end
					if #Pool > 0 then
						Target = Pool[math.random(1, #Pool)]
						break
					end
					Cursor = Data.nextPageCursor
					if type(Cursor) ~= "string" then break end
				end
				if not Target then
					Teleporting = false
					Notify({ Title = "Server Hop", Text = "No server found" })
					return
				end
				Notify({ Title = "Server Hop", Text = Target.playing .. " / " .. Target.maxPlayers .. " players" })
				local ok = pcall(function()
					TeleportService:TeleportToPlaceInstance(game.PlaceId, Target.id, LocalPlayer)
				end)
				if not ok then
					Teleporting = false
					Notify({ Title = "Server Hop", Text = "Teleport failed" })
					return
				end
				task.delay(10, function()
					Teleporting = false
				end)
			end)
		end

		local ServerPanel = Panel(HomeLeft, 2, "Server", "server", nil, true)
		local PlayersValue = InfoRow(ServerPanel, 1, "Players", "")
		local function UpdatePlayers()
			PlayersValue.Text = #Players:GetPlayers() .. " / " .. Players.MaxPlayers
		end
		UpdatePlayers()
		Players.PlayerAdded:Connect(UpdatePlayers)
		Players.PlayerRemoving:Connect(function()
			task.defer(UpdatePlayers)
		end)
		InfoRow(ServerPanel, 2, "Job ID", game.JobId ~= "" and string.sub(game.JobId, 1, 8) or "N/A")
		ActionButton(ServerPanel, 3, "Rejoin", Rejoin)
		ActionButton(ServerPanel, 4, "Server Hop", ServerHop)

	end

	function Window:ConfigManager()
		if ConfigBuilt then return end
		ConfigBuilt = true
		BuildConfigManager()
		task.delay(0.4, AutoLoadStart)
	end

	do
	local SearchEntries
	local SearchResults = {}
	local SearchSelected = 0
	local SearchOpen = false
	local SearchOver = false
	local SearchToken = 0
	local SearchStroke = SearchHolder:FindFirstChildOfClass("UIStroke")
	SearchBox.TextTruncate = Enum.TextTruncate.AtEnd

	local KindIcons = {
		Toggle = "toggle-right",
		Slider = "sliders-horizontal",
		Dropdown = "list",
		Keybind = "keyboard",
		Color = "palette",
		Button = "mouse-pointer-click",
		Section = "layout-grid",
		Input = "pencil",
	}

	local ExampleNames = {}

	local function Escape(Text)
		Text = string.gsub(Text, "&", "&amp;")
		Text = string.gsub(Text, "<", "&lt;")
		Text = string.gsub(Text, ">", "&gt;")
		return Text
	end

	local function Highlight(Text, Query)
		if Query == "" then return Escape(Text) end
		local Start, Finish = string.find(string.lower(Text), Query, 1, true)
		if not Start then return Escape(Text) end
		return Escape(string.sub(Text, 1, Start - 1)) .. '<font color="#0077ff">' .. Escape(string.sub(Text, Start, Finish)) .. "</font>" .. Escape(string.sub(Text, Finish + 1))
	end

	local function Score(Text, Query, Strict)
		local Lower = string.lower(Text)
		if Lower == Query then return 100 end
		local Start = string.find(Lower, Query, 1, true)
		if Start then
			if Start == 1 then return 80 end
			if string.sub(Lower, Start - 1, Start - 1) == " " then return 60 end
			return 40
		end
		if Strict then return 0 end
		local Pos = 1
		for Char in string.gmatch(Query, "%S") do
			local At = string.find(Lower, Char, Pos, true)
			if not At then return 0 end
			Pos = At + 1
		end
		return 15
	end

	local function BuildEntries()
		if SearchEntries then return SearchEntries end
		SearchEntries = {}
		for _, Tab in ipairs(Tabs) do
			table.insert(SearchEntries, { Name = Tab.Name, Kind = "Tab", Tab = Tab, Icon = Tab.Icon, Sub = "Tab" })
		end
		for _, Item in ipairs(SearchIndex) do
			local Owner
			for _, Tab in ipairs(Tabs) do
				if Tab.Page:IsAncestorOf(Item.Obj) then
					Owner = Tab
					break
				end
			end
			if Owner then
				local Section
				local Up = Item.Obj.Parent
				while Up and Up ~= Owner.Page do
					if SectionTitles[Up] then
						Section = SectionTitles[Up]
						break
					end
					Up = Up.Parent
				end
				local FoundSub
				for _, Candidate in ipairs(Owner.Subs) do
					if Candidate.Frame:IsAncestorOf(Item.Obj) then
						FoundSub = Candidate
						break
					end
				end
				local Base = Owner.Name
				if FoundSub then Base = Base .. "  •  " .. FoundSub.Name end
				local Sub = Base
				if Section and Item.Kind ~= "Section" then Sub = Base .. "  •  " .. Section end
				table.insert(SearchEntries, {
					Name = Item.Name,
					Kind = Item.Kind,
					Tab = Owner,
					Obj = Item.Obj,
					Section = Section,
					SubTab = FoundSub,
					Icon = KindIcons[Item.Kind],
					Sub = Sub,
				})
			end
		end
		return SearchEntries
	end

	local function RunSearch(Query)
		local Found = {}
		for _, Entry in ipairs(BuildEntries()) do
			local Value = Score(Entry.Name, Query)
			if Value == 0 then
				local Extra = math.max(Score(Entry.Tab.Name, Query, true), Entry.Section and Score(Entry.Section, Query, true) or 0)
				Value = Extra * 0.25
			end
			if Value > 0 then
				if Entry.Kind == "Tab" then Value = Value + 4 end
				table.insert(Found, { Entry = Entry, Score = Value })
			end
		end
		table.sort(Found, function(A, B)
			if A.Score ~= B.Score then return A.Score > B.Score end
			return A.Entry.Name < B.Entry.Name
		end)
		local Result = {}
		for Index = 1, math.min(#Found, 7) do
			Result[Index] = Found[Index].Entry
		end
		return Result, #Found
	end

	local function ExampleEntries()
		local Result, Used = {}, {}
		local All = BuildEntries()
		for _, Name in ipairs(ExampleNames) do
			for _, Entry in ipairs(All) do
				if string.lower(Entry.Name) == string.lower(Name) and not Used[Entry] then
					Used[Entry] = true
					table.insert(Result, Entry)
					break
				end
			end
		end
		for _, Entry in ipairs(All) do
			if #Result >= 6 then break end
			if not Used[Entry] and Entry.Kind ~= "Tab" then
				Used[Entry] = true
				table.insert(Result, Entry)
			end
		end
		return Result
	end

	local SuggestPanel = New("Frame", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(0, 398, 0, 27),
		Size = UDim2.fromOffset(178, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.PanelBody,
		BorderSizePixel = 0,
		Visible = false,
		ZIndex = 30,
	}, Main)
	Corner(SuggestPanel, Round.Section)
	Stroke(SuggestPanel, Theme.Stroke, 1)
	List(SuggestPanel, 0)

	local SuggestHeader = Label(SuggestPanel, "", 8, Theme.Dim)
	SuggestHeader.Size = UDim2.new(1, 0, 0, 18)
	SuggestHeader.LayoutOrder = 1
	Pad(SuggestHeader, 8, 0, 8, 0)

	local SuggestRows = New("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = 2,
	}, SuggestPanel)
	List(SuggestRows, 1)
	Pad(SuggestRows, 3, 0, 3, 4)

	local RowObjects = {}

	local function PaintRows()
		for Index, Row in ipairs(RowObjects) do
			Tween(Row, { BackgroundTransparency = Index == SearchSelected and 0 or 1 }, 0.12)
		end
	end

	local function SetSearchOpen(Value)
		if SearchOpen == Value then return end
		SearchOpen = Value
		SearchToken = SearchToken + 1
		local Mine = SearchToken
		if not Value then SearchOver = false end
		Tween(SearchHolder, {
			Size = UDim2.fromOffset(Value and 118 or 98, 21),
			Position = UDim2.new(0, Value and 280 or 300, 0, 7),
		}, 0.3)
		if SearchStroke then Tween(SearchStroke, { Color = Value and Theme.Accent or Theme.Stroke }, 0.25) end
		if Value then
			Fade(SuggestPanel, 1, 0)
			SuggestPanel.Position = UDim2.new(0, 398, 0, 27)
			SuggestPanel.Visible = true
			Fade(SuggestPanel, 0, 0.35)
			Ease(SuggestPanel, { Position = UDim2.new(0, 398, 0, 33) }, 0.35, Enum.EasingStyle.Quint)
		else
			Fade(SuggestPanel, 1, 0.22)
			local Motion = Ease(SuggestPanel, { Position = UDim2.new(0, 398, 0, 27) }, 0.22, Enum.EasingStyle.Quint)
			Motion.Completed:Connect(function(State)
				if Mine == SearchToken and State == Enum.PlaybackState.Completed then SuggestPanel.Visible = false end
			end)
		end
	end

	local function Flash(Target)
		local Pos = (Target.AbsolutePosition - Main.AbsolutePosition) / CurrentScale
		local Size = Target.AbsoluteSize / CurrentScale
		local Box = New("Frame", {
			Position = UDim2.fromOffset(Pos.X - 3, Pos.Y - 2),
			Size = UDim2.fromOffset(Size.X + 6, Size.Y + 4),
			BackgroundColor3 = Theme.Accent,
			BackgroundTransparency = 0.8,
			BorderSizePixel = 0,
			ZIndex = 25,
		}, Main)
		Corner(Box, Round.Button)
		local Line = Stroke(Box, Theme.Accent, 1)
		task.delay(0.7, function()
			Tween(Box, { BackgroundTransparency = 1 }, 0.6)
			Tween(Line, { Transparency = 1 }, 0.6)
			task.delay(0.7, function()
				Box:Destroy()
			end)
		end)
	end

	local function ResolveTarget(Entry)
		local Hidden
		local Up = Entry.Obj.Parent
		while Up and Up ~= Entry.Tab.Page do
			if Up:IsA("GuiObject") and not Up.Visible then Hidden = Up end
			Up = Up.Parent
		end
		if Hidden and Hidden.Parent then return Hidden.Parent end
		return Entry.Obj
	end

	local function FindScroll(Target, Page)
		local Up = Target.Parent
		while Up and Up ~= Page do
			if Up:IsA("ScrollingFrame") and Up:GetAttribute("Column") then return Up end
			Up = Up.Parent
		end
		return nil
	end

	local function GoTo(Entry)
		SetSearchOpen(false)
		SearchBox.Text = ""
		SearchBox:ReleaseFocus()
		local Same = CurrentTab == Entry.Tab
		Select(Entry.Tab)
		if Entry.SubTab then Entry.Tab:SelectSub(Entry.SubTab, true) end
		if not Entry.Obj then return end
		local Opened = false
		local Walk = Entry.Obj
		while Walk and Walk ~= Entry.Tab.Page do
			local Expand = PanelExpand[Walk]
			if Expand and Expand() then Opened = true end
			Walk = Walk.Parent
		end
		task.delay((Same and 0.05 or 0.7) + (Opened and 0.45 or 0), function()
			if CurrentTab ~= Entry.Tab or not Entry.Obj.Parent then return end
			local Target = ResolveTarget(Entry)
			local Scroll = FindScroll(Target, Entry.Tab.Page)
			if Scroll then
				local Offset = (Target.AbsolutePosition.Y - Scroll.AbsolutePosition.Y) / CurrentScale + Scroll.CanvasPosition.Y
				Ease(Scroll, { CanvasPosition = Vector2.new(0, math.max(Offset - 10, 0)) }, 0.35, Enum.EasingStyle.Quint)
			end
			task.delay(0.4, function()
				if CurrentTab ~= Entry.Tab or not Target.Parent then return end
				Flash(Target)
			end)
		end)
	end

	local function Render()
		for _, Row in ipairs(RowObjects) do
			Row:Destroy()
		end
		RowObjects = {}
		local Raw = string.match(SearchBox.Text, "^%s*(.-)%s*$")
		local Query = string.lower(Raw)
		local Items, Total
		if Query == "" then
			Items = ExampleEntries()
			SuggestHeader.Text = "Try searching for"
		else
			Items, Total = RunSearch(Query)
			if Total == 0 then
				SuggestHeader.Text = 'No results for "' .. Raw .. '"'
			else
				SuggestHeader.Text = Total .. (Total == 1 and " result" or " results")
			end
		end
		SearchResults = Items
		SearchSelected = #Items > 0 and 1 or 0
		for Index, Entry in ipairs(Items) do
			local Row = New("TextButton", {
				Size = UDim2.new(1, 0, 0, 26),
				BackgroundColor3 = Theme.Item,
				BackgroundTransparency = Index == 1 and 0 or 1,
				BorderSizePixel = 0,
				Text = "",
				AutoButtonColor = false,
				LayoutOrder = Index,
			}, SuggestRows)
			Corner(Row, Round.Button)
			local RowIcon = Icon(Row, Entry.Icon, 10, Theme.Accent)
			RowIcon.AnchorPoint = Vector2.new(0, 0.5)
			RowIcon.Position = UDim2.new(0, 7, 0.5, 0)
			local RowName = Label(Row, Highlight(Entry.Name, Query), 9, Theme.Text)
			RowName.RichText = true
			RowName.TextTruncate = Enum.TextTruncate.AtEnd
			RowName.Position = UDim2.new(0, 24, 0, 3)
			RowName.Size = UDim2.new(1, -28, 0, 12)
			local RowSub = Label(Row, Entry.Sub, 7, Theme.Dim)
			RowSub.TextTruncate = Enum.TextTruncate.AtEnd
			RowSub.Position = UDim2.new(0, 24, 0, 14)
			RowSub.Size = UDim2.new(1, -28, 0, 9)
			Row.MouseEnter:Connect(function()
				SearchSelected = Index
				PaintRows()
			end)
			Row.MouseButton1Click:Connect(function()
				GoTo(Entry)
			end)
			RowObjects[Index] = Row
		end
	end

	SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
		if SearchOpen then Render() end
	end)

	SearchBox.Focused:Connect(function()
		Render()
		SetSearchOpen(true)
	end)

	SearchBox.FocusLost:Connect(function(Enter)
		if Enter and SearchResults[SearchSelected] then
			GoTo(SearchResults[SearchSelected])
			return
		end
		task.delay(0.3, function()
			if not SearchBox:IsFocused() and not SearchOver then SetSearchOpen(false) end
		end)
	end)

	SuggestPanel.MouseEnter:Connect(function()
		SearchOver = true
	end)

	SuggestPanel.MouseLeave:Connect(function()
		SearchOver = false
		if not SearchBox:IsFocused() then SetSearchOpen(false) end
	end)

	UserInputService.InputBegan:Connect(function(Input)
		if not SearchOpen or not SearchBox:IsFocused() then return end
		local Count = #SearchResults
		if Input.KeyCode == Enum.KeyCode.Down then
			if Count > 0 then
				SearchSelected = SearchSelected % Count + 1
				PaintRows()
			end
		elseif Input.KeyCode == Enum.KeyCode.Up then
			if Count > 0 then
				SearchSelected = (SearchSelected - 2) % Count + 1
				PaintRows()
			end
		elseif Input.KeyCode == Enum.KeyCode.Escape then
			SetSearchOpen(false)
			SearchBox.Text = ""
			SearchBox:ReleaseFocus()
		end
	end)

	task.spawn(function()
		task.wait(2)
		local Pool = { "Search..." }
		for _, Entry in ipairs(ExampleEntries()) do
			if #Entry.Name <= 10 then table.insert(Pool, "Try: " .. Entry.Name) end
		end
		local Index = 0
		while Gui.Parent do
			if not SearchBox:IsFocused() and SearchBox.Text == "" then
				Index = Index % #Pool + 1
				SearchBox.PlaceholderText = Pool[Index]
			end
			task.wait(2.5)
		end
	end)

	end

	for _, Root in ipairs(Roots()) do
		if pcall(function() Gui.Parent = Root end) and Gui.Parent == Root then break end
	end
	if Gui.Parent then NotifyGui.Parent = Gui.Parent end
	UpdateScale()
	SetVisible(true)
	Notify({ Title = WindowTitle, Text = "Interface loaded" })

	Window.Gui = Gui
	Window.NotifyGui = NotifyGui

	function Window:Notify(Opts)
		return Notify(Opts or {})
	end

	function Window:Watermark(Value)
		WatermarkWrap.Visible = Value ~= false
	end

	function Window:SetVisible(Value)
		SetVisible(Value == true)
	end

	function Window:Toggle()
		SetVisible(not WindowVisible)
	end

	function Window:Destroy()
		Gui:Destroy()
		NotifyGui:Destroy()
	end

	return Window
end

return Library
