Ext.Osiris.RegisterListener("NRD_OnStatusAttempt", 4, "before", function(target, status, handle, instigator)
    if instigator == "NULL_00000000-0000-0000-0000-000000000000" then return end -- Spams the console in few cases otherwise
    local s = Ext.ServerEntity.GetStatus(target, handle) --- @type EsvStatus|EsvStatusHeal|EsvStatusHealing
    local healer = Ext.ServerEntity.GetCharacter(instigator)
    target = Ext.ServerEntity.GetCharacter(target)
    if status == "REGENERATION" and (target:GetStatus("DECAYING_TOUCH") or target.Stats.TALENT_Zombie) then
        local stat = Ext.Stats.Get(s.StatusId)
        s.HealAmount = math.min(Ext.Utils.Round(stat.HealValue * Game.Math.GetAverageLevelDamage(healer.Stats.Level) * Ext.ExtraData.HealToDamageRatio / 100), 30)
        return
    end
end)