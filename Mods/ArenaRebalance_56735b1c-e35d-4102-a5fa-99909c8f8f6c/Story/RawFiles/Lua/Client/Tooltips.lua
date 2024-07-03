Ext.Events.SessionLoaded:Subscribe(function(e)
    Game.Tooltip.RegisterListener("Skill", "Shout_Adrenaline", function(character, skill, tooltip)
        local property = tooltip:GetElement("SkillProperties").Properties[1]
        local label = string.gsub(string.reverse(property.Label), "%d+", "3", 1)
        property.Label = string.reverse(label)
    end)
end)