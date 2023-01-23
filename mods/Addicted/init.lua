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
                self.runtimeData.inGame = true;
                RegisterVFXs()
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

    function CreateVFX(effectName, effect)
        CName.new(effectName);
        local custom = entEffectDesc.new();
        custom.effectName = effectName;
        custom.effect = effect;
        return custom
    end

    function CreateVFXs()
        local vfxs = {}
        local mildly_splinter_buff  = CreateVFX("mildly_splinter_buff", "base\\fx\\camera\\splinter_buff\\mildly_splinter_buff_fx.effect")
        local piddly_splinter_buff  = CreateVFX("piddly_splinter_buff", "base\\fx\\camera\\splinter_buff\\piddly_splinter_buff_fx.effect")
        local mildly_reflex_buster  = CreateVFX("mildly_reflex_buster", "base\\fx\\camera\\reflex_buster\\mildly_reflex_buster.effect")
        local piddly_reflex_buster  = CreateVFX("piddly_reflex_buster", "base\\fx\\camera\\reflex_buster\\piddly_reflex_buster.effect")
        table.insert(vfxs, mildly_splinter_buff)
        table.insert(vfxs, piddly_splinter_buff)
        table.insert(vfxs, mildly_reflex_buster)
        table.insert(vfxs, piddly_reflex_buster)
        return vfxs
    end

    function RegisterVFXs()
        local vfxs = CreateVFXs()
        local size = table.maxn(vfxs)
        local effects = GetPlayer():FindComponentByName("fx_player").effectDescs
        local vfx
        for i = 0,size,1
        do
            print("[Addicted]:RegisterVFXs", " ", vfxs[i])
            vfx = vfxs[i]
            table.insert(effects, vfx)
        end
        GetPlayer():FindComponentByName("fx_player").effectDescs = effects
    end

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