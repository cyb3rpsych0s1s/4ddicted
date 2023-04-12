enum BiomonitorState {
    Idle = 0,
    Booting = 1,
    Analyzing = 2,
    Summarizing = 3,
    Closing = 4,
    Dismissing = 5,
}

enum BloodGroup {
    Unknown = 0,
    A = 1,
    B = 2,
    O = 3,
    AB = 4,
}

public class Chemical {
    public let Key: CName;
    public let From: Float;
    public let To: Float;
}

public class Symptom {
    public let Title: String;
    public let Status: String;
}

public class Customer {
    public let FirstName: String;
    public let LastName: String;
    public let Age: String;
    public let BloodGroup: String;
    public let Insurance: String;
}

public class CrossThresholdEvent extends Event {
    public let Customer: ref<Customer>;
    public let Symptoms: array<ref<Symptom>>;
    public let Chemicals: array<ref<Chemical>>;
    public let Dismissable: Bool;
    public let boot: Bool;
}

public class DismissBiomonitorEvent extends Event {}

public class InteractionHubEvent extends Event {
    public let Show: Bool;
}

public class SkipTimeEvent extends Event {}

public class CrossThresholdCallback extends DelayCallback {
    private let controller: wref<BiomonitorController>;
    private let event: ref<CrossThresholdEvent>;
    public func Call() -> Void {
      E(s"attempt at warning again");
      this.controller.OnCrossThresholdEvent(this.event);
    }
}

public class ClosingBeepCallback extends DelayCallback {
    private let controller: wref<BiomonitorController>;
    public func Call() -> Void {
        E(s"beep on close");
        this.controller.Beep();
    }            
}

enum BiomonitorRestrictions {
    InMenu = 1,
    InRadialWheel = 2,
    InQuickHackPanel = 3,
    InPhotoMode = 4,
}