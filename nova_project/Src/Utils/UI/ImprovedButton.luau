--[[
	Improved Button Component for Nova
	Enhanced button with better visual feedback and animations
]]

local Constants = require(script.Parent.Constants)
local Interface = require(script.Parent.Interface)

local ImprovedButton = {}

type ButtonConfig = {
	Text: string?,
	Icon: string?,
	Size: UDim2?,
	Position: UDim2?,
	AnchorPoint: Vector2?,
	BackgroundColor: Color3?,
	HoverColor: Color3?,
	ActiveColor: Color3?,
	TextSize: number?,
	CornerRadius: UDim?,
	OnClick: (() -> ())?,
	Parent: Instance?,
	LayoutOrder: number?,
}

function ImprovedButton.Create(config: ButtonConfig)
	local button = Interface.New("TextButton", {
		Size = config.Size or UDim2.fromOffset(100, 36),
		Position = config.Position or UDim2.fromScale(0, 0),
		AnchorPoint = config.AnchorPoint or Vector2.new(0, 0),
		BackgroundColor3 = config.BackgroundColor or Constants.Colors.Accent.Primary,
		Text = config.Icon and "" or (config.Text or "Button"),
		TextSize = config.TextSize or Constants.TextSize.Regular,
		TextColor3 = Constants.Colors.Text.Primary,
		AutoButtonColor = false,
		LayoutOrder = config.LayoutOrder or 0,
		Parent = config.Parent,
		
		["UICorner"] = {
			CornerRadius = config.CornerRadius or Constants.CornerRadius.Medium,
		},
		
		["UIStroke"] = {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Color = Constants.Colors.Border.Primary,
			Thickness = Constants.StrokeThickness.Thin,
		},
	})
	
	-- Add padding if text is present
	if not config.Icon or config.Text then
		Interface.New("UIPadding", {
			PaddingLeft = Constants.Padding.Medium,
			PaddingRight = Constants.Padding.Medium,
			PaddingTop = Constants.Padding.Small,
			PaddingBottom = Constants.Padding.Small,
			Parent = button,
		})
	end
	
	-- Add icon if specified
	if config.Icon then
		local Icons = require(script.Parent.Icons)
		local iconImage = Interface.NewIcon(config.Icon, {
			Size = config.Text and Constants.Sizes.Icon.Medium or Constants.Sizes.Icon.Large,
			Position = config.Text and UDim2.fromOffset(8, 0) or UDim2.fromScale(0.5, 0.5),
			AnchorPoint = config.Text and Vector2.new(0, 0.5) or Vector2.new(0.5, 0.5),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Parent = button,
		})
		
		-- If both icon and text, add text label
		if config.Text then
			Interface.New("TextLabel", {
				Text = config.Text,
				TextSize = config.TextSize or Constants.TextSize.Regular,
				TextColor3 = Constants.Colors.Text.Primary,
				Size = UDim2.new(1, -36, 1, 0),
				Position = UDim2.fromOffset(32, 0),
				TextXAlignment = Enum.TextXAlignment.Left,
				BackgroundTransparency = 1,
				Parent = button,
			})
		end
	end
	
	-- Hover animation
	local originalColor = config.BackgroundColor or Constants.Colors.Accent.Primary
	local hoverColor = config.HoverColor or Constants.Colors.Accent.Hover
	local activeColor = config.ActiveColor or Constants.Colors.Accent.Active
	
	button.MouseEnter:Connect(function()
		wax.shared.TweenService:Create(
			button,
			Constants.TweenInfo.Default,
			{ BackgroundColor3 = hoverColor }
		):Play()
	end)
	
	button.MouseLeave:Connect(function()
		wax.shared.TweenService:Create(
			button,
			Constants.TweenInfo.Default,
			{ BackgroundColor3 = originalColor }
		):Play()
	end)
	
	button.MouseButton1Down:Connect(function()
		wax.shared.TweenService:Create(
			button,
			Constants.TweenInfo.Fast,
			{ BackgroundColor3 = activeColor }
		):Play()
	end)
	
	button.MouseButton1Up:Connect(function()
		wax.shared.TweenService:Create(
			button,
			Constants.TweenInfo.Fast,
			{ BackgroundColor3 = hoverColor }
		):Play()
	end)
	
	-- Click callback
	if config.OnClick then
		button.MouseButton1Click:Connect(config.OnClick)
	end
	
	return button
end

return ImprovedButton
