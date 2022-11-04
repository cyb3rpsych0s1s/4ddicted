registerForEvent("onInit", function()
    print("CET:Addicted:onInit")
    
--     -- derive effect icon
--   TweakDB:CloneRecord("UIIcon.acid_doused", "UIIcon.regeneration_icon")
--   TweakDB:SetFlat("UIIcon.acid_doused.atlasPartName", "acid_doused")
--   -- derive status effect
--   TweakDB:CloneRecord("BaseStatusEffect.Addicted", "BaseStatusEffect.Drugged")
end)

function StrLocKey(key)
    if type(key) == "string" then
        return "LocKey#" .. tostring(LocKey(key).hash):gsub("ULL$", "")
    end
    if type(key) == "cdata" then
        return "LocKey#" .. tostring(key):gsub("ULL$", "")
    end
    if type(key) == "number" then
        return "LocKey#" .. tostring(key)
    end
    return ""
end
