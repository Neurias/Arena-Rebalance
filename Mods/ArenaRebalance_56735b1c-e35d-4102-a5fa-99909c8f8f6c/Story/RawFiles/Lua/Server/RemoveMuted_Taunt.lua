local cleansedStatuses = {
    ENRAGED = true,
    ARCANE_STITCH = true,
    CLEAR_MINDED = true,
    CHARMED = true,
    MAD = true,
}

Ext.Osiris.RegisterListener("CharacterStatusApplied", 3, "after", function(target, status, caster)
    if cleansedStatuses[status] == true then
        RemoveStatus(target, "SP_TAUNT_MUTE")
    end
end)

Ext.Osiris.RegisterListener("CharacterStatusRemoved", 3, "before", function(character, status, instigator)
	if status == "TAUNTED" then
		RemoveStatus(character, "SP_TAUNT_MUTE")
	end
end)