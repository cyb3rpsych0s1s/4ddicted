local GameUI = require("GameUI")
local Cron = require("Cron")

registerForEvent("onInit", function()
    print("[Addicted]:onInit")

    Observe('PlayerPuppet', 'OnStatusEffectApplied', function(self, evt)
        print("[Addicted]:OnStatusEffectApplied")
        print(GameDump(evt))
    end)

    Observe('PlayerPuppet', 'OnStatusEffectRemoved', function (self, evt)
        print("[Addicted]:OnStatusEffectRemoved")
        print(GameDump(evt))
    end)

    GameUI.OnSessionStart(function()
        print("[Addicted]:OnSessionStart")
        -- Cron.After(0.25, CreateTweaks, nil)
    end)

    GameUI.OnSessionEnd(function()
        
    end)
end)

-- function CreateTweaks()
--     print("[Addicted]:CreateTweaks")
--     CName.add("splinter_addicted");
--     effects = GetPlayer():FindComponentByName("fx_player").effectDescs;
--     custom = entEffectDesc.new();
--     custom.effectName = "splinter_addicted";
--     custom.effect = "base\\fx\\camera\\splinter_buff\\purple_haze_fx.effect";
--     custom.id = 15896385745314451005;
--     table.insert(effects, custom);
--     GetPlayer():FindComponentByName("fx_player").effectDescs = effects;
-- end

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
