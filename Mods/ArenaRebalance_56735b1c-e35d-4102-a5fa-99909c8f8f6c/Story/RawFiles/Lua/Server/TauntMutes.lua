Ext.Osiris.RegisterListener("CharacterStatusApplied", 3, "after", function(target, status, caster)
    if status == "TAUNTED" then
		_P(status)
       ApplyStatus(target, "SP_TAUNT_MUTE", 6.0, 1, caster)
    end
end)

Ext.Osiris.RegisterListener("CharacterStatusApplied", 3, "after", function(target, status, caster)
    --
    if status == "ENRAGED" then
      RemoveStatus(target, "SP_TAUNT_MUTE")
    end
    --
    if status == "ARCANE_STITCH" then
        Ext.OnNextTick(function() RemoveStatus(target, "SP_TAUNT_MUTE") end)
    end
    --
    if status == "CLEAR_MINDED" then
        Ext.OnNextTick(function() RemoveStatus(target, "SP_TAUNT_MUTE") end)
    end
    --
    if status == "CHARMED" then
        Ext.OnNextTick(function() RemoveStatus(target, "SP_TAUNT_MUTE") end)
    end
    --
    if status == "MAD" then
        Ext.OnNextTick(function() RemoveStatus(target, "SP_TAUNT_MUTE") end)
    end
end)