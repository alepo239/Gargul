---@type GL
local _, GL = ...;

---@class Events
GL.Events = {
    _initialized = false,
    Frame = nil,
    Registry = {
        EventListeners = {},
        EventByIdentifier = {},
    },
};

local Events = GL.Events; ---@type Events

--- Prepare the event frame for future use
---
---@param EventFrame table
---@return void
function Events:_init(EventFrame)
    GL:debug("Events:_init");

    -- No need to initialize this class twice
    if (self._initialized) then
        return;
    end

    self.Frame = EventFrame;
    self.Frame:SetScript("OnEvent", self.listen);

    self._initialized = true;
end

--- Helper function that turns the mouse button pressed and modifier keys held into a identifier string
---
---@param mouseButtonPressed string
---@return string
function Events:getClickCombination(mouseButtonPressed)
    local ShortcutKeySegments = {};

    if (IsControlKeyDown()) then
        tinsert(ShortcutKeySegments, "CTRL");
    end

    if (IsAltKeyDown()) then
        tinsert(ShortcutKeySegments, "ALT");
    end

    if (IsShiftKeyDown()) then
        tinsert(ShortcutKeySegments, "SHIFT");
    end

    if (mouseButtonPressed == "LeftButton") then
        tinsert(ShortcutKeySegments, "CLICK");
    end

    if (mouseButtonPressed == "RightButton") then
        tinsert(ShortcutKeySegments, "RIGHTCLICK");
    end

    return table.concat(ShortcutKeySegments, "_");
end

--- Register an event listener
---
---@param identifier string
---@param event string
---@param callback function
---@return boolean
function Events:register(identifier, event, callback)
    GL:debug("Events:register");

    -- The user is attempting a mass assignment, pass it on!
    if (type(identifier) == "table") then
        return self:massRegister(identifier, event);
    end

    if (GL:empty(identifier)
        or GL:empty(event)
        or type(callback) ~= "function"
    ) then
        return false;
    end

    -- We're not listening to this event yet, register it
    if (GL:empty(self.Registry.EventListeners[event])) then
        -- We exclude internal events (prefixed with GL.) since we fire
        -- those manually from within the codebase without relying on a frame
        if (not GL:strStartsWith(event, "GL.")) then
            self.Frame:RegisterEvent(event);
        end

        self.Registry.EventListeners[event] = {};
    end

    self.Registry.EventByIdentifier[identifier] = event;
    self.Registry.EventListeners[event][identifier] = callback;

    return true;
end

--- Unregister a listener based on its identifier
---
---@param identifier string
---@return void
function Events:unregister(identifier)
    if (type(identifier) == table) then
        for _, event in pairs(identifier) do
            self:unregister(event);
        end

        return;
    end

    -- This is to get rid of any reference
    local event = tostring(self.Registry.EventByIdentifier[identifier]);

    -- Make sure the event still exists
    if (GL:empty(event)
        or not self.Registry.EventByIdentifier[identifier]
    ) then
        return;
    end

    self.Registry.EventListeners[event][identifier] = nil;
    self.Registry.EventByIdentifier[identifier] = nil;

    -- Check if the given event still has active listeners
    local eventStillHasListeners = false;
    if (not GL:empty(self.Registry.EventListeners[event])) then
        eventStillHasListeners = true;
    end

    -- There are no longer any listeners for this event
    -- so we can unregister it on our event frame
    if (not eventStillHasListeners) then
        self.Registry.EventListeners[event] = nil;

        -- We exclude internal events (prefixed with GL.) since we fire
        -- those manually from within the codebase without relying on a frame
        if (not GL:strStartsWith(event, "GL.")) then
            self.Frame:UnregisterEvent(event);
        end
    end
end

--- Fire the event listeners whenever a registered event comes in
---
---@param event string
---@param . any
---@return void
function Events:listen(event, ...)
    local args = {...};

    for _, listener in pairs(GL.Events.Registry.EventListeners[event] or {}) do
        pcall(function () listener(event, unpack(args)); end);
    end
end

--- Register multiple event listeners
---
---@param EventDetails table
---@param callback function
---@return boolean
function Events:massRegister(EventDetails, callback)
    for _, Entry in pairs(EventDetails) do
        local identifier, event;

        if (type(Entry) == "table") then
            identifier = Entry[1];
            event = Entry[2];
        elseif (type(Entry) == "string") then
            event = Entry;
            identifier = Entry .. "Lister" .. GL:uuid();
        else
            return false;
        end

        self:register(identifier, event, callback);
    end
end

--- Fire an event manually (assuming there's a listener for it)
---
---@param event string
---@param . any
---@return void
function Events:fire(event, ...)
    self:listen(event, ...);
end

GL:debug("Events.lua");