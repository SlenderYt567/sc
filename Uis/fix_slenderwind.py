import re

file_path = r'c:\Users\User\Desktop\Script\Uis\SlenderWind'

with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Update MakeDraggable for memory leak
old_draggable = r'''    UserInputService\.InputChanged:Connect\(function\(input\)
        if input == DragInput and Dragging then Update\(input\) end
    end\)'''
new_draggable = '''    local dragConn
    dragConn = UserInputService.InputChanged:Connect(function(input)
        if not object.Parent then dragConn:Disconnect() return end
        if input == DragInput and Dragging then Update(input) end
    end)'''
content = re.sub(old_draggable, new_draggable, content)

# 2. Main Container constraints
old_main = r'''    Create\("UIStroke", \{Parent = Main, Color = Colors\.Stroke, Thickness = 1\}\)'''
new_main = '''    Create("UIStroke", {Parent = Main, Color = Colors.Stroke, Thickness = 1})
    Create("UISizeConstraint", {Parent = Main, MaxSize = Vector2.new(800, 600), MinSize = Vector2.new(450, 300)})
    -- Premium UI Aspect Ratio for Mobile scaling
    Create("UIAspectRatioConstraint", {Parent = Main, AspectRatio = 1.55, AspectType = Enum.AspectType.ScaleWithParentSize, DominantAxis = Enum.DominantAxis.Width})'''
content = re.sub(old_main, new_main, content)

# 3. Slider connections memory leak
old_slider_1 = r'''            UserInputService\.InputChanged:Connect\(function\(input\)
                if Dragging and \(input\.UserInputType == Enum\.UserInputType\.MouseMovement or input\.UserInputType == Enum\.UserInputType\.Touch\) then
                    UpdateInput\(input\)
                end
            end\)'''
new_slider_1 = '''            local sCon1
            sCon1 = UserInputService.InputChanged:Connect(function(input)
                if not fill.Parent then sCon1:Disconnect() return end
                if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    UpdateInput(input)
                end
            end)'''
content = content.replace(old_slider_1.replace('fill', 'Fill'), new_slider_1.replace('fill', 'Fill'))

old_slider_2 = r'''            UserInputService\.InputEnded:Connect\(function\(input\)
                if input\.UserInputType == Enum\.UserInputType\.MouseButton1 or input\.UserInputType == Enum\.UserInputType\.Touch then Dragging = false end
            end\)'''
new_slider_2 = '''            local sCon2
            sCon2 = UserInputService.InputEnded:Connect(function(input)
                if not fill.Parent then sCon2:Disconnect() return end
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then Dragging = false end
            end)'''
content = content.replace(old_slider_2.replace('fill', 'Fill'), new_slider_2.replace('fill', 'Fill'))

# 4. Keybd connection memory leak
old_keybd = r'''            UserInputService\.InputBegan:Connect\(function\(input\)
                if Waiting and input\.UserInputType == Enum\.UserInputType\.Keyboard then'''
new_keybd = '''            local keyCon
            keyCon = UserInputService.InputBegan:Connect(function(input)
                if not BindBtn.Parent then keyCon:Disconnect() return end
                if Waiting and input.UserInputType == Enum.UserInputType.Keyboard then'''
content = content.replace(old_keybd, new_keybd)

# 5. UI Window toggle memory leak
old_toggle = r'''    UserInputService\.InputBegan:Connect\(function\(input, gp\)
        if not gp and input\.KeyCode == Self\.Keybind then ToggleUI\(\) end
    end\)'''
new_toggle = '''    local togCon
    togCon = UserInputService.InputBegan:Connect(function(input, gp)
        if not Main.Parent then togCon:Disconnect() return end
        if not gp and input.KeyCode == Self.Keybind then ToggleUI() end
    end)'''
content = content.replace(old_toggle, new_toggle)

# 6. Change "Version: V10.0 [Obsidian Edition]" to "Version: V11.0 [Premium Edition]"
content = content.replace('Version: V10.0 [Obsidian Edition]', 'Version: V11.0 [Premium Edition]')
content = content.replace('New Features vs V9:', 'New Features vs V10:\n    + Mobile Responsivity (UISizeConstraint & AspectRatio)\n    + Memory Leak Fixes (Destroy Connections)\n    + Automated Scaling & Fixes')

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Patching successful!")
