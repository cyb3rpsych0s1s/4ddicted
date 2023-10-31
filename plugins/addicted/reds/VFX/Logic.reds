module Addicted

private func IsAlterableVFX(name: CName) -> Bool {
    return Equals(name, n"splinter_buff") || Equals(name, n"reflex_buster");
}

private func GetVFXName(threshold: Threshold, name: CName) -> CName {
    if !IsAlterableVFX(name)
    || !IsSerious(threshold) { return name; }
    let vfx = name;
    switch(vfx) {
        case n"splinter_buff":
        case n"reflex_buster":
            vfx = StringToName((Equals(threshold, Threshold.Severely) ? "severely" : "notably") + "_weakened_" + NameToString(vfx));
    }
    return vfx;
}