local Interface = require(script.Parent.Interface)
local Constants = require(script.Parent.Constants)
local ImageFetcher = require(script.Parent.ImageFetch)

local LoadingScreen = {}

function LoadingScreen.show()
    local NovaLogo = ImageFetcher.GetImage("Logo")
    
    local ScreenGui = Interface.New("ScreenGui", {
        Name = "NovaLoading",
        DisplayOrder = 9999,
        ResetOnSpawn = false,
        Parent = Interface.GetScreenParent(),
    })

    local MainFrame = Interface.New("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Constants.Colors.Background.Primary,
        Parent = ScreenGui,
    })

    local Container = Interface.New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(300, 300),
        BackgroundTransparency = 1,
        Parent = MainFrame,
    })

    local Logo = Interface.New("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.4),
        Size = UDim2.fromOffset(150, 150),
        Image = NovaLogo,
        BackgroundTransparency = 1,
        ImageTransparency = 1,
        Parent = Container,
    })

    local Title = Interface.New("TextLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.65),
        Size = UDim2.fromOffset(200, 30),
        Text = "NOVA PROJECT",
        TextColor3 = Constants.Colors.Accent.Primary,
        TextSize = 24,
        Font = Enum.Font.GothamBold,
        TextTransparency = 1,
        BackgroundTransparency = 1,
        Parent = Container,
    })

    local Creator = Interface.New("TextLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.72),
        Size = UDim2.fromOffset(200, 20),
        Text = "by 04xSkater",
        TextColor3 = Constants.Colors.Text.Secondary,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextTransparency = 1,
        BackgroundTransparency = 1,
        Parent = Container,
    })

    local ProgressBarBackground = Interface.New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.85),
        Size = UDim2.fromOffset(200, 4),
        BackgroundColor3 = Constants.Colors.Background.Tertiary,
        BorderSizePixel = 0,
        Parent = Container,
    })

    local ProgressBar = Interface.New("Frame", {
        Size = UDim2.fromScale(0, 1),
        BackgroundColor3 = Constants.Colors.Accent.Primary,
        BorderSizePixel = 0,
        Parent = ProgressBarBackground,
    })

    Interface.New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = ProgressBarBackground })
    Interface.New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = ProgressBar })

    -- Animations
    local ts = game:GetService("TweenService")
    local ti = TweenInfo.new(1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

    ts:Create(Logo, ti, { ImageTransparency = 0, Position = UDim2.fromScale(0.5, 0.45) }):Play()
    task.wait(0.5)
    ts:Create(Title, ti, { TextTransparency = 0 }):Play()
    task.wait(0.3)
    ts:Create(Creator, ti, { TextTransparency = 0 }):Play()
    task.wait(0.5)

    -- Fake loading progress
    local steps = 20
    for i = 1, steps do
        ts:Create(ProgressBar, TweenInfo.new(0.2), { Size = UDim2.fromScale(i/steps, 1) }):Play()
        task.wait(0.1)
    end

    task.wait(0.5)

    -- Fade out
    local fadeTi = TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
    ts:Create(Logo, fadeTi, { ImageTransparency = 1 }):Play()
    ts:Create(Title, fadeTi, { TextTransparency = 1 }):Play()
    ts:Create(Creator, fadeTi, { TextTransparency = 1 }):Play()
    ts:Create(ProgressBarBackground, fadeTi, { BackgroundTransparency = 1 }):Play()
    ts:Create(ProgressBar, fadeTi, { BackgroundTransparency = 1 }):Play()
    ts:Create(MainFrame, fadeTi, { BackgroundTransparency = 1 }):Play()

    task.wait(0.6)
    ScreenGui:Destroy()
end

return LoadingScreen
