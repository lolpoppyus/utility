-- made by vozoid B)

local Signal = {}
local Connection = {}

do
    -- localization
    local instance_new = Instance.new
    local coroutine_wrap = coroutine.wrap
    local table_clear = table.clear
    local setmetatable = setmetatable
    local table_remove = table.remove

    Signal.__index = Signal
    Connection.__index = Connection

    --[[
        Creates a new connection
        @return Connection (table)
    ]]

    function Connection.new(event, callback)
        local self = setmetatable({}, Connection)

        self.Connected = true
        self._connection = event._event:Connect(callback)
        self._connection_index = #event._connections + 1
        self._event = event

        event._connections[#event._connections + 1] = self._connection

        return self
    end

    --[[
        Disconnects a connection
    ]]

    function Connection:Disconnect()
        table_remove(self._event._connections, self._connection_index)
        self.Connected = false

        self._connection:Disconnect()
    end

    --[[
        Creates a new signal
        @return Signal (table)
    ]]

    function Signal.new()
        local self = setmetatable({}, Signal)

        self._bindable_event = instance_new("BindableEvent")
        self._event = self._bindable_event.Event
        self._connections = {}

        return self
    end

    --[[
        Fires the connections with the argument ...
    ]]

    function Signal:Fire(...)
         self._bindable_event:Fire(...)
    end

    --[[
        Create a new connection. Returns a connection which can be disconnected. Callback called when :Fire(...) is called
        @return Connection (table)
    ]]

    function Signal:Connect(callback)
        local connection = Connection.new(self, callback)
        return connection
    end

    --[[
        Yields the thread until :Fire(...) is called. Returns the arguments that :Fire(...) provided.
    ]]

    function Signal:Wait()
        return self._event:Wait()
    end

    --[[
        Disconnects all connections to the signal. The signal is still useable after calling this.
    ]]

    function Signal:DisconnectAll()
        for _, connection in next, self._connections do
            -- Check if connection hasnt been disconnected
            if connection.Connected then
                -- Disconnects connection
                connection:Disconnect()
            end
        end

        -- Clears all connections
        self._connections = {}
    end

     --[[
        Destroys the BindableEvent and disconnects all connections to the signal. The signal is still unusable after calling this.
        Clears the table and sets the metatable to nil.
    ]]

    function Signal:Destroy()
        if self._bindable_event then
            -- Destroys the BindableEvent and sets the BindableEvent and Event to nil
            self._bindable_event:Destroy()
            self._bindable_event = nil
            self._event = nil
        end

        -- Disconnects all connections
        self:DisconnectAll()

        -- Makes the signal unusable
        setmetatable(self, nil)
        table_clear(self)
    end
end

return Signal
