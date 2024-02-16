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
        local mildly_splinter_buff  = CreateVFX("mildly_splinter_buff", "addicted\\fx\\camera\\splinter_buff\\mildly_splinter_buff_fx.effect")
        local piddly_splinter_buff  = CreateVFX("piddly_splinter_buff", "addicted\\fx\\camera\\splinter_buff\\piddly_splinter_buff_fx.effect")
        local mildly_reflex_buster  = CreateVFX("mildly_reflex_buster", "addicted\\fx\\camera\\reflex_buster\\mildly_reflex_buster.effect")
        local piddly_reflex_buster  = CreateVFX("piddly_reflex_buster", "addicted\\fx\\camera\\reflex_buster\\piddly_reflex_buster.effect")
        local reflex_purple         = CreateVFX("reflex_purple", "addicted\\fx\\camera\\purple_haze\\reflex_buster.effect")
        local splinter_gold         = CreateVFX("splinter_gold", "addicted\\fx\\camera\\purple_haze\\splinter_buff_fx.effect")
        local purple_haze           = CreateVFX("purple_haze", "addicted\\fx\\camera\\purple_haze\\purple_haze.effect")
        table.insert(vfxs, mildly_splinter_buff)
        table.insert(vfxs, piddly_splinter_buff)
        table.insert(vfxs, mildly_reflex_buster)
        table.insert(vfxs, piddly_reflex_buster)
        table.insert(vfxs, reflex_purple)
        table.insert(vfxs, maitre_splinter)
        table.insert(vfxs, purple_haze)
        return vfxs
    end

    function RegisterVFXs()
        local vfxs = CreateVFXs()
        local size = table.maxn(vfxs)
        local effects = GetPlayer():FindComponentByName("fx_player").effectDescs
        local vfx
        for i = 0,size,1
        do
            if vfxs[i] then
                print("[Addicted]:RegisterVFXs", " ", vfxs[i])
                vfx = vfxs[i]
                table.insert(effects, vfx)
            end
        end
        GetPlayer():FindComponentByName("fx_player").effectDescs = effects
    end
end

return addicted:new()