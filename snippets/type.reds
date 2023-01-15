module Addicted

/// keep track of consumption per substance
public class Consumption {
    let id: TweakDBID;
    let consumed: Int32;

    public static func Create(id: TweakDBID) -> ref<Consumption> {
        let consumption = new Consumption();
        consumption.id = id;
        consumption.consumed = 1;
        return consumption;
    }

    /// return printable substance
    public func ToPrettyString() -> String {
        return TDBID.ToStringDEBUG(this.id) + "(" + this.consumed + ")";
    }
}

/// keep track of substances consumption
public class Consumptions {
    let isildur: array<ref<Consumption>>;

    public static func New() -> ref<Consumptions> {
        let isildur = new Consumptions();
        return isildur;
    }

    /// update whenever substance weans off
    public func WeanOff(substance: TweakDBID) -> Void {
        let found = Consumptions.AlreadyConsumed(substance);
        if NotEquals(found, -1) {
            this.isildur[found].consumed -= 1;
        }
    }

    /// update whenever substance is consumed
    public func Consume(substance: TweakDBID) -> Void {
        let found = Consumptions.AlreadyConsumed(substance);
        if NotEquals(found, -1) {
            this.isildur[found].consumed += 1;
        } else {
            ArrayPush(this.isildur, Consumption.Create(substance));
        }
    }

    /// check if substance has already been consumed
    public func AlreadyConsumed(consumed: TweakDBID) -> Int32 {
        let at: Int32 = -1;
        for existing in this.isildur {
            at += 1;
            if existing.id == consumed {
                return at;
            }
        }
        return at;
    }

    /// return comma separated printable substances
    public func ToPrettyString() -> String {
        let out = "";
        let first = true;
        for substance in this.isildur {
            if !first {
                out += ", " + substance.ToPrettyString();
            }
            else {
                out = substance.ToPrettyString();
                first = false;
            }
        }
        return out;
    }
}