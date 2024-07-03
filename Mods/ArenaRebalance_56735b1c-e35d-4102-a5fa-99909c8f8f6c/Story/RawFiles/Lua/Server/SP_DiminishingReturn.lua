local diminishingReturnMult = {
    SP_WEB = 0.65
}

local function CustomPow(x, y)
    if y > 1 then
        return CustomPow(x * x, y-1)
    else
        return x
    end
end

local function GetTableSize(table)
	local size = 0
    if not table then return 0 end
	for i,j in pairs(table) do
		size = size + 1
	end
	return size
end

--- Table that keep tracks of active DMRs
StatusMemory = {}

StatusMemory.__index = StatusMemory

---@param character EsvCharacter
---@param status string
---@param applications integer
local function StatusPowerDecrease(character, status, applications)
    local status = character:GetStatus(status)
    if not status then return end
    local multiplier = CustomPow(diminishingReturnMult[status.StatusId], applications)
    status.StatsMultiplier = status.StatsMultiplier * multiplier
    local entry = Ext.Stats.Get(status.StatusId).StatsId
    for i,statArray in pairs(character.Stats.DynamicStats) do
        if entry == statArray.TranslationKey then
            for stat, value in pairs(statArray) do
                if type(value) == "number" and stat ~= "Level" then
                    statArray[stat] = math.floor(tonumber(value) * multiplier)
                end
            end
        end
    end
end

function StatusMemory:Increment(character, status)
    if not self[character] then
        self[character] = {}
    end
    if not self[character][status] then
        self[character][status] = 1
    elseif self[character][status] then
        self[character][status] = self[character][status] + 1
    end
end

function StatusMemory:Wipe(character, status)
    if not self[character] then return end
    if self[character][status] then
        self[character][status] = nil
    end
    if GetTableSize(self[character]) == 0 then
        self[character] = nil
    end
end

function StatusMemory:ApplyDMR(character, status)
    if not self[character] then return end
    if not self[character][status] then
        return
    elseif self[character][status] then
        StatusPowerDecrease(Ext.ServerEntity.GetCharacter(character), status, self[character][status])
    end
end

Ext.Osiris.RegisterListener("CharacterGuarded", 1, "before", function(character)
    SetTag(character, "SP_HasDelayed")
end)

Ext.Osiris.RegisterListener("ObjectTurnStarted", 1, "before", function(character)
    if IsTagged(character, "SP_HasDelayed") == 0 then
        local char = Ext.ServerEntity.GetCharacter(character)
        for status, mult in pairs(diminishingReturnMult) do
            local statusInstance = char:GetStatus(status)
            if statusInstance then
                StatusMemory:Increment(char.MyGuid, status)
            else
                StatusMemory:Wipe(char.MyGuid, status)  
            end
        end
    end
    ClearTag(character, "SP_HasDelayed")
end)

Ext.Osiris.RegisterListener("ObjectTurnEnded", 1, "before", function(character)
    if IsTagged(character, "SP_HasDelayed") == 0 and StatusMemory[GetUUID(character)] then
        local char = Ext.ServerEntity.GetCharacter(character)
        for status, mult in pairs(diminishingReturnMult) do
            if char:GetStatus(status) then
                StatusMemory:ApplyDMR(char.MyGuid, status)
            end
        end
    end
end)

--- @param e EsvLuaBeforeStatusApplyEvent
Ext.Events.BeforeStatusApply:Subscribe(function(e)
    local character = Ext.ServerEntity.GetCharacter(e.Status.TargetHandle).MyGuid   
    if StatusMemory[character] and StatusMemory[character][e.Status.StatusId] then     
        local multiplier = 1
        if IsTagged(character, "SP_HasDelayed") == 0 then
            multiplier = CustomPow(diminishingReturnMult[e.Status.StatusId], StatusMemory[character][e.Status.StatusId])
        elseif StatusMemory[character][e.Status.StatusId] > 2 then
            multiplier = CustomPow(diminishingReturnMult[e.Status.StatusId], StatusMemory[character][e.Status.StatusId]-1)
        end
        e.Status.StatsMultiplier = e.Status.StatsMultiplier * multiplier
    end
end)
