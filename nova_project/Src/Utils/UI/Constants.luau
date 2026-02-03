local Constants = {}

-- Nova Blue Color (from logo)
local NOVA_BLUE = Color3.fromRGB(0, 174, 255)

Constants.Colors = {
    Accent = {
        Primary = NOVA_BLUE,
    },
    Background = {
        Primary = Color3.fromRGB(10, 10, 12),
        Secondary = Color3.fromRGB(15, 15, 18),
        Tertiary = Color3.fromRGB(20, 20, 25),
    },
    Border = {
        Primary = NOVA_BLUE, -- Nova theme: borders are blue
        Secondary = Color3.fromRGB(40, 40, 50),
    },
    Text = {
        Primary = Color3.fromRGB(255, 255, 255),
        Secondary = Color3.fromRGB(180, 190, 200),
        Tertiary = Color3.fromRGB(120, 130, 140),
    }
}

function Constants.ApplyTheme(themeName)
    -- Theme is now permanently Nova
end

return Constants
