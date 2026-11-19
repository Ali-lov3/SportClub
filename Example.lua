local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/User/Repo/main/Source.lua"))()

local Window = Library:CreateWindow({
	Title = "Example",
	GameInfo = "Example",
	Logo = 77434646025119,
	ConfigFolder = "Example",
	Key = "EXAMPLE-0000-0000",
	LifeTime = true,
	Anonymous = false,
})

Window:HomeManager()
Window:ConfigManager()

local Tab = Window:Tab({ Name = "Example", Icon = "layers" })
local First = Tab:SubTab({ Name = "Example", Icon = "layers" })
local Second = Tab:SubTab({ Name = "Example", Icon = "settings" })

local Basic = First:Section({ Name = "Example", Icon = "layers", Side = "Left" })

Basic:Toggle({
	Name = "Example",
	Flag = "ExampleToggle",
	Default = false,
	Callback = function(Value)
		print(Value)
	end,
})

local Option = Basic:OptionToggle({
	Name = "Example",
	Flag = "ExampleOption",
	Default = false,
})

Option:Slider({
	Name = "Example",
	Flag = "ExampleOptionSlider",
	Min = 0,
	Max = 100,
	Default = 50,
	Decimals = 0,
})

Option:Toggle({
	Name = "Example",
	Flag = "ExampleOptionToggle",
	Default = true,
})

Basic:Slider({
	Name = "Example",
	Flag = "ExampleSlider",
	Min = 0,
	Max = 1,
	Default = 0.5,
	Decimals = 2,
})

Basic:Button({
	Name = "Example",
	Callback = function()
		Window:Notify({ Title = "Example", Text = "Example", Icon = "bell" })
	end,
})

local Lists = First:Section({ Name = "Example", Icon = "list", Side = "Right" })

Lists:Dropdown({
	Name = "Example",
	Flag = "ExampleDropdown",
	Options = { "Example 1", "Example 2", "Example 3" },
	Default = "Example 1",
})

Lists:SearchDropdown({
	Name = "Example",
	Flag = "ExampleSearchDropdown",
	Options = { "Example 1", "Example 2", "Example 3", "Example 4", "Example 5", "Example 6" },
	Default = "Example 1",
})

Lists:MultiDropdown({
	Name = "Example",
	Flag = "ExampleMultiDropdown",
	Options = { "Example 1", "Example 2", "Example 3", "Example 4" },
	Default = { "Example 1", "Example 2" },
})

local Input = Second:Section({ Name = "Example", Icon = "keyboard", Side = "Left" })

Input:Keybind({
	Name = "Example",
	Flag = "ExampleKeybind",
	Pressed = function()
		Window:Toggle()
	end,
})

Input:ColorPicker({
	Name = "Example",
	Flag = "ExampleColor",
	Default = Color3.fromRGB(0, 119, 255),
})

local Extra = Second:Section({ Name = "Example", Icon = "sliders-horizontal", Side = "Right" })

Extra:Toggle({
	Name = "Example",
	Flag = "ExampleExtraToggle",
	Default = true,
})

Extra:Button({
	Name = "Example",
	Callback = function()
		Window:Notify({ Title = "Example", Text = "Example", Icon = "check" })
	end,
})
