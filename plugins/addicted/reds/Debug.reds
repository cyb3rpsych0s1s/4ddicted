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
        Cast<Uint32>(2));
    System.GetInstance(player.GetGame()).UpdateEffect(ItemID.FromTDBID(t"Items.BonesMcCoyV0"), Threshold.Notably);
}