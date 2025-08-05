module Addicted

import Addicted.Utils.*

private func CreateVFX(name: CName, asset: ResRef) -> ref<entEffectDesc> {
    let custom = new entEffectDesc();
    let reference = Reflection.GetTypeOf(custom);
    let clazz = reference.GetInnerType().AsClass();
    let effectName = clazz.GetProperty(n"effectName");
    let effect = clazz.GetProperty(n"effect");
    effectName.SetValue(ToVariant(custom), ToVariant(name));
    effect.SetValue(ToVariant(custom), ToVariant(asset));
    return custom;
}

private func CreateVFXs() -> array<ref<entEffectDesc>> {
    let vfxs: array<ref<entEffectDesc>> = [];
    let mildly_splinter_buff = CreateVFX(n"mildly_splinter_buff", r"addicted\\fx\\camera\\splinter_buff\\mildly_splinter_buff_fx.effect");
    let piddly_splinter_buff = CreateVFX(n"piddly_splinter_buff", r"addicted\\fx\\camera\\splinter_buff\\piddly_splinter_buff_fx.effect");
    let mildly_reflex_buster = CreateVFX(n"mildly_reflex_buster", r"addicted\\fx\\camera\\reflex_buster\\mildly_reflex_buster.effect");
    let piddly_reflex_buster = CreateVFX(n"piddly_reflex_buster", r"addicted\\fx\\camera\\reflex_buster\\piddly_reflex_buster.effect");
    ArrayPush(vfxs, mildly_splinter_buff);
    ArrayPush(vfxs, piddly_splinter_buff);
    ArrayPush(vfxs, mildly_reflex_buster);
    ArrayPush(vfxs, piddly_reflex_buster);
    return vfxs;
}

/// register VFX from WolvenKit archive
public func RegisterVFXs(player: ref<PlayerPuppet>) {
    let vfxs = CreateVFXs();
    let size = ArraySize(vfxs);
    let spawner = player.FindComponentByName(n"fx_player") as entEffectSpawnerComponent;
    let effects: array<ref<entEffectDesc>> = FromVariant(Reflection
    .GetTypeOf(spawner)
    .GetInnerType()
    .AsClass()
    .GetProperty(n"effectDescs")
    .GetValue(spawner));
    let vfx: ref<entEffectDesc>;
    let i: Int32 = 0;
    while i < size {
        if IsDefined(vfxs[i]) {
            vfx = vfxs[i];
            E(s"RegisterVFXs \(NameToString(FromVariant(Reflection.GetTypeOf(vfx).GetInnerType().AsClass().GetProperty(n"effectName").GetValue(vfx))))");
            ArrayPush(effects, vfx);
        }
        i += 1;
    }
    Reflection
    .GetTypeOf(spawner)
    .GetInnerType()
    .AsClass()
    .GetProperty(n"effectDescs")
    .SetValue(spawner, effects);
}
