if not getgenv().drawingextension then
    getgenv().drawingextension = true

    local Signal = loadstring(game:HttpGet("https://raw.githubusercontent.com/lolpoppyus/utility/main/Signal.lua"))()

    local inputService = game:GetService("UserInputService")
    local runService = game:GetService("RunService")

    function mouse_over(obj)
        if obj.__OBJECT_EXISTS then
            local posX = obj.Position.X
            local posY = obj.Position.Y

            local sizeX, sizeY
            if typeof(obj.Size) == "Vector2" then
                sizeX = posX + obj.Size.X
                sizeY = posY + obj.Size.Y
            else
                sizeX = posX + obj.TextBounds.X
                sizeY = posY + obj.TextBounds.Y
            end
            
            if inputService:GetMouseLocation().X >= posX and inputService:GetMouseLocation().Y >= posY and inputService:GetMouseLocation().X <= sizeX and inputService:GetMouseLocation().Y <= sizeY then
                return true
            end

            return false
        else
            return false
        end
    end

    local properties = {
        Name = "Name",
        Parent = "Parent",
        AbsolutePosition = "AbsolutePosition"
    }

    local classes = {
        Square = "Square",
        Text = "Text",
        Image = "Image"
    }

    local draw = Drawing.new
    Drawing.new = function(shape)
        local obj = draw(shape)

        local mt = getmetatable(obj)

        local events = {
            MouseButton1Click = Signal.new(),
            MouseButton2Click = Signal.new(),
            MouseButton1Down = Signal.new(),
            MouseButton1Up = Signal.new(),
            MouseButton2Down = Signal.new(),
            MouseButton2Up = Signal.new(),
            MouseEnter = Signal.new(),
            MouseLeave = Signal.new(),
            MouseMoved = Signal.new(),
            InputBegan = Signal.new(),
            InputEnded = Signal.new(),
            InputChanged = Signal.new(),
            ChildAdded = Signal.new(),
            DescendantAdded = Signal.new()
        }

        local mouseEntered = false

        -- Events
        if classes[shape] then
            for event, signal in next, events do
                rawset(obj, event, signal)
            end
            
            inputService.InputBegan:connect(function(input)
                -- InputBegan
                if mouse_over(obj) then
                    obj.InputBegan:Fire(input)
                end

                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    --MouseButton1Click and MouseButton1Down and InputBegan
                    if mouse_over(obj) then
                        obj.MouseButton1Click:Fire()
                        obj.MouseButton1Down:Fire()
                    end
                elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
                    --MouseButton2Click and MouseButton2Down
                    if mouse_over(obj) then
                        obj.MouseButton2Click:Fire()
                        obj.MouseButton2Down:Fire()
                    end
                end
            end)

            inputService.InputEnded:connect(function(input)
                -- InputEnded
                if mouse_over(obj) then
                    obj.InputEnded:Fire(input)
                end

                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    --MouseButton1Up
                    if mouse_over(obj) then
                        obj.MouseButton1Up:Fire()
                    end
                elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
                    -- MouseButton2Up
                    if mouse_over(obj) then
                        obj.MouseButton2Up:Fire()
                    end
                end
            end)

            inputService.InputChanged:connect(function(input)
                if input.UserInputType ~= Enum.UserInputType.Keyboard and input.UserInputType ~= Enum.UserInputType.TextInput then
                    if mouse_over(obj) then
                        obj.InputChanged:Fire(input)
                    end
                end

                if input.UserInputType == Enum.UserInputType.MouseMovement then
                    if mouse_over(obj) then
                        -- MouseMoved
                        obj.MouseMoved:Fire()

                        -- MouseEnter
                        if not mouseEntered then
                            obj.MouseEnter:Fire()
                            mouseEntered = true
                        end
                    else
                        -- MouseLeave
                        if mouseEntered then
                            obj.MouseLeave:Fire()
                            obj.InputEnded:Fire(input)
                            mouseEntered = false
                        end
                    end
                end
            end)
        end
        
        -- Children and Descendants
        local children = {}
        local descendants = {}

        rawset(obj, "GetChildren", function()
            for i, child in next, children do
                if not child.__OBJECT_EXISTS then
                    table.remove(newchildren, i)
                end
            end

            return children
        end)

        rawset(obj, "GetDescendants", function()
            for i, descendant in next, descendants do
                if not descendant.__OBJECT_EXISTS then
                    table.remove(newchildren, i)
                end
            end

            return descendants
        end)

        rawset(obj, "FindFirstChild", function(self, str)
            for _, child in next, children do
                if child.Name == str then
                    return child
                end
            end
        end)

        -- __newindex hook
        local oldnewindex
        oldnewindex = hookfunction(mt.__newindex, function(t, k, v)
            -- Name
            if k == "Name" then
                rawset(t, k, v)
            end
            
            -- Parents, Descendants and Children
            if k == "Parent" then
                if typeof(v) == "table" then
                    table.insert(v:GetChildren(), t)
                    v.DescendantAdded:Fire(t)
                    v.ChildAdded:Fire(t)

                    local highestParent = v
                    local lastHighestParent = highestParent

                    repeat
                        table.insert(lastHighestParent:GetDescendants(), t)
                        lastHighestParent.DescendantAdded:Fire(t)

                        highestParent = highestParent.Parent
                        lastHighestParent = highestParent
                    until
                        typeof(highestParent) ~= "table"

                    rawset(t, k, v)
                else
                    error("Invalid parent type: " .. typeof(v))
                end
            end

            if k == "Position" then
                rawset(t, "AbsolutePosition", v)
            end

            -- return drawing property (position, size, etc)
            if not properties[k] then
                oldnewindex(t, k, v)
            end
        end)

        -- __index hook
        local oldindex
        oldindex = hookfunction(mt.__index, function(t, k, v)
            if properties[k] then
                -- return property
                return rawget(t, k)
            else
                -- return drawing property (position, size, etc)
                return oldindex(t, k, v)
            end
        end)

        return obj
    end
end
