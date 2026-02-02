--[[
	UI Constants for Nova
	Centralized styling values for consistent theming
	Customized for 04xSkater
]]

local Constants = {}

-- Corner Radius
Constants.CornerRadius = {
	Large = UDim.new(0, 10),
	Medium = UDim.new(0, 8),
	Small = UDim.new(0, 6),
	Round = UDim.new(1, 0),
}

-- Theme Definitions
Constants.Themes = {
    Dark = { -- Cobalt Style
        Background = {
            Primary = Color3.fromRGB(15, 15, 15),
            Secondary = Color3.fromRGB(20, 20, 20),
            Tertiary = Color3.fromRGB(10, 10, 10),
        },
        Accent = {
            Primary = Color3.fromRGB(25, 25, 25),
            Hover = Color3.fromRGB(30, 30, 30),
            Active = Color3.fromRGB(50, 50, 50),
            Light = Color3.fromRGB(200, 200, 200),
        },
        Border = {
            Primary = Color3.fromRGB(30, 30, 30),
            Secondary = Color3.fromRGB(40, 40, 40),
        }
    },
    Nova = {
        Background = {
            Primary = Color3.fromRGB(10, 10, 12),
            Secondary = Color3.fromRGB(15, 15, 20),
            Tertiary = Color3.fromRGB(5, 5, 7),
        },
        Accent = {
            Primary = Color3.fromRGB(0, 174, 255), -- Electric Blue from Logo
            Hover = Color3.fromRGB(0, 190, 255),
            Active = Color3.fromRGB(0, 150, 220),
            Light = Color3.fromRGB(255, 255, 255),
        },
        Border = {
            Primary = Color3.fromRGB(30, 30, 40),
            Secondary = Color3.fromRGB(0, 174, 255), -- Blue border for highlights
        }
    }
}

-- Current active colors (will be updated by Window.luau)
Constants.Colors = {}

function Constants.ApplyTheme(themeName)
    local theme = Constants.Themes[themeName] or Constants.Themes.Dark
    
    Constants.Colors.Background = theme.Background
    Constants.Colors.Accent = theme.Accent
    Constants.Colors.Border = theme.Border
    
    -- Static Colors
    Constants.Colors.Status = {
        Success = Color3.fromRGB(52, 199, 89),
        Warning = Color3.fromRGB(255, 153, 0),
        Error = Color3.fromRGB(255, 69, 58),
        Info = theme.Accent.Primary,
    }
    Constants.Colors.Text = {
        Primary = Color3.fromRGB(255, 255, 255),
        Secondary = Color3.fromRGB(180, 190, 200),
        Tertiary = Color3.fromRGB(120, 130, 140),
    }
end

-- Default initialization
Constants.ApplyTheme("Dark")

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
