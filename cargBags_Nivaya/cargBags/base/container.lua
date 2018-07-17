--[[
    cargBags: An inventory framework addon for World of Warcraft

    Copyright (C) 2010  Constantin "Cargor" Schomburg <xconstruct@gmail.com>

    cargBags is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation; either version 2
    of the License, or (at your option) any later version.

    cargBags is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with cargBags; if not, write to the Free Software
    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
]]
local _, ns = ...
local cargBags = ns.cargBags

-- Lua Globals --
local next, ipairs = _G.next, _G.ipairs

--[[!
    @class Container
        The container class provides the virtual bags for cargBags
]]
local Container = cargBags:NewClass("Container", nil, "Button")

local mt_bags = {__index = function(self, bagID)
    self[bagID] = _G.CreateFrame("Frame", nil, self.container)
    self[bagID]:SetID(bagID)
    return self[bagID]
end}

--[[!
    Creates a new instance of the class
    @param name <string>
    @param ... Arguments passed to the OnCreate-callback
    @return container <Container>
    @callback container:OnCreate(name, ...)
]]
function Container:New(name, ...)
    cargBags.debug("Container:New", name, ...)
    local implName = self.implementation.name
    local container = _G.setmetatable(_G.CreateFrame("Button", implName..name), self.__index)

    container.name = name
    container.buttons = {}
    container.bags = _G.setmetatable({container = container}, mt_bags)
    container:ScheduleContentCallback()

    container.implementation.contByName[name] = container -- Make this into pretty function?
    _G.tinsert(container.implementation.contByID, container)

    container:SetParent(self.implementation)

    if container.OnCreate then container:OnCreate(name, ...) end

    return container
end

--[[!
    Adds an ItemButton to this container
    @param button <ItemButton>
    @callback button:OnAdd(self)
    @callback OnButtonAdd(button)
]]
function Container:AddButton(button)
    cargBags.debug("Container:AddButton", button)
    button.container = self
    button:SetParent(self.bags[button.bagID])
    self:ScheduleContentCallback()
    _G.tinsert(self.buttons, button)
    if button.OnAdd then button:OnAdd(self) end
    if self.OnButtonAdd then self:OnButtonAdd(button) end
end

--[[!
    Removes an ItemButton from the container
    @param button <ItemButton>
    @callback button:OnRemove(self)
    @callback OnButtonRemove(button)
]]
function Container:RemoveButton(button)
    cargBags.debug("Container:RemoveButton", button)
    for i, single in ipairs(self.buttons) do
        if button == single then
            self:ScheduleContentCallback()
            button.container = nil
            if button.OnRemove then button:OnRemove(self) end
            if self.OnButtonRemove then self:OnButtonRemove(button) end
            return _G.tremove(self.buttons, i)
        end
    end
end

--[[
    @callback OnContentsChanged()
]]
local updater, scheduled = _G.CreateFrame"Frame", {}
updater:Hide()
updater:SetScript("OnUpdate", function(self)
    self:Hide()
    for container in next, scheduled do
        if(container.OnContentsChanged) then container:OnContentsChanged() end
        scheduled[container] = nil
    end
end)

--[[
    Schedules a Content-callback in the next update
]]
function Container:ScheduleContentCallback()
    cargBags.debug("Container:ScheduleContentCallback")
    scheduled[self] = true
    updater:Show()
end

--[[
    Applies a function to the contained buttons
    @param func <function>
    @param ... Arguments which are passed to the function
]]
function Container:ApplyToButtons(func, ...)
    cargBags.debug("Container:ApplyToButtons", ...)
    for i, button in next, self.buttons do
        func(button, ...)
    end
end