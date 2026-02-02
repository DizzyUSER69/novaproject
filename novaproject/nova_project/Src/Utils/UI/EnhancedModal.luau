--[[
	Enhanced Modal Component for Nova
	Improved modal with smooth animations and better UX
]]

local Constants = require(script.Parent.Constants)
local Interface = require(script.Parent.Interface)

local EnhancedModal = {}

type ModalConfig = {
	Title: string,
	Icon: string?,
	Size: UDim2?,
	MinSize: UDim2?,
	MaxSize: UDim2?,
	Resizable: boolean?,
	Parent: Instance,
}

function EnhancedModal.Create(config: ModalConfig)
	local modal = {}
	
	-- Background overlay
	local overlay = Interface.New("TextButton", {
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Text = "",
		Visible = false,
		ZIndex = 1000,
		Parent = config.Parent,
	})
	
	-- Modal container
	local container = Interface.New("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Constants.Colors.Background.Secondary,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = config.Size or UDim2.fromScale(0.6, 0.7),
		ZIndex = 1001,
		Visible = false,
		Parent = config.Parent,
		
		["UICorner"] = {
			CornerRadius = Constants.CornerRadius.Medium,
		},
		
		["UIStroke"] = {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Color = Constants.Colors.Border.Primary,
			Thickness = Constants.StrokeThickness.Thin,
		},
	})
	
	-- Title bar
	local titleBar = Interface.New("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 36),
		Parent = container,
		
		["UIPadding"] = {
			PaddingLeft = Constants.Padding.Medium,
			PaddingRight = Constants.Padding.Medium,
			PaddingTop = Constants.Padding.Medium,
			PaddingBottom = Constants.Padding.Medium,
		},
	})
	
	-- Title text
	local titleText = Interface.New("TextLabel", {
		Text = config.Title,
		TextSize = Constants.TextSize.Large,
		TextColor3 = Constants.Colors.Text.Primary,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Size = UDim2.new(1, -60, 1, 0),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Parent = titleBar,
	})
	
	-- Icon (if provided)
	if config.Icon then
		local Icons = require(script.Parent.Icons)
		if config.Icon:match("rbxasset") then
			Interface.New("ImageLabel", {
				Image = config.Icon,
				Size = UDim2.fromScale(1, 1),
				Position = UDim2.fromOffset(4, 0),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				BackgroundTransparency = 1,
				Parent = titleBar,
			})
		else
			Interface.NewIcon(config.Icon, {
				ImageTransparency = 0.5,
				Size = UDim2.fromScale(1, 1),
				Position = UDim2.fromOffset(4, 0),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Parent = titleBar,
			})
		end
	end
	
	-- Close button
	local closeButton = Interface.New("ImageButton", {
		Size = UDim2.fromScale(1, 1),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.fromScale(1, 0),
		BackgroundTransparency = 1,
		Parent = titleBar,
	})
	
	local closeIcon = Interface.NewIcon("x", {
		ImageTransparency = 0.5,
		Size = UDim2.fromOffset(22, 22),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		Parent = closeButton,
	})
	
	-- Close button hover effects
	closeButton.MouseEnter:Connect(function()
		wax.shared.TweenService:Create(
			closeIcon,
			Constants.TweenInfo.Default,
			{ ImageTransparency = 0.25 }
		):Play()
	end)
	
	closeButton.MouseLeave:Connect(function()
		wax.shared.TweenService:Create(
			closeIcon,
			Constants.TweenInfo.Default,
			{ ImageTransparency = 0.5 }
		):Play()
	end)
	
	-- Separator line
	Interface.New("Frame", {
		Parent = container,
		BackgroundColor3 = Constants.Colors.Border.Primary,
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.fromOffset(0, 36),
	})
	
	-- Content area
	local content = Interface.New("ScrollingFrame", {
		AnchorPoint = Vector2.new(0, 1),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0, 1),
		Size = UDim2.new(1, 0, 1, -37),
		ClipsDescendants = true,
		ScrollBarThickness = 2,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.fromScale(0, 0),
		Parent = container,
		
		["UIPadding"] = {
			PaddingLeft = Constants.Padding.Large,
			PaddingRight = Constants.Padding.Large,
			PaddingTop = Constants.Padding.Large,
			PaddingBottom = Constants.Padding.Large,
		},
	})
	
	-- Modal methods
	function modal:Open()
		overlay.Visible = true
		container.Visible = true
		
		-- Fade in overlay
		wax.shared.TweenService:Create(
			overlay,
			Constants.TweenInfo.Default,
			{ BackgroundTransparency = 0.5 }
		):Play()
		
		-- Scale in container
		container.Size = UDim2.fromScale(0, 0)
		wax.shared.TweenService:Create(
			container,
			TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{ Size = config.Size or UDim2.fromScale(0.6, 0.7) }
		):Play()
	end
	
	function modal:Close()
		-- Fade out overlay
		local overlayTween = wax.shared.TweenService:Create(
			overlay,
			Constants.TweenInfo.Default,
			{ BackgroundTransparency = 1 }
		)
		
		-- Scale out container
		local containerTween = wax.shared.TweenService:Create(
			container,
			TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In),
			{ Size = UDim2.fromScale(0, 0) }
		)
		
		overlayTween:Play()
		containerTween:Play()
		
		containerTween.Completed:Connect(function()
			overlay.Visible = false
			container.Visible = false
		end)
	end
	
	function modal:GetContent()
		return content
	end
	
	function modal:SetTitle(newTitle: string)
		titleText.Text = newTitle
	end
	
	-- Connect close button
	closeButton.MouseButton1Click:Connect(function()
		modal:Close()
	end)
	
	-- Connect overlay click to close
	overlay.MouseButton1Click:Connect(function()
		modal:Close()
	end)
	
	modal.Container = container
	modal.Content = content
	modal.Overlay = overlay
	
	return modal
end

return EnhancedModal
