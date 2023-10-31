import Addicted.System
import Addicted.Threshold

// DebugAddictTo(Game.GetPlayer());
public func DebugAddictTo(player: wref<PlayerPuppet>) -> Void {
    let system = GameInstance.GetStatusEffectSystem(player.GetGame());
    system.ApplyStatusEffect(
        player.GetEntityID(),
        t"BaseStatusEffect.AddictToBonesMcCoy70",
        t"Addiction",
        player.GetEntityID(),
        Cast<Uint32>(1));
    System.GetInstance(player.GetGame()).UpdateEffect(ItemID.FromTDBID(t"Items.BonesMcCoy70V0"), Threshold.Severely);
}