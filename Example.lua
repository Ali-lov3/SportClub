local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Ali-lov3/SportClub/refs/heads/main/Source.lua"))()

local Window = Library:CreateWindow({
	Title = "sportsclub",
	TitleAccent = "sports",
	GameInfo = "Bloxstrike",
	Link = "https://getsportsclub.com",
	Logo = 77434646025119,
	ConfigFolder = "Example",
	Footer = true,
	LifeTime = true,
})

Window:ConfigManager()

local Aim = Window:Tab({ Name = "Aim Assistance", Icon = "eye", Category = "Main", Description = "Crosshair locks into target head" })
local Misc = Window:Tab({ Name = "Misc", Icon = "eye", Category = "Main", Description = "Small extras" })
local Visuals = Window:Tab({ Name = "Visuals", Icon = "eye", Category = "Visuals", Description = "Everything you can see" })
local Servers = Window:Tab({ Name = "Servers", Icon = "eye", Category = "Other", Description = "Rejoin and hop servers" })
local Settings = Window:Tab({ Name = "Settings", Icon = "eye", Category = "Settings", Description = "Interface options" })

local Aimbot = Aim:SubTab({ Name = "Aimbot", Icon = "eye" })
local Silent = Aim:SubTab({ Name = "Silent", Icon = "eye" })
local Trigger = Aim:SubTab({ Name = "Trigger", Icon = "eye" })

local Main = Aimbot:Section({ Name = "Aimbot", Icon = "eye", Side = "Left" })

Main:Toggle({ Name = "Selected Toggle", Flag = "SelectedToggle", Default = true })
Main:Toggle({ Name = "Unselected Toggle", Flag = "UnselectedToggle", Default = true })

Main:Slider({
	Name = "Slider",
	Flag = "MainSlider",
	Min = 0,
	Max = 100,
	Default = 49,
	Decimals = 0,
	Suffix = "%",
})

local SliderLeft, SliderRight = Main:Split()

SliderLeft:Slider({ Name = "Slider", Flag = "SplitSliderLeft", Min = 0, Max = 100, Default = 78, Decimals = 0, Suffix = "%" })
SliderRight:Slider({ Name = "Slider", Flag = "SplitSliderRight", Min = 0, Max = 100, Default = 50, Decimals = 0, Suffix = "%" })

Main:MultiDropdown({
	Name = "Dropdown",
	Flag = "MainDropdown",
	Options = { "Value1", "Value2", "Value3", "Value4", "Value5", "Value6" },
	Default = { "Value3", "Value4", "Value5", "Value6" },
})

Main:Input({ Name = "Input", Flag = "MainInput", Placeholder = "Type here" })

local Premium = Aimbot:Section({ Name = "Premium", Icon = "eye", Side = "Left", Collapsed = true })

Premium:Toggle({ Name = "Premium Toggle", Flag = "PremiumToggle", Default = false })

local Elements = Aimbot:Section({ Name = "Elements", Icon = "eye", Side = "Right" })

local WithColor = Elements:Toggle({ Name = "Toggle w Colorpicker", Flag = "ToggleColor", Default = true })
WithColor:ColorPicker({ Flag = "ToggleColorValue", Default = Color3.fromRGB(230, 110, 20) })

Elements:Keybind({ Name = "Keypicker", Flag = "PlainKeypicker" })

local WithKey = Elements:Toggle({ Name = "Toggle w Keypicker", Flag = "ToggleKey", Default = true })
WithKey:Keybind({ Flag = "ToggleKeyValue" })

Elements:Divider()

Elements:Toggle({ Name = "Risky Toggle", Flag = "RiskyToggle", Style = "Risky", Default = false })

Elements:Slider({
	Name = "Warning Slider",
	Flag = "WarningSlider",
	Style = "Warning",
	Min = 0,
	Max = 10,
	Default = 3,
	Decimals = 0,
})

Elements:Divider({ Name = "Aimbot Settings" })

Elements:Label({
	Name = "Label",
	Description = "This is a label with a description and a seperator",
	Separator = true,
})

local NotifyLeft, NotifyRight = Elements:Split()

NotifyLeft:Button({
	Name = "Notify",
	Callback = function()
		Window:Notify({ Title = "This is a notification" })
	end,
})

NotifyRight:Button({
	Name = "Notify Full",
	Callback = function()
		Window:Notify({
			Title = '<font color="rgb(0,119,255)">Hello</font> there!',
			Text = 'This notification has an <font color="rgb(255,200,0)">optional</font> description.',
		})
	end,
})

Elements:Button({
	Name = "Notify Color",
	Callback = function()
		Window:Notify({
			Title = "Custom color",
			Text = "The glow follows the color option.",
			Color = Color3.fromRGB(255, 70, 70),
		})
	end,
})

Elements:Divider({ Name = "Centered Divider", Centered = true })

Elements:SearchDropdown({
	Name = "Dropdown (Search)",
	Flag = "SearchDropdown",
	Options = { "Option1", "Option2", "Option3", "Option4", "Option5" },
	Default = "Option1",
})

local MiscSection = Misc:Section({ Name = "Misc", Icon = "eye", Side = "Left" })
MiscSection:Toggle({ Name = "Example", Flag = "MiscToggle", Default = false })

local VisualSection = Visuals:Section({ Name = "Visuals", Icon = "eye", Side = "Left" })
VisualSection:Toggle({ Name = "Example", Flag = "VisualToggle", Default = false })

local ServerSection = Servers:Section({ Name = "Servers", Icon = "eye", Side = "Left" })
ServerSection:Button({
	Name = "Example",
	Callback = function()
		Window:Notify({ Title = "Example" })
	end,
})

local SettingSection = Settings:Section({ Name = "Settings", Icon = "eye", Side = "Left" })
SettingSection:Toggle({ Name = "Example", Flag = "SettingToggle", Default = true })
