local Constants = {}

Constants.Colors = {
    Accent = {
        Primary = Color3.fromRGB(0, 174, 255),
    },
    Background = {
        Primary = Color3.fromRGB(15, 15, 15),
        Secondary = Color3.fromRGB(20, 20, 20),
        Tertiary = Color3.fromRGB(25, 25, 25),
    },
    Border = {
        Primary = Color3.fromRGB(30, 30, 30),
        Secondary = Color3.fromRGB(40, 40, 40),
    },
    Text = {
        Primary = Color3.fromRGB(255, 255, 255),
        Secondary = Color3.fromRGB(180, 180, 180),
        Tertiary = Color3.fromRGB(120, 120, 120),
    }
}

function Constants.ApplyTheme(themeName)
    -- No longer used
end

return Constants
