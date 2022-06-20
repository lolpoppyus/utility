--[[
    Custom tween, usually gets time off by around 0.002 seconds
    Works with drawing objects
]]

local Signal = loadstring(game:HttpGet("https://raw.githubusercontent.com/vozoid/utility/main/Signal.lua"))()

--[[
    Easing styles math: https://www.desmos.com/calculator/m8myals511
    Add more EasingStyles by doing this:
    Convert the Out math (Blue icon) (example: 1.001 · -2⁻¹⁰ˣ + 1 to something like
    {name} = function(delta)
        return 1.001 * (-2 ^ (-10 * delta)) + 1
    end
]]

local Tween = {
    EasingStyle = {
        Linear = function(delta)
            return delta
        end,

        Exponential = function(delta)
            return 1.001 * (-2 ^ (-10 * delta)) + 1
        end,

        Quad = function(delta)
            return -(delta - 1) ^ 2 + 1
        end,

        Quart = function(delta)
            return -(delta - 1) ^ 4 + 1
        end,

        Quint = function(delta)
            return (delta - 1) ^ 5 + 1
        end
    }
}

do
    -- Localization
    local render_stepped = game:GetService("RunService").RenderStepped
    local tick = tick
    local math_min = math.min
    local task_defer = task.defer
    local task_wait = task.wait
    local next = next

    Tween.__index =  Tween

    -- Function to support number lerping
    local function lerp(value1, value2, alpha)
        if type(value1) == "number" then
            return value1 + ((value2 - value1) * alpha)
        end
            
        return value1:lerp(value2, alpha)
    end

    --[[
        Creates a new tween
        @return Tween (table)
    ]]

    function Tween.new(object, info, values)
        local self = setmetatable({}, Tween)

        self.Completed = Signal.new()
        self._object = object
        self._time = info[1]
        self._easingStyle = info[2] or Tween.EasingStyle.Linear
        self._values = values

        return self
    end

    --[[
        Plays the tween
    ]]

    function Tween:Play()
        local loops = {}

        -- Loop through every property to edit
        for property, value in next, self._values do
            local start_time = tick()
            local start_value = self._object[property]
            local stopped = false

            loops[#loops + 1] = render_stepped:Connect(function()
                local delta = (tick() - start_time) / self._time

                -- Do the chosen EasingStyle's math
                local alpha = self._easingStyle(delta)

                task_defer(function()
                    self._object[property] = lerp(start_value, value, alpha)
                end)
            end)
        end

        task_defer(function()
            task_wait(self._time)

            -- Sets every property
            for property, value in next, self._values do
                self._object[property] = value
            end

            -- Disconnects every loop
            for _, connection in next, loops do
                connection:Disconnect()
            end

            self.Completed:Fire()
        end)
    end
end

local e = Instance.new("ScreenGui", game.CoreGui)
local f = Instance.new("Frame", e)
f.Size = UDim2.new(0, 300, 0, 300)
local r = Tween.new(f, {1, Tween.EasingStyle.Quad}, {Position = UDim2.new(0, 500, 0, 400)})
local old = tick()
r:Play()

r.Completed:Connect(function()
    print(tick() - old)
    print(f.Position)
end)
--[[
local e = Drawing.new("Square")
e.Visible = true
e.Filled = true
e.Thickness = 0
e.Color = Color3.fromRGB(192, 185, 20)
e.Size = Vector2.new(100, 100)
e.Position = Vector2.new(0, 0)

local r = Tween.new(e, 3, {Color = Color3.fromRGB(0, 255, 255)})
r:Play()
local old = tick()
r.Completed:Wait()
print(tick() - old)
print(e.Color)
e:Remove()]]