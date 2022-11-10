registerForEvent("onInit", function()
    print("CET:Addicted:onInit")
    Observe('PlayerPuppet', 'OnStatusEffectApplied', function(self, evt)
        print("CET:OnStatusEffectApplied")
        print(GameDump(evt))
    end)
    Observe('PlayerPuppet', 'OnStatusEffectRemoved', function (self, evt)
        print("CET:OnStatusEffectRemoved")
        print(GameDump(evt))
    end)
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
