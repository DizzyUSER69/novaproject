--[[
	UI Constants for Nova
	Centralized styling values for consistent theming
]]

local Constants = {}

-- Corner Radius
Constants.CornerRadius = {
	Large = UDim.new(0, 10),
	Medium = UDim.new(0, 8),
	Small = UDim.new(0, 6),
	Round = UDim.new(1, 0),
}

-- Colors
Constants.Colors = {
	Background = {
		Primary = Color3.fromRGB(15, 15, 15),
		Secondary = Color3.fromRGB(10, 10, 10),
		Tertiary = Color3.fromRGB(5, 5, 5),
	},
	Accent = {
		Primary = Color3.fromRGB(25, 25, 25),
		Hover = Color3.fromRGB(30, 30, 30),
		Active = Color3.fromRGB(50, 50, 50),
	},
	Status = {
		Success = Color3.fromRGB(52, 199, 89),
		Warning = Color3.fromRGB(255, 153, 0),
		Error = Color3.fromRGB(255, 69, 58),
		Info = Color3.fromRGB(10, 132, 255),
	},
	Text = {
		Primary = Color3.fromRGB(255, 255, 255),
		Secondary = Color3.fromRGB(180, 180, 180),
		Tertiary = Color3.fromRGB(128, 128, 128),
	},
	Border = {
		Primary = Color3.fromRGB(25, 25, 25),
		Secondary = Color3.fromRGB(40, 40, 40),
	},
}

-- Padding
Constants.Padding = {
	None = UDim.new(0, 0),
	XSmall = UDim.new(0, 2),
	Small = UDim.new(0, 4),
	Medium = UDim.new(0, 6),
	Large = UDim.new(0, 8),
	XLarge = UDim.new(0, 12),
}

-- Spacing
Constants.Spacing = {
	None = UDim.new(0, 0),
	XSmall = UDim.new(0, 2),
	Small = UDim.new(0, 4),
	Medium = UDim.new(0, 6),
	Large = UDim.new(0, 8),
	XLarge = UDim.new(0, 15),
}

-- Text Sizes
Constants.TextSize = {
	Small = 14,
	Medium = 15,
	Regular = 16,
	Large = 17,
	XLarge = 18,
}

-- Tween Info
Constants.TweenInfo = {
	Default = TweenInfo.new(0.2, Enum.EasingStyle.Exponential),
	Fast = TweenInfo.new(0.1, Enum.EasingStyle.Exponential),
	Slow = TweenInfo.new(0.3, Enum.EasingStyle.Exponential),
}

-- Sizes
Constants.Sizes = {
	Button = {
		Small = UDim2.fromOffset(24, 24),
		Medium = UDim2.fromOffset(30, 30),
		Large = UDim2.fromOffset(36, 36),
	},
	Icon = {
		Small = UDim2.fromOffset(16, 16),
		Medium = UDim2.fromOffset(20, 20),
		Large = UDim2.fromOffset(24, 24),
	},
}

-- Transparency
Constants.Transparency = {
	Opaque = 0,
	SemiTransparent = 0.5,
	Transparent = 1,
}

-- Stroke Thickness
Constants.StrokeThickness = {
	Thin = 1,
	Medium = 2,
	Thick = 3,
}

return Constants
