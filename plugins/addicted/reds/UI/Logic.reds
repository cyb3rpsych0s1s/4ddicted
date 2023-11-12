module Addicted

private func IsAlterableUIIcon(name: String) -> Bool {
    return Equals(name, "first_aid_whiff_icon")
    || Equals(name, "regeneration_icon")
    || Equals(name, "health_booster_icon")
    || Equals(name, "drugs_endotrisine");
}

private func GetUIIcon(threshold: Threshold, name: String) -> String {
    LogChannel(n"DEBUG", s"threshold: \(ToString(threshold)), icon: \(name)");
    if !IsAlterableUIIcon(name)
    || !IsSerious(threshold) { return "UIIcon." + name; }
    let icon = name;
    switch(icon) {
        case "first_aid_whiff_icon":
        case "regeneration_icon":
        case "health_booster_icon":
            icon = (Equals(threshold, Threshold.Severely) ? "severely" : "notably") + "_weakened_" + icon;
        // TODO: drugs_endotrisine for WannabeEdgerunner
    }
    return "UIIcon." + icon;
}
