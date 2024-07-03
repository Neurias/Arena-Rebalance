---@class InSurfaceTracker
---@field Characters table<string, boolean>
---@field SurfaceControllers SurfaceStatusController[]
InSurfaceTracker = {
    Characters = {},
    SurfaceControllers = {}
}

---@param surface ESurfaceFlag
---@param status string
---@param statusDuration number
function InSurfaceTracker:CreateNewController(surface, status, statusDuration)
    local controller = SurfaceStatusController:New{Surface = surface, Status = status, StatusDuration = statusDuration}
    table.insert(self.SurfaceControllers, controller)
end

---@param grid EocAiGrid
---@param character EsvCharacter
---@return ESurfaceFlag|nil, ESurfaceFlag|nil
function InSurfaceTracker:GetSurfaces(grid, character)
    local groundSurface
    local cloudSurface
    local cellInfo = grid:GetCellInfo(character.WorldPos[1], character.WorldPos[3])
    if cellInfo.GroundSurface ~= nil then
        groundSurface = Ext.Entity.GetSurface(cellInfo.GroundSurface).SurfaceType
    end
    if cellInfo.CloudSurface ~= nil then
        cloudSurface = Ext.Entity.GetSurface(cellInfo.CloudSurface).SurfaceType
    end
    return groundSurface, cloudSurface
end

function InSurfaceTracker:RegisterTickListener()
    for _, character in pairs(Ext.Entity.GetAllCharacterGuids()) do
        if HasActiveStatus(character, "INSURFACE") == 1 then
            self.Characters[character] = true
        end
    end

    Ext.Events.Tick:Subscribe(function()
        local grid = Ext.Entity.GetAiGrid()
        for character in pairs(self.Characters) do
            local esvChar = Ext.Entity.GetCharacter(character) --[[@as EsvCharacter]]
            if esvChar ~= nil then
                local ground, cloud = self:GetSurfaces(grid, esvChar)
                for _, controller in ipairs(self.SurfaceControllers) do
                    if controller.Surface == ground or controller.Surface == cloud then
                        controller:AddCharacter(character)
                    end
                end
            else
                self.Characters[character] = nil
            end
        end
    end)
end

Ext.Osiris.RegisterListener("CharacterStatusApplied", 3, "after", function(character, status)
    if status == "INSURFACE" then
        InSurfaceTracker.Characters[character] = true
    end
end)

Ext.Osiris.RegisterListener("CharacterStatusRemoved", 3, "after", function(character, status)
    if status == "INSURFACE" then
        InSurfaceTracker.Characters[character] = nil
    end
end)

--console gets spammed without an event wrapper because the ai grid doesn't get initialized until the level is loaded
Ext.Osiris.RegisterListener("GameStarted", 2, "after", function()
    InSurfaceTracker:RegisterTickListener()
end)
Ext.Events.ResetCompleted:Subscribe(function() InSurfaceTracker:RegisterTickListener() end)