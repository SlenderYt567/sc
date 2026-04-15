--[[
    SlenderHub Skill: UI Logic & Animations
    Version: 1.0
    Description: Standardized tween functions and UI interaction feedback.
]]

local UISkill = {}
local TweenService = game:GetService("TweenService")

-- Standard modern easing
local StandardInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

-- Function to animate a property safely
function UISkill.Animate(object, properties, info)
    if not object then return end
    local tween = TweenService:Create(object, info or StandardInfo, properties)
    tween:Play()
    return tween
end

-- Hover Effect (Scale & Color)
function UISkill.AddHoverEffect(button, originalColor, hoverColor)
    button.MouseEnter:Connect(function()
        UISkill.Animate(button, {
            BackgroundColor3 = hoverColor or originalColor:lerp(Color3.new(1,1,1), 0.1),
            Size = button.Size + UDim2.fromOffset(2, 2)
        }, TweenInfo.new(0.2))
    end)
    
    button.MouseLeave:Connect(function()
        UISkill.Animate(button, {
            BackgroundColor3 = originalColor,
            Size = button.Size - UDim2.fromOffset(2, 2)
        }, TweenInfo.new(0.2))
    end)
end

-- Ripple Effect (Premium Touch)
function UISkill.CreateRipple(button)
    button.Activated:Connect(function()
        local ripple = Instance.new("Frame")
        ripple.Name = "Ripple"
        ripple.Parent = button
        ripple.BackgroundColor3 = Color3.new(1, 1, 1)
        ripple.BackgroundTransparency = 0.6
        ripple.Size = UDim2.new(0, 0, 0, 0)
        ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
        ripple.AnchorPoint = Vector2.new(0.5, 0.5)
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = ripple
        
        UISkill.Animate(ripple, {
            Size = UDim2.new(1.5, 0, 1.5, 0),
            BackgroundTransparency = 1
        }, TweenInfo.new(0.5))
        
        task.delay(0.5, function() ripple:Destroy() end)
    end)
end

return UISkill
