---@class SurfaceStatusController
---@field Status string
---@field StatusDuration number
---@field Surface string
---@field Characters table<string, boolean>
---@field EventId integer
SurfaceStatusController = {}

function SurfaceStatusController:New(o)
    o = o or {}
    o.Characters = o.Characters or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

---@param grid EocAiGrid
---@param character EsvCharacter
function SurfaceStatusController:CheckForSurface(grid, character)
    local isInGroundSurface = false
    local isInCloudSurface = false
    local cellInfo = grid:GetCellInfo(character.WorldPos[1], character.WorldPos[3])
    if cellInfo.GroundSurface ~= nil then
        isInGroundSurface = Ext.Entity.GetSurface(cellInfo.GroundSurface).SurfaceType == self.Surface
    end
    if cellInfo.CloudSurface ~= nil then
        isInCloudSurface = Ext.Entity.GetSurface(cellInfo.CloudSurface).SurfaceType == self.Surface
    end
    return isInGroundSurface or isInCloudSurface
end

function SurfaceStatusController:Unregister()
    Ext.Events.Tick:Unsubscribe(self.EventId)
    self.EventId = nil
end

---@param character string
function SurfaceStatusController:RemoveCharacter(character)
    self.Characters[character] = nil
    if not next(self.Characters) then
        self:Unregister()
    end
end

function SurfaceStatusController:Register()
    self.EventId = Ext.Events.Tick:Subscribe(function()
        if next(self.Characters) then
            local grid = Ext.Entity.GetAiGrid()
            for character in pairs(self.Characters) do
                local esvChar = Ext.Entity.GetCharacter(character) --[[@as EsvCharacter]]
                if esvChar ~= nil then
                    local isInSurface = self:CheckForSurface(grid, esvChar)
                    local status = esvChar:GetStatus(self.Status)
                    if isInSurface then
                        if status == nil then
                            local newStatus = Ext.PrepareStatus(character, self.Status, self.StatusDuration)
                            Ext.ApplyStatus(newStatus)
                        elseif self.StatusDuration > 0 then
                            status.CurrentLifeTime = self.StatusDuration
                            status.RequestClientSync = true
                        end
                    elseif not isInSurface and status ~= nil then
                        self:RemoveCharacter(character)
                        if self.StatusDuration <= 0 then
                            RemoveStatus(character, self.Status)
                        else
                            status.KeepAlive = false
                        end
                    end
                else
                    self:RemoveCharacter(character)
                end
            end
        end
    end)
end

---@param character string
function SurfaceStatusController:AddCharacter(character)
    self.Characters[character] = true
    if self.EventId == nil then
        self:Register()
    end
end

