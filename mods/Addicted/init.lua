local GameUI = require("GameUI")
local Cron = require("Cron")

addicted = {
    runtimeData = {
        inGame = false
    }
}

function addicted:new()
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
            Cron.After(0.25, function ()
                print("[Addicted]:Cron:After:tick")
                self.runtimeData.inGame = true
                CName.new("purple_haze");
                effects = GetPlayer():FindComponentByName("fx_player").effectDescs;
                custom = entEffectDesc.new();
                custom.effectName = "purple_haze";
                custom.effect = "base\\fx\\camera\\splinter_buff\\purple_haze_fx.effect";
                table.insert(effects, custom);
                GetPlayer():FindComponentByName("fx_player").effectDescs = effects;
            end, nil)
        end)

        GameUI.OnSessionEnd(function()
            self.runtimeData.inGame = false
        end)

        self.runtimeData.inGame = not GameUI.IsDetached()
    end)

    registerForEvent('onUpdate', function(delta)
        -- This is required for Cron to function
        Cron.Update(delta)
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
end

return addicted:new()