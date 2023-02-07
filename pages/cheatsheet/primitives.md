# Primitives

```swift
let v: String = "Hello world";
let v: CName = n"Debuff";
let v: TweakDBID = t"BaseStatusEffect.BlackLaceV0";
let v: ResRef = r"base\\gameplay\\gui\\common\\main_colors.inkstyle";
let v: LocKey = l"MyMod-Setting-Desc";
```

```swift
let v: String = NameToString(n"Debuff");
let v: Bool = IsNameValid(n"Debuff");

let v: TweakDBID = TDBID.None();
let v: TweakDBID = TDBID.Create("Items.BlackLaceV0");
let v: Bool = TDBID.IsValid(t"Items.BlackLaceV0");
let v: Uint64 = TDBID.ToNumber(t"Items.BlackLaceV0");
let v: String = TDBID.ToStringDEBUG(t"Items.BlackLaceV0");

let v: String = ItemID.ToDebugString(someItemID);
let v: Bool = ItemID.IsDefined(someItemID);
let v: TweakDBID = ItemID.GetTDBID(someItemID);
let v: ItemID = ItemID.FromTDBID(t"Items.FirstAidWhiffV0");

let system: ICooldownSystem = Game.ICooldownSystem();
let v: Int32 = system.GetCIDByItemID(someItemID);
let v: Int32 = system.GetCIDByRecord(t"BaseStatusEffect.HealthBooster");
```

```swift
let delay: DelayID = GameInstance.GetDelaySystem(player.GetGame()).DelayCallback();
let defined: Bool = NotEquals(delay, GetInvalidDelayID());
```
